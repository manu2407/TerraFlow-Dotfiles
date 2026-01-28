// TerraShellService.qml - IPC connection to terra-shell daemon
// TerraFlow Dotfiles

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: service
    
    // State properties (updated from terra-shell)
    property int activeWorkspace: 1
    property string windowTitle: ""
    property string windowClass: ""
    
    property int batteryLevel: 100
    property bool batteryCharging: false
    
    property int volume: 50
    property bool volumeMuted: false
    
    property bool networkConnected: false
    property string networkSsid: ""
    
    property string mediaTitle: ""
    property string mediaArtist: ""
    property bool mediaPlaying: false
    
    // Socket connection
    property var socket: Socket {
        path: "/tmp/terra-shell.sock"
        
        onConnected: {
            console.log("Connected to terra-shell")
            // Request full state on connect
            send("state\n")
        }
        
        onDisconnected: {
            console.log("Disconnected from terra-shell")
            // Try to reconnect after 2 seconds
            reconnectTimer.start()
        }
        
        onDataReceived: function(data) {
            try {
                var response = JSON.parse(data)
                handleResponse(response)
            } catch (e) {
                console.warn("Failed to parse response:", data)
            }
        }
    }
    
    // Reconnection timer
    property var reconnectTimer: Timer {
        interval: 2000
        onTriggered: {
            console.log("Attempting to reconnect to terra-shell...")
            socket.connect()
        }
    }
    
    // Polling timer for state updates
    property var pollTimer: Timer {
        interval: 1000
        repeat: true
        running: socket.connected
        
        onTriggered: {
            socket.send("state\n")
        }
    }
    
    // Handle incoming responses
    function handleResponse(response) {
        if (response.type === "state") {
            // Full state update
            activeWorkspace = response.workspace || 1
            windowTitle = response.window?.title || ""
            windowClass = response.window?.class || ""
            batteryLevel = response.battery?.level || 100
            batteryCharging = response.battery?.charging || false
            volume = response.audio?.volume || 50
            volumeMuted = response.audio?.muted || false
            networkConnected = response.network?.connected || false
            networkSsid = response.network?.ssid || ""
            mediaTitle = response.media?.title || ""
            mediaArtist = response.media?.artist || ""
            mediaPlaying = response.media?.playing || false
        } else if (response.type === "battery") {
            batteryLevel = response.level
            batteryCharging = response.charging
        } else if (response.type === "audio") {
            volume = response.volume
            volumeMuted = response.muted
        } else if (response.type === "workspaces") {
            activeWorkspace = response.active
        } else if (response.type === "window") {
            windowTitle = response.title
            windowClass = response.class
        } else if (response.type === "media") {
            mediaTitle = response.title
            mediaArtist = response.artist
            mediaPlaying = response.playing
        } else if (response.type === "network") {
            networkConnected = response.connected
            networkSsid = response.ssid
        }
    }
    
    // Control functions
    function setVolume(level) {
        socket.send("volume " + level + "\n")
    }
    
    function toggleMute() {
        socket.send("mute\n")
    }
    
    function setBrightness(level) {
        socket.send("brightness " + level + "\n")
    }
    
    function mediaToggle() {
        socket.send("media-toggle\n")
    }
    
    function mediaNext() {
        socket.send("media-next\n")
    }
    
    function mediaPrev() {
        socket.send("media-prev\n")
    }
    
    function dispatch(command, args) {
        socket.send("dispatch " + command + " " + args + "\n")
    }
    
    // Initialize connection on component load
    Component.onCompleted: {
        socket.connect()
    }
}
