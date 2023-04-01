#!/usr/bin/env bash

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use 
polybar-msg cmd quit
# Otherwise you can use the nuclear option:
# killall -q polybar

# Launch the bars
echo "---" | tee -a /tmp/mainbar.log
echo "---" | tee -a /tmp/topbar.log
polybar mainbar 2>&1 | tee -a /tmp/mainbar.log & disown
polybar topbar 2>&1 | tee -a /tmp/topbar.log & disown

echo "Bars launched..."
