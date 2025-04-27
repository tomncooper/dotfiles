#!/bin/bash

# Exit on any error
set -e

# Function to display usage
usage() {
    echo "Usage: $0 <string-to-add> <path-to-desktop-file>"
    exit 1
}

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    usage
fi

STRING_TO_ADD="$1"
DESKTOP_FILE="$2"

# Check if the specified file exists
if [ ! -f "$DESKTOP_FILE" ]; then
    echo "Error: Specified .desktop file does not exist."
    exit 1
fi

# Escape special characters in the supplied string for grep
ESCAPED_STRING=$(echo "$STRING_TO_ADD" | sed -e 's/[]\/$*.^[]/\\&/g')

# Check if the string is already present in the Exec command
if grep -qE "Exec=.*${ESCAPED_STRING}.*" "$DESKTOP_FILE"; then
    echo "The string '$STRING_TO_ADD' is already present in the Exec command of $DESKTOP_FILE."
    exit 0
fi

# Use sed to modify the Exec line in the .desktop file
sed -i.bak -E "s|^(Exec=[^ ]+)(.*%U)|\1 $STRING_TO_ADD\2|" "$DESKTOP_FILE"

if [ $? -eq 0 ]; then
    echo "Successfully updated the Exec command in $DESKTOP_FILE."
    echo "A backup of the original file has been created as $DESKTOP_FILE.bak."
else
    echo "Failed to update the Exec command in $DESKTOP_FILE."
    exit 1
fi
