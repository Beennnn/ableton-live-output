# ableton-live-output

**Switch Ableton Live's audio output device from the command line, on macOS — in the
running app, without quitting or restarting it.**

```bash
live-output                  # what Live is playing out of right now
live-output --list           # every output Live offers (✔ marks the current one)
live-output "P-Series"       # switch to the first output whose name contains this
```

```
$ live-output --list
No Device
Use System Interface
Background Music (2 In, 2 Out)
MacBook Pro Speakers (0 In, 2 Out)
✔ P-Series (2 In, 2 Out)

$ live-output MacBook
OK: MacBook Pro Speakers (0 In, 2 Out)
```

## The problem

In Live, changing the audio output is a **manual trip through a dialog**: Settings →
Audio → Audio Output Device, pick from the menu, close. Every time. There is no shortcut
to bind, no MIDI mapping, no menu item, nothing to click on the way past.

That is an annoyance at a desk. It is a different thing entirely on stage, where the
output changes between soundcheck and set, where a laptop that woke up on the wrong
device produces silence at the first note, and where nobody is going to open a settings
dialog in front of an audience. It cannot be scripted into a bring-up routine, cannot be
folded into a "get the rig ready" button, cannot be checked and repaired automatically —
**unless something drives that dialog for you. That is what this is.**

Worth knowing before you reach for something cleaner: there is nothing cleaner.

| Route | Why it doesn't work |
|---|---|
| AppleScript | Live ships **no scripting dictionary** — no `.sdef` in the bundle |
| `Preferences.cfg` | Binary, UTF-16 keys, and **the device name is not in it in readable form**. Live also rewrites the file when it quits, so editing it under a running Live changes nothing |
| Live's Python API | Control-surface scripts reach tracks, clips and devices — **not the audio hardware** |
| Max for Live | Same limit: it lives inside the audio engine, it does not choose it |

What is left is the accessibility layer, and Live 12 exposes it properly: the settings
window publishes its pop-up buttons and the device list is enumerable. This script drives
that, then **reads the value back** to confirm the change actually took before reporting
success.

## Install

```bash
git clone https://github.com/Beennnn/ableton-live-output.git
cd ableton-live-output && ./install.sh      # symlinks into ~/.local/bin
```

Then allow whatever **calls** the script in **System Settings → Privacy & Security →
Accessibility**. That permission is granted per calling process, and it does not carry
over: a terminal you authorised does nothing for a background service that runs the same
script. When it is missing you get exit code 4 and a line telling you so, rather than an
AppleScript error number.

**Accessibility alone is enough** — the script never needs *Input Monitoring* or a second
"send keystrokes" grant. It used to: `⌘,` opened the settings window and `esc` dismissed a
drop-down, and both are keystrokes, which macOS gates separately from reading the
interface. A process holding only the read grant therefore failed every time while
everything else about it worked. Both are now done through the accessibility tree — a
click on the menu item, and `AXCancel` on the open menu — with the keystroke kept only as
a fallback.

## It does not read a single translated string

Window and tab titles follow Live's UI language, so relying on them would break the day
the interface is in another language. The audio page is found by **structure** — it is
the only settings page holding three pop-up buttons (driver type, input device, output
device) — and the output is the third from the top. The device names themselves come from
CoreAudio, and are matched as a substring, case-insensitively (AppleScript's `contains`).

## Exit codes

| code | meaning |
|---|---|
| 0 | done, or state printed |
| 1 | bad usage, or Live is not running |
| 2 | no output matches the pattern |
| 3 | the change did not take |
| 4 | the caller lacks Accessibility permission |

Code 4 covers the same refusal seen from three angles, because the repair is identical in
all three: `-25211` (reading the interface denied), `1002` (sending input denied) and
`-1743` (sending Apple events denied).

Machine-readable on purpose: a caller should never have to parse a sentence.

## Two traps this already walks around

**One permission where two were being asked for.** See the install note above: opening
settings and closing a drop-down went through keystrokes, which macOS grants separately
from reading the interface. The menu item is clicked at **position 3** rather than by its
label (`About Live | — | Settings… | — | Services | …`), which keeps the rule this
project holds to: never depend on a translated string.

**Waiting for a delay instead of for the thing.** Opening the settings window takes up to
three seconds; a fixed pause is wrong both ways — too short and the first call fails, too
long and every call drags. The script polls until the element exists. The symptom before
that fix was distinctive: the first call failed, the next two worked, because they found
the window already open.

**A here-document inside `$( )`.** Bash 3.2 — the `/bin/bash` that macOS ships, and the
one a launchd service gets — rejects it: *unexpected EOF while looking for matching `'`*.
Homebrew's bash 5 accepts it. So the script ran fine from a terminal and failed only when
called by a service. It now writes through a temporary file instead.

## Tested on

Live 12.4.2, macOS 26 (Tahoe), Apple Silicon. Live 11 and earlier expose a different
accessibility tree and are **not** supported.

## Licence

MIT.
