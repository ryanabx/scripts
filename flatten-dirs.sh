#!/usr/bin/env bash
set -euo pipefail

# Usage: ./collapse_subfolders.sh /path/to/Photos
BASE="$1"

# Remove trailing slash if present
BASE="${BASE%/}"

# Ensure it exists
if [[ ! -d "$BASE" ]]; then
    echo "Error: $BASE is not a directory"
    exit 1
fi

# Find all files under the base (excluding the base dir itself)
find "$BASE" -type f | while read -r FILE; do
    # Remove the base path prefix
    REL="${FILE#$BASE/}"

    # Replace slashes with hyphens
    NEWNAME="${REL//\//-}"

    # Build the final path
    TARGET="$BASE/$NEWNAME"

    # If the target file already exists, append numeric suffix
    if [[ -e "$TARGET" ]]; then
        i=1
        while [[ -e "${TARGET%.*}-$i.${TARGET##*.}" ]]; do
            ((i++))
        done
        TARGET="${TARGET%.*}-$i.${TARGET##*.}"
    fi

    echo "Moving:"
    echo "  $FILE → $TARGET"
    mv "$FILE" "$TARGET"
done

# Clean up empty directories
find "$BASE" -type d -empty -not -path "$BASE" -delete
