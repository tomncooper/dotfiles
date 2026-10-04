"""Handler for tidal.com browser playback.

Tidal supplies proper `xesam:artist` / `xesam:album` / `xesam:title`, so
this handler is a pass-through. It exists mainly as the template for new
site handlers: copy it, adjust URL_PATTERNS, add parsing in normalize().
"""

import re

from . import Track

URL_PATTERNS = [re.compile(r"tidal\.com", re.IGNORECASE)]


def normalize(fields):
    artist = fields.get("artist", "") or ""
    album = fields.get("album", "") or ""
    title = fields.get("title", "") or ""
    if not (artist or album or title):
        return None
    return Track(artist=artist, album=album, title=title, site="tidal",
                 label="Tidal")
