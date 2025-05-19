import { Gtk, Widget, Variable } from "astal/gtk4";

// Props interface for component customization
interface MenuButtonProps {
    label?: string;
    dropdownItems?: string[];
}

// Reusable MenuButton component
function MenuButtonComponent({ label = "Menu", dropdownItems = ["Option 1", "Option 2", "Option 3"] }: MenuButtonProps): JSX.Element {
    // State for dropdown selection
    const selected = Variable<string>(dropdownItems[0]);

    // State for slider value
    const sliderValue = Variable<number>(50);

    // Create the popover content
    const popoverContent = (
        <box
            vertical={true}
            spacing={10}
            margin={10}
        >
            {/* Dropdown */}
            <dropdown
                model={Gtk.StringList.new(dropdownItems)}
                onNotifySelected={(self) => {
                    const index = self.selected;
                    if (index !== -1) {
                        selected.set(dropdownItems[index]);
                        console.log(`Selected: ${dropdownItems[index]}`);
                    }
                }}
            />
            {/* Slider */}
            <scale
                min={0}
                max={100}
                step={1}
                value={sliderValue.get()}
                onValueChanged={(self) => {
                    sliderValue.set(self.value);
                    console.log(`Slider value: ${self.value}`);
                }}
            />
        </box>
    );

    // Create the popover
    const popover = (
        <popover>
            {popoverContent}
        </popover>
    );

    // Return the MenuButton widget
    return (
        <menubutton
            label={label}
            popover={popover}
            onClicked={() => {
                console.log("Button clicked, opening menu");
            }}
            css="padding: 6px;"
        />
    );
}

export default MenuButtonComponent;
