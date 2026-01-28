// Clock.qml - Date and Time Display
// TerraFlow Dotfiles

import QtQuick
import "../../config.qml" as Config

Text {
    id: clock
    
    property string currentTime: ""
    property string currentDate: ""
    
    text: currentTime
    color: Config.fgPrimary
    font.family: Config.fontFamily
    font.pixelSize: Config.fontSize
    font.weight: Font.Medium
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            var now = new Date()
            clock.currentTime = Qt.formatTime(now, "hh:mm")
            clock.currentDate = Qt.formatDate(now, "ddd, MMM d")
        }
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        ToolTip {
            visible: parent.containsMouse
            text: clock.currentDate
        }
    }
}
