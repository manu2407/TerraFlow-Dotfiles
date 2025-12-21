const { Widget } = ags;
const { Audio, Mpris } = ags.Service;

const VolumeSlider = () => Widget.Slider({
    onChange: ({ value }) => Audio.speaker.volume = value,
});

const MicSlider = () => Widget.Slider({
    onChange: ({ value }) => Audio.microphone.volume = value,
});

const NetworkPicker = () => Widget.Box({
    children: [
        Widget.Label("Wifi: Connected"), // Placeholder
    ],
});

const PerformanceToggle = () => Widget.Switch({
    onActivate: ({ active }) => Utils.execAsync(['powerprofilesctl', 'set', active ? 'performance' : 'balanced']),
});

const MediaControls = () => Widget.Box({
    children: [
        Widget.Button({ label: "Prev", onClicked: () => Mpris.getPlayer('')?.previous() }),
        Widget.Button({ label: "Play/Pause", onClicked: () => Mpris.getPlayer('')?.playPause() }),
        Widget.Button({ label: "Next", onClicked: () => Mpris.getPlayer('')?.next() }),
    ],
});

export const Dashboard = () => Widget.Window({
    name: 'dashboard',
    anchor: ['right', 'top', 'bottom'],
    child: Widget.Box({
        vertical: true,
        className: 'dashboard',
        children: [
            Widget.Label({ label: "Volume" }),
            VolumeSlider(),
            Widget.Label({ label: "Mic" }),
            MicSlider(),
            NetworkPicker(),
            Widget.Label({ label: "Performance Mode" }),
            PerformanceToggle(),
            MediaControls(),
        ],
    }),
});
