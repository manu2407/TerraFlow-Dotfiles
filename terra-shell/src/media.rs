//! Media player control (MPRIS via playerctl)

use std::process::Command;
use std::sync::Arc;
use tokio::sync::RwLock;
use tokio::time::{interval, Duration};
use tracing::debug;

use crate::AppState;

/// Monitor media players
pub async fn monitor(state: Arc<RwLock<AppState>>) {
    let mut interval = interval(Duration::from_secs(1));
    
    loop {
        interval.tick().await;
        
        let (title, artist, playing) = get_media_info();
        let mut s = state.write().await;
        if s.media_title != title || s.media_artist != artist || s.media_playing != playing {
            debug!("Media: {} - {} (playing: {})", artist, title, playing);
            s.media_title = title;
            s.media_artist = artist;
            s.media_playing = playing;
        }
    }
}

/// Get current media info
fn get_media_info() -> (String, String, bool) {
    let status = Command::new("playerctl")
        .args(["status"])
        .output();
    
    let playing = match status {
        Ok(out) => String::from_utf8_lossy(&out.stdout).trim() == "Playing",
        Err(_) => false,
    };
    
    let metadata = Command::new("playerctl")
        .args(["metadata", "--format", "{{title}}\\n{{artist}}"])
        .output();
    
    let (title, artist) = match metadata {
        Ok(out) => {
            let text = String::from_utf8_lossy(&out.stdout);
            let lines: Vec<&str> = text.lines().collect();
            (
                lines.first().unwrap_or(&"").to_string(),
                lines.get(1).unwrap_or(&"").to_string(),
            )
        }
        Err(_) => (String::new(), String::new()),
    };
    
    (title, artist, playing)
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
