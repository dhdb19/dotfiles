import { App } from "astal/gtk3"
import { Variable, GLib, bind } from "astal"
import { Astal, Gtk, Gdk } from "astal/gtk3"
import Hyprland from "gi://AstalHyprland"
import Mpris from "gi://AstalMpris"
import Battery from "gi://AstalBattery"
import Wp from "gi://AstalWp"
import Network from "gi://AstalNetwork"
import Tray from "gi://AstalTray"
import Gio from "gi://Gio";


function LauncherButton() {
    const menu = new Gio.Menu()
    menu.append("Open Terminal", "app.launch-terminal")

    const actions = new Gio.SimpleActionGroup()
    const terminalAction = new Gio.SimpleAction({ name: "launch-terminal" })
    terminalAction.connect("activate", () => {
        // replace this with your terminal launcher
        GLib.spawn_command_line_async("ghostty")
    })
    actions.add_action(terminalAction)

    const iconPath = "/home/jordi/.config/ags/assets/nix.svg"  
    const fileIcon = Gio.FileIcon.new(Gio.File.new_for_path(iconPath))

    return <menubutton
        className="LauncherButton"
        menuModel={menu}
        usePopover={true}
        actionGroup={["app", actions]}>
        <icon gicon={fileIcon} />
    </menubutton>
}

function SysTray() {
    const tray = Tray.get_default()

    return <box className="SysTray">
        {bind(tray, "items").as(items => items.map(item => (
            <menubutton
                tooltipMarkup={bind(item, "tooltipMarkup")}
                usePopover={false}
                actionGroup={bind(item, "actionGroup").as(ag => ["dbusmenu", ag])}
                menuModel={bind(item, "menuModel")}>
                <icon gicon={bind(item, "gicon")} />
            </menubutton>
        )))}
    </box>
}

function Wifi() {
    const network = Network.get_default()
    const wifi = bind(network, "wifi")

    return <box visible={wifi.as(Boolean)}>
        {wifi.as(wifi => wifi && (
            <icon
                tooltipText={bind(wifi, "ssid").as(String)}
                className="Wifi"
                icon={bind(wifi, "iconName")}
            />
        ))}
    </box>

}

function AudioSlider() {
    const speaker = Wp.get_default()?.audio.defaultSpeaker!

    return <box className="AudioSlider" css="min-width: 140px">
        <icon icon={bind(speaker, "volumeIcon")} />
        <slider
            hexpand
            onDragged={({ value }) => speaker.volume = value}
            value={bind(speaker, "volume")}
        />
    </box>
}

function BatteryLevel() {
    const bat = Battery.get_default()

    return <box className="Battery"
        visible={bind(bat, "isPresent")}>
        <icon icon={bind(bat, "batteryIconName")} />
        <label label={bind(bat, "percentage").as(p =>
            `${Math.floor(p * 100)} %`
        )} />
    </box>
}

function Media() {
    const mpris = Mpris.get_default()

    return <box className="Media">
        {bind(mpris, "players").as(ps => ps[0] ? (
            <box>
                <box
                    className="Cover"
                    valign={Gtk.Align.CENTER}
                    css={bind(ps[0], "coverArt").as(cover =>
                        `background-image: url('${cover}');`
                    )}
                />
                <label
                    label={bind(ps[0], "metadata").as(() =>
                        `${ps[0].title} - ${ps[0].artist}`
                    )}
                />
            </box>
        ) : (
            <label label="Nothing Playing" />
        ))}
    </box>
}

function Workspaces() {
    const hypr = Hyprland.get_default()
    const wsNames = ["Files", "Options", "Edit", "View", "Go"]

    return <box className="Workspaces">
    {bind(hypr, "workspaces").as(wss => {
      // Filter out special workspaces as before
      const filteredWss = wss.filter(ws => !(ws.id >= -99 && ws.id <= -2))

      // Find the highest workspace id present
      const maxId = filteredWss.reduce((max, ws) => ws.id > max ? ws.id : max, 1)

      // Create an array of workspace IDs from 1 to maxId
      const workspaceRange = Array.from({ length: maxId }, (_, i) => i + 1)

      // Map over workspaceRange, find the real workspace if exists, else null (empty)
      return workspaceRange.map(id => {
        const ws = filteredWss.find(w => w.id === id) || { id }

        // Assign a name from the wsNames list by cycling through it if more workspaces than names
        const name = wsNames[(id - 1) % wsNames.length]

        // Determine if focused
        const isFocused = bind(hypr, "focusedWorkspace").as(fw => fw && fw.id === id)

        return (
          <button
            className={isFocused ? "focused" : ""}
            onClicked={() => ws.focus && ws.focus()}>
            {name}
          </button>
        )
      })
    })}
  </box>
}

function prettifyClass(cls: string): string {
    const segments = cls.split(".");
    const last = segments[segments.length - 1];
    return last.charAt(0).toUpperCase() + last.slice(1);
}

function FocusedClient() {
    const hypr = Hyprland.get_default()
    const focused = bind(hypr, "focusedClient")

    return <box
        className="Focused"
        visible={focused.as(Boolean)}>
        {focused.as(client => (
            client && <label label={bind(client, "class").as(prettifyClass)} />
        ))}
    </box>
}

function Time({ format = "%a %d %b %H:%M" }) {
    const time = Variable<string>("").poll(1000, () =>
        GLib.DateTime.new_now_local().format(format)!)

    return <label
        className="Time"
        onDestroy={() => time.drop()}
        label={time()}
    />
}

export default function Bar(monitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    return <window
        // className="Bar"
        gdkmonitor={monitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={TOP | LEFT | RIGHT}>
        <centerbox className="Bar">
            <box hexpand halign={Gtk.Align.START}>
                <LauncherButton />
                <FocusedClient />
                <Workspaces />
            </box>
            <box>

            </box>
            <box hexpand halign={Gtk.Align.END} >
                <Media />
                <SysTray />
                <Wifi />
                <AudioSlider />
                <BatteryLevel />
                <Time />
            </box>
        </centerbox>
    </window>
}
