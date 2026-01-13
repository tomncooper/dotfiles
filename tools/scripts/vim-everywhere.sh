#!/bin/bash

# VIM Everywhere 
# Inspired by: https://github.com/cknadler/vim-anywhere
# This script allows you to open a temporary file in gvim, edit it,
# and then copy the contents back to the clipboard.

# Check if gvim is installed
if ! command -v gvim &> /dev/null; then
    echo "Error: gvim is not installed. Please install it first." >&2
    exit 1
fi

# Check if wl-copy is installed
if ! command -v wl-copy &> /dev/null; then
    echo "Error: wl-copy is not installed. Please install the wl-clipboard package." >&2
    exit 1
fi

TMPFILE=$(mktemp /tmp/vim-everywhere.XXXXXX)
chmod o-r $TMPFILE # Make file only readable by you

gvim --nofork $TMPFILE

wl-copy --trim-newline < $TMPFILE

