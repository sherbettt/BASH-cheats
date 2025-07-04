
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000



# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# color aliases
alias sudo='sudo '
alias ls='ls --color=always'
alias ll='ll --color=always'
alias dmesg='dmesg --color=always'
alias grep='grep --color=always'
alias gcc='gcc -fdiagnostics-color=always'
alias pacman='pacman --color=always'
alias dir='dir --color=always'
alias diff='diff --color=always'

# some more other aliases
alias sudo='sudo '
alias tree='tree -Csu -a --du --dirsfirst'    # alternative to 'ls'
alias cls='clear'
alias repo='grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/*'
alias apta='sudo apt update -y && sudo apt upgrade -y && sudo apt dist-upgrade -y'
alias lz='eza -aghlo -F -U --group-directories-first --icons=automatic --total-size'
alias lzz='eza -aghli -F -U --group-directories-first --icons=automatic --time-style=long-iso'
alias ll='ls -alFS --group-directories-first'
alias llt='ll --time-style=+%F_%X'
alias la='ls -A'
alias l='ls -CF'
alias pcat='pygmentize -g'
alias batc='bat --config-dir; bat --cache-dir' # for Ubuntu is batcat, for ohther - bat
alias batp='bat -p -S'
alias getip="curl ifconfig.me ; echo"
alias np='notepad2.exe'
alias h='history'
alias j='jobs -l'
alias r='rlogin'
alias which='type -all'
alias path='echo -e ${PATH//:/\\n}'
alias du='du -kh'
alias df='df -kTh'
alias ipc='ip -c addr show'
alias ipa='ip -br -c addr show'
alias mc-visudo='sudo EDITOR=mcedit visudo'


# Power commands
alias shutdown="sudo shutdown -P now"
alias reboot="sudo shutdown -r now"

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi



# PS1
INPUT_COLOR="\[\033[0m\]"
DIR_COLOR="\[\033[0;33m\]"
DIR="\w"

LINE_VERTICAL="\342\224\200"
LINE_CORNER_1="\342\224\214"
LINE_CORNER_2="\342\224\224"
LINE_COLOR="\[\033[0;37m\]"

USER_NAME="\[\033[0;32m\]\u"
HOST_NAME="\[\033[1;94m\]\h"
TIME="\[\033[0;90m\]\t"
SYMBOL="\[\033[0;92m\]$"

if [[ ${EUID} == 0 ]]; then
	USER_NAME="\[\033[0;31m\]\u"
	SYMBOL="\[\033[0;31m\]#"
fi

PS1="$LINE_COLOR$LINE_CORNER_1$LINE_VERTICAL $USER_NAME $DIR_COLOR$DIR \n$LINE_COLOR$LINE_CORNER_2$LINE_VERTICAL $SYMBOL $INPUT_COLOR"
#PS1="$LINE_COLOR$LINE_CORNER_1$LINE_VERTICAL $USER_NAME $DIR_COLOR$DIR \n$LINE_COLOR$LINE_VERTICAL $HOST_NAME \n$LINE_COLOR$LINE_CORNER_2$LINE_VERTICAL $SYMBOL $INPUT_COLOR"

# цветной bash
# https://pingvinus.ru/note/bash-promt
# https://ziggi.org/cveta-v-terminale/
# https://gist.github.com/ziggi/a873de4c020c4752a889
