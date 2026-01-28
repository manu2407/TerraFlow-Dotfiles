// config.qml - Quickshell Configuration
// TerraFlow Dotfiles

pragma Singleton
import QtQuick

QtObject {
    // Colors (CuteCat - Gruvbox Dark)
    readonly property color bgPrimary: "#1d2021"
    readonly property color bgSecondary: "#3c3836"
    readonly property color bgTertiary: "#504945"
    
    readonly property color fgPrimary: "#ebdbb2"
    readonly property color fgSecondary: "#d5c4a1"
    readonly property color fgMuted: "#928374"
    
    readonly property color accent: "#fbf1c7"
    readonly property color accentAlt: "#fabd2f"
    readonly property color success: "#b8bb26"
    readonly property color warning: "#fe8019"
    readonly property color error: "#fb4934"
    
    // Bar settings
    readonly property int barHeight: 40
    readonly property int barMargin: 8
    readonly property int barRadius: 12
    readonly property real barOpacity: 0.85
    
    // Gaps
    readonly property int gapOuter: 10
    readonly property int gapInner: 5
    
    // Fonts
    readonly property string fontFamily: "Inter"
    readonly property string fontMono: "Iosevka Nerd Font"
    readonly property int fontSize: 13
    readonly property int fontSizeSmall: 11
    readonly property int fontSizeLarge: 16
    
    // Animation
    readonly property int animDuration: 200
    readonly property int animDurationFast: 100
    readonly property int animDurationSlow: 300
}
