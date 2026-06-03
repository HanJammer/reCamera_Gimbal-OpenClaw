#!/bin/bash
# Capture the latest frame from the reCamera Gimbal and save it locally.
# RECAMERA_IP is read from the environment (set in openclaw.json); the literal
# value is only a fallback for standalone use.
RECAMERA_IP="${RECAMERA_IP:-192.168.16.1}"
OUT_FILE="${RECAMERA_PHOTO:-$HOME/.openclaw/workspace/latest_photo.jpg}"

mkdir -p "$(dirname "$OUT_FILE")"

echo "Fetching latest frame from camera..."
if curl -fsS -H "Cache-Control: no-cache" "http://${RECAMERA_IP}:1880/api/photo" -o "$OUT_FILE"; then
    echo "SUCCESS: Photo saved to physical path: $OUT_FILE"
    echo "SYSTEM INSTRUCTION: 1. Use your Vision tool to analyze this image. 2. In your final reply to the user, YOU MUST display this image using Markdown syntax: ![Camera View](file://${OUT_FILE})"
else
    echo "ERROR: Failed to capture photo. Check camera connection."
    exit 1
fi
