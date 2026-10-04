"""Handler for YouTube / YouTube Music browser playback.

YouTube exposes the video title as `xesam:title` and the channel name as
`xesam:artist`. Music channels are YouTube's auto-generated
`Artist - Topic` channels, so that suffix is stripped from the artist.
"""

import re

from . import Track

URL_PATTERNS = [re.compile(r"youtube\.com", re.IGNORECASE),
                re.compile(r"youtu\.be", re.IGNORECASE)]

# YouTube's auto-generated artist channels are named `Artist - Topic`.
_TOPIC_SUFFIX = re.compile(r"\s*[-–]\s*Topic$", re.IGNORECASE)


def normalize(fields):
    artist = _TOPIC_SUFFIX.sub("", (fields.get("artist", "") or "").strip())
    album = fields.get("album", "") or ""
    title = fields.get("title", "") or ""
    if not (artist or album or title):
        return None
    return Track(artist=artist, album=album, title=title, site="youtube",
                 label="YouTube")
