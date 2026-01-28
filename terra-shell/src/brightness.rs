//! Brightness control module

use std::process::Command;

/// Get current brightness (0-100)
pub fn get_brightness() -> Option<u8> {
    let output = Command::new("brightnessctl")
        .args(["info", "-m"])
        .output()
        .ok()?;
    
    let stdout = String::from_utf8_lossy(&output.stdout);
    // Output format: device,class,current,max,percentage
    let parts: Vec<&str> = stdout.split(',').collect();
    
    if parts.len() >= 4 {
        parts[3].trim_end_matches('%').parse().ok()
    } else {
        None
    }
}

/// Set brightness level
pub fn set_brightness(level: u8) -> bool {
    Command::new("brightnessctl")
        .args(["set", &format!("{}%", level)])
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

/// Increase brightness
pub fn increase(amount: u8) -> bool {
    Command::new("brightnessctl")
        .args(["set", &format!("+{}%", amount)])
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

/// Decrease brightness
pub fn decrease(amount: u8) -> bool {
    Command::new("brightnessctl")
        .args(["set", &format!("{}%-", amount)])
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}
