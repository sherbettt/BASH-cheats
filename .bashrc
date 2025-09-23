# ~/.bashrc
# The individual per-interactive-shell startup file.

# Source global definitions.
if [ -r /etc/bashrc ]; then
        . /etc/bashrc
fi

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000


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


## Simple PS1
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;38;5;46m\]\u\[\033[01;38;5;226m\]@\[\033[01;38;5;85m\]\h \[\033[01;38;5;226m\]\w\n\[\033[01;38;5;45m\]\t \[\033[01;38;5;201m\]\$ \[\033[00m\]'

if [ "$(id -u)" -eq 0 ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;38;5;196m\]\u\[\033[01;38;5;226m\]@\[\033[01;38;5;85m\]\h \[\033[01;38;5;226m\]\w\n\[\033[01;38;5;45m\]\t \[\033[01;38;5;201m\]\$ \[\033[00m\]'
else
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;38;5;46m\]\u\[\033[01;38;5;226m\]@\[\033[01;38;5;85m\]\h \[\033[01;38;5;226m\]\w\n\[\033[01;38;5;45m\]\t \[\033[01;38;5;201m\]\$ \[\033[00m\]'
fi


# Define user specific aliases and functions.

export EDITOR=/usr/bin/mcedit
export VISUAL=$EDITOR

# Более яркие цвета для LS (KDE)
export LS_COLORS='rs=0:di=01;94:ln=01;36:...'

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
alias ccat='highlight --out-format=xterm256 --syntax=ini'
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
alias freeh='free --si -h'
alias duh='du -kh'
alias dfh='df -kTh'
alias ipc='ip -c addr show'
alias ipa='ip -br -c addr show'
alias lsblk-more='lsblk --output TYPE,PATH,NAME,FSAVAIL,FSUSE%,SIZE,MOUNTPOINT,UUID,FSTYPE,PTTYPE,PARTUUID'
alias mc-visudo='sudo EDITOR=mcedit visudo'

# Power commands
alias shutdown="sudo shutdown -P now"
alias reboot="sudo shutdown -r now"



# PS1
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
    # Стиль для root
    USER_NAME="\[\033[1;38;5;208m\]\u"  # Ярко-оранжевый (жирный)
    HOST_NAME="\[\033[1;38;5;39m\]\h"   # Ярко-голубой
    ARROW="\[\033[1;38;5;196m\]▶"       # Ярко-красная стрелочка
    PS1="\
${LINE_COLOR}${LINE_CORNER_1}${LINE_VERTICAL} ${USER_NAME}\n\
${LINE_COLOR}${LINE_CROSS}${LINE_VERTICAL} ${HOST_NAME} ${DIR_COLOR}\w ${ARROW} ${INPUT_COLOR}"
else
    # Стиль для обычного пользователя
    USER_NAME="\[\033[1;38;5;46m\]\u"   # Ярко-зелёный
    HOST_NAME="\[\033[1;38;5;39m\]@\h"  # Ярко-голубой с символом @
    ARROW="\[\033[1;38;5;85m\]▶"        # Ярко-кислотная зелёная стрелочка
    PS1="\
${LINE_COLOR}${LINE_CORNER_1}${LINE_VERTICAL} ${USER_NAME}${HOST_NAME}\n\
${LINE_COLOR}${LINE_CORNER_2}${LINE_VERTICAL} ${DIR_COLOR}\w ${ARROW} ${INPUT_COLOR}"
fi


# цветной bash
# https://pingvinus.ru/note/bash-promt
# https://ziggi.org/cveta-v-terminale/
# https://gist.github.com/ziggi/a873de4c020c4752a889

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


### Яркие цвета в Konsole, в сессии
# Bright terminal colors
set_bright_colors() {
    # Проверяем что мы в интерактивной сессии и поддерживаем escape-последовательности
    if [[ $- == *i* ]] && [[ -t 1 ]] && [[ "$TERM" != "dumb" ]]; then
        case "$TERM" in
            xterm*|rxvt*|konsole*|screen*|tmux*)
                printf "\e]10;#FFFFFF\a"  # Bright white text
                printf "\e]11;#000000\a"  # Black background
                printf "\e]12;#00FF00\a"  # Green cursor
                ;;
        esac
    fi
}

# Вызываем функцию при запуске bash

# Яркая цветовая схема для терминала
if [[ $- == *i* ]] && [[ -t 1 ]]; then
    # Основные цвета
    printf "\e]10;#FFFFFF\a"  # Текст: ярко-белый
    printf "\e]11;#000000\a"  # Фон: черный
    
    # Цвета ANSI (0-15)
    printf "\e]4;0;#000000\a"   # Black
    printf "\e]4;1;#FF5555\a"   # Bright Red
    printf "\e]4;2;#55FF55\a"   # Bright Green
    printf "\e]4;3;#FFFF55\a"   # Bright Yellow
    printf "\e]4;4;#5555FF\a"   # Bright Blue
    printf "\e]4;5;#FF55FF\a"   # Bright Magenta
    printf "\e]4;6;#55FFFF\a"   # Bright Cyan
    printf "\e]4;7;#FFFFFF\a"   # Bright White
    printf "\e]4;8;#555555\a"   # Bright Black
    printf "\e]4;9;#FF8080\a"   # Bright Red (intense)
    printf "\e]4;10;#80FF80\a"  # Bright Green (intense)
    printf "\e]4;11;#FFFF80\a"  # Bright Yellow (intense)
    printf "\e]4;12;#8080FF\a"  # Bright Blue (intense)
    printf "\e]4;13;#FF80FF\a"  # Bright Magenta (intense)
    printf "\e]4;14;#80FFFF\a"  # Bright Cyan (intense)
    printf "\e]4;15;#FFFFFF\a"  # Bright White (intense)
    
    # Курсор
    printf "\e]12;#00FF00\a"    # Зеленый курсор
fi
set_bright_colors
