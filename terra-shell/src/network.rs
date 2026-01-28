//! Network monitoring module

use std::process::Command;
use std::sync::Arc;
use tokio::sync::RwLock;
use tokio::time::{interval, Duration};
use tracing::debug;

use crate::AppState;

/// Monitor network status
pub async fn monitor(state: Arc<RwLock<AppState>>) {
    let mut interval = interval(Duration::from_secs(5));
    
    loop {
        interval.tick().await;
        
        let (connected, ssid) = get_wifi_info();
        let mut s = state.write().await;
        if s.wifi_connected != connected || s.wifi_ssid != ssid {
            debug!("Network: connected={}, ssid={:?}", connected, ssid);
            s.wifi_connected = connected;
            s.wifi_ssid = ssid;
        }
    }
}

/// Get WiFi info from nmcli
fn get_wifi_info() -> (bool, Option<String>) {
    let output = match Command::new("nmcli")
        .args(["-t", "-f", "ACTIVE,SSID", "device", "wifi"])
        .output()
    {
        Ok(o) => o,
        Err(_) => return (false, None),
    };
    
    let stdout = String::from_utf8_lossy(&output.stdout);
    
    for line in stdout.lines() {
        let parts: Vec<&str> = line.split(':').collect();
        if parts.len() >= 2 && parts[0] == "yes" {
            return (true, Some(parts[1].to_string()));
        }
    }
    
    (false, None)
}
