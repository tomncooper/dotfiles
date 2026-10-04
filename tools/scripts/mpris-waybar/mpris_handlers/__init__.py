"""Handler package for mpris-waybar.

Defines the normalized `Track` type, then auto-discovers every handler
module in this package. A handler module is any module here that defines
`normalize(fields)`; it should also define `URL_PATTERNS` (a list of
compiled regexes matched against `xesam:url`). An empty `URL_PATTERNS`
means "always matches" (used by `default.py`).

Chain order: alphabetical by module name, with `default` always last.
Adding a new site = drop one file in this directory; nothing else changes.
"""

import importlib
import pkgutil
from dataclasses import dataclass
from typing import Optional


@dataclass
class Track:
    """Normalized metadata produced by a handler."""

    artist: str = ""
    album: str = ""
    title: str = ""
    site: Optional[str] = None  # handler name, e.g. "bandcamp"; None = unknown
    # Human-readable source name for the tooltip, e.g. "Tidal" or
    # "Bandcamp". None = fall back to the playing application name.
    label: Optional[str] = None


def load_handlers():
    """Import every submodule and return handler modules in chain order."""
    handlers = []
    for mod_info in pkgutil.iter_modules(__path__):
        mod = importlib.import_module(f".{mod_info.name}", __name__)
        if hasattr(mod, "normalize"):
            handlers.append(mod)
    # alphabetical, but `default` (the catch-all) always last
    handlers.sort(key=lambda m: (m.__name__.rsplit(".", 1)[-1] == "default",
                                 m.__name__))
    return handlers
