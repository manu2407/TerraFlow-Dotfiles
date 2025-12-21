const { Widget } = ags;
const { Hyprland } = ags.Service;

const Workspaces = () => Widget.Box({
    className: 'workspaces',
    children: Hyprland.bind('workspaces').transform(ws => {
        return ws.map(({ id }) => Widget.Button({
            onClicked: () => Hyprland.sendMessage(`dispatch workspace ${id}`),
            child: Widget.Label(`${id}`),
            className: Hyprland.active.workspace.bind('id').transform(i => i === id ? 'focused' : ''),
        }));
    }),
});

const Clock = () => Widget.Label({
    className: 'clock',
    label: Utils.exec('date "+%H:%M"'),
    setup: self => self.poll(1000, self => self.label = Utils.exec('date "+%H:%M"')),
});

export const Bar = (monitor = 0) => Widget.Window({
    name: `bar-${monitor}`,
    monitor,
    anchor: ['top', 'left', 'right'],
    exclusive: true,
    child: Widget.CenterBox({
        startWidget: Workspaces(),
        centerWidget: Clock(),
        endWidget: Widget.Label({ label: 'TerraFlow', className: 'title' }),
    }),
});
