// MediaPlayer.qml - Now Playing
// TerraFlow Dotfiles

import QtQuick
import QtQuick.Layouts
import "../../config.qml" as Config

RowLayout {
    id: media
    spacing: 8
    visible: title.length > 0
    
    // TODO: Connect to terra-shell for MPRIS data
    property string title: ""
    property string artist: ""
    property bool playing: false
    
    Text {
        text: media.playing ? "󰏤" : "󰐊"
        color: Config.accent
        font.family: Config.fontMono
        font.pixelSize: Config.fontSizeLarge
        
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                // Toggle play/pause via playerctl
            }
        }
    }
    
    Text {
        text: {
            if (media.artist.length > 0) {
                return media.artist + " - " + media.title
            }
            return media.title
        }
        color: Config.fgSecondary
        font.family: Config.fontFamily
        font.pixelSize: Config.fontSizeSmall
        
        // Truncate long titles
        elide: Text.ElideRight
        Layout.maximumWidth: 200
    }
}
