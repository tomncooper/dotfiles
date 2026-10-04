"""Handler for bandcamp.com browser playback.

Bandcamp puts everything it wants to show into `xesam:title`, sometimes
prefixed with a status icon (e.g. `▶︎ In Moments | Slowe`) and formatted as
`Left | Right` where Right is the artist. Which side is the track name
depends on the page type in the URL:

- `/album/...`  → Left is the *album* name (no track name available)
- `/track/...`  → Left is the *track* name
- anything else → treat Left as the track name
"""

import re

from . import Track

URL_PATTERNS = [re.compile(r"bandcamp\.com", re.IGNORECASE)]

# Leading play/pause/stop/record icons Bandcamp embeds in titles, including
# the emoji variation selectors U+FE0E / U+FE0F (e.g. `▶︎` = U+25B6 U+FE0E).
_LEADING_ICONS = re.compile(
    r"^(?:[\u25b6\u25b7\u23f8\u23f9\u23fa\u25cf\u2759\u275a][\ufe0e\ufe0f]?"
    r"|❚❚)+\s*"
)

SEPARATOR = " | "


def _clean_title(raw):
    """Strip leading status icons and surrounding whitespace."""
    return _LEADING_ICONS.sub("", raw or "").strip()


def normalize(fields):
    raw_title = _clean_title(fields.get("title", ""))
    url = fields.get("url", "") or ""

    artist = fields.get("artist", "") or ""
    album = fields.get("album", "") or ""
    title = ""

    if SEPARATOR in raw_title:
        left, right = (part.strip() for part in raw_title.split(SEPARATOR, 1))
        if "/album/" in url:
            # Album page: no track name available; Left is the album.
            album = album or left
        else:
            title = left
        artist = artist or right
    else:
        title = raw_title

    if not (artist or album or title):
        return None

    return Track(artist=artist, album=album, title=title, site="bandcamp",
                 label="Bandcamp")
