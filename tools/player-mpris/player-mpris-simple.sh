#!/bin/sh

player_status=$(playerctl status 2> /dev/null)

if [ "$player_status" = "Playing" ]; then
    echo "Playing: $(playerctl metadata artist) - $(playerctl metadata title)" | cut -c -50
elif [ "$player_status" = "Paused" ]; then
    echo "Paused: $(playerctl metadata artist) - $(playerctl metadata title)" | cut -c -50
else
    echo "No Media"
fi
