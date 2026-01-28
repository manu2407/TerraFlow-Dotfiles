//! Terra Shell v1.0 - System Service Daemon
//!
//! Powers Quickshell widgets with real-time system data.
//! Communicates via Unix socket IPC.

mod audio;
mod battery;
mod brightness;
mod hyprland;
mod ipc;
mod media;
mod network;

use std::path::PathBuf;
use std::sync::Arc;
use tokio::net::UnixListener;
use tokio::sync::{broadcast, RwLock};
use tracing::{info, Level};
use tracing_subscriber::FmtSubscriber;

const SOCKET_PATH: &str = "/tmp/terra-shell.sock";

/// Shared state accessible by all handlers
#[derive(Debug, Default)]
pub struct AppState {
    pub active_workspace: i32,
    pub active_window_title: String,
    pub active_window_class: String,
    pub battery_level: u8,
    pub battery_charging: bool,
    pub volume: u8,
    pub volume_muted: bool,
    pub brightness: u8,
    pub wifi_ssid: Option<String>,
    pub wifi_connected: bool,
    pub media_title: String,
    pub media_artist: String,
    pub media_playing: bool,
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Initialize logging
    let subscriber = FmtSubscriber::builder()
        .with_max_level(Level::INFO)
        .finish();
    tracing::subscriber::set_global_default(subscriber)?;

    info!("Terra Shell v{} starting...", env!("CARGO_PKG_VERSION"));

    // Remove stale socket if exists
    let socket_path = PathBuf::from(SOCKET_PATH);
    if socket_path.exists() {
        std::fs::remove_file(&socket_path)?;
    }

    // Create shared state
    let state = Arc::new(RwLock::new(AppState::default()));
    
    // Create broadcast channel for Hyprland events
    let (hypr_tx, _) = broadcast::channel::<hyprland::HyprlandEvent>(32);

    // Create Unix socket listener
    let listener = UnixListener::bind(&socket_path)?;
    info!("Listening on {}", SOCKET_PATH);

    // Start system monitors
    let state_clone = state.clone();
    tokio::spawn(async move {
        battery::monitor(state_clone).await;
    });

    let state_clone = state.clone();
    tokio::spawn(async move {
        audio::monitor(state_clone).await;
    });

    let state_clone = state.clone();
    tokio::spawn(async move {
        network::monitor(state_clone).await;
    });

    let state_clone = state.clone();
    tokio::spawn(async move {
        media::monitor(state_clone).await;
    });

    // Start Hyprland event monitor
    let hypr_tx_clone = hypr_tx.clone();
    let state_clone = state.clone();
    tokio::spawn(async move {
        // Subscribe to events and update state
        let mut rx = hypr_tx_clone.subscribe();
        tokio::spawn(hyprland::monitor(hypr_tx_clone));
        
        while let Ok(event) = rx.recv().await {
            let mut s = state_clone.write().await;
            match event {
                hyprland::HyprlandEvent::WorkspaceChanged { id, .. } => {
                    s.active_workspace = id;
                }
                hyprland::HyprlandEvent::ActiveWindowChanged { class, title } => {
                    s.active_window_class = class;
                    s.active_window_title = title;
                }
                _ => {}
            }
        }
    });

    // Initialize state with current values
    {
        let mut s = state.write().await;
        if let Some(ws) = hyprland::get_active_workspace().await {
            s.active_workspace = ws;
        }
        if let Some(win) = hyprland::get_active_window().await {
            s.active_window_title = win.title;
            s.active_window_class = win.class;
        }
    }

    // Accept client connections (Quickshell)
    loop {
        match listener.accept().await {
            Ok((stream, _)) => {
                let state_clone = state.clone();
                tokio::spawn(ipc::handle_client(stream, state_clone));
            }
            Err(e) => {
                tracing::error!("Failed to accept connection: {}", e);
            }
        }
    }
}
