#!/bin/bash

# Ensure FILE is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

FILE="$1"

# Handle Directories
if [ -d "$FILE" ]; then
    if command -v lsd &> /dev/null; then
        lsd --tree --depth 2 --color=always --icon=always "$FILE"
    elif command -v eza &> /dev/null; then
        eza --tree --level=2 --color=always --icons --group-directories-first --git "$FILE"
    elif command -v tree &> /dev/null; then
        tree -C -L 2 "$FILE"
    else
        ls -F --color=always "$FILE"
    fi
    exit 0
fi

# Determine MIME type
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

case "$MIME" in
    image/*)
        if command -v chafa &> /dev/null; then
            chafa -f sixel -s "${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}" "$FILE"
        elif command -v img2sixel &> /dev/null; then
            img2sixel < "$FILE"
        else
            echo "Install chafa or libsixel for image previews"
        fi
        ;;
    application/pdf)
        if command -v pdftoppm &> /dev/null && command -v chafa &> /dev/null; then
            pdftoppm -f 1 -l 1 -png "$FILE" | chafa -f sixel -s "${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}"
        else
            echo "Install poppler-utils and chafa for PDF previews"
        fi
        ;;
    video/*)
        if command -v ffmpeg &> /dev/null && command -v chafa &> /dev/null; then
            # Extract thumbnail at 00:00:00 (safer for short clips)
            ffmpeg -loglevel error -ss 00:00:00 -i "$FILE" -vframes 1 -f image2pipe -vcodec png - 2>/dev/null | chafa -f sixel -s "${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}"
        else
            echo "Install ffmpeg and chafa for video previews"
        fi
        ;;
    *)
        if command -v bat &> /dev/null; then
            bat --color=always --style=numbers --line-range :500 "$FILE"
        else
            head -n 500 "$FILE"
        fi
        ;;
esac
