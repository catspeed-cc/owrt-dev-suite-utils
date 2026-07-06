#!/bin/sh

# --- CONFIGURATION ---
#BUTTON_CANDIDATES="0 1 2 3 4 5 10 11 18 20 21 22 29 30 31 32 33 34 35 36 37 39 40 42 43 44 45 46 47 49 50 51 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99"
BUTTON_CANDIDATES="10 11 18 22 29 30 31 32 33 37 39 42 43 44 45 46 47 49 50 51 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99"

# Auto-detect Base Offset (same logic as usb-power-probe.sh)
BASE=$(cat /sys/kernel/debug/gpio 2>/dev/null | grep -E "pinctrl-msm|1000000.pinctrl" | head -1 | sed -n 's/.*GPIOs \([0-9]*\)-.*/\1/p')

if [ -z "$BASE" ]; then
    echo "Warning: Could not auto-detect GPIO base. Assuming 512."
    BASE=512
fi

echo "Detected GPIO Base Offset: $BASE"
echo "Starting button scan on logical pins: $BUTTON_CANDIDATES"
echo "Actual GPIOs tested will be: $(echo $BUTTON_CANDIDATES | sed "s/ / + $BASE /g")"
echo "Press Ctrl+C at any time to abort."
echo "---"

STOP=0
for pin in $BUTTON_CANDIDATES; do
    [ "$STOP" -eq 1 ] && break

    GPIO=$((pin + BASE))

    # 1) Export & configure as input
    if ! echo "$GPIO" > /sys/class/gpio/export 2>/dev/null; then
        echo "Skipping Logical GPIO $pin (Actual: $GPIO): already exported or invalid."
        continue
    fi
    echo "in" > /sys/class/gpio/gpio$GPIO/direction

    # 3) Check start value
    START_VAL=$(cat /sys/class/gpio/gpio$GPIO/value | tr -d '[:space:]')
    echo "Logical GPIO $pin (Actual: $GPIO) -> Initial state: $START_VAL"

    # 4) Ask user to hold button & press Enter
    echo -n "Please hold the button and press Enter... "
    read

    # 5) Check value & report change
    END_VAL=$(cat /sys/class/gpio/gpio$GPIO/value | tr -d '[:space:]')
    if [ "$START_VAL" != "$END_VAL" ]; then
        echo "✅ MATCH FOUND! Logical GPIO $pin (Actual: $GPIO) changed from $START_VAL to $END_VAL."
        echo -n "Continue probing other GPIOs? (y/n): "
        read RESP
        case "$RESP" in
            [Nn]*) STOP=1 ;;
        esac
    else
        echo "No change detected on this pin."
    fi

    # 6) Ask user to release button & press Enter
    echo -n "Please release the button and press Enter... "
    read

    # 7) Unconfigure / restore
    echo "$GPIO" > /sys/class/gpio/unexport 2>/dev/null
    echo "---"
done

echo "Scan complete."
