//! Hyprland IPC module

use tokio::time::{interval, Duration};
use tracing::debug;

/// Workspace info
#[derive(Debug, Clone, serde::Serialize)]
pub struct WorkspaceInfo {
    pub id: i32,
    pub name: String,
    pub windows: u32,
    pub active: bool,
}

/// Active window info
#[derive(Debug, Clone, serde::Serialize)]
pub struct WindowInfo {
    pub title: String,
    pub class: String,
}

/// Monitor Hyprland events
pub async fn monitor() {
    let mut interval = interval(Duration::from_millis(100));
    
    loop {
        interval.tick().await;
        
        // TODO: Use hyprland-rs crate to subscribe to IPC events
        debug!("Hyprland IPC tick");
    }
}

/// Get all workspaces
pub fn get_workspaces() -> Vec<WorkspaceInfo> {
    // TODO: Implement via hyprland-rs
    vec![]
}

/// Get active window
pub fn get_active_window() -> Option<WindowInfo> {
    // TODO: Implement via hyprland-rs
    None
}

/// Dispatch command to Hyprland
pub fn dispatch(command: &str, args: &str) -> bool {
    std::process::Command::new("hyprctl")
        .args(["dispatch", command, args])
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}
