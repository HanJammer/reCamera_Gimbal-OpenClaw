# Changelog

All notable changes to this fork are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Baseline is the upstream Seeed release (skill `version: 1.2`).

## [2.2] - 2026-06-04

Keep the agent's workspace clean. In testing, camera output (photos, sweep
captures, JSON, audio) was landing in the workspace root and cluttering it.

### Added
- **"Workspace Artifacts" section in `SKILL.md`** — instructs the runtime agent
  to write photos, sweep captures, JSON responses, and audio into a per-session
  scratch directory, never the workspace root.
- **`.gitignore`** for stray local capture artifacts (e.g. `latest_photo.jpg`),
  in case the smoke test or scripts are run from inside the repo.

### Changed
- **Photo capture now writes to a scratch directory** instead of the workspace
  root: `~/.openclaw/workspace/tmp/recamera-gimbal/` (Linux) /
  `%USERPROFILE%\.openclaw\workspace\tmp\recamera-gimbal\` (Windows). Updated in
  `SKILL.md` (Step 1/2) and in `capture_photo.{ps1,sh}`, which create the
  directory and save there (overridable via `RECAMERA_TMPDIR`, or a full path via
  `RECAMERA_PHOTO`). The capture helper's image markdown now points at the new
  path too.
- Skill `version` 2.1 → 2.2.

## [2.1] - 2026-06-04

Hardening pass driven by real-world OpenClaw agent testing of the 2.0 skill.
Focus: stop the agent from hanging on SSH, give it a bounded way to repair its
own access, and tighten the docs/config hygiene.

### Added
- **"SSH Bootstrap For LED/Audio" section in `SKILL.md`** — a precise, bounded
  procedure the runtime agent can follow to self-repair passwordless SSH when
  `RECAMERA_PASS` is present (test → keygen → `known_hosts` → install key →
  scoped `sudo` repair of `/home/recamera/.ssh` → re-verify), with explicit
  secret-handling safety rules and a matching exception in the operating rules.
- **`openclaw.example.json`** — a placeholder config fragment to copy into your
  real `openclaw.json`, so the README is no longer the only config source.
- **Security section** in `README.md` (don't commit real secrets, use
  placeholders).
- **Minimal photo smoke test** + real `curl` commands in the "Verify" step
  (replacing bare URLs that looked pasteable but were not commands), and a
  "Transport at a glance" table making the HTTP-vs-SSH split explicit.

### Changed
- **SSH/SCP calls in all scripts now pass `-o BatchMode=yes -o ConnectTimeout=5`**
  so they fail fast instead of hanging on a host-key / password / `sudo` prompt
  (a real failure mode seen in agent testing).
- **Expanded the `SKILL.md` SSH section** from the 2.0 "First-Time Setup" note
  into the full "SSH Bootstrap For LED/Audio" procedure (see Added).
- **Config docs clarified:** `skills.load.extraDirs` is optional — needed only
  when the skill lives outside the default `~/.openclaw/workspace/skills` folder;
  per-skill `env` always goes through `skills.entries.recamera-gimbal.env`.
- **README "Policy" now separates runtime-agent policy from maintainer access:**
  the "do not read/edit `scripts/`" rule constrains the executing agent, not
  maintainers.
- **Documented `control_led_v2` as a developer fallback** (scp + remote script)
  in both `README.md` and `SKILL.md`, so it is not mistaken for the default.
- **Normalized `README.md` whitespace** — removed the stray non-breaking spaces
  (`U+00A0`) in lists/tables that produced noisy diffs and rendering quirks.
- Kept the Seeed wiki link as-is (the `cpenclaw` slug is a real, working Seeed
  URL — verified; `openclaw` 404s) and documented that with a note.
- Skill `version` 2.0 → 2.1.

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
