import { App, Gdk } from "astal/gtk4"
import style from "./style.scss"
import Bar from "./widget/Bar"
import { Variable, GLib, bind } from "astal"
imports.gi.versions.Gtk4LayerShell = '1.0';
const Gtk4LayerShell = imports.gi.Gtk4LayerShell;

// const display = Gdk.Display.get_default();
// if (!display) {
//   console.error('Failed to get default display');
//   process.exit(1);
// }

// // Get the monitors as a GList and convert to array
// const monitorsList = display.get_monitors();
// const monitors = [];

// // Iterate over the GList to populate the monitors array
// for (let i = 0; i < monitorsList.get_length(); i++) {
//   const monitor = monitorsList.get_nth_data(i);
//   if (monitor) {
//     monitors.push(monitor);
//   }
// }

// if (monitors.length === 0) {
//   console.error('No monitors found');
//   process.exit(1);
// }

App.start({
  css: style,
  instanceName: "js",
  requestHandler(request, res) {
    print(request)
    res("ok")
  },
  main() {
    console.log("GDK_BACKEND:", GLib.getenv("GDK_BACKEND"));
    console.log("WAYLAND_DISPLAY:", GLib.getenv("WAYLAND_DISPLAY"));
    console.log("Gtk4LayerShell loaded:", Gtk4LayerShell);
    App.get_monitors().map(Bar)
    // console.log('Monitors List:', monitorsList, 'Length:', monitorsList.get_length());
    // windows: monitors.map(monitor => Bar(monitor))
  },
})
