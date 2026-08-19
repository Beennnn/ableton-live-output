# ableton-live-output

**Set Ableton Live's audio output device from the command line, on macOS — in the
running app, without quitting or restarting it.**

```bash
live-output                  # what Live is playing out of right now
live-output --list           # every output Live offers (✔ marks the current one)
live-output "P-Series"       # switch to the first output whose name contains this
```

```
$ live-output --list
No Device
Utiliser interface du système
Background Music (2 In, 2 Out)
Haut-parleurs MacBook Pro (0 In, 2 Out)
✔ P-Series (2 In, 2 Out)

$ live-output MacBook
OK: Haut-parleurs MacBook Pro (0 In, 2 Out)
```

## Why this exists

There is no supported way to do this. Live has **no AppleScript dictionary**, its
`Preferences.cfg` stores the device in a **binary blob** (UTF-16 keys, no readable device
name) that Live rewrites when it quits — so editing it under a running Live achieves
nothing — and Live's Python API (control surfaces) doesn't reach the audio hardware.

What is left is the accessibility layer, and Live 12 exposes it properly: the settings
window publishes its pop-up buttons, and the device list is enumerable. This script drives
that, and verifies the value actually changed before reporting success.

The use case it was written for: a laptop rig where the audio interface changes between
the desk and the stage, and where discovering at the first note that Live is still on
`No Device` is not an option.

## Install

```bash
git clone https://github.com/Beennnn/ableton-live-output.git
cd ableton-live-output && ./install.sh      # symlinks into ~/.local/bin
```

Then allow the terminal (or whatever calls it) in **System Settings → Privacy & Security
→ Accessibility**. Without that, macOS blocks the UI queries and the script reports that
it cannot see Live.

## What it does not read

It never touches Live's language: window and tab titles follow the UI language, so relying
on them would break the day the interface is translated. The audio page is found by
**structure** — it is the only settings page holding three pop-up buttons (driver type,
input device, output device) — and the output is the third from the top.

## Exit codes

| code | meaning |
|---|---|
| 0 | done, or state printed |
| 1 | bad usage, or Live is not running |
| 2 | no output matches the pattern |
| 3 | the change did not take |

Machine-readable on purpose: the caller should not have to parse a French sentence.

## Tested on

Live 12.4.2, macOS 26 (Tahoe), Apple Silicon. Live 11 and earlier expose a different
accessibility tree and are **not** supported.

## Licence

MIT.
