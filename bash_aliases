# -*-sh-*-
#---------------------------
# * Bash Aliases
#---------------------------
# * Set up custom aliases support and environment variables
git_bash_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [[ -e ${git_bash_folder}/custom_bash_aliases ]] ; then
    source ${git_bash_folder}/custom_bash_aliases
    ALIAS_FILE="$git_bash_folder/custom_bash_aliases"
else
    ALIAS_FILE="${git_bash_folder}/.bash_aliases"
fi
echo "ALIAS_FILE=${ALIAS_FILE}"

# Wrapper for qdbus on Qt6 systems
# Ensures 'qdbus-qt6' is available, even if only 'qdbus6' exists (common on openSUSE)

if command -v qdbus6 >/dev/null 2>&1 && ! command -v qdbus-qt6 >/dev/null 2>&1; then
    alias qdbus-qt6='qdbus6'
fi

# * Define my aliases
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
alias mv-down="fd -t f --changed-within 1d . $HOME/Downloads | fzf -m --bind 'enter:become(mv -v {+} .)'"
alias mv_downloads_pwd='fd --changed-within 5min . ~/Downloads -x mv -v {} .'
alias mvdoc="fd -t f --changed-within 3d . $HOME/OneDrive/Scanner-Inbox/Documents/ | fzf -m --bind 'enter:become(mv -v {+} .)'"
alias mvphoto="fd -t f --changed-within 3d . $HOME/OneDrive/Scanner-Inbox/Photos/ | fzf -m --bind 'enter:become(mv -v {+} .)'"
alias path='echo -e ${PATH//:/\\n}'
alias qe='emacsclient -nw -a ""'
alias st='startwin'
alias suzy='sudo zypper'
alias testspeed='echo "Server ID,Sponsor,Server Name,Timestamp,Distance,Ping,Download,Upload,Share,IP Address" | tee -a ~/OneDrive/testspeed_results.csv; for i in {1..300}; do echo -n "${i}",`date "+%Y-%m-%d %H%M%S"` "," | tee -a ~/OneDrive/testspeed_results.csv; speedtest --csv 2>&1| tee -a ~/OneDrive/testspeed_results.csv; sleep 900 ; done'
alias up-git='alias up-git; pushd ~/.emacs.d; git pull; cd ~/.git-bash.d; git pull; popd'
alias up-sys='bash ~/.git-bash.d/setup/install.sh'
alias wp='echo "$(cygpath -m "$(pwd)")" | tr -d "\n" | clip.exe'
alias zy='zypper'
complete -F _zypper suzy
complete -F _zypper zy

# ** Prefer batcat, then bat, for 'cat' functionality
if command -v batcat >/dev/null 2>&1; then
  alias cat='batcat'
elif command -v bat >/dev/null 2>&1; then
  alias cat='bat'
fi

# ** Utilize lsd if present
if command -v lsd >/dev/null 2>&1; then
    alias l='lsd -l -a --group-directories-first --date relative --sort time --reverse --blocks permission,size,date,name'
    alias ls='lsd --group-directories-first'
    alias la='lsd -a --group-directories-first'
    alias ll='lsd -al --group-directories-first --date relative --sort time --reverse --blocks permission,size,date,name'
else
    alias l='ls -a --color=auto -otFLr'
    alias la='ls --color=auto -A'
    alias ll='ls --color=auto -altrF'
    alias ls='ls --color=auto'
fi

# ** docker-opencode
if [[ -e "${HOME}/src/docker-opencode/docker-opencode.sh" ]] ; then
    alias d-opencode="${HOME}/src/docker-opencode/docker-opencode.sh"
else
    alias d-opencode="echo docker-opencode is not in ~/src"
fi

# * Load the custom bash aliases
# this needs to be at the end in case there are overrides
if [[ -e ${git_bash_folder}/custom_bash_aliases ]] ; then
    source ${git_bash_folder}/custom_bash_aliases
fi
