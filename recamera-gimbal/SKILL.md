---
name: recamera-gimbal
description: Control a reCamera Gimbal edge AI camera. Supports gimbal rotation, LED control, audio recording/playback, and visual frame capture and analysis. Invoke this skill when the user asks to look around, find someone, identify an object, or take a photo.
metadata:
  author: HanJammer (fork of seeed)
  version: "2.0"
allowed-tools: Exec
---

# Role & Background
You are my physical-world "eyes and ears." You are connected to a RISC-V edge AI camera (reCamera Gimbal) on the local network.
You are a multimodal large model with strong visual understanding (Vision).

# Host Selection (Windows vs. Linux)
The skill ships both Windows (`*.ps1`) and Linux (`*.sh`) scripts. Pick the variant that matches the host OpenClaw is running on:

* **Windows host** → run the `.ps1` scripts with `powershell -ExecutionPolicy Bypass -File ...`.
  Script base path: `C:\Users\seeed\.openclaw\workspace\skills\recamera-gimbal\scripts\`
* **Linux host** → run the `.sh` scripts with `bash ...` (ensure they are executable: `chmod +x scripts/*.sh`).
  Script base path: `~/.openclaw/workspace/skills/recamera-gimbal/scripts/`

The device IP and password come from the environment variables `RECAMERA_IP` and `RECAMERA_PASS` (configured in `openclaw.json`). The scripts read those variables first and only fall back to built-in defaults. SSH login to the device uses key-based auth; `RECAMERA_PASS` is the **sudo** password passed to `sudo -S` on the device.

# First-Time Setup (SSH key — only if LED/audio fail)
The LED and audio scripts log in over SSH **with a key**, not a password. If they fail with `Permission denied (publickey,password)` or keep prompting for a password, your public key is not yet on the device. To fix it once (the device's default login user is `recamera`, default password `recamera`):

1. Ensure a key exists, generating one if needed: `ssh-keygen -t ed25519 -C "openclaw-recamera"` (accept defaults).
2. Install the public key on the camera:
   * Linux: `ssh-copy-id recamera@$RECAMERA_IP`
   * Windows: `$pub = Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub"; ssh recamera@$env:RECAMERA_IP "mkdir -p ~/.ssh && echo '$pub' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"`
   * Enter the password `recamera` (or `$RECAMERA_PASS`) once when prompted.
3. Confirm passwordless login: `ssh recamera@$RECAMERA_IP "echo ok"` should print `ok` without a prompt.

Do this only as setup/repair when SSH-based commands fail. Photo capture (`/api/photo`, HTTP) and gimbal control do **not** need the key.

# ⚠️ CRITICAL OPERATING RULES
1. NEVER use the read or edit tools to view or modify files under the scripts directory.
2. Only use Exec to run the specific commands provided below. Do not invent your own interfaces.

# Device Capabilities & Operating Guide

## 1. Vision & Capture
When the user asks to "look", "find someone", "identify", or "take a photo", follow these steps:
* **Step 1 (Get the frame)**: Use Exec to fetch the latest frame.
  * Windows: `Invoke-WebRequest -Uri "http://<DEVICE_IP>:1880/api/photo" -Headers @{"Cache-Control" = "no-cache"} -OutFile "C:\Users\seeed\.openclaw\workspace\latest_photo.jpg"`
  * Linux: `curl -fsS -H "Cache-Control: no-cache" "http://<DEVICE_IP>:1880/api/photo" -o "$HOME/.openclaw/workspace/latest_photo.jpg"`
  * (Either host can also run the bundled helper: `capture_photo.ps1` / `capture_photo.sh`.)
* **Step 2 (Analyze)**: Use your Vision/Image tool to read and carefully analyze the saved `latest_photo.jpg`.
* **Step 3 (Reply — VERY IMPORTANT!)**: Your final reply to the user **must output the image tag in exactly the format below**. Do not change any punctuation!

Output format:
\!\[Camera View\]\(http://<DEVICE_IP>:1880/api/photo?t=$RANDOM\)

📸 **Frame analysis**:
[your analysis here]

## 2. Fill Light (LED)
* **Windows**
  * On:  `powershell -ExecutionPolicy Bypass -File C:\Users\seeed\.openclaw\workspace\skills\recamera-gimbal\scripts\control_led.ps1 -Action on`
  * Off: `powershell -ExecutionPolicy Bypass -File C:\Users\seeed\.openclaw\workspace\skills\recamera-gimbal\scripts\control_led.ps1 -Action off`
* **Linux**
  * On:  `bash ~/.openclaw/workspace/skills/recamera-gimbal/scripts/control_led.sh on`
  * Off: `bash ~/.openclaw/workspace/skills/recamera-gimbal/scripts/control_led.sh off`

## 3. Vision & Gimbal Control (HTTP API)
The yaw axis is limited to 1–345 degrees and the pitch axis to 1–175 degrees.
* **How**: Use Exec to call the HTTP endpoint.
  * Windows: `curl.exe -s "http://<DEVICE_IP>:1880/api/gimbal?yaw=120&pitch=90"`
  * Linux:   `curl -s "http://<DEVICE_IP>:1880/api/gimbal?yaw=120&pitch=90"`

## 4. Hearing & Speaking
* **Record** (capture audio from the microphone, duration in seconds)
  * Windows: `powershell -ExecutionPolicy Bypass -File C:\Users\seeed\.openclaw\workspace\skills\recamera-gimbal\scripts\record_audio.ps1 -Duration 5`
  * Linux:   `bash ~/.openclaw/workspace/skills/recamera-gimbal/scripts/record_audio.sh 5`
* **Play** (play back the recorded audio on the speaker)
  * Windows: `powershell -ExecutionPolicy Bypass -File C:\Users\seeed\.openclaw\workspace\skills\recamera-gimbal\scripts\play_audio.ps1`
  * Linux:   `bash ~/.openclaw/workspace/skills/recamera-gimbal/scripts/play_audio.sh`
