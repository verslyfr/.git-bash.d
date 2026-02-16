
# * Configure the git_prompt
if [[ -e /usr/share/git/completion/git-prompt.sh ]] ; then
    . /usr/share/git/completion/git-prompt.sh
elif [[ -e /usr/share/git-core/contrib/completion/git-prompt.sh ]] ; then
     . /usr/share/git-core/contrib/completion/git-prompt.sh
elif [[ -e /usr/share/bash-completion/completions/git-prompt.sh ]] ; then
    . /usr/share/bash-completion/completions/git-prompt.sh
elif [[ -e /etc/bash_completion.d/git-prompt ]] ; then
    . /etc/bash_completion.d/git-prompt
else
    echo "Did not find git-prompt.sh"
fi
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
export PS1='\[\033[32m\]\u@\h \[\033[33m\]\w\[\033[36m\]`__git_ps1`\[\033[0m\]\n$ '

#===============================================================
# Source:
#   https://www.linuxtopia.org/online_books/advanced_bash_scripting_guide/sample-bashrc.html

### Source global definitions (if any)

[[ -f /etc/bashrc ]] && . /etc/bashrc   # --> Read /etc/bashrc, if present.
[[ -f /etc/bash.bashrc ]] && . /etc/bash.bashrc 

# * Some settings

ulimit -S -c 0                  # Don't want any coredumps
set -o notify
set -o noclobber
set -o ignoreeof
#set -o nounset                  # if we set this it causes git prompt to have issues
#set -o xtrace                   # useful for debugging

# ** Enable options:
shopt -s autocd                 # switch to directory if only path given
shopt -s cdspell
shopt -s cdable_vars            # "cd var" will use the value of variable, var, as the
                                # directory
shopt -s checkhash
shopt -s checkwinsize
shopt -s no_empty_cmd_completion  # bash>=2.04 only
shopt -s nocaseglob             # match file names in a case-insensitive manner
shopt -s cmdhist
shopt -s histappend histreedit histverify
shopt -s extglob                # necessary for programmable completion

umask 0077                      # set files rw for user and directories to rwx
                                # for user; no other access

# ** Disable options:
shopt -u mailwarn
unset MAILCHECK                 # I don't want my shell to warn me of incoming mail

bind 'set completion-ignore-case on'   # ignore case for completions

export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
export HISTIGNORE="&:bg:fg:ll:h"

# PROMPT Settings
PROMPT_DIRTRIM=2                # Only have the last part of the path

# * Update the path
[[ -e ${HOME}/.local/bin ]] && export PATH=${HOME}/.local/bin:${PATH}
[[ -e ${HOME}/.npm-global/bin ]] && export PATH=${PATH}:${HOME}/.npm-global/bin


# * Define some colors first:
red='\e[0;31m'
RED='\e[1;31m'
blue='\e[0;34m'
BLUE='\e[1;34m'
cyan='\e[0;36m'
CYAN='\e[1;36m'
NC='\e[0m'              # No Color
nc='\e[0m'
# --> Nice. Has the same effect as using "ansi.sys" in DOS.

# Looks best on a black background.....
echo -e "${CYAN}This is BASH ${RED}${BASH_VERSION%.*}${CYAN} - DISPLAY on ${RED}$DISPLAY${NC}"
echo -e "Recommended apps: ${RED}pinta${NC}"
# pinta is an image editor

# for wsl, we use wslpath instead of cygpath
if hash wslpath 2>/dev/null; then
    echo -e "Aliasing ${RED}cygpath${NC} to ${RED}wslpath${NC}"
    alias cygpath=wslpath
    alias clip=clip.exe
fi

function _exit()	# function to run upon exit of shell
{
    echo -e "${RED}Hasta la vista, baby${NC}"
}
trap _exit EXIT

BASHRC_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "BASHRC_PATH=${BASHRC_PATH}"

# fix up DIR_COLORS
eval `dircolors -b "${BASHRC_PATH}/DIR_COLORS"`

# * Emacs settings
export ALTERNATE_EDITOR=""

if hash emacsclientw 2>/dev/null; then
    export EDITOR="emacsclientw -t"               # $EDITOR opens in terminal
    export VISUAL="emacsclientw -c -a ''"         # $VISUAL opens in GUI mode
else
    export EDITOR="emacsclient -nw"
    export VISUAL='emacsclient -ca ""'
fi

function kill-emacs() {
    if hash emacsclientw 2>/dev/null; then
        emacsclientw -e '(kill-emacs)'
    else
        emacsclient -e '(kill-emacs)'
    fi
}


# * Load the bash functions and aliases
if [ -f ${BASHRC_PATH}/bash_functions  ] ; then . ${BASHRC_PATH}/bash_functions; fi
if [ -f ${BASHRC_PATH}/bash_aliases  ] ; then . ${BASHRC_PATH}/bash_aliases; fi

# * Initialize fzf to use fd
echo "Initialize fzf to use fd."
FD_COMMAND=fd
_ONEDRIVE=
_DOWNLOADS=
_DATA=
if command -v fdfind &> /dev/null; then FD_COMMAND=fdfind; fi

_FZF_DIRECTORIES='.'
[[ -d ${HOME}/OneDrive\ -\ Cummins ]] && _FZF_DIRECTORIES="${_FZF_DIRECTORIES} "'"${HOME}/OneDrive - Cummins"'
[[ -d ${HOME}/OneDrive ]] && _FZF_DIRECTORIES="${_FZF_DIRECTORIES} "'"${HOME}/OneDrive"'
[[ -d ${HOME}/Downloads ]] && _FZF_DIRECTORIES="${_FZF_DIRECTORIES} "'"${HOME}/Downloads"'
[[ -d /mnt/e/Data/ ]] && _FZF_DIRECTORIES="${_FZF_DIRECTORIES} "'"/mnt/e/Data/"'

export FZF_CTRL_T_COMMAND="${FD_COMMAND} -L -E winhome ${_FZF_DIRECTORIES} "
export FZF_ALT_C_COMMAND="${FD_COMMAND} -L -E winhome -t d  ${_FZF_DIRECTORIES}"
export FZF_ALT_C_OPTS="--exact --preview '~/.git-bash.d/scripts/fzf-preview.sh {}'"
export FZF_DEFAULT_COMMAND="${FD_COMMAND} --type f "
export FZF_DEFAULT_OPTS="--exact -i --layout=reverse --inline-info --style=default --height 80% --preview-window right,70%,hidden --bind 'ctrl-/:change-preview-window(right,70%|hidden)' --preview '~/.git-bash.d/scripts/fzf-preview.sh {}'"

_fzf_compgen_path() {
    fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude ".git" . "$1"
}

eval "$(fzf --bash)"
_fzf_setup_completion path ag git kubectl st
_fzf_setup_completion dir tree
