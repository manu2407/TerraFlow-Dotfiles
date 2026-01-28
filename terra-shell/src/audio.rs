//! Audio control module (PipeWire/PulseAudio via wpctl)

use std::process::Command;
use tokio::time::{interval, Duration};
use tracing::debug;

/// Audio status
#[derive(Debug, Clone, serde::Serialize)]
pub struct AudioInfo {
    pub volume: u8,
    pub muted: bool,
}

/// Monitor audio status
pub async fn monitor() {
    let mut interval = interval(Duration::from_millis(500));
    
    loop {
        interval.tick().await;
        
        if let Some(info) = get_volume() {
            debug!("Audio: {}% (muted: {})", info.volume, info.muted);
            // TODO: Broadcast to connected clients
        }
    }
}

/// Get current volume from wpctl
fn get_volume() -> Option<AudioInfo> {
    let output = Command::new("wpctl")
        .args(["get-volume", "@DEFAULT_AUDIO_SINK@"])
        .output()
        .ok()?;
    
    let stdout = String::from_utf8_lossy(&output.stdout);
    // Output format: "Volume: 0.50" or "Volume: 0.50 [MUTED]"
    
    let parts: Vec<&str> = stdout.split_whitespace().collect();
    if parts.len() < 2 {
        return None;
    }
    
    let volume_float: f32 = parts[1].parse().ok()?;
    let volume = (volume_float * 100.0) as u8;
    let muted = stdout.contains("[MUTED]");
    
    Some(AudioInfo { volume, muted })
}

/// Set volume
pub fn set_volume(level: u8) -> bool {
    Command::new("wpctl")
        .args(["set-volume", "@DEFAULT_AUDIO_SINK@", &format!("{}%", level)])
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

/// Toggle mute
pub fn toggle_mute() -> bool {
    Command::new("wpctl")
        .args(["set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}
