# .git-bash.d

A comprehensive, multi-environment Bash configuration designed for consistency across Windows (Git Bash), OpenSUSE Tumbleweed, and Ubuntu/Debian systems.

## Overview

This repository standardizes my shell environment, providing:
*   **Unified Bash Config**: Shared aliases, functions, and environment variables.
*   **Package Management**: A single command (`up-sys`) to ensure essential tools are installed across different Linux distributions.
*   **Custom Tools**: Integrated installers for tools not in standard repositories (e.g., `opencode`).

## Installation

1.  **Clone the repository** to your home directory:
    ```bash
    git clone https://github.com/verslyfr/.git-bash.d.git ~/.git-bash.d
    ```

2.  **Source the configuration**:
    Add the following to your `~/.bashrc` (Linux) or `~/.bash_profile` (Windows Git Bash):

    ```bash
    if [ -f ~/.git-bash.d/.bashrc ]; then . ~/.git-bash.d/.bashrc; fi
    ```

3.  **Reload your shell**:
    ```bash
    source ~/.bashrc
    ```

## Usage

### System Update & Installation (`up-sys`)

This repository includes a powerful utility to synchronize your installed packages.

**Command:**
```bash
up-sys
```

**What it does:**
1.  **Detects OS**: Automatically identifies if you are on OpenSUSE or Ubuntu.
2.  **Installs System Packages**:
    *   **OpenSUSE**: Uses `zypper` to install packages listed in `setup/packages/opensuse.txt`.
    *   **Ubuntu**: Uses `apt` (and external repos/PPAs where needed) to install packages from `setup/packages/ubuntu.txt`.
3.  **Installs Custom Tools**: Runs scripts in `setup/custom/` (e.g., installing `opencode`).

### Advanced FZF Previews

This configuration includes a custom preview script (`fzf-preview.sh`) that enhances `fzf` with rich media support.

*   **Directories**: Shows a colorful tree view (using `lsd`, `eza`, or `tree`).
*   **Images**: Renders images directly in the terminal using Sixel graphics (requires `chafa` or `libsixel`).
*   **Videos**: Extracts and displays a thumbnail frame (requires `ffmpeg`).
*   **PDFs**: Renders the first page as an image (requires `poppler-utils`).
*   **Text**: Syntax highlighting via `bat`.

These previews are automatically enabled for:
*   **Ctrl-T**: File selection.
*   **Alt-C**: Directory navigation.

**Usage:**
*   **Toggle Preview**: Press `Ctrl-/` to show/hide the preview pane (hidden by default).
*   **Layout**: Preview opens on the right (70% width).

### Repository Maintenance

*   **`up-git`**: Updates both `~/.emacs.d` and `~/.git-bash.d` by pulling the latest changes from their respective git repositories.

### Quick File Management

*   **`mv-down`**: Move recent files (changed within 1 day) from `~/Downloads` to the current directory using `fzf` for selection.
*   **`mvdoc`**: Move recent files (changed within 3 days) from `~/OneDrive/Scanner-Inbox/Documents/` to the current directory.
*   **`mvphoto`**: Move recent files (changed within 3 days) from `~/OneDrive/Scanner-Inbox/Photos/` to the current directory.

### Key Features & Packages

*   **Editors**: Emacs (GUI/Terminal), custom `VISUAL` settings.
*   **Terminal**: WezTerm (configured for both OpenSUSE and Ubuntu).
*   **CLI Utilities**:
    *   `fzf` (configured for exact matching), `fd`, `ripgrep`, `bat`, `lsd` (modern replacements for standard unix tools).
    *   `gh` (GitHub CLI), `git`.
    *   `pandoc`, `aspell`, `zip`, `openscad`, `speedtest-cli`.
*   **Dev Tools**: Build essentials (`devel_basis` / `build-essential`), `cmake`.
*   **Multimedia**: `ImageMagick`, `exiftool`, `pinta`, `okular`.

## Environment Support

| OS | Status | Notes |
| :--- | :--- | :--- |
| **OpenSUSE Tumbleweed** | ✅ Fully Supported | Uses `zypper` + patterns. |
| **Ubuntu / Debian** | ✅ Fully Supported | Maps packages, adds PPAs (e.g. WezTerm), handles symlinks (`batcat` -> `bat`). |
| **Windows (Git Bash)** | ⚠️ Partial Support | Core bash config works. `up-sys` logic is Linux-specific. |

## Customization

*   **Aliases**: stored in `.bash_aliases`.
*   **Functions**: stored in `.bash_functions`.
*   **Package Lists**: Edit `setup/packages/` to add/remove system packages.
