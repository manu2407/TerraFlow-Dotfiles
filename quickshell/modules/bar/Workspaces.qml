// Workspaces.qml - Hyprland Workspace Indicator
// TerraFlow Dotfiles

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../config.qml" as Config

RowLayout {
    id: workspaces
    spacing: 6
    
    Repeater {
        // Show workspaces 1-10
        model: 10
        
        Rectangle {
            required property int index
            property int workspaceId: index + 1
            property bool isActive: Hyprland.activeWorkspace?.id === workspaceId
            property bool hasWindows: Hyprland.workspaces.some(w => w.id === workspaceId && w.windows > 0)
            
            width: isActive ? 24 : 8
            height: 8
            radius: 4
            
            color: {
                if (isActive) return Config.accent
                if (hasWindows) return Config.fgSecondary
                return Config.bgTertiary
            }
            
            Behavior on width {
                NumberAnimation { duration: Config.animDuration }
            }
            
            Behavior on color {
                ColorAnimation { duration: Config.animDuration }
            }
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace", workspaceId)
            }
        }
    }
}
