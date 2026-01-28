//! Hyprland IPC module - Direct socket communication
//!
//! Connects to Hyprland's Unix socket for workspace and window info.

use std::env;
use std::path::PathBuf;
use tokio::io::{AsyncBufReadExt, AsyncWriteExt, BufReader};
use tokio::net::UnixStream;
use tokio::sync::broadcast;
use tracing::{debug, error, info, warn};

/// Hyprland event types
#[derive(Debug, Clone, serde::Serialize)]
#[serde(tag = "type")]
pub enum HyprlandEvent {
    WorkspaceChanged { id: i32, name: String },
    ActiveWindowChanged { class: String, title: String },
    MonitorFocused { name: String },
    FullscreenChanged { fullscreen: bool },
}

/// Workspace info
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct Workspace {
    pub id: i32,
    pub name: String,
    pub monitor: String,
    pub windows: u32,
    #[serde(rename = "hasfullscreen")]
    pub has_fullscreen: bool,
    #[serde(rename = "lastwindow")]
    pub last_window: String,
    #[serde(rename = "lastwindowtitle")]
    pub last_window_title: String,
}

/// Active window info
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct ActiveWindow {
    pub class: String,
    pub title: String,
    pub address: String,
    pub mapped: bool,
    pub floating: bool,
    pub fullscreen: i32,
}

/// Get Hyprland socket path
fn get_socket_path(socket_type: &str) -> Option<PathBuf> {
    let instance = env::var("HYPRLAND_INSTANCE_SIGNATURE").ok()?;
    let runtime_dir = env::var("XDG_RUNTIME_DIR").unwrap_or_else(|_| "/tmp".to_string());
    Some(PathBuf::from(format!(
        "{}/hypr/{}/.socket{}.sock",
        runtime_dir, instance, socket_type
    )))
}

/// Send command to Hyprland and get response
pub async fn hyprctl(command: &str) -> Option<String> {
    let socket_path = get_socket_path("")?;
    
    let mut stream = UnixStream::connect(&socket_path).await.ok()?;
    stream.write_all(command.as_bytes()).await.ok()?;
    
    let mut response = String::new();
    let mut reader = BufReader::new(stream);
    reader.read_line(&mut response).await.ok()?;
    
    Some(response)
}

/// Get all workspaces
pub async fn get_workspaces() -> Vec<Workspace> {
    let socket_path = match get_socket_path("") {
        Some(p) => p,
        None => return vec![],
    };
    
    let mut stream = match UnixStream::connect(&socket_path).await {
        Ok(s) => s,
        Err(_) => return vec![],
    };
    
    if stream.write_all(b"j/workspaces").await.is_err() {
        return vec![];
    }
    
    let mut response = Vec::new();
    let mut buf = [0u8; 4096];
    
    loop {
        match tokio::io::AsyncReadExt::read(&mut stream, &mut buf).await {
            Ok(0) => break,
            Ok(n) => response.extend_from_slice(&buf[..n]),
            Err(_) => break,
        }
    }
    
    let json_str = String::from_utf8_lossy(&response);
    serde_json::from_str(&json_str).unwrap_or_default()
}

/// Get active window
pub async fn get_active_window() -> Option<ActiveWindow> {
    let socket_path = get_socket_path("")?;
    
    let mut stream = UnixStream::connect(&socket_path).await.ok()?;
    stream.write_all(b"j/activewindow").await.ok()?;
    
    let mut response = Vec::new();
    let mut buf = [0u8; 4096];
    
    loop {
        match tokio::io::AsyncReadExt::read(&mut stream, &mut buf).await {
            Ok(0) => break,
            Ok(n) => response.extend_from_slice(&buf[..n]),
            Err(_) => break,
        }
    }
    
    let json_str = String::from_utf8_lossy(&response);
    serde_json::from_str(&json_str).ok()
}

/// Get active workspace ID
pub async fn get_active_workspace() -> Option<i32> {
    let socket_path = get_socket_path("")?;
    
    let mut stream = UnixStream::connect(&socket_path).await.ok()?;
    stream.write_all(b"j/activeworkspace").await.ok()?;
    
    let mut response = Vec::new();
    let mut buf = [0u8; 4096];
    
    loop {
        match tokio::io::AsyncReadExt::read(&mut stream, &mut buf).await {
            Ok(0) => break,
            Ok(n) => response.extend_from_slice(&buf[..n]),
            Err(_) => break,
        }
    }
    
    let json_str = String::from_utf8_lossy(&response);
    let ws: serde_json::Value = serde_json::from_str(&json_str).ok()?;
    ws.get("id")?.as_i64().map(|id| id as i32)
}

/// Dispatch command to Hyprland
pub async fn dispatch(command: &str, args: &str) -> bool {
    let socket_path = match get_socket_path("") {
        Some(p) => p,
        None => return false,
    };
    
    let cmd = format!("dispatch {} {}", command, args);
    
    let mut stream = match UnixStream::connect(&socket_path).await {
        Ok(s) => s,
        Err(_) => return false,
    };
    
    stream.write_all(cmd.as_bytes()).await.is_ok()
}

/// Monitor Hyprland events via socket2
pub async fn monitor(tx: broadcast::Sender<HyprlandEvent>) {
    let socket_path = match get_socket_path("2") {
        Some(p) => p,
        None => {
            warn!("Hyprland socket not found - not running under Hyprland?");
            return;
        }
    };
    
    info!("Connecting to Hyprland event socket: {:?}", socket_path);
    
    loop {
        match UnixStream::connect(&socket_path).await {
            Ok(stream) => {
                info!("Connected to Hyprland event socket");
                let reader = BufReader::new(stream);
                let mut lines = reader.lines();
                
                while let Ok(Some(line)) = lines.next_line().await {
                    if let Some(event) = parse_event(&line) {
                        debug!("Hyprland event: {:?}", event);
                        let _ = tx.send(event);
                    }
                }
                
                warn!("Hyprland socket disconnected, reconnecting...");
            }
            Err(e) => {
                error!("Failed to connect to Hyprland: {}", e);
            }
        }
        
        tokio::time::sleep(tokio::time::Duration::from_secs(2)).await;
    }
}

/// Parse event line from Hyprland socket2
fn parse_event(line: &str) -> Option<HyprlandEvent> {
    let (event_type, data) = line.split_once(">>")?;
    
    match event_type {
        "workspace" => {
            let id: i32 = data.parse().ok()?;
            Some(HyprlandEvent::WorkspaceChanged {
                id,
                name: data.to_string(),
            })
        }
        "activewindow" => {
            let (class, title) = data.split_once(',')?;
            Some(HyprlandEvent::ActiveWindowChanged {
                class: class.to_string(),
                title: title.to_string(),
            })
        }
        "monitoradded" | "focusedmon" => Some(HyprlandEvent::MonitorFocused {
            name: data.to_string(),
        }),
        "fullscreen" => Some(HyprlandEvent::FullscreenChanged {
            fullscreen: data == "1",
        }),
        _ => None,
    }
}
