#!/bin/bash
# LED control (SCP temp-script variant).
# Builds a small script locally, copies it to the device with scp, runs it, and
# cleans up. Mirrors control_led_v2.ps1.
RECAMERA_IP="${RECAMERA_IP:-192.168.16.1}"
RECAMERA_PASS="${RECAMERA_PASS:-recamera}"
ACTION=$1

if [ -z "$RECAMERA_IP" ] || [ -z "$RECAMERA_PASS" ]; then
    echo "Missing environment variables" >&2
    exit 1
fi

if [ "$ACTION" = "on" ]; then
    VAL=1
elif [ "$ACTION" = "off" ]; then
    VAL=0
else
    echo "Invalid argument, must be 'on' or 'off'"
    exit 1
fi

# Create a temporary script file that carries the password and command
TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT
cat > "$TMP_FILE" <<EOF
#!/bin/bash
echo '${RECAMERA_PASS}' | sudo -S sh -c 'echo $VAL > /sys/class/leds/white/brightness'
EOF

# Copy the temporary script to the remote host with SCP
scp -o StrictHostKeyChecking=no "$TMP_FILE" "recamera@${RECAMERA_IP}:/tmp/control_led.sh"

# Execute the remote script
ssh -o StrictHostKeyChecking=no "recamera@${RECAMERA_IP}" "chmod +x /tmp/control_led.sh && /tmp/control_led.sh"
