# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

#export EDITOR=/usr/bin/vim
export EDITOR=/usr/bin/mcedit
export VISUAL=$EDITOR

# Simple color PS1
# PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]'
# PS1='${debian_chroot:+($debian_chroot)}\[\033[01;33m\]\u\[\033[01;36m\]@\[\033[01;38;5;85m\]\h \[\033[01;36m\]\w \[\033[01;35m\]>\[\033[00m\] '

# Complex PS1
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
${LINE_COLOR}${LINE_CORNER_1}${LINE_VERTICAL} ${USER_NAME}\n\
${LINE_COLOR}${LINE_CROSS}${LINE_VERTICAL} ${HOST_NAME} ${DIR_COLOR}${DIR}\n\
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


# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

# color aliases
export LS_OPTIONS='--color=auto'
eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
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
alias ll='ls -alFS --group-directories-first --si'
alias llt='ll --time-style=+%F_%X'
alias la='ls -A'
alias l='ls -CF'
alias pcat='pygmentize -g'
alias ccat='highlight --out-format=xterm256 --syntax=yaml --style=molokai'
alias batc='bat --config-dir; bat --cache-dir' # for Ubuntu is batcat, for ohther - bat
alias batp='bat -p -S'
alias getip="curl ifconfig.me ; echo"
alias getip2='curl 2ip.ru ; echo'
  # curl -s https://yandex.ru/internet | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}'
alias localip='ifconfig | grep "inet " | grep -v 127.0.0.1'
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


# цветной bash
# https://pingvinus.ru/note/bash-promt
# https://ziggi.org/cveta-v-terminale/
# https://gist.github.com/ziggi/a873de4c020c4752a889
