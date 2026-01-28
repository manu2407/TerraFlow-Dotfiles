//! IPC handler for Quickshell communication

use std::sync::Arc;
use tokio::io::{AsyncBufReadExt, AsyncWriteExt, BufReader};
use tokio::net::UnixStream;
use tokio::sync::RwLock;
use tracing::{debug, error};

use crate::{audio, brightness, hyprland, media, AppState};

/// Handle a connected client (Quickshell)
pub async fn handle_client(stream: UnixStream, state: Arc<RwLock<AppState>>) {
    debug!("New client connected");
    
    let (reader, mut writer) = stream.into_split();
    let mut reader = BufReader::new(reader);
    let mut line = String::new();
    
    loop {
        line.clear();
        
        match reader.read_line(&mut line).await {
            Ok(0) => {
                debug!("Client disconnected");
                break;
            }
            Ok(_) => {
                let response = handle_message(line.trim(), &state).await;
                if let Err(e) = writer.write_all(response.as_bytes()).await {
                    error!("Failed to write response: {}", e);
                    break;
                }
                if let Err(e) = writer.write_all(b"\n").await {
                    error!("Failed to write newline: {}", e);
                    break;
                }
            }
            Err(e) => {
                error!("Failed to read from client: {}", e);
                break;
            }
        }
    }
}

/// Handle incoming message and return response
async fn handle_message(message: &str, state: &Arc<RwLock<AppState>>) -> String {
    let parts: Vec<&str> = message.split_whitespace().collect();
    
    if parts.is_empty() {
        return r#"{"error": "empty command"}"#.to_string();
    }
    
    match parts[0] {
        // === STATE QUERIES ===
        
        "state" | "all" => {
            // Return complete state
            let s = state.read().await;
            serde_json::json!({
                "type": "state",
                "workspace": s.active_workspace,
                "window": {
                    "title": s.active_window_title,
                    "class": s.active_window_class
                },
                "battery": {
                    "level": s.battery_level,
                    "charging": s.battery_charging
                },
                "audio": {
                    "volume": s.volume,
                    "muted": s.volume_muted
                },
                "network": {
                    "connected": s.wifi_connected,
                    "ssid": s.wifi_ssid
                },
                "media": {
                    "title": s.media_title,
                    "artist": s.media_artist,
                    "playing": s.media_playing
                }
            }).to_string()
        }
        
        "battery" => {
            let s = state.read().await;
            serde_json::json!({
                "type": "battery",
                "level": s.battery_level,
                "charging": s.battery_charging
            }).to_string()
        }
        
        "audio" => {
            let s = state.read().await;
            serde_json::json!({
                "type": "audio",
                "volume": s.volume,
                "muted": s.volume_muted
            }).to_string()
        }
        
        "workspace" | "workspaces" => {
            let workspaces = hyprland::get_workspaces().await;
            let s = state.read().await;
            serde_json::json!({
                "type": "workspaces",
                "active": s.active_workspace,
                "list": workspaces
            }).to_string()
        }
        
        "window" => {
            let s = state.read().await;
            serde_json::json!({
                "type": "window",
                "title": s.active_window_title,
                "class": s.active_window_class
            }).to_string()
        }
        
        "media" => {
            let s = state.read().await;
            serde_json::json!({
                "type": "media",
                "title": s.media_title,
                "artist": s.media_artist,
                "playing": s.media_playing
            }).to_string()
        }
        
        "network" => {
            let s = state.read().await;
            serde_json::json!({
                "type": "network",
                "connected": s.wifi_connected,
                "ssid": s.wifi_ssid
            }).to_string()
        }
        
        // === CONTROL COMMANDS ===
        
        "volume" => {
            if parts.len() >= 2 {
                if let Ok(level) = parts[1].parse::<u8>() {
                    audio::set_volume(level);
                    let mut s = state.write().await;
                    s.volume = level;
                }
            }
            r#"{"ok": true}"#.to_string()
        }
        
        "mute" => {
            audio::toggle_mute();
            let mut s = state.write().await;
            s.volume_muted = !s.volume_muted;
            r#"{"ok": true}"#.to_string()
        }
        
        "brightness" => {
            if parts.len() >= 2 {
                if let Ok(level) = parts[1].parse::<u8>() {
                    brightness::set_brightness(level);
                }
            }
            r#"{"ok": true}"#.to_string()
        }
        
        "media-toggle" | "play-pause" => {
            media::play_pause();
            r#"{"ok": true}"#.to_string()
        }
        
        "media-next" | "next" => {
            media::next();
            r#"{"ok": true}"#.to_string()
        }
        
        "media-prev" | "prev" => {
            media::previous();
            r#"{"ok": true}"#.to_string()
        }
        
        "dispatch" => {
            if parts.len() >= 3 {
                hyprland::dispatch(parts[1], parts[2]).await;
            }
            r#"{"ok": true}"#.to_string()
        }
        
        _ => {
            r#"{"error": "unknown command"}"#.to_string()
        }
    }
}
