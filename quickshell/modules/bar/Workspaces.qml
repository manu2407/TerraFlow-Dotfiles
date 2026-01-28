// Workspaces.qml - Hyprland Workspace Indicator (Connected to terra-shell)
// TerraFlow Dotfiles

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../services/TerraShellService.qml" as TerraShell
import "../../config.qml" as Config

RowLayout {
    id: workspaces
    spacing: 6
    
    // Active workspace from terra-shell
    property int activeWorkspace: TerraShell.TerraShellService.activeWorkspace
    
    Repeater {
        // Show workspaces 1-10
        model: 10
        
        Rectangle {
            required property int index
            property int workspaceId: index + 1
            property bool isActive: workspaceId === workspaces.activeWorkspace
            
            width: isActive ? 24 : 8
            height: 8
            radius: 4
            
            color: isActive ? Config.accent : Config.bgTertiary
            
            Behavior on width {
                NumberAnimation { duration: Config.animDuration }
            }
            
            Behavior on color {
                ColorAnimation { duration: Config.animDuration }
            }
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: TerraShell.TerraShellService.dispatch("workspace", workspaceId)
            }
        }
    }
}
