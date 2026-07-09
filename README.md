# gpio-probe

This repository contains utility scripts designed to help identify GPIO pins when their hardware functions are unknown. Each script is tailored to a specific probing use case.

Both scripts include configuration variables at the top that you may need to adjust, such as the list of GPIOs to scan. It is generally recommended to avoid GPIOs that are already in use by the system. You can check currently active pins by running `cat /sys/kernel/debug/gpio` and excluding any that appear configured.

Based on experience, the lower-numbered GPIOs are typically things like nand, switches, etc & the higher-numbered GPIOs are often left unconfigured by default - making them a safe starting point for scanning.

#### Please note that probing certain pins may occasionally cause your device to crash or reboot. If this happens, simply reboot the device and remove the problematic GPIO from your scan list before trying again.

## 🛠️ DpenWRT Developerr Suite

`owrt-dev-suite-utils` is integrated into another GPLv3 project `owrt-dev-suite` which contains an advanced and highly customizable build script for OpenWRT.

For advanced and highly customizable developer build script for OpenWRT, see the dedicated **GPLv3 owrt-dev-suite**:
👉 [github.com/catspeed-cc/owrt-dev-suite](https://github.com/catspeed-cc/owrt-dev-suite)

## finding GPIOs to probe
You can find GPIOs to probe by listing them in two ways:
- `cat /sys/kernel/debug/gpio` to get all of them
- `cat /sys/kernel/debug/gpio | grep "in  low  func0 2mA pull down"` to get likely unconfigured ones

When including them in the script do not put 'GPIO' just put the numbers.

## `usb-power-probe.sh`
This script was originally developed to identify the USB power/enable line on the TEW-829DRU router. On this specific hardware, GPIOs are offset by 512 (meaning logical pin 0 corresponds to actual GPIO 512, logical pin 1 to 513, and so on). Ensure that the base offset matches your target device's architecture.

1. Identify a list of GPIOs to scan (use `cat /sys/kernel/debug/gpio` to view all available pins).
2. Open the script and add your chosen logical pin numbers to the `CANDIDATES` variable.
3. Adjust the `BASE` offset if necessary for your device.
4. Insert a USB flash drive with an LED indicator into the port you wish to test.
5. Run the script using `./usb-power-probe.sh`.
6. Monitor both the terminal output for USB-related `dmesg` messages and the USB drive's LED for any activity or flashing.
7. If the router crashes or reboots, remove that specific GPIO from your `CANDIDATES` list and try again.

## `button-probe.sh`
This script identifies which GPIO pin corresponds to a physical button by monitoring its electrical state changes. It exports each candidate GPIO as an input, records its initial state, prompts you to press and release the button, and reports whether the value changed.

1. Open the script and add your candidate logical GPIO numbers to the `BUTTON_CANDIDATES` variable.
2. Verify or manually set the auto-detected base offset at the top of the script if needed.
3. Run the script using `./button-probe.sh`.
4. Follow the on-screen instructions: hold down the button and press Enter, then release it and press Enter again.
5. If a matching pin is found, you will be prompted to decide whether to continue scanning the remaining pins.
6. If the router crashes or reboots, remove that GPIO from your `BUTTON_CANDIDATES` list, reboot the device, and restart the process.

## Disclaimer
mooleshacat and catspeed-cc are not responsible for any hardware damage caused by using these tools. Proceed at your own risk.
