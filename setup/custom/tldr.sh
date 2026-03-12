#!/bin/bash

# Ensure pipx is run without strict failure if package is not found initially, but install.sh already set strict mode.
# We just need to check if pipx exists.

# Find pipx command (could be pipx, pipx-3.13, etc.)
PIPX_CMD=""
if command -v pipx &> /dev/null; then
    PIPX_CMD="pipx"
elif command -v pipx-3.13 &> /dev/null; then
    PIPX_CMD="pipx-3.13"
elif command -v pipx-3.12 &> /dev/null; then
    PIPX_CMD="pipx-3.12"
elif command -v pipx-3.11 &> /dev/null; then
    PIPX_CMD="pipx-3.11"
fi

if [ -n "$PIPX_CMD" ]; then
    echo "Installing tldr via $PIPX_CMD..."
    "$PIPX_CMD" install tldr
    "$PIPX_CMD" ensurepath
    # Initialize tldr cache
    if command -v tldr &> /dev/null; then
        tldr --update
    elif [ -f ~/.local/bin/tldr ]; then
        ~/.local/bin/tldr --update
    fi
else
    echo "pipx is not installed. Skipping tldr installation."
fi
