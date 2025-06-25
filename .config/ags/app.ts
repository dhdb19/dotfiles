import { App, Gtk } from "astal/gtk4"
import style from "./style.scss"
import Bar from "./widget/Bar"

App.start({
  css: style,
  main() {
    console.log("monitors: ", App.get_monitors().length);
    App.get_monitors().map(Bar)
  },
})
