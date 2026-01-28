// WindowTitle.qml - Active Window Title
// TerraFlow Dotfiles

import QtQuick
import Quickshell.Hyprland
import "../../config.qml" as Config

Text {
    id: windowTitle
    
    property string title: Hyprland.activeWindow?.title ?? ""
    
    text: title.length > 50 ? title.substring(0, 47) + "..." : title
    color: Config.fgSecondary
    font.family: Config.fontFamily
    font.pixelSize: Config.fontSizeSmall
    
    opacity: title.length > 0 ? 1 : 0
    
    Behavior on opacity {
        NumberAnimation { duration: Config.animDurationFast }
    }
}
