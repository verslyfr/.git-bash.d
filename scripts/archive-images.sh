#!/bin/bash
# ==============================================================================
# Archive Images Script
# ==============================================================================
#
# Purpose:
#   Archives selected image files or folders, preserving directory structure 
#   relative to a root folder. Supports processing history tracking and 
#   handling of .originals/.picasaoriginals subfolders.
#
# Usage:
#   ./archive-images.sh -a <archive_folder> -r <root_folder> <file_or_folder>...
#
# Dependencies:
#   - yq, fd, fzf, rsync
#
# ==============================================================================

# Default variables
ARCHIVE_DIR=""
ROOT_DIR=""

# Function to display usage
usage() {
    echo "Usage: $0 -a <archive_folder> -r <root_folder> <target>..."
    exit 1
}

# Parse options
while getopts ":a:r:" opt; do
  case $opt in
    a) ARCHIVE_DIR="$OPTARG" ;;
    r) ROOT_DIR="$OPTARG" ;;
    \?) echo "Invalid option -$OPTARG" >&2; usage ;;
  esac
done

shift $((OPTIND-1))

# Check mandatory arguments
if [ -z "$ARCHIVE_DIR" ] || [ -z "$ROOT_DIR" ] || [ $# -eq 0 ]; then
    usage
fi

# Ensure absolute paths
ARCHIVE_DIR=$(realpath "$ARCHIVE_DIR")
ROOT_DIR=$(realpath "$ROOT_DIR")
HISTORY_FILE="$ARCHIVE_DIR/processed_history.json"

# Initialize history file if missing
if [ ! -f "$HISTORY_FILE" ]; then
    echo "[]" > "$HISTORY_FILE"
fi

# Function to check history
check_history() {
    local folder="$1"
    # Check if folder is in history array
    yq -e ".[] | select(. == \"$folder\")" "$HISTORY_FILE" >/dev/null 2>&1
}

# Function to add to history
add_to_history() {
    local folder="$1"
    # Append to history array if not present
    if ! check_history "$folder"; then
        yq -i ". += [\"$folder\"]" "$HISTORY_FILE"
    fi
}

ALL_FILES=""
PROCESSED_DIRS=()

# Iterate over targets to build file list
for TARGET in "$@"; do
    TARGET=$(realpath "$TARGET")
    
    if [ -d "$TARGET" ]; then
        # --- Folder Handling ---
        
        # Calculate relative path from ROOT_DIR
        REL_PATH="${TARGET#$ROOT_DIR/}"
        
        # Check history
        if check_history "$REL_PATH"; then
            read -p "Folder '$REL_PATH' already processed. Reprocess? [y/N] " confirm
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                echo "Skipping '$REL_PATH'."
                continue
            fi
        fi
        
        PROCESSED_DIRS+=("$REL_PATH")

        echo "Scanning for images in '$TARGET'..."
        
        # Build file list (non-recursive in main folder)
        FILES=$(fd -t f -e jpg -e jpeg -e png -e gif -e bmp -e tiff -e webp -e heic -e raw -e nef -e cr2 -e arw -e dng --max-depth 1 . "$TARGET")
        
        if [ -n "$FILES" ]; then
            ALL_FILES="$ALL_FILES"$'\n'"$FILES"
        fi
        
        # Check subfolders: .original, .originals, .picasaoriginals
        for sub in ".original" ".originals" ".picasaoriginals"; do
            if [ -d "$TARGET/$sub" ]; then
                SUB_FILES=$(fd -t f -e jpg -e jpeg -e png -e gif -e bmp -e tiff -e webp -e heic -e raw -e nef -e cr2 -e arw -e dng --max-depth 1 . "$TARGET/$sub")
                if [ -n "$SUB_FILES" ]; then
                    ALL_FILES="$ALL_FILES"$'\n'"$SUB_FILES"
                fi
            fi
        done
        
    elif [ -f "$TARGET" ]; then
        # --- Single File Handling ---
        ALL_FILES="$ALL_FILES"$'\n'"$TARGET"
    else
        echo "Target not found: $TARGET"
    fi
done

# Trim leading newline
ALL_FILES="${ALL_FILES#$'\n'}"

if [ -z "$ALL_FILES" ]; then
    echo "No files found to process."
    exit 0
fi

# Run FZF for selection
# Use generic preview if scripts/fzf-preview.sh is not found in local dir
# but we know it's in the repo structure relative to this script.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PREVIEW_CMD="$SCRIPT_DIR/fzf-preview.sh {}"

SELECTED=$(echo "$ALL_FILES" | fzf -m --preview-window nohidden --preview "$PREVIEW_CMD")

if [ -n "$SELECTED" ]; then
    echo "$SELECTED" | while read -r file; do
        if [ -z "$file" ]; then continue; fi
        
        # Calculate destination path relative to ROOT_DIR
        ABS_FILE=$(realpath "$file")
        
        # Verify file is inside ROOT_DIR
        if [[ "$ABS_FILE" != "$ROOT_DIR"* ]]; then
            echo "Warning: File '$file' is outside root directory '$ROOT_DIR'. Skipping."
            continue
        fi
        
        REL_FILE="${ABS_FILE#$ROOT_DIR/}"
        DEST_DIR="$ARCHIVE_DIR/$(dirname "$REL_FILE")"
        
        # Create destination directory
        mkdir -p "$DEST_DIR"
        
        # Move file using rsync (preserve attributes, remove source)
        echo "Archiving: $REL_FILE"
        rsync -av --remove-source-files "$ABS_FILE" "$DEST_DIR/"
    done
    
    # Update history for processed directories
    for dir in "${PROCESSED_DIRS[@]}"; do
        add_to_history "$dir"
    done
    
    echo "Processing complete."
else
    echo "No files selected."
fi
