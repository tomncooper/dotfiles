"""Fallback handler: local players (strawberry, mpv, …) and unknown sites.

Always matches. Proper local players supply correct metadata fields, so
those pass through unchanged. If the fields are empty but the title looks
like an unknown browser site's page title (leading status icons and/or a
`title | artist` pipe format), apply conservative cleanup.
"""

import re

from . import Track

URL_PATTERNS = []  # empty = always matches

# Same leading-icon set as bandcamp.py.
_LEADING_ICONS = re.compile(
    r"^(?:[\u25b6\u25b7\u23f8\u23f9\u23fa\u25cf\u2759\u275a][\ufe0e\ufe0f]?"
    r"|❚❚)+\s*"
)

SEPARATOR = " | "


def normalize(fields):
    artist = fields.get("artist", "") or ""
    album = fields.get("album", "") or ""
    title = _LEADING_ICONS.sub("", fields.get("title", "") or "").strip()

    # Unknown browser site: metadata only lives in the page title.
    if not artist and not album and SEPARATOR in title:
        left, right = (part.strip() for part in title.split(SEPARATOR, 1))
        title, artist = left, right

    if not (artist or album or title):
        return None

    return Track(artist=artist, album=album, title=title, site=None)
