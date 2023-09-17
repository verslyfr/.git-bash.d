# -*-sh-*-
#---------------------------
# Bash Aliases
#---------------------------

git_bash_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [[ -e ${git_bash_folder}/custom_bash_aliases ]] ; then
    ${git_bash_folder}/custom_bash_aliases
    ALIAS_FILE="$git_bash_folder/custom_bash_aliases"
else
    ALIAS_FILE="${git_bash_folder}/.bash_aliases"
fi
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
alias st='startwin'
alias wp='echo "$(cygpath -m "$(pwd)")" | clip'
alias testspeed='echo "run","date","server name","server id","idle latency","idle jitter","packet loss","download","upload","download bytes","upload bytes","share url","download server count","download latency","download latency jitter","download latency low","download latency high","upload latency","upload latency jitter","upload latency low","upload latency high","idle latency low","idle latency high" | tee -a ~/OneDrive/testspeed_results.csv; for i in {1..300}; do echo -n "${i}",`date "+%Y-%m-%d %H%M%S"` "," | tee -a ~/OneDrive/testspeed_results.csv; speedtest -u Mbps -f csv -p no -s 42592 2>&1| tee -a ~/OneDrive/testspeed_results.csv; sleep 900 ; done'

### Recently added
