# -*-sh-*-
#---------------------------
# Bash Aliases
#---------------------------

ALIAS_FILE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.bash_aliases"
echo "ALIAS_FILE=${ALIAS_FILE}"

### Define my aliases
alias alias-edit='e "${ALIAS_FILE}"'
alias cls='tput reset'
alias ebashaliases='e "${ALIAS_FILE}"'
alias ebashfunctions='e "${FUNCTION_FILE}"'
alias ebashrc='e "${BASHRC_PATH}/.bashrc"'
alias egrep='egrep --color=auto'
alias eini='e "${HOME}/.emacs.d/init.el"'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias h='history 20'
alias l='ls --color=auto -otF'
alias la='ls --color=auto -A'
alias ll='ls --color=auto -alF'
alias ls='ls --color=auto'
alias path='echo -e ${PATH//:/\\n}'
alias st='explorer.exe'

### Recently added
