

# If not running interactively, don't do anything
[ -z "$PS1" ] && return


# Mac specific things
if [ "$(uname)" == "Darwin" ] ; then

    # Add brew to the path
    export PATH="/usr/local/bin:$PATH"
    export PATH="/usr/local/sbin:$PATH"
    export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"

    # temp fix for python line profile
    export PATH="/Users/ianbriggs/Library/Python/3.7/bin:$PATH"

    # Color GNU ls
    alias ls="gls --color"

    # GNU rm; do not delete / or prompt if deleting more than 3 files at a time
    alias rm='grm -I --preserve-root'

    # brew cleanup old files not covered by brew cleanup
    caskBasePath="$( brew --prefix )/Caskroom"

    function __clean-cask
    {
	# Split $1 into an array
	IFS=' ' read -ra caskArray <<< "$1"

	local cask="${caskArray[0]}"
	local caskDirectory="${caskBasePath}/${cask}"

	# Slicing: array:startIndex:length ; exclude first and last elements
	local versionsToRemove=("${caskArray[@]:1:${#caskArray[@]}-2}")

	if [[ -n ${versionsToRemove} ]]; then
	    for versionToRemove in "${versionsToRemove[@]}"; do
		echo "Removing ${cask} ${versionToRemove}..."
		rm -fr "${caskDirectory}/${versionToRemove}"
		rm -fr "${caskDirectory}/.metadata/${versionToRemove}"
	    done
	fi
    }

    function __clean-casks
    {
	while read cask; do
	    __clean-cask "${cask}"
	done <<< "$( brew cask list --versions )"
    }

    # brew alias
    alias brewit="brew update && brew upgrade && brew cask upgrade && brew cleanup && brew doctor && __clean-casks"
else

    # Linux specific things

    # Color ls
    alias ls="ls --color"

    # Do not delete / or prompt if deleting more than 3 files at a time
    alias rm='rm -I --preserve-root'
fi


# ls aliases
export LSCOLORS=Gxfxcxdxbxegedabagacad
alias ll='ls -lh'
alias la='ls -lah'


# grep aliases
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'


# Make cd act like zsh with AUTO_PUSHD
pushd()
{
    if [ $# -eq 0 ]; then
	DIR="${HOME}"
    else
	DIR="$1"
    fi

    builtin pushd "${DIR}" > /dev/null
}
popd()
{
    builtin popd > /dev/null
}
alias cd='pushd'


# Use a better which
alias which="command -v"


# Make tab completion insensitive
bind "set completion-ignore-case on"


# Colorize diff
alias diff='colordiff'


# Make looking at $PATH easier
alias path='echo -e ${PATH//:/\\n}'


# Fat finger fix
alias cd..='cd ..'


# Make arrow keys search history
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'


# Correct dir spellings
shopt -q -s cdspell
shopt -q -s dirspell
shopt -q -s nocaseglob


# Turn on the extended pattern matching features
shopt -q -s extglob
shopt -q -s globstar


# Append rather than overwrite history on exit
shopt -q -s histappend


# Make multi-line commandsline in history
shopt -q -s cmdhist


# Disable [CTRL-D] which is used to exit the shell
set -o ignoreeof


# Fallback to path search when command hash table fails
shopt -q -s checkhash


# Don't try to command complete an empty line
shopt -q -s no_empty_cmd_completion


# Use less command as a pager
export PAGER=less


# Set emacs as default text editor
export EDITOR=emacs




# Prompt stuff

# Normal Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

NC="\e[m"               # Color Reset

ALERT=${BWhite}${On_Red} # Bold White on red background




# Test connection type:
if [ -n "${SSH_CONNECTION}" ]; then
    CNX=${Green}        # Connected on remote machine, via ssh (good).
else
    CNX=${Cyan}        # Connected on local machine.
fi


# Test user type:
if [[ ${USER} == "root" ]]; then
    SU=${Alert}           # User is root.
elif [[ ${USER} != $(logname) ]]; then
    SU=${Red}             # User is not login user.
else
    SU=${White}           # User is normal (well ... most of us are).
fi


# Commonly used escape sequences:
# \u	The current user
# \w	The current working directory
# \W	The last fragment of the current working directory. For example, if you
#         are currently in /usr/local/bin, this will give you bin.
# \h	The name of the computer, upto a dot(.). For example, if your computer is
#         named ubuntu.pc, this gives you ubuntu.
# \H	The full hostname
# \d	The date in “Weekday Month Date” format (e.g.”Tue 21 July”)
# \t	The current time in 24 hour HH:MM:SS format
# \T	The current time in 12 hour HH:MM:SS format
# \@	The current time in 12-hour AM/PM format
# \n	Move on to the next line.

GIT_BRANCH='$(git branch 2>/dev/null | sed -n "s/* \(.*\)/\1 /p")'

PROMPT_COMMAND=__prompt_command # Func to gen PS1 after CMDs

__prompt_command() {
    local EXIT="$?"             # This needs to be first
    PS1=""
    if [[ $EXIT != 0 ]]; then
	ARROW=$'\xe2\x86\xb3 '
	PS1+="${Red}${ARROW}${EXIT}${NC}\n"
    fi

    ARROWS=$'\xc2\xbb'
    PS1+="${CNX}\h${NC} ${SU}\w${NC} ${Yellow}${GIT_BRANCH}${NC}\n${ARROWS} "
}

