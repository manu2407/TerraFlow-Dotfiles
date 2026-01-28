//! IPC handler for Quickshell communication

use tokio::io::{AsyncBufReadExt, AsyncWriteExt, BufReader};
use tokio::net::UnixStream;
use tracing::{debug, error};

/// Handle a connected client (Quickshell)
pub async fn handle_client(stream: UnixStream) {
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
                let response = handle_message(line.trim()).await;
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
async fn handle_message(message: &str) -> String {
    let parts: Vec<&str> = message.split_whitespace().collect();
    
    if parts.is_empty() {
        return r#"{"error": "empty command"}"#.to_string();
    }
    
    match parts[0] {
        "battery" => {
            // Return battery status
            serde_json::json!({
                "type": "battery",
                "level": 85,
                "charging": false
            }).to_string()
        }
        "audio" => {
            if let Some(info) = crate::audio::get_volume() {
                serde_json::to_string(&info).unwrap_or_default()
            } else {
                r#"{"error": "audio unavailable"}"#.to_string()
            }
        }
        "volume" => {
            if parts.len() >= 2 {
                if let Ok(level) = parts[1].parse::<u8>() {
                    crate::audio::set_volume(level);
                }
            }
            r#"{"ok": true}"#.to_string()
        }
        "mute" => {
            crate::audio::toggle_mute();
            r#"{"ok": true}"#.to_string()
        }
        "brightness" => {
            if parts.len() >= 2 {
                if let Ok(level) = parts[1].parse::<u8>() {
                    crate::brightness::set_brightness(level);
                }
            }
            r#"{"ok": true}"#.to_string()
        }
        "media" => {
            match parts.get(1) {
                Some(&"toggle") => { crate::media::play_pause(); }
                Some(&"next") => { crate::media::next(); }
                Some(&"prev") => { crate::media::previous(); }
                _ => {}
            }
            r#"{"ok": true}"#.to_string()
        }
        _ => {
            r#"{"error": "unknown command"}"#.to_string()
        }
    }
}
