import { App, Astal } from "astal/gtk4";

App.start({
  main() {
    const win = new Astal.Window({
      gdkmonitor: App.get_monitors()[0],
      exclusivity: Astal.Exclusivity.EXCLUSIVE,
      anchor: Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT,
      application: App,
    });
    win.add(new Gtk.Label({ label: "Test Bar" }));
    win.show();
  },
});
