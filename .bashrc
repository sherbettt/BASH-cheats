# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

#export EDITOR=/usr/bin/vim
export EDITOR=/usr/bin/mcedit
export VISUAL=$EDITOR

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;33m\]\u\[\033[01;36m\]@\[\033[01;38;5;85m\]\h \[\033[01;36m\]\w \[\033[01;35m\]>\[\033[00m\] '

# Simple color PS1
# Вариант 1: Светло-красный root (91) и ярко-желтый хост (93)
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;91m\]\u\[\033[01;36m\]@\[\033[01;93m\]\h \[\033[01;36m\]\w \[\033[01;32m\]>\[\033[00m\] '

# Вариант 2: Ярко-красный root (31) и желтый хост (33)
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[01;36m\]@\[\033[01;33m\]\h \[\033[01;36m\]\w \[\033[01;32m\]>\[\033[00m\] '

# Автоматическое определение: root красный, обычный пользователь желтый
if [ "$(id -u)" -eq 0 ]; then
    # ROOT пользователь - красный
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;91m\]\u\[\033[01;36m\]@\[\033[01;93m\]\h \[\033[01;36m\]\w \[\033[01;32m\]>\[\033[00m\] '
else
    # Обычный пользователь - желтый
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;33m\]\u\[\033[01;36m\]@\[\033[01;93m\]\h \[\033[01;36m\]\w \[\033[01;32m\]>\[\033[00m\] '
fi


# You may uncomment the following lines if you want `ls' to be colorized:
# export LS_OPTIONS='--color=auto'
# eval "$(dircolors)"
# alias ls='ls $LS_OPTIONS'
# alias ll='ls $LS_OPTIONS -l'
# alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

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
