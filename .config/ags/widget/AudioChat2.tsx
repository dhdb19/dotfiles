import { Variable, bind, GLib } from "astal"
import { Gtk, App } from "astal/gtk4"
import Wp from "gi://AstalWp"

export function AudioMenu2() {

  const wp = Wp.get_default();
  print("Wp Default Object:", wp);

  const audio = wp.audio;
    print("Audio:", audio);

    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => {
      print("Delayed check:");
      print("audio.speakers:", audio.speakers);
      audio.speakers?.forEach((s, i) => {
          print(`Speaker ${i}: ${s.constructor.name}, desc: ${s.description}`);
      });
      return GLib.SOURCE_REMOVE;
    });

    // const audio = Wp.get_default()?.audio;
    if (!audio) {
        print("AstalWp not ready yet.");
        return new Gtk.Label({ label: "No audio available" });
    }

    // Only proceed if speakers actually exist and have description
    if (!audio.speakers?.length || !audio.speakers[0]?.description) {
        print("Speakers not ready, retrying in 500ms...");
        GLib.timeout_add(GLib.PRIORITY_DEFAULT, 500, () => {
            App.add_window(new Gtk.Window({ child: AudioMenu2() }));
            return GLib.SOURCE_REMOVE;
        });
        return new Gtk.Label({ label: "Loading speakers..." });
    }

    const selectedIndex = Variable(0);
    const speakerList = Variable<string[]>([]);

    // Use a Gtk.StringList to avoid GType issues
    const stringList = Gtk.StringList.new([]);
    const dropdown = new Gtk.DropDown({
        model: stringList,
        selected: selectedIndex,
        halign: Gtk.Align.FILL,
    });

    // Updates the dropdown items
    function updateDevices() {
        const speakers = audio.speakers;
        audio.speakers.forEach((s, i) => {
          print(`Speaker ${i}: ${s} — Type: ${s.constructor.name}`);
          print(`Description: ${s.description}`);
        });
        if (!speakers?.length) {
            print("No speakers found.");
            return;
        }

        // stringList.remove_all();
        const names = speakers.map((s, i) => {
            print(`Speaker ${i}:`, s.description);
            return s.description ?? `Unknown ${i}`;
        });

        names.forEach(name => stringList.append(name));

        const currentIndex = speakers.indexOf(audio.speaker);
        selectedIndex.value = currentIndex >= 0 ? currentIndex : 0;
    }

    // Reactively update when `speakers` changes
    bind(audio, "speakers").as(updateDevices);

    // Manual first-time population
    updateDevices();

    // Set speaker when a new index is selected
    selectedIndex.subscribe((idx) => {
        const speakers = audio.speakers;
        const chosen = speakers?.[idx];
        if (chosen) {
            print(`Switching to speaker: ${chosen.description}`);
            audio.speaker = chosen;
        }
    });

    const popover = new Gtk.Popover();
    popover.set_has_arrow(false);
    popover.set_position(Gtk.PositionType.BOTTOM);
    popover.set_child(dropdown);

    const barButton = new Gtk.MenuButton({});
    barButton.set_child(new Gtk.Image({ icon_name: "audio-volume-high-symbolic", pixel_size: 20 }));
    barButton.set_popover(popover);

    return barButton;
}
