#!/bin/bash
# ==============================================================================
# FZF Preview Script
# ==============================================================================
#
# Purpose:
#   This script serves as a unified preview handler for fzf (fuzzy finder).
#   It determines the file type of the selected item and generates an appropriate
#   visual preview within the terminal window.
#
# Features:
#   1. Directories: Displays a colorful, single-level tree view (prioritizing 'lsd').
#   2. Images: Renders Sixel graphics using 'chafa' or 'img2sixel'.
#   3. Videos: Extracts a thumbnail frame using 'ffmpeg' and renders it.
#   4. PDFs: Renders the first page as an image.
#   5. Text/Code: Uses 'bat' for syntax highlighting.
#
# Usage:
#   Integrated via .bashrc into FZF_DEFAULT_OPTS and FZF_ALT_C_OPTS.
#   Examples:
#     export FZF_DEFAULT_OPTS="--preview '~/.git-bash.d/fzf-preview.sh {}'"
#     export FZF_ALT_C_OPTS="--preview '~/.git-bash.d/fzf-preview.sh {}'"
#   Can be run manually: ./fzf-preview.sh <filename>
#
# Dependencies:
#   - bat, chafa, ffmpeg, poppler-utils (pdftoppm), lsd/eza/tree
#
# ==============================================================================

# Ensure FILE is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

FILE="$1"

# ------------------------------------------------------------------------------
# 1. Directory Handling
# ------------------------------------------------------------------------------
if [ -d "$FILE" ]; then
    if command -v lsd &> /dev/null; then
        # Use lsd for colorful tree view (User Preference)
        lsd --tree --depth 1 --color=always --icon=always --directory-only "$FILE"
    elif command -v eza &> /dev/null; then
        # Use eza as modern alternative
        eza --tree --level=1 --color=always --icons --group-directories-first --git --only-dirs "$FILE"
    elif command -v tree &> /dev/null; then
        # Fallback to standard tree
        tree -C -L 1 -d "$FILE"
    else
        # Ultimate fallback
        ls -F --color=always "$FILE"
    fi
    exit 0
fi

# ------------------------------------------------------------------------------
# 2. File Type Detection
# ------------------------------------------------------------------------------
MIME=$(file --mime-type -b -- "$FILE")
EXT="${FILE##*.}"
EXT="${EXT,,}" # lowercase extension

# Default FZF variables if not set (e.g. manual run)
: "${FZF_PREVIEW_COLUMNS:=80}"
: "${FZF_PREVIEW_LINES:=24}"

# Fix for MP4 videos sometimes being detected as audio/mp4
if [[ "$MIME" == "audio/mp4" && ( "$EXT" == "mp4" || "$EXT" == "m4v" ) ]]; then
    MIME="video/mp4"
fi

# Fallback based on extension if MIME is generic or empty
if [[ -z "$MIME" || "$MIME" == "application/octet-stream" || "$MIME" == "application/x-dosexec" ]]; then
    case "$EXT" in
        mp4|mkv|avi|mov|flv|wmv|webm|m4v|mpg|mpeg) MIME="video/mp4" ;;
        jpg|jpeg|png|gif|bmp|tiff|webp|ico|svg) MIME="image/jpeg" ;;
        pdf) MIME="application/pdf" ;;
    esac
fi

# ------------------------------------------------------------------------------
# 3. Preview Generation Logic
# ------------------------------------------------------------------------------
case "$MIME" in
    # --- Images (Sixel) ---
    image/*)
        if command -v chafa &> /dev/null; then
            chafa -f sixel -s "${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}" "$FILE"
        elif command -v img2sixel &> /dev/null; then
            img2sixel < "$FILE"
        else
            echo "Install chafa or libsixel for image previews"
        fi
        ;;

    # --- PDFs (First Page) ---
    application/pdf)
        if command -v pdftoppm &> /dev/null && command -v chafa &> /dev/null; then
            pdftoppm -f 1 -l 1 -png "$FILE" | chafa -f sixel -s "${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}"
        else
            echo "Install poppler-utils and chafa for PDF previews"
        fi
        ;;

    # --- Videos (Thumbnail) ---
    video/*)
        if command -v ffmpeg &> /dev/null && command -v chafa &> /dev/null; then
            # Extract thumbnail at 00:00:00 (safer for short clips)
            ffmpeg -loglevel error -ss 00:00:00 -i "$FILE" -vframes 1 -f image2pipe -vcodec png - 2>/dev/null | chafa -f sixel -s "${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}"
        else
            echo "Install ffmpeg and chafa for video previews"
        fi
        ;;

    # --- Default (Text/Binary) ---
    *)
        if command -v bat &> /dev/null; then
            bat --color=always --style=numbers --line-range :500 "$FILE"
        else
            head -n 500 "$FILE"
        fi
        ;;
esac
