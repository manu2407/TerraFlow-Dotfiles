//! Media player control (MPRIS via playerctl)

use std::process::Command;
use tokio::time::{interval, Duration};
use tracing::debug;

/// Media player status
#[derive(Debug, Clone, serde::Serialize)]
pub struct MediaInfo {
    pub title: String,
    pub artist: String,
    pub album: String,
    pub playing: bool,
    pub position: u64,   // seconds
    pub duration: u64,   // seconds
}

/// Monitor media players
pub async fn monitor() {
    let mut interval = interval(Duration::from_secs(1));
    
    loop {
        interval.tick().await;
        
        if let Some(info) = get_media_info() {
            debug!("Media: {} - {}", info.artist, info.title);
            // TODO: Broadcast to connected clients
        }
    }
}

/// Get current media info
fn get_media_info() -> Option<MediaInfo> {
    let status = Command::new("playerctl")
        .args(["status"])
        .output()
        .ok()?;
    
    let status_str = String::from_utf8_lossy(&status.stdout).trim().to_string();
    
    if status_str.is_empty() || status_str == "No players found" {
        return None;
    }
    
    let metadata = Command::new("playerctl")
        .args(["metadata", "--format", "{{title}}\n{{artist}}\n{{album}}"])
        .output()
        .ok()?;
    
    let metadata_str = String::from_utf8_lossy(&metadata.stdout);
    let lines: Vec<&str> = metadata_str.lines().collect();
    
    Some(MediaInfo {
        title: lines.get(0).unwrap_or(&"").to_string(),
        artist: lines.get(1).unwrap_or(&"").to_string(),
        album: lines.get(2).unwrap_or(&"").to_string(),
        playing: status_str == "Playing",
        position: 0,
        duration: 0,
    })
}

/// Play/pause toggle
pub fn play_pause() -> bool {
    Command::new("playerctl")
        .args(["play-pause"])
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

/// Next track
pub fn next() -> bool {
    Command::new("playerctl")
        .args(["next"])
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

/// Previous track
pub fn previous() -> bool {
    Command::new("playerctl")
        .args(["previous"])
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}
