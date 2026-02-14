#!/bin/bash
if ! command -v opencode &> /dev/null; then
    echo "Installing opencode..."
    curl -fsSL https://opencode.ai/install | bash
else
    echo "opencode is already installed."
fi
