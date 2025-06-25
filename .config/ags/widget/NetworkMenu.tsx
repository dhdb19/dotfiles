import { App, Astal, Gtk, Gdk } from "astal/gtk4"
import Hyprland from "gi://AstalHyprland"
import Mpris from "gi://AstalMpris"
import Wp from "gi://AstalWp"
import Gio from "gi://Gio";
import Network from "gi://AstalNetwork"
import { Variable, GLib, bind } from "astal"



export function NetworkMenu() {

  const barButton = new Gtk.MenuButton({})

  const buttonImage = new Gtk.Image({
    pixel_size: "20",
    icon_name: "network-wired-symbolic"
  })

  barButton.set_child(buttonImage)

  const nw = Network.get_default()

  const popover = new Gtk.Popover({
    has_arrow: false,
    position: Gtk.PositionType.BOTTOM
  })

  const selectedIndex = Variable<number>(0)

  function wiredDropdown() {
    const wiredDropdown = new Gtk.DropDown({
      model: new Gio.ListStore({
        item_type: Network.Network.$gtype
      }),
      selected: selectedIndex,
      factory: new Gtk.SignalListItemFactory(),
      halign: Gtk.Align.FILL,
    })

    wiredDropdown.factory.connect("setup", (_factory, item) => {
      const label = new Gtk.Label({label: "Placeholder"})
      item.set_child(label)
    })

      wiredDropdown.factory.connect("bind", (_factory, item) => {
        const network = item.get_item() as Network.Network;
        const label = item.get_child() as Gtk.Label;
        network.set_device()
    })

    return wiredDropdown
  }

  wiredDropdown()

  
  function wifiDropdown() {
    const wifiDropdown = new Gtk.DropDown({
      model: new Gio.ListStore({
        item_type: Network.Network.$gtype
      }),
      selected: selectedIndex,
      factory: new Gtk.SignalListItemFactory(),
      halign: Gtk.Align.FILL,
    })

    wifiDropdown.factory.connect("setup", (_factory, item) => {
      const label = new Gtk.Label({label: "Placeholder"})
      item.set_child(label)
    })

    wifiDropdown.factory.connect("bind", (_factory, item) => {
        const network = item.get_item() as Network.AccessPoint;
        const label = item.get_child() as Gtk.Label;
        network.set_device()
    })

    return wifiDropdown
  }

  wifiDropdown()

  function updateWifi() {
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 200, () => {
      // nw.wifi.wifi_scan()
      const accessPoints = nw.wifi.access_points
      const model = wifiDropdown().get_model() as Gio.ListStore<Network.AccessPoint>;
      print("%%%%Access Points:", accessPoints)
      accessPoints.forEach((device, idx) => {
        print(`Adding access point${idx}:`, device?.name ?? "No description");
        model.append(device);
        })

      return GLib.SOURCE_REMOVE;
    })
  }

  updateWifi()

  
  function updateWired() {
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 200, () => {
      const wired = nw.wired.get_device()
      print(wired)
      const model = wiredDropdown().get_model() as Gio.ListStore<Network.Wired>
      print("=====LAN conncetion:", wired)
      // wired.forEach((device, idx) => {
      //   print(`Addinf wired:${idx}`, device?.name ?? "No description" );
      //   model.append(device)
      // })
      model.append(wired)
      return GLib.SOURCE_REMOVE;
    })
  }

  updateWired()

  function MenuBox(){

  const menubox = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL
  })

  menubox.append(wiredDropdown())
  menubox.append(wifiDropdown())
  
  return menubox
  
  }

  // const audioMenuBox = new Gtk.Box({
  //   orientation: Gtk.Orientation.VERTICAL
  // })
  // dropdownBox.append(dropdown)
  // dropdownBox.append(slider)

  popover.set_child(MenuBox())

  // popover.set_child(sliderBox)

  barButton.set_popover(popover)

  
  
  return barButton
  
}
