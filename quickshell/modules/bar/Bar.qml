// Bar.qml - Main Status Bar
// TerraFlow Dotfiles

import QtQuick
import QtQuick.Layouts
import "../../config.qml" as Config

Rectangle {
    id: bar
    
    anchors.fill: parent
    anchors.margins: Config.barMargin
    
    radius: Config.barRadius
    color: Qt.rgba(
        Config.bgPrimary.r,
        Config.bgPrimary.g,
        Config.bgPrimary.b,
        Config.barOpacity
    )
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        
        // Left section - Workspaces
        Loader {
            source: "Workspaces.qml"
            Layout.alignment: Qt.AlignLeft
        }
        
        // Center section - Window Title
        Item {
            Layout.fillWidth: true
            
            Loader {
                anchors.centerIn: parent
                source: "WindowTitle.qml"
            }
        }
        
        // Right section - System info
        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 16
            
            Loader { source: "MediaPlayer.qml" }
            Loader { source: "Battery.qml" }
            Loader { source: "Clock.qml" }
        }
    }
}
