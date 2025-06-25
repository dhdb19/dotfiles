import { Variable, GLib, bind } from "astal"
import { subprocess, exec, execAsync } from "astal/process"
import { interval, timeout, idle } from "astal/time"
import { App, Astal, Gtk, Gdk } from "astal/gtk4"
import Hyprland from "gi://AstalHyprland"
import Gio from "gi://Gio";
import FocusTracker from 'astal/services/focus';


export function FocusedClient() {
  
  function prettifyClass(cls: string): string {
    const segments = cls.split(".");
    const last = segments[segments.length - 1];
    return last.charAt(0).toUpperCase() + last.slice(1);
}

    const hypr = Hyprland.get_default()
    const focused = bind(hypr, "focusedClient")

    return <box
      cssNames={["Focused"]}
      visible={true}>
        {focused.as(client => {
          // print("?=?=?=?=?==?", client)
          const clientName = client && <label label={bind(client, "class").as(prettifyClass)} />
          if (clientName) {
            return clientName
          } else {
            return "Programme"
          }
        })}
    </box>

}


