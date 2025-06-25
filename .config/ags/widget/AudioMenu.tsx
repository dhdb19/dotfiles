import { Variable, GLib, bind } from "astal"
import { App, Astal, Gtk, Gdk } from "astal/gtk4"
import Hyprland from "gi://AstalHyprland"
import Mpris from "gi://AstalMpris"
import Wp from "gi://AstalWp"
import Gio from "gi://Gio";

export function AudioMenu() {

  const barButton = new Gtk.MenuButton({})

  const buttonImage = new Gtk.Image({
    icon_name : "audio-volume-high-symbolic",
    pixel_size: "20"
  })

  barButton.set_child(buttonImage)

  const wp = Wp.get_default()

  const audio = wp.audio
  console.log("AudioMenu audio:", audio)


  const popover = new Gtk.Popover({
    has_arrow: false,
    position: Gtk.PositionType.BOTTOM
  })
  
  const selectedIndex = Variable<number>(0);

  const dropdown = new Gtk.DropDown({
    model: new Gio.ListStore({item_type: Wp.Endpoint.$gtype}),
    selected: selectedIndex,
    factory: new Gtk.SignalListItemFactory(),
    halign: Gtk.Align.FILL
  })

  dropdown.factory.connect("setup", (_factory, item) => {
    const label = new Gtk.Label({ label: "Placeholder"})
    item.set_child(label);
  })

  dropdown.factory.connect("bind", (_factory, item) => {
    const device = item.get_item() as Wp.Endpoint;
    const label = item.get_child() as Gtk.Label;
    device.set_is_default(true);
    label.label = device?.description|| "Unknown Device"
    // print(
      // "\nBinding item:", device,
      // "Output device:", device?.description, "\n",
      // "Selected", dropdown.get_selected_item().description, "\n",
      // "Is Default?", device?.is_default, "\n",
      // "Default Speaker:", audio.default_speaker.description, "\n",
      // "Volume:", device.volume)
  })

function speakerConnect() {
    dropdown.get_model().connect('items-changed', (_list, position, removed, added) => {
      console.log(`${removed} items were removed, and ${added} added at ${position}`);
    });    
}

speakerConnect()

  function UpdateDevices() {
      GLib.timeout_add(GLib.PRIORITY_DEFAULT, 300, () => {
        audio.speakers.forEach((s, i) => {
          print(`Speaker ${i} type:`, s.constructor?.name ?? typeof s);
          print(`GType:`, s.$gtype);
          print("Description", s.description)
        });
        const speakers = audio.speakers
        const model = dropdown.get_model() as Gio.ListStore<Wp.Endpoint>;
        speakers.forEach((device, idx) => {
          print(`Adding speaker ${idx}:`, device?.description ?? "No description");
          model.append(device);
        });
        const index = speakers.indexOf(audio.speaker);
        selectedIndex.value = index >= 0 ? index : 0;
      return GLib.SOURCE_REMOVE;
      })
}

  UpdateDevices();

  // function VolumeSlider() {
  //   const speaker = Wp.get_default().audio.get_default_speaker()
  //   print("=?=???==?=?=??=?=", speaker, speaker.volume)
  //   const slider = new Gtk.Scale({
  //     adjustment: new Gtk.Adjustment({
  //       lower: 0,
  //       upper: 100,
  //       value:   () => {
  //         GLib.timeout_add(GLib.PRIORITY_DEFAULT, 500, () => {
  //           print("=?=???==?=?=??=?=", speaker, speaker.volume)
  //           bind(speaker, "volume")
  //         return GLib.SOURCE_REMOVE;
  //         })
  //       }
  //     }),

  // })

  //   return slider
  // }

  const adjustment = new Gtk.Adjustment({ lower: 0, upper: 1, step_increment: 0.01 })
  const slider = new Gtk.Scale({
      orientation: Gtk.Orientation.HORIZONTAL,
      adjustment: adjustment,
      digits: 2,
      hexpand: true
  })
  const listStore = new Gio.ListStore({ item_type: Wp.Endpoint.$gtype })

    function updateSliderToSelectedDevice() {
        const index = selectedIndex.value
        const device = listStore.get_item(index) as Wp.Endpoint
        if (device) {
            adjustment.set_value(device.volume)
        }
    }

    function connectSliderToDevice() {
        slider.connect('value-changed', () => {
            const index = selectedIndex.value
            const device = listStore.get_item(index) as Wp.Endpoint
            if (device) {
                device.volume = adjustment.get_value()
                print(`Set volume of ${device.description} to ${device.volume}`)
            }
        })
    }

    connectSliderToDevice()
    updateSliderToSelectedDevice()

  const someButton = new Gtk.Button()
  someButton.set_label("Hey")
  
  
  function MenuBox() {

  const menubox = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL
  })

  menubox.append(dropdown)
  menubox.append(slider)
  menubox.append(someButton)
  
  return menubox
  
  }


  popover.set_child(MenuBox())


  barButton.set_popover(popover)

  return barButton

}
