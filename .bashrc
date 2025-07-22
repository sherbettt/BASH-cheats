
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
alias path='echo -e ${PATH//:/\\n}'
alias apta='sudo apt update -y && sudo apt upgrade -y && sudo apt dist-upgrade -y'
alias ll='ls -alFS --group-directories-first'
alias llt='ll --time-style=+%F_%X'
alias la='ls -A'
alias l='ls -CF'
alias lz='eza -aghlo -F -U --group-directories-first --icons=automatic --total-size'
alias lzz='eza -aghli -F -U --group-directories-first --icons=automatic --time-style=long-iso'
alias pcat='pygmentize -g'
alias batc='bat --config-dir; bat --cache-dir' # for Ubuntu is batcat, for ohther - bat
alias batp='bat -p -S'
alias getip="curl ifconfig.me ; echo"
alias np='notepad2.exe'
alias h='history'
alias j='jobs -l'
alias r='rlogin'
alias which='type -all'
alias du='du -kh'
alias df='df -kTh'
alias ipc='ip -c addr show'
alias ipa='ip -br -c addr show'
alias lsblk-more='lsblk --output TYPE,PATH,NAME,FSAVAIL,FSUSE%,SIZE,MOUNTPOINT,UUID,FSTYPE,PTTYPE,PARTUUID'
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


# Simple color PS1
# PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]'


# PS1
# Цвета (яркие и жирные)
INPUT_COLOR="\[\033[0m\]"
DIR_COLOR="\[\033[1;38;5;208m\]"      # Ярко-оранжевый (жирный)
LINE_COLOR="\[\033[1;37m\]"           # Ярко-белая граница

# Псевдографика (Unicode)
LINE_VERTICAL="\342\224\200"          # "─"
LINE_CORNER_1="\342\224\214"          # "┌"
LINE_CORNER_2="\342\224\224"          # "└"
LINE_CROSS="\342\224\234"             # "├"

# Динамические настройки для пользователя/root
if [[ ${EUID} == 0 ]]; then
    # Стиль для root (3 строки + оранжевый вместо красного)
    USER_NAME="\[\033[1;38;5;208m\]\u"  # Ярко-оранжевый (жирный)
    HOST_NAME="\[\033[1;38;5;39m\]\h"   # Ярко-голубой
    SYMBOL="\[\033[1;38;5;196m\]#"      # Ярко-красный #
    PS1="\
${LINE_COLOR}${LINE_CORNER_1}${LINE_VERTICAL} ${USER_NAME} ${HOST_NAME}\n\
${LINE_COLOR}${LINE_CROSS}${LINE_VERTICAL} ${DIR_COLOR}${DIR}\n\
${LINE_COLOR}${LINE_CORNER_2}${LINE_VERTICAL} ${SYMBOL} ${INPUT_COLOR}"
else
    # Стиль для обычного пользователя (2 строки)
    USER_NAME="\[\033[1;38;5;46m\]\u"   # Ярко-зелёный
    HOST_NAME="\[\033[1;38;5;39m\]\h"   # Ярко-голубой
    SYMBOL="\[\033[1;38;5;196m\]\$"     # Ярко-красный $
    PS1="\
${LINE_COLOR}${LINE_CORNER_1}${LINE_VERTICAL} ${USER_NAME} ${DIR_COLOR}${DIR}\n\
${LINE_COLOR}${LINE_CORNER_2}${LINE_VERTICAL} ${SYMBOL} ${INPUT_COLOR}"
fi

# цветной bash
# https://pingvinus.ru/note/bash-promt
# https://ziggi.org/cveta-v-terminale/
# https://gist.github.com/ziggi/a873de4c020c4752a889
