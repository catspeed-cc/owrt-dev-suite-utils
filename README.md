# gpio-probe

Use these tools for probing GPIO's if you are unsure which are which. Each tool does a specific function.

Depending on the script there are configuration variables at the top you may want to change (such as GPIO's to probe). Typically you want to avoid GPIO that are already in use, so run `cat /sys/kernel/debug/gpio` and avoid ones that appear configured. In my case the last bunch were mostly default configuration so they were not in use, good place to probe. Sometimes probing will cause a crash, or your switch to reset. You just have to reboot and start over, removing that GPIO from your probe list.

## `usb-power-probe.sh`
This script was used to probe the USB on TEW-829DRU. In my router's case the GPIO are offset by 512, so for 0 it is 512, 1 it is 513, etc. So if there is an offset there you must make sure it is correct for your device.

1. select a bunch of GPIO's to probe (use `cat /sys/kernel/debug/gpio` to list all)
2. edit the script and put the numbers in
3. change the offset if required
4. find usb with LED on it and stick it in the port
5. start the probing `./usb-power-probe.sh`
6. monitor both the console output for dmesg output related to USB and the USB stick for flashy light
7. if the router crashes or reboots, remove that GPIO from the list
