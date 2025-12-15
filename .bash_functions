# -*-sh-*-

# * Bash Functions
#----------------------

FUNCTION_FILE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.bash_functions"
echo "FUNCTION_FILE=${FUNCTION_FILE}"

# ** File & strings related functions:
#-----------------------------------

# *** ff    :arrow_right: Find a file with a pattern in name:
function ff() { find . -type f -iname '*'$*'*' -ls ; }
# *** fe    :arrow_right: Find a file with pattern $1 in name and Execute $2 on it:
function fe() { find . -type f -iname '*'$1'*' -exec "${2:-file}" {} \;  ; }
# *** fstr  :arrow_right: Find pattern in a set of filesand highlight them:
function fstr()
{
    OPTIND=1
    local case=""
    local usage="fstr: find string in files.
Usage: fstr [-i] \"pattern\" [\"filename pattern\"] "
    while getopts :it opt
    do
        case "$opt" in
        i) case="-i " ;;
        *) echo "$usage"; return;;
        esac
    done
    shift $(( $OPTIND - 1 ))
    if [ "$#" -lt 1 ]; then
        echo "$usage"
        return;
    fi
    local SMSO=$(tput smso)
    local RMSO=$(tput rmso)
    find . -type f -name "${2:-*}" -print0 | xargs -0 grep -sn ${case} "$1" 2>&- | \
sed "s/$1/${SMSO}\0${RMSO}/gI" | more
}

# ** ii     :arrow_right: get current host related info
function ii()   # get current host related info
{
    echo -e "\nYou are logged on ${RED}$HOST"
    echo -e "\nAdditionnal information:$NC " ; uname -a
    echo -e "\n${RED}Users logged on:$NC " ; whoami
    echo -e "\n${RED}Current date :$NC " ; date
#    echo -e "\n${RED}Machine stats :$NC " ; uptime
#    echo -e "\n${RED}Memory stats :$NC " ; free
#    my_ip 2>&- ;
#    echo -e "\n${RED}Local IP Address :$NC" ; echo ${MY_IP:-"Not connected"}
#    echo -e "\n${RED}ISP Address :$NC" ; echo ${MY_ISP:-"Not connected"}
    echo
}

# ** ask    :arrow_right: Ask for confirmation
function ask()
{
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

# ** Alias Functions
# *** alias-add :arrow_right: will add the argument, $1, to the end of the aliases file
function alias-add() {
    ##
    # alias-add will add the argument, $1, to the end of the aliases file
    if [ -z "$1" ] ; then
        echo -e alias-add will add the alias, ${blue}\$1${nc}, to the end of the ${blue}$ALIAS_FILE${nc} file
    else
    echo $(alias $1) >> $ALIAS_FILE
    fi
}

# *** alias-pwd :arrow_right: create a new alias, $1, for the changing the current directory provided by
function alias-pwd() {
    ##
    # alias-pwd will create a new alias, $1, for the changing the current directory provided by
    # `pwd`
    if [ -z "$1" ] ; then
        echo -e alias-pwd will create a new global alias, ${blue}"\$1"${nc}, for the changing the current directory, ${blue}`pwd`${nc}
    else
        declare -g $1="$(pwd)"
        echo $1="'$(pwd)'" >> ${ALIAS_FILE}
        echo Made global alias, $1, for "$(pwd)"
    fi
}

# ** Color Functions
# *** color-16 :arrow_right: print out 16 colors to the terminal
function color-16() {
    ##
    # color-16 will print out the colors to the terminal
    #          use it to determine what the colors will look like
    #          in your terminal or to choose sequences
    for clbg in {40..47} {100..107} 49 ; do
        #Foreground
        for clfg in {30..37} {90..97} 39 ; do
            #Formatting
            for attr in 0 1 2 4 5 7 ; do
                #Print the result
                echo -en "\e[${attr};${clbg};${clfg}m ^[${attr};${clbg};${clfg}m \e[0m"
            done
            echo #Newline
        done
    done
}

# *** color-256 :arrow_right: print out 256 colors to the terminal
function color-256() {
    ##
    # color-256 will print out colors to the terminal
    #           use it to determine what the colors will look like
    #           in your terminal and to choose sequences
    for fgbg in 38 48 ; do # Foreground / Background
        for color in {0..255} ; do # Colors
            # Display the color
            printf "\e[${fgbg};5;%sm  %3s  \e[0m" $color $color
            # Display 6 colors per lines
            # if [ $((($color + 1) % 6)) == 4 ] ; then
            #     echo "" # New line
            # fi
        done
        echo # New line
    done
}

# ** Windows integration functions
# *** wf :arrow_right: put the file argument on the clipboard in windows format
function wf {
    if [ ! -f "$1" ]
    then
        echo -e "Did not find the file, \"$1\". Unable to put on the clipboard."
        return
    fi
    echo "Capturing \"$(realpath "$1")\" on the clipboard."
    echo "$(cygpath -w "$(realpath "$1")")" | tr -d '\n' | clip
}

# *** startwin :arrow_right: for each file argument will launch explorer.exe on the file
function startwin ()
{
    for filepath in "$@"; do
        [ "" == "$filepath" ] && filepath="."
        if [ ! -e "${filepath}" ]; then
            echo "  Did not find the file, "$filepath". Unable to continue."
            continue
        fi
        echo "  Opening "$(realpath "${filepath}")" using explorer.exe."
        explorer.exe "$(cygpath -w "$(realpath "${filepath}")")"
    done
}

# ** ls functions
# *** lh :arrow_right: list files sorted by most recent first and chop with head
function lh () {
    # list file details sorted by most recent at the top and limit with head
    if [[ "$1" == "" ]]
    then
        ls --color=auto --color=auto -ot | head
    else
        ls --color=auto --color=auto -ot $* | head
    fi
}

# ** fzf functions for fd
# To use custom commands instead of find, override _fzf_compgen_{path,dir}
if ! declare -f _fzf_compgen_path > /dev/null; then
  _fzf_compgen_path() {
    echo "$1"
    command fd --type d --type f --type l --exclude .git --exclude AppData --exclude env --exclude .env --hidden 
    # command find -L "$1" \
    #   -name .git -prune -o -name .hg -prune -o -name .svn -prune -o \( -type d -o -type f -o -type l \) \
    #   -a -not -path "$1" -print 2> /dev/null | sed 's@^\./@@'
  }
fi

if ! declare -f _fzf_compgen_dir > /dev/null; then
  _fzf_compgen_dir() {
    command fd --type d --exclude .git --exclude env --exclude AppData --exclude .env --hidden 
    # command find -L "$1" \
    #   -name .git -prune -o -name .hg -prune -o -name .svn -prune -o -type d \
    #   -a -not -path "$1" -print 2> /dev/null | sed 's@^\./@@'
  }
fi

