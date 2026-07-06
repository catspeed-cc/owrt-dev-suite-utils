#!/bin/sh

# --- CONFIGURATION ---
#BUTTON_CANDIDATES="0 1 2 3 4 5 10 11 18 20 21 22 29 30 31 32 33 34 35 36 37 39 40 42 43 44 45 46 47 49 50 51 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99"
LED_CANDIDATES="50 51 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99"

# Auto-detect Base Offset (same logic as usb-power-probe.sh)
BASE=$(cat /sys/kernel/debug/gpio 2>/dev/null | grep -E "pinctrl-msm|1000000.pinctrl" | head -1 | sed -n 's/.*GPIOs \([0-9]*\)-.*/\1/p')

if [ -z "$BASE" ]; then
    echo "Warning: Could not auto-detect GPIO base. Assuming 512."
    BASE=512
fi

echo "Detected GPIO Base Offset: $BASE"
echo "Starting LED scan on logical pins: $LED_CANDIDATES"
echo "Actual GPIOs tested will be: $(echo $LED_CANDIDATES | sed "s/ / + $BASE /g")"
echo "Press Ctrl+C at any time to abort."
echo "---"

STOP=0
for pin in $LED_CANDIDATES; do
    [ "$STOP" -eq 1 ] && break

    GPIO=$((pin + BASE))

    # Unexport GPIO before each loop iteration
    echo "$GPIO" > /sys/class/gpio/unexport 2>/dev/null || true
    sleep 1

    # Export GPIO
    echo "$GPIO" > /sys/class/gpio/export 2>/dev/null && \
        echo "Successfully exported Logical GPIO $pin (Actual: $GPIO)." || \
        { echo "Failed to export Logical GPIO $pin (Actual: $GPIO)."; continue; }
    sleep 1

    # Configure as output
    echo "out" > /sys/class/gpio/gpio$GPIO/direction 2>/dev/null && \
        echo "Successfully set direction for Logical GPIO $pin (Actual: $GPIO)." || \
        { echo "Failed to set direction for Logical GPIO $pin (Actual: $GPIO)."; continue; }
    sleep 1

    # Set HIGH for 2 seconds
    echo "Testing Logical GPIO $pin (Actual: $GPIO) -> Setting HIGH..."
    echo "1" > /sys/class/gpio/gpio$GPIO/value 2>/dev/null && \
        echo "Successfully set HIGH." || \
        { echo "Failed to set HIGH for Logical GPIO $pin (Actual: $GPIO)."; }
    sleep 2

    # Set LOW
    echo "Setting LOW..."
    echo "0" > /sys/class/gpio/gpio$GPIO/value 2>/dev/null && \
        echo "Successfully set LOW." || \
        { echo "Failed to set LOW for Logical GPIO $pin (Actual: $GPIO)."; }

    # Unconfigure at end of iteration
    echo "$GPIO" > /sys/class/gpio/unexport 2>/dev/null || true
    echo "---"
done

echo "Scan complete."
