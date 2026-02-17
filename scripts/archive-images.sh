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
AUTO_ARCHIVE_FILES=""
PROCESSED_DIRS=()
MARK_PROCESSED_STR="[MARK_PROCESSED]"

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
        # Using sed to make paths relative for display
        FILES=$(fd -t f -e jpg -e jpeg -e png -e gif -e bmp -e tiff -e webp -e heic -e raw -e nef -e cr2 -e arw -e dng --max-depth 1 . "$TARGET" | sed "s|^$ROOT_DIR/||")
        
        if [ -n "$FILES" ]; then
            ALL_FILES="$ALL_FILES"$'\n'"$FILES"
        fi
        
        # Add dummy entry (relative path is already clean)
        ALL_FILES="$ALL_FILES"$'\n'"$MARK_PROCESSED_STR ($REL_PATH)"
        
        # Check subfolders: .original, .originals, .picasaoriginals, Originals
        # These are stored in AUTO_ARCHIVE_FILES and NOT shown in FZF
        for sub in ".original" ".originals" ".picasaoriginals" "Originals"; do
            if [ -d "$TARGET/$sub" ]; then
                SUB_FILES=$(fd -t f -e jpg -e jpeg -e png -e gif -e bmp -e tiff -e webp -e heic -e raw -e nef -e cr2 -e arw -e dng --max-depth 1 . "$TARGET/$sub" | sed "s|^$ROOT_DIR/||")
                if [ -n "$SUB_FILES" ]; then
                    AUTO_ARCHIVE_FILES="$AUTO_ARCHIVE_FILES"$'\n'"$SUB_FILES"
                fi
            fi
        done
        
    elif [ -f "$TARGET" ]; then
        # --- Single File Handling ---
        # Make path relative
        REL_FILE="${TARGET#$ROOT_DIR/}"
        ALL_FILES="$ALL_FILES"$'\n'"$REL_FILE"
    else
        echo "Target not found: $TARGET"
    fi
done

# Trim leading newline
ALL_FILES="${ALL_FILES#$'\n'}"
AUTO_ARCHIVE_FILES="${AUTO_ARCHIVE_FILES#$'\n'}"

if [ -z "$ALL_FILES" ]; then
    echo "No files found to process."
    exit 0
fi

# Run FZF for selection
# Use generic preview if scripts/fzf-preview.sh is not found in local dir
# but we know it's in the repo structure relative to this script.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PREVIEW_CMD="$SCRIPT_DIR/fzf-preview.sh $ROOT_DIR/{}"

# FZF now sees relative paths. Preview command needs full path to work.
SELECTED=$(echo "$ALL_FILES" | fzf -m --preview-window nohidden --preview "$PREVIEW_CMD")

if [ -n "$SELECTED" ]; then
    
    # Process FZF Selection (Manual)
    echo "$SELECTED" | while read -r file; do
        if [ -z "$file" ]; then continue; fi
        
        # Check for marker
        if [[ "$file" == "$MARK_PROCESSED_STR"* ]]; then
            echo "Marking folder as processed (no files moved for this entry)."
            continue
        fi
        
        # Reconstruct absolute source path
        ABS_FILE="$ROOT_DIR/$file"
        
        # Destination path is relative (already have it in $file)
        DEST_DIR="$ARCHIVE_DIR/$(dirname "$file")"
        
        # Create destination directory
        mkdir -p "$DEST_DIR"
        
        # Move file using rsync (preserve attributes, remove source)
        echo "Archiving: $file"
        rsync -av --remove-source-files "$ABS_FILE" "$DEST_DIR/"
    done
    
    # Process Auto-Archive Files (Originals)
    if [ -n "$AUTO_ARCHIVE_FILES" ]; then
        echo "Auto-archiving originals..."
        echo "$AUTO_ARCHIVE_FILES" | while read -r file; do
             if [ -z "$file" ]; then continue; fi
             
             ABS_FILE="$ROOT_DIR/$file"
             DEST_DIR="$ARCHIVE_DIR/$(dirname "$file")"
             
             mkdir -p "$DEST_DIR"
             echo "Archiving (Original): $file"
             rsync -av --remove-source-files "$ABS_FILE" "$DEST_DIR/"
        done
    fi
    
    # Update history for processed directories
    for dir in "${PROCESSED_DIRS[@]}"; do
        add_to_history "$dir"
    done
    
    echo "Processing complete."
else
    echo "No files selected. Folders NOT marked as processed."
fi
