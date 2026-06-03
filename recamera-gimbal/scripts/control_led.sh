#!/bin/bash
# Simple LED control script for reCamera.
# RECAMERA_IP / RECAMERA_PASS are read from the environment (set in openclaw.json);
# the literal values are only a fallback for standalone use.
RECAMERA_IP="${RECAMERA_IP:-192.168.16.1}"
RECAMERA_PASS="${RECAMERA_PASS:-recamera}"
ACTION=$1

if [ "$ACTION" = "on" ]; then
    VAL=1
elif [ "$ACTION" = "off" ]; then
    VAL=0
else
    echo "Usage: $0 on|off"
    exit 1
fi

# SSH command to control LED
ssh -o StrictHostKeyChecking=no "recamera@${RECAMERA_IP}" "echo '${RECAMERA_PASS}' | sudo -S sh -c 'echo $VAL > /sys/class/leds/white/brightness'"
