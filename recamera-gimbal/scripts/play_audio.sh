#!/bin/bash
# Play back the recorded audio (/home/recamera/test.wav) on the reCamera speaker
RECAMERA_IP="${RECAMERA_IP:-192.168.16.1}"
RECAMERA_PASS="${RECAMERA_PASS:-recamera}"

ssh -o StrictHostKeyChecking=no "recamera@${RECAMERA_IP}" "echo '${RECAMERA_PASS}' | sudo -S aplay -D hw:1,0 /home/recamera/test.wav"
