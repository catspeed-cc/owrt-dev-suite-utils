#!/bin/sh

# --- CONFIGURATION ---
# Common IPQ4019 USB/LED GPIO candidates (logical numbers 0-99)
CANDIDATES="53 55 56 58 60 67 68 69 70 45 46 47 48 49"

# Auto-detect Base Offset
# Look for the Qualcomm pinctrl chip in debugfs
BASE=$(cat /sys/kernel/debug/gpio 2>/dev/null | grep -E "pinctrl-msm|1000000.pinctrl" | head -1 | sed -n 's/.*GPIOs \([0-9]*\)-.*/\1/p')

# Fallback if auto-detect fails (IPQ4019 is usually 412)
if [ -z "$BASE" ]; then
    echo "Warning: Could not auto-detect GPIO base. Assuming 412."
    BASE=412
fi

echo "Detected GPIO Base Offset: $BASE"
echo "Starting scan on logical pins: $CANDIDATES"
echo "Actual GPIOs tested will be: $(echo $CANDIDATES | sed "s/ / + $BASE /g")"
echo "Watch your multimeter/LED. Press Ctrl+C to stop."

for pin in $CANDIDATES; do
    # Calculate actual GPIO number
    GPIO=$((pin + BASE))
    
    # Export
    if ! echo "$GPIO" > /sys/class/gpio/export 2>/dev/null; then
        # Skip if already in use or invalid
        continue
    fi

    # Set Output High
    echo "out" > /sys/class/gpio/gpio$GPIO/direction
    echo "1" > /sys/class/gpio/gpio$GPIO/value
    
    echo "Testing Logical GPIO $pin (Actual: $GPIO) -> HIGH"
    
    # Wait for observation
    sleep 2
    
    # Reset to Input (Safe State)
    echo "in" > /sys/class/gpio/gpio$GPIO/direction
    echo "$GPIO" > /sys/class/gpio/unexport
done

echo "Scan complete."
