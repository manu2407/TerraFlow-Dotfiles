//! Network monitoring module

use std::process::Command;
use tokio::time::{interval, Duration};
use tracing::debug;

/// Network status
#[derive(Debug, Clone, serde::Serialize)]
pub struct NetworkInfo {
    pub connected: bool,
    pub ssid: Option<String>,
    pub strength: Option<u8>,
}

/// Monitor network status
pub async fn monitor() {
    let mut interval = interval(Duration::from_secs(5));
    
    loop {
        interval.tick().await;
        
        if let Some(info) = get_wifi_info() {
            debug!("Network: {:?}", info);
            // TODO: Broadcast to connected clients
        }
    }
}

/// Get WiFi info from nmcli
fn get_wifi_info() -> Option<NetworkInfo> {
    let output = Command::new("nmcli")
        .args(["-t", "-f", "ACTIVE,SSID,SIGNAL", "device", "wifi"])
        .output()
        .ok()?;
    
    let stdout = String::from_utf8_lossy(&output.stdout);
    
    for line in stdout.lines() {
        let parts: Vec<&str> = line.split(':').collect();
        if parts.len() >= 3 && parts[0] == "yes" {
            return Some(NetworkInfo {
                connected: true,
                ssid: Some(parts[1].to_string()),
                strength: parts[2].parse().ok(),
            });
        }
    }
    
    Some(NetworkInfo {
        connected: false,
        ssid: None,
        strength: None,
    })
}
