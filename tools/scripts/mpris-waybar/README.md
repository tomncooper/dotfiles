# mpris-waybar

Custom Waybar module replacing the built-in `mpris` module. Renders:

```
{player icon} {status icon} {artist}: {track}
```

with **pluggable, per-site cleanup logic**, fixing Bandcamp browser titles
that embed play/pause icons (`▶︎ In Moments | Slowe`) and pipe-separated
`Album | Artist` formats.

| Source              | Bar text                                        |
|---------------------|-------------------------------------------------|
| Bandcamp album page | `🦊 ▶ Slowe: In Moments`                        |
| Tidal               | `🦊 ▶ Incubus: Wish You Were Here`              |
| Strawberry          | `🍓 ▶ The Tiberian Sons: Dual Wielder [AC7]`    |

The album is shown in place of the track name when no track name is
available (Bandcamp album-page view) and is otherwise omitted from bar
text (it appears in the tooltip). No progress/position display — the
module is fully event-driven.

## How it works

`mpris-waybar.py` supervises a long-lived `playerctl -p playerctld -F
metadata` stream. `playerctld` (auto-activated via D-Bus on Fedora, no
unit needed) proxies the most recently active player, so the stream
survives Firefox/Strawberry restarts. Plain `playerctl -F` is used as a
fallback if the daemon never produces output.

Each metadata line is `\x1f`-separated into fields, passed through the
**handler chain** in `mpris_handlers/`, and rendered as one JSON line:

```json
{"text": "🦊 ▶ Slowe: In Moments", "tooltip": "...", "class": ["bandcamp", "player-firefox"]}
```

Empty `text` hides the module (no active player / Stopped).

> **Note:** `{{status}}` must stay first in the playerctl format template —
> it's what subscribes playerctl's follow mode to playback-status changes,
> so pause/play updates arrive without polling.

## Click / scroll controls

Configured in `~/.config/waybar/config.jsonc` (`custom/mpris`):

- left click: play-pause
- middle click: previous
- right click: next
- scroll up/down: `playerctld shift` / `unshift` (cycle active player)

`exec-on-event: false` is required so Waybar doesn't restart the daemon
on every interaction.

## Adding a site handler

Drop a new file in `mpris_handlers/`. It is auto-discovered (alphabetical
order, `default.py` always last). Template — copy `tidal.py`:

```python
import re
from . import Track

URL_PATTERNS = [re.compile(r"example\.com", re.IGNORECASE)]

def normalize(fields):
    # fields: status, player, title, artist, album, url, art_url
    return Track(artist=fields["artist"], album=fields["album"],
                 title=fields["title"], site="example")
```

Return `None` from `normalize()` to decline and let the next handler try.

## Testing

Offline (no player needed) — feed `\x1f`-separated metadata blobs:

```sh
printf 'Playing\x1ffirefox\x1f▶︎ In Moments | Slowe\x1f\x1f\x1fhttps://x.bandcamp.com/album/in-moments\x1f\n' \
  | ./mpris-waybar.py --debug
```

One-shot current state:

```sh
./mpris-waybar.py --once
```

Live (Waybar): `swaymsg reload` and watch the module. Restarted players
respawn the stream automatically (1 s backoff).
