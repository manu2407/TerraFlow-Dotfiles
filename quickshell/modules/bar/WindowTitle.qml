// WindowTitle.qml - Active Window Title (Connected to terra-shell)
// TerraFlow Dotfiles

import QtQuick
import "../services/TerraShellService.qml" as TerraShell
import "../../config.qml" as Config

Text {
    id: windowTitle
    
    // Connected to terra-shell service
    property string title: TerraShell.TerraShellService.windowTitle
    
    text: title.length > 50 ? title.substring(0, 47) + "..." : title
    color: Config.fgSecondary
    font.family: Config.fontFamily
    font.pixelSize: Config.fontSizeSmall
    
    opacity: title.length > 0 ? 1 : 0
    
    Behavior on opacity {
        NumberAnimation { duration: Config.animDurationFast }
    }
}
