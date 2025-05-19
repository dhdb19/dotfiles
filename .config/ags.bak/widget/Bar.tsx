import { App, Astal, Gtk, Gdk } from "astal/gtk4";
import { Variable } from "astal";

const time = Variable("").poll(1000, "date");

export default function Bar(monitor: Gdk.Monitor) {
    return (
        <window
            application={App}
            gdkmonitor={monitor}
            anchor={Astal.WindowAnchor.TOP}
            exclusivity={Astal.Exclusivity.EXCLUSIVE}
        >
            <centerbox className="Bar">
                <button
                    onClicked={() => print("Clicked!")}
                    halign={Gtk.Align.CENTER}
                >
                    <label label={time()} />
                </button>
            </centerbox>
        </window>
    );
}
