# Changelog

All notable changes to this fork are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Baseline is the upstream Seeed release (skill `version: 1.2`).

## [2.0] - 2026-06-03

This is the first release of the **HanJammer fork** of Seeed's
`reCamera_Gimbal-OpenClaw`. It makes the skill cross-platform (Windows **and**
Linux), removes the Chinese-only content, fixes a couple of real bugs, and
documents the SSH-key model the scripts actually rely on.

### Added
- **Linux / bash support.** Every script now ships a `.sh` companion next to the
  existing `.ps1`: `control_led.sh`, `control_led_v2.sh`, `capture_photo.sh`,
  `record_audio.sh`, `play_audio.sh`.
- **SSH Key Setup** documentation — a dedicated section in `README.md` and a
  "First-Time Setup" section in `SKILL.md`, since the LED/audio scripts log in
  with a key (not a password). Includes an agent-driven option (let the OpenClaw
  agent generate and install the key).
- **Linux host variant throughout `README.md`**: prerequisites, install paths,
  a Linux `openclaw.json` block alongside the Windows one, script-path examples,
  and Linux-specific troubleshooting.
- `.gitattributes` enforcing **LF** line endings for `*.sh` (so they run on the
  device) and CRLF for `*.ps1`.

### Changed
- **Scripts read `RECAMERA_IP` / `RECAMERA_PASS` from the environment first**
  (as set in `openclaw.json`), falling back to built-in defaults only for
  standalone use. `openclaw.json` is now the single source of truth — no need to
  edit scripts.
- **`SKILL.md` fully translated to English** (frontmatter `description` included)
  and reorganized with a Windows-vs-Linux host-selection guide.
- Default device address changed to **`192.168.16.1`** (the actual default IP of
  the camera's broadcast hotspot).
- Default password changed to **`recamera`** (the device's real default login
  password).
- Skill `author` → `HanJammer (fork of seeed)`, `version` 1.2 → 2.0.

### Fixed
- **Audio scripts were swapped:** `play_audio` recorded and `record_audio`
  played. They now match their names and `SKILL.md` (`record_audio` records,
  `play_audio` plays back).

### Removed
- Chinese-language `README_zh.md`.
- Redundant/experimental LED scripts that duplicated `control_led` or did not
  work: `control_led_custom`, `control_led_demo`, `control_led_ps1`,
  `control_led_simple` (both `.ps1` and `.sh`). The maintained variants are
  `control_led` (canonical) and `control_led_v2` (scp + remote-script).

### Security
- Removed a hardcoded private LAN IP (`192.168.31.198`) that appeared to be a
  developer's personal camera address, replacing it with the documented hotspot
  default.
