//! Audio control module (PipeWire/PulseAudio via wpctl)

use std::process::Command;
use std::sync::Arc;
use tokio::sync::RwLock;
use tokio::time::{interval, Duration};
use tracing::debug;

use crate::AppState;

/// Monitor audio status
pub async fn monitor(state: Arc<RwLock<AppState>>) {
    let mut interval = interval(Duration::from_millis(500));
    
    loop {
        interval.tick().await;
        
        if let Some((volume, muted)) = get_volume() {
            let mut s = state.write().await;
            if s.volume != volume || s.volume_muted != muted {
                debug!("Audio: {}% (muted: {})", volume, muted);
                s.volume = volume;
                s.volume_muted = muted;
            }
        }
    }
}

/// Get current volume from wpctl
pub fn get_volume() -> Option<(u8, bool)> {
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
    
    Some((volume, muted))
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
