# gpio-probe

Use these tools for probing GPIOs if you are unsure which pins correspond to specific hardware functions. Each script handles a different use case.

Depending on the script, there are configuration variables at the top that you may want to change (such as the list of GPIOs to probe). Typically, you want to avoid GPIOs that are already in use. Run `cat /sys/kernel/debug/gpio` and avoid pins that appear configured. In my experience, the last batch of GPIOs were mostly default/unconfigured, making them a safe place to start probing. Sometimes probing will cause a crash or reset your device. You just have to reboot and start over, removing that GPIO from your probe list.

## `usb-power-probe.sh`
This script was used to probe the USB power/enable line on the TEW-829DRU router. On this device, the GPIOs are offset by 512 (so logical pin 0 is actual GPIO 512, pin 1 is 513, etc.). You must ensure the base offset is correct for your specific device.

1. select a bunch of GPIOs to probe (use `cat /sys/kernel/debug/gpio` to list all)
2. edit the script and put the logical numbers in `CANDIDATES`
3. change the `BASE` offset if required
4. find a USB stick with an LED on it and plug it into the port
5. start the probing `./usb-power-probe.sh`
6. monitor both the console output for `dmesg` messages related to USB and the USB stick for a flashing light
7. if the router crashes or reboots, remove that GPIO from your probe list

## `button-probe.sh`
This script detects which GPIO pin corresponds to a physical button by monitoring its state changes. It exports each candidate GPIO as an input, reads its initial state, waits for you to press and release the button, and reports if the value changed.

1. edit the script and add your candidate logical GPIO numbers to `BUTTON_CANDIDATES`
2. verify or change the auto-detected base offset at the top of the script
3. start the probing `./button-probe.sh`
4. follow the on-screen prompts: hold the button, press Enter, release the button, press Enter
5. if a match is found, you'll be asked whether to continue scanning other pins
6. if the router crashes or reboots, remove that GPIO from your probe list and reboot

## Disclaimer
mooleshacat and catspeed-cc are not responsible for damage to hardware - proceed at your own risk.
