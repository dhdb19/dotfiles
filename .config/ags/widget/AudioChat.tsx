export function SomethingElse() {
    // Get the default WirePlumber context from Astal
    const audio = Wp.get_default()?.audio;
    if (!audio) {
        // Fallback if audio is not available (e.g., WirePlumber not ready)
        return new Gtk.Label({ label: "No Audio Found" });
    }

    // Get the current audio stream object (typically the default output stream)
    const stream = audio.stream;

    // Create a reactive variable bound to the stream's volume property
    const volumeVar = bind(stream, "volume");

    // Create a reactive variable bound to the stream's mute state
    const mutedVar = bind(stream, "isMuted");

    // Define the icon for the top-level bar button (changes with volume/mute state)
    const barIcon = bind(stream, "volume", "isMuted").as(() =>
        new Gio.ThemedIcon({
            name: volumeIcon(stream.volume, stream.isMuted), // Dynamically resolve icon name
        })
    );

    // Define the icon used for the mute/unmute button in the popover
    const muteButtonIcon = bind(stream, "volume", "isMuted").as(() =>
        new Gio.ThemedIcon({
            name: volumeIcon(stream.volume, stream.isMuted),
        })
    );

    // Create a reactive variable for tracking the selected device index in the dropdown
    const selectedIndex = Variable<number>(0);

    // Create the dropdown widget for choosing among output devices (e.g., speakers, headphones)
    const dropdown = new Gtk.DropDown({
        model: new Gio.ListStore({ item_type: Wp.Device.$gtype }), // Backing model to hold Wp.Device objects
        selected: selectedIndex.bind(), // Bind selected index to reactive variable
        factory: new Gtk.SignalListItemFactory(), // Factory to render dropdown items
        halign: Gtk.Align.FILL, // Make dropdown stretch to fill horizontal space
    });

    // Setup handler defines the structure of each dropdown item
    dropdown.factory.connect("setup", (_factory, item) => {
        item.set_child(new Gtk.Label()); // Each item will contain a Gtk.Label as its child
    });

    // Bind handler updates each dropdown item whenever its underlying object changes
    dropdown.factory.connect("bind", (_factory, item) => {
        const device = item.get_item() as Wp.Device; // Get the bound Wp.Device object
        const label = item.get_child() as Gtk.Label; // Get the child Gtk.Label
        label.label = device?.description || "Unknown Device"; // Set label text to device description
    });

    // Function to update the dropdown with current list of available speaker devices
    const updateDevices = () => {
        const speakers = audio.speakers; // Get list of output devices (e.g., speakers)
        if (!speakers) {
            // If speakers list not yet populated, exit
            return;
        }

        const model = dropdown.get_model() as Gio.ListStore<Wp.Device>; // Cast model to correct type

        // Clear all items in the model
        model.remove_all?.();

        // Append each available speaker device to the model
        speakers.forEach((device) => model.append(device));

        // Find the index of the currently active speaker device
        const index = speakers.indexOf(audio.speaker);

        // Update selected index to match current speaker, or fall back to first device
        selectedIndex.value = index >= 0 ? index : 0;
    };

    // Automatically call updateDevices() whenever the speaker list changes
    bind(audio, "speakers").as(updateDevices);

    // Call updateDevices() once initially to populate the dropdown
    updateDevices();

    // Subscribe to dropdown selection changes
    selectedIndex.subscribe((idx) => {
        const model = dropdown.get_model() as Gio.ListStore<Wp.Device>; // Cast model
        const device = model.get_object?.(idx); // Get selected device
        if (device) {
            // Set it as the new active speaker in WirePlumber
            audio.speaker = device;
        }
    });

    // Create a mute/unmute button with an icon
    const muteBtn = new Gtk.Button({
        child: new Gtk.Image({
            gicon: muteButtonIcon, // Reactive icon updates with mute/volume state
            pixelSize: 16,         // Icon size
        }),
        tooltip_text: "Mute / Unmute", // Tooltip for clarity
    });

    // Toggle mute state when the button is clicked
    muteBtn.connect("clicked", () => {
        stream.isMuted = !stream.isMuted;
    });

    // Create a volume slider to control stream volume
    const slider = new Gtk.Scale({
        orientation: Gtk.Orientation.HORIZONTAL, // Horizontal slider
        drawValue: false,                        // Do not draw numeric value
        min: 0,                                  // Minimum value (0%)
        max: 1,                                  // Maximum value (100%)
        step: 0.01,                              // Step size (1%)
        hexpand: true,                           // Allow slider to expand horizontally
        value: volumeVar.bind(),                 // Bind slider value to reactive volume variable
    });

    // When user moves the slider, update the stream volume accordingly
    slider.connect("value-changed", () => {
        stream.volume = slider.get_value(); // Set stream volume to slider value
    });

    // Return the full Gtk.Widget for this audio control widget
    return (
        // Top-level button shown in the panel or bar
        <menubutton usePopover cssClasses={["AudioButton"]}>
            {/* Icon shown in the bar (updates with volume/mute state) */}
            <image gicon={barIcon} pixelSize={16} />

            {/* Popover content that appears when the menubutton is clicked */}
            <popover>
                {/* Vertical box layout to organize dropdown + controls */}
                <box
                    orientation={Gtk.Orientation.VERTICAL}
                    spacing={8}
                    marginTop={8}
                    marginBottom={8}
                    marginStart={12}
                    marginEnd={12}
                >
                    {/* Device selector dropdown */}
                    {dropdown}

                    {/* Horizontal box for mute button and volume slider */}
                    <box spacing={8} hexpand>
                        {muteBtn}
                        {slider}
                    </box>
                </box>
            </popover>
        </menubutton>
    );
}

