//! Battery monitoring module

use std::fs;
use std::path::Path;
use std::sync::Arc;
use tokio::sync::RwLock;
use tokio::time::{interval, Duration};
use tracing::debug;

use crate::AppState;

/// Monitor battery status
pub async fn monitor(state: Arc<RwLock<AppState>>) {
    let mut interval = interval(Duration::from_secs(30));
    
    loop {
        interval.tick().await;
        
        if let Some((level, charging)) = read_battery() {
            debug!("Battery: {}% (charging: {})", level, charging);
            let mut s = state.write().await;
            s.battery_level = level;
            s.battery_charging = charging;
        }
    }
}

/// Read battery info from sysfs
fn read_battery() -> Option<(u8, bool)> {
    // Try common battery paths
    let paths = [
        "/sys/class/power_supply/BAT0",
        "/sys/class/power_supply/BAT1",
        "/sys/class/power_supply/battery",
    ];
    
    for bat_path in paths {
        let path = Path::new(bat_path);
        if path.exists() {
            let capacity = fs::read_to_string(path.join("capacity"))
                .ok()?
                .trim()
                .parse::<u8>()
                .ok()?;
            
            let status = fs::read_to_string(path.join("status"))
                .ok()?
                .trim()
                .to_string();
            
            return Some((capacity, status == "Charging"));
        }
    }
    
    None
}
