""" Displays the Swatch internet time (.beat) in Waybar compatible JSON """

import json
import math

from datetime import datetime, timezone


def current_beattime(utc_offset):
    """ Calculate the current Swatch internet time (.beat) based on the provided UTC offset. """

    # Present day, Present time
    time_utc = datetime.now(timezone.utc)

    # Present day, Present seconds
    present_second = (
        time_utc.hour * 3600 +
        time_utc.minute * 60 +
        time_utc.second +
        (time_utc.microsecond / 1e6)
    )

    # TimeZone application
    present_second = (present_second + (utc_offset * 3600) + 86400) % 86400

    # Convert to beat
    beats = (present_second / 86400) * 1000

    # Truncate to 2 decimal places (centibeats) per Swatch spec
    beats = math.floor(beats * 100) / 100
    beats = beats % 1000

    return f'@{beats:06.2f}'


if __name__ == "__main__":
    try:
        # Time Zone
        UTC_OFFSET = 1
        beat_time = current_beattime(UTC_OFFSET)

        output = {
            "text": beat_time,
            "tooltip": "Current beat time"
        }
        print(json.dumps(output))

    except (ValueError, TypeError, OSError) as e:

        # In case of error, output empty JSON to avoid JSON errors in Waybar
        output = {
            "text": "Error",
            "tooltip": f"Script error: {str(e)}"
        }
        print(json.dumps(output))
