#!/bin/bash
# Record audio from the reCamera microphone into /home/recamera/test.wav
RECAMERA_IP="${RECAMERA_IP:-192.168.16.1}"
RECAMERA_PASS="${RECAMERA_PASS:-recamera}"
DURATION="${1:-5}"

ssh -o StrictHostKeyChecking=no "recamera@${RECAMERA_IP}" "echo '${RECAMERA_PASS}' | sudo -S arecord -D hw:0,0 -r 16000 -f S16_LE -c 1 -d ${DURATION} /home/recamera/test.wav"
