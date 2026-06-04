---
name: recamera-gimbal
description: Control a reCamera Gimbal edge AI camera. Supports gimbal rotation, LED control, audio recording/playback, and visual frame capture and analysis. Invoke this skill when the user asks to look around, find someone, identify an object, or take a photo.
metadata:
  author: HanJammer (fork of seeed)
  version: "2.2"
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

# SSH Bootstrap For LED/Audio
LED and audio commands require **passwordless SSH** as `recamera@$RECAMERA_IP`. Photo capture (`/api/photo`) and gimbal control go over HTTP and do **not** need SSH — never block those on an SSH problem. The device's default login user is `recamera` and default password `recamera`.

**Always test SSH before the first LED/audio command of a session:**
```bash
ssh -o BatchMode=yes -o ConnectTimeout=5 recamera@$RECAMERA_IP "echo ok"
```
If it prints `ok`, proceed. If it fails (`Permission denied`, timeout, or it would otherwise hang), you MAY bootstrap SSH access — **but only when `RECAMERA_PASS` is present in the skill environment**.

Bootstrap steps (Linux host shown; on Windows use the equivalent paths under `$env:USERPROFILE\.ssh`):

1. Ensure a local key exists (no passphrase):
   ```bash
   test -f ~/.ssh/id_ed25519.pub || ssh-keygen -t ed25519 -C "openclaw-recamera" -N "" -f ~/.ssh/id_ed25519
   ```
2. Add the camera host key if missing (prevents the interactive `known_hosts` prompt that would hang you):
   ```bash
   mkdir -p ~/.ssh && chmod 700 ~/.ssh
   ssh-keygen -F "$RECAMERA_IP" >/dev/null || ssh-keyscan -H "$RECAMERA_IP" >> ~/.ssh/known_hosts
   ```
3. Install the public key on the camera using the owner-provided `RECAMERA_PASS` (prefer `ssh-copy-id`, or `sshpass -e ssh-copy-id` with `SSHPASS` taken from `$RECAMERA_PASS`). Read the password from the environment only — do **not** print it, place it in command arguments, put it in shell history, or repeat it in your final answer.
4. If a normal user-level install fails with permission errors on `/home/recamera/.ssh`, you MAY use `sudo -S` on the camera with `RECAMERA_PASS` to repair **only that path** — nothing else. Allowed remote scope:
   ```bash
   mkdir -p /home/recamera/.ssh
   touch /home/recamera/.ssh/authorized_keys
   # append the local public key to authorized_keys if missing
   chown -R recamera:recamera /home/recamera/.ssh
   chmod 700 /home/recamera/.ssh
   chmod 600 /home/recamera/.ssh/authorized_keys
   ```
5. Verify again and proceed with LED/audio **only after** this prints `ok`:
   ```bash
   ssh -o BatchMode=yes -o ConnectTimeout=5 recamera@$RECAMERA_IP "echo ok"
   ```

**Safety rules for SSH bootstrap**
* Use `RECAMERA_PASS` only from the environment/config.
* Never echo, log, memorize, or include the password in replies.
* Do not make broad remote changes; only repair `/home/recamera/.ssh` ownership/permissions when needed.
* Do not run unrelated `sudo` commands on the camera.
* If login still fails after one repair attempt, stop and report the exact non-secret error.

# ⚠️ CRITICAL OPERATING RULES
1. NEVER use the read or edit tools to view or modify files under the scripts directory.
2. Only use Exec to run the specific commands provided below. Do not invent your own interfaces.
   * **Exception:** the SSH bootstrap commands in "SSH Bootstrap For LED/Audio" above are allowed, but only to set up the passwordless SSH that LED/audio require.

# Workspace Artifacts
Keep camera output out of the workspace root. Use this per-session scratch directory for photos, sweep captures, JSON responses, and other temporary gimbal artifacts:

* Linux: `$HOME/.openclaw/workspace/tmp/recamera-gimbal/`
* Windows: `%USERPROFILE%\.openclaw\workspace\tmp\recamera-gimbal\`

Create the directory before saving files. Do not write `gimbal_*`, `latest_photo*`, audio captures, or sweep outputs directly into the workspace root.

# Device Capabilities & Operating Guide

## 1. Vision & Capture
When the user asks to "look", "find someone", "identify", or "take a photo", follow these steps:
* **Step 1 (Get the frame)**: Use Exec to fetch the latest frame into the scratch directory.
  * Windows: `New-Item -ItemType Directory -Force "$env:USERPROFILE\.openclaw\workspace\tmp\recamera-gimbal" | Out-Null; Invoke-WebRequest -Uri "http://<DEVICE_IP>:1880/api/photo" -Headers @{"Cache-Control" = "no-cache"} -OutFile "$env:USERPROFILE\.openclaw\workspace\tmp\recamera-gimbal\latest_photo.jpg"`
  * Linux: `mkdir -p "$HOME/.openclaw/workspace/tmp/recamera-gimbal" && curl -fsS -H "Cache-Control: no-cache" "http://<DEVICE_IP>:1880/api/photo" -o "$HOME/.openclaw/workspace/tmp/recamera-gimbal/latest_photo.jpg"`
  * (Either host can also run the bundled helper: `capture_photo.ps1` / `capture_photo.sh`, which save to the same scratch directory.)
* **Step 2 (Analyze)**: Use your Vision/Image tool to read and carefully analyze the saved `tmp/recamera-gimbal/latest_photo.jpg`.
* **Step 3 (Reply — VERY IMPORTANT!)**: Your final reply to the user **must output the image tag in exactly the format below**. Do not change any punctuation!

Output format:
\!\[Camera View\]\(http://<DEVICE_IP>:1880/api/photo?t=$RANDOM\)

📸 **Frame analysis**:
[your analysis here]

## 2. Fill Light (LED)
This uses SSH — if it is the first SSH-based command of the session, run the "SSH Bootstrap For LED/Audio" test first.
* **Windows**
  * On:  `powershell -ExecutionPolicy Bypass -File C:\Users\seeed\.openclaw\workspace\skills\recamera-gimbal\scripts\control_led.ps1 -Action on`
  * Off: `powershell -ExecutionPolicy Bypass -File C:\Users\seeed\.openclaw\workspace\skills\recamera-gimbal\scripts\control_led.ps1 -Action off`
* **Linux**
  * On:  `bash ~/.openclaw/workspace/skills/recamera-gimbal/scripts/control_led.sh on`
  * Off: `bash ~/.openclaw/workspace/skills/recamera-gimbal/scripts/control_led.sh off`

Use `control_led` (above) by default. `control_led_v2` is a developer fallback (copies a temp script via `scp` then runs it on the device) — only use it if inline `sudo -S` over SSH misbehaves on the firmware.

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
