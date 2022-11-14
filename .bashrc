
# The prompt in the emacs shell does not support some control sequences
# therefore we are fixing up the sequence
if [ -n "$INSIDE_EMACS" ]; then
    export PS1='\[\033[32m\]\u@\h \[\033[33m\]\w\[\033[36m\]`__git_ps1`\[\033[0m\]\n$ '
fi

#===============================================================
# Source:
#   https://www.linuxtopia.org/online_books/advanced_bash_scripting_guide/sample-bashrc.html


### Source global definitions (if any)

if [ -f /etc/bashrc ]; then
    . /etc/bashrc   # --> Read /etc/bashrc, if present.
fi

### Some settings

ulimit -S -c 0                  # Don't want any coredumps
set -o notify
set -o noclobber
set -o ignoreeof
#set -o nounset                  # if we set this it causes git prompt to have issues
#set -o xtrace                   # useful for debugging

#### Enable options:
shopt -s autocd                 # switch to directory if only path given
shopt -s cdspell
shopt -s cdable_vars            # "cd var" will use the value of variable, var, as the
                                # directory
shopt -s checkhash
shopt -s checkwinsize
# shopt -s mailwarn
# shopt -s sourcepath
shopt -s no_empty_cmd_completion  # bash>=2.04 only
shopt -s nocaseglob             # match file names in a case-insensitive manner
shopt -s cmdhist
shopt -s histappend histreedit histverify
shopt -s extglob                # necessary for programmable completion

#### Disable options:
shopt -u mailwarn
unset MAILCHECK                 # I don't want my shell to warn me of incoming mail

export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
export HISTIGNORE="&:bg:fg:ll:h"
# export HOSTFILE=$HOME/.hosts	# Put a list of remote hosts in ~/.hosts


### Update the path
if [ -e ~/.local/bin ] ; then PATH+=:~/.local/bin/ ; fi


### Define some colors first:
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
echo -e "${CYAN}This is BASH ${RED}${BASH_VERSION%.*}${CYAN} - DISPLAY on ${RED}$DISPLAY${NC}\n"

function _exit()	# function to run upon exit of shell
{
    echo -e "${RED}Hasta la vista, baby${NC}"
}
trap _exit EXIT

BASHRC_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "BASHRC_PATH=${BASHRC_PATH}"

export ALTERNATE_EDITOR=""
export EDITOR="emacsclientw -t"               # $EDITOR opens in terminal
export VISUAL="emacsclientw -c -a ''"         # $VISUAL opens in GUI mode

function kill-emacs() {
    emacsclientw -e '(client-save-kill-emacs)'
}

if [ -f ${BASHRC_PATH}/.bash_functions  ] ; then . ${BASHRC_PATH}/.bash_functions; fi
if [ -f ${BASHRC_PATH}/.bash_aliases  ] ; then . ${BASHRC_PATH}/.bash_aliases; fi

if [ "" == "${INSIDE_EMACS}" ]
then
    echo "Loading fzf completions if they exist in ~/.local/bin"
    if [ -f ${HOME}/.local/bin/fzf_completion.bash ]; then . ${HOME}/.local/bin/fzf_completion.bash; fi
    if [ -f ${HOME}/.local/bin/fzf_keybindings.bash ]; then . ${HOME}/.local/bin/fzf_keybindings.bash; fi
    if command -v fd &> /dev/null
    then
        export FZF_CTRL_T_COMMAND="fd . $HOME"
        export FZF_ALT_C_COMMAND="fd --type d . $HOME"
    fi
    
else
    echo "Not loading fzf completions because in emacs."
fi
