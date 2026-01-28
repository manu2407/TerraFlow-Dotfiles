// Battery.qml - Battery Status (Connected to terra-shell)
// TerraFlow Dotfiles

import QtQuick
import QtQuick.Layouts
import "../services/TerraShellService.qml" as TerraShell
import "../../config.qml" as Config

RowLayout {
    id: battery
    spacing: 4
    
    // Connected to terra-shell service
    property int level: TerraShell.TerraShellService.batteryLevel
    property bool charging: TerraShell.TerraShellService.batteryCharging
    
    Text {
        text: {
            if (battery.charging) return "󰂄"
            if (battery.level > 90) return "󰁹"
            if (battery.level > 70) return "󰂀"
            if (battery.level > 50) return "󰁾"
            if (battery.level > 30) return "󰁼"
            if (battery.level > 10) return "󰁺"
            return "󰂃"
        }
        color: {
            if (battery.level < 20) return Config.error
            if (battery.charging) return Config.success
            return Config.fgPrimary
        }
        font.family: Config.fontMono
        font.pixelSize: Config.fontSizeLarge
    }
    
    Text {
        text: battery.level + "%"
        color: Config.fgPrimary
        font.family: Config.fontFamily
        font.pixelSize: Config.fontSizeSmall
    }
}
