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
use tokio::net::UnixListener;
use tracing::{info, Level};
use tracing_subscriber::FmtSubscriber;

const SOCKET_PATH: &str = "/tmp/terra-shell.sock";

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

    // Create Unix socket listener
    let listener = UnixListener::bind(&socket_path)?;
    info!("Listening on {}", SOCKET_PATH);

    // Start system monitors
    let _battery_handle = tokio::spawn(battery::monitor());
    let _audio_handle = tokio::spawn(audio::monitor());
    let _network_handle = tokio::spawn(network::monitor());
    let _media_handle = tokio::spawn(media::monitor());
    let _hyprland_handle = tokio::spawn(hyprland::monitor());

    // Accept client connections (Quickshell)
    loop {
        match listener.accept().await {
            Ok((stream, _)) => {
                tokio::spawn(ipc::handle_client(stream));
            }
            Err(e) => {
                tracing::error!("Failed to accept connection: {}", e);
            }
        }
    }
}
