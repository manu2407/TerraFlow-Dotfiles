// MediaPlayer.qml - Now Playing (Connected to terra-shell)
// TerraFlow Dotfiles

import QtQuick
import QtQuick.Layouts
import "../services/TerraShellService.qml" as TerraShell
import "../../config.qml" as Config

RowLayout {
    id: media
    spacing: 8
    visible: TerraShell.TerraShellService.mediaTitle.length > 0
    
    // Connected to terra-shell service
    property string title: TerraShell.TerraShellService.mediaTitle
    property string artist: TerraShell.TerraShellService.mediaArtist
    property bool playing: TerraShell.TerraShellService.mediaPlaying
    
    Text {
        text: media.playing ? "󰏤" : "󰐊"
        color: Config.accent
        font.family: Config.fontMono
        font.pixelSize: Config.fontSizeLarge
        
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: TerraShell.TerraShellService.mediaToggle()
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
