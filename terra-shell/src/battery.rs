//! Battery monitoring module

use std::fs;
use std::path::Path;
use tokio::time::{interval, Duration};
use tracing::debug;

/// Battery status
#[derive(Debug, Clone, serde::Serialize)]
pub struct BatteryInfo {
    pub level: u8,
    pub charging: bool,
    pub time_remaining: Option<u32>, // minutes
}

/// Monitor battery status
pub async fn monitor() {
    let mut interval = interval(Duration::from_secs(30));
    
    loop {
        interval.tick().await;
        
        if let Some(info) = read_battery() {
            debug!("Battery: {}% (charging: {})", info.level, info.charging);
            // TODO: Broadcast to connected clients
        }
    }
}

/// Read battery info from sysfs
fn read_battery() -> Option<BatteryInfo> {
    let bat_path = Path::new("/sys/class/power_supply/BAT0");
    
    if !bat_path.exists() {
        return None;
    }
    
    let capacity = fs::read_to_string(bat_path.join("capacity"))
        .ok()?
        .trim()
        .parse::<u8>()
        .ok()?;
    
    let status = fs::read_to_string(bat_path.join("status"))
        .ok()?
        .trim()
        .to_string();
    
    Some(BatteryInfo {
        level: capacity,
        charging: status == "Charging",
        time_remaining: None, // TODO: Calculate from energy_now/power_now
    })
}
