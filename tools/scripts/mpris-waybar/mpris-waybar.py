#!/usr/bin/env python3
"""Waybar custom module: MPRIS media player display with per-site cleanup.

Renders `{player icon} {status icon} {artist}: {track}` and emits one JSON
line per metadata/playback-status change. Long-lived (no interval) so Waybar
keeps it alive and re-renders on every line we print.

Data source: `playerctl -p playerctld -F metadata` (follow mode). The
`{{status}}` token at the start of the format template is load-bearing —
it's what makes playerctl's follow mode subscribe to playback-status
changes, so pause/play updates arrive without any polling. Do not remove
it. `{{position}}` is deliberately excluded (no progress tracking).

Usage:
  mpris-waybar.py            long-lived follow mode (for Waybar)
  mpris-waybar.py --once     print one JSON line for the current state
  mpris-waybar.py --debug    read \\x1f-separated metadata blobs from stdin,
                             render them (offline testing)
"""

import argparse
import json
import os
import signal
import subprocess
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from mpris_handlers import Track, load_handlers  # noqa: E402

# \x1f = ASCII unit separator; never collides with `|` or em-dashes in titles.
FORMAT = ("{{status}}\x1f{{playerName}}\x1f{{xesam:title}}\x1f{{xesam:artist}}"
          "\x1f{{xesam:album}}\x1f{{xesam:url}}\x1f{{mpris:artUrl}}")

FIELD_NAMES = ("status", "player", "title", "artist", "album", "url",
               "art_url")

# Prefix match handles Firefox instance names like `firefox.instance_1_56`.
PLAYER_ICONS = [("firefox", "🦊"), ("strawberry", "🍓"), ("mpv", "🎵")]
DEFAULT_PLAYER_ICON = "🌐"

STATUS_ICONS = {"playing": "▶", "paused": "⏸", "stopped": "⏹"}


# --------------------------------------------------------------------------
# Parsing / normalization
# --------------------------------------------------------------------------

def sanitize(field):
    """Newlines inside metadata would corrupt the line-based protocol."""
    return (field or "").replace("\n", " ").replace("\r", " ")


def parse_fields(line):
    parts = line.split("\x1f")
    parts += [""] * (len(FIELD_NAMES) - len(parts))
    return {name: sanitize(part) for name, part in zip(FIELD_NAMES, parts)}


def normalize_track(fields):
    """Run the handler chain; first handler whose URL matches wins."""
    for handler in load_handlers():
        patterns = getattr(handler, "URL_PATTERNS", [])
        url = fields.get("url", "")
        if patterns and not any(p.search(url) for p in patterns):
            continue
        track = handler.normalize(fields)
        if track is not None:
            return track
    return None


# --------------------------------------------------------------------------
# Rendering
# --------------------------------------------------------------------------

def player_icon(name):
    lowered = (name or "").lower()
    for prefix, icon in PLAYER_ICONS:
        if lowered.startswith(prefix):
            return icon
    return DEFAULT_PLAYER_ICON


def render(fields, track):
    """Return (text, tooltip, classes). Empty text hides the module."""
    status = (fields.get("status", "") or "").strip()
    status_key = status.lower()

    if status_key == "stopped":
        return "", "", []

    track = track or Track()
    p_icon = player_icon(fields.get("player", ""))
    s_icon = STATUS_ICONS.get(status_key, STATUS_ICONS["playing"])

    if track.title:
        body = f"{track.artist}: {track.title}" if track.artist else track.title
    elif track.album:
        body = f"{track.artist}: {track.album}" if track.artist else track.album
    else:
        return "", "", []

    text = f"{p_icon} {s_icon} {body}"

    lines = []
    if track.title:
        lines.append(f"Title: {track.title}")
    if track.artist:
        lines.append(f"Artist: {track.artist}")
    if track.album:
        lines.append(f"Album: {track.album}")
    lines.append(f"Player: {fields.get('player', '') or '?'} ({status or '?'})")
    tooltip = "\n".join(lines)

    classes = []
    if status_key == "paused":
        classes.append("paused")
    if track.site:
        classes.append(track.site)
    player = (fields.get("player", "") or "").strip()
    if player:
        classes.append(f"player-{player}")

    return text, tooltip, classes


def emit(text, tooltip="", classes=None):
    print(json.dumps({"text": text, "tooltip": tooltip,
                      "class": classes or []}, ensure_ascii=False))


def emit_empty():
    emit("", "", [])


# --------------------------------------------------------------------------
# Modes
# --------------------------------------------------------------------------

def run_once():
    """Print one JSON line for the current state, then exit."""
    for cmd in (["playerctl", "-p", "playerctld"],
                ["playerctl"]):
        try:
            result = subprocess.run(
                cmd + ["metadata", "--format", FORMAT],
                capture_output=True, text=True, timeout=5)
        except (subprocess.TimeoutExpired, FileNotFoundError):
            continue
        if result.returncode == 0 and result.stdout.strip():
            fields = parse_fields(result.stdout.strip())
            text, tooltip, classes = render(fields, normalize_track(fields))
            emit(text, tooltip, classes)
            return
    emit_empty()


def debug_mode():
    """Read \\x1f-separated metadata blobs from stdin; render each one.

    Accepts literal "\\x1f" escape sequences as well as real 0x1f bytes, so
    blobs can be typed in a shell. Line starting with '#' are comments.
    """
    for raw in sys.stdin:
        raw = raw.rstrip("\n")
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        line = raw.replace("\\x1f", "\x1f")
        fields = parse_fields(line)
        text, tooltip, classes = render(fields, normalize_track(fields))
        print(f"text   : {text!r}")
        print(f"tooltip: {tooltip!r}")
        print(f"class  : {classes}")
        print()


def follow_forever():
    """Supervise a playerctl follow stream; respawn on exit."""
    handlers = load_handlers()  # fail fast if a handler is broken
    use_playerctld = True

    while True:
        cmd = ["playerctl"] + (["-p", "playerctld"] if use_playerctld else [])
        cmd += ["-F", "metadata", "--format", FORMAT]
        try:
            proc = subprocess.Popen(cmd, stdout=subprocess.PIPE,
                                    stderr=subprocess.DEVNULL, text=True)
        except FileNotFoundError:
            emit_empty()
            sys.exit(1)

        got_output = False
        try:
            for line in proc.stdout:
                line = line.strip()
                if not line:
                    continue
                got_output = True
                fields = parse_fields(line)
                text, tooltip, classes = render(fields, normalize_track(fields))
                emit(text, tooltip, classes)
        except (BrokenPipeError, KeyboardInterrupt):
            pass
        finally:
            proc.terminate()
            try:
                proc.wait(timeout=2)
            except subprocess.TimeoutExpired:
                proc.kill()

        # Stream died. If the playerctld proxy never produced anything, fall
        # back to plain `playerctl -F` next time around.
        if use_playerctld and not got_output:
            use_playerctld = False

        emit_empty()
        time.sleep(1)


def _terminate(signum, _frame):
    sys.exit(0)


def main():
    sys.stdout.reconfigure(line_buffering=True)
    signal.signal(signal.SIGTERM, _terminate)
    signal.signal(signal.SIGINT, _terminate)

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--once", action="store_true",
                        help="print one JSON line for the current state")
    parser.add_argument("--debug", action="store_true",
                        help="render metadata blobs from stdin")
    args = parser.parse_args()

    if args.debug:
        debug_mode()
    elif args.once:
        run_once()
    else:
        follow_forever()


if __name__ == "__main__":
    main()
