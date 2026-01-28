// shell.qml - Quickshell Main Entry Point
// TerraFlow Dotfiles

import Quickshell
import QtQuick

ShellRoot {
    id: root
    
    // Load configuration
    property var config: Qt.include("config.qml")
    
    // Bar on each monitor
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            required property var modelData
            screen: modelData
            
            anchors {
                top: true
                left: true
                right: true
            }
            
            height: 40
            color: "transparent"
            
            // Import bar module
            Loader {
                anchors.fill: parent
                source: "modules/bar/Bar.qml"
            }
        }
    }
    
    // OSD overlay (volume/brightness)
    Loader {
        source: "modules/osd/Osd.qml"
    }
    
    // Notification center
    Loader {
        source: "modules/notifications/NotificationCenter.qml"
    }
}
