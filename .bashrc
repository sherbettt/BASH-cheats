# ~/.bashrc: executed by bash(1) for non-login shells.

# Яркие цвета для терминала
export TERM=xterm-256color

# Editor settings
export EDITOR=/usr/bin/mcedit
export VISUAL=$EDITOR

# Simple color PS1
# Компактный яркий PS1 с полным путем
#PS1='\[\033[1;32m\]\u\[\033[1;36m\]@\[\033[1;35m\]\h \[\033[1;33m\]\w \[\033[1;31m\]\$\[\033[0m\] '


# Яркие цвета для PS1
INPUT_COLOR="\[\033[0m\]"
DIR_COLOR="\[\033[1;38;5;208m\]"      # Ярко-оранжевый (жирный)
LINE_COLOR="\[\033[1;97m\]"           # Ярко-белая граница (97 - самый яркий белый)

# Цвета для обычного пользователя
USER_COLOR="\[\033[1;38;5;46m\]"      # Ярко-зелёный (светло-зелёный)
HOST_COLOR="\[\033[1;38;5;22m\]"      # Тёмно-зелёный жирный
AT_COLOR="\[\033[1;38;5;165m\]"       # Пурпурный для @
SYMBOL_COLOR="\[\033[1;38;5;208m\]"   # Оранжевый для $

# Цвета для root
ROOT_USER_COLOR="\[\033[1;38;5;196m\]"    # Ярко-красный жирный
ROOT_SYMBOL_COLOR="\[\033[1;38;5;208m\]"  # Оранжевый для #

# Псевдографика (Unicode)
LINE_VERTICAL="\342\224\200"          # "─"
LINE_CORNER_1="\342\224\214"          # "┌"
LINE_CORNER_2="\342\224\224"          # "└"

# Для обычного пользователя (2 строки)
PS1="\
${LINE_COLOR}${LINE_CORNER_1}${LINE_VERTICAL} ${USER_COLOR}\u${AT_COLOR}@${HOST_COLOR}\h\n\
${LINE_COLOR}${LINE_CORNER_2}${LINE_VERTICAL} ${DIR_COLOR}\w ${SYMBOL_COLOR}\$ ${INPUT_COLOR}"

# Для root (2 строки, как у пользователя)
if [[ ${EUID} == 0 ]]; then
    PS1="\
${LINE_COLOR}${LINE_CORNER_1}${LINE_VERTICAL} ${ROOT_USER_COLOR}\u${AT_COLOR}@${HOST_COLOR}\h\n\
${LINE_COLOR}${LINE_CORNER_2}${LINE_VERTICAL} ${DIR_COLOR}\w ${ROOT_SYMBOL_COLOR}# ${INPUT_COLOR}"
fi


# Функция для вывода системной информации
sysinfo() {
    echo -e "\033[1;97m┌───────────────────── СИСТЕМНАЯ ИНФОРМАЦИЯ ─────────────────────\033[0m"

    # Сеть
    echo -e "\033[1;96m│ NETWORK:\033[0m"
    ip -br -c addr show | head -5 | while read line; do
        echo -e "\033[1;97m│ \033[1;36m$line\033[0m"
    done

    # Диски
    echo -e "\033[1;97m│\033[0m"
    echo -e "\033[1;93m│ DISKS:\033[0m"
    df -h / /home /boot 2>/dev/null | while read line; do
        echo -e "\033[1;97m│ \033[1;33m$line\033[0m"
    done

    # Память
    echo -e "\033[1;97m│\033[0m"
    echo -e "\033[1;92m│ MEMORY:\033[0m"
    free -h | while read line; do
        echo -e "\033[1;97m│ \033[1;32m$line\033[0m"
    done

    # Время работы системы
    echo -e "\033[1;97m│\033[0m"
    echo -e "\033[1;95m│ UPTIME:\033[0m"
    uptime -p | while read line; do
        echo -e "\033[1;97m│ \033[1;35m$line\033[0m"
    done

    echo -e "\033[1;97m└─────────────────────────────────────────────────────────────────\033[0m"
}

# Вывод информации только при интерактивном shell и при source
if [[ $- == *i* ]]; then
    # Не выводим при каждом source, только при первом запуске терминала
    if [ -z "$BASHRC_LOADED" ]; then
        export BASHRC_LOADED=1
        clear
        echo -e "\033[1;97m"
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║                   .bashrc ЗАГРУЖЕН!                          ║"
        echo "║        Используйте 'sysinfo' для показа информации           ║"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo -e "\033[0m"
        sysinfo
        # Показываем текущий путь при загрузке
        echo -e "\033[1;97m📍 Текущая директория: \033[1;93m$(pwd)\033[0m"
    fi
fi



# Quick system info commands
alias sinfo='sysinfo'
alias status='echo -e "\033[1;97mСистемный статус:\033[0m" && sysinfo'

# Color aliases with brighter colors
export LS_OPTIONS='--color=auto'
eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'

# Bright color aliases
alias ls='ls --color=always'
alias ll='ll --color=always'
alias dir='dir --color=always'
alias grep='grep --color=always'
alias dmesg='dmesg --color=always'
alias gcc='gcc -fdiagnostics-color=always'
alias pacman='pacman --color=always'
alias diff='diff --color=always'

# System monitoring aliases
alias disks='df -hT / /home /boot /var 2>/dev/null | grep -v "^tmpfs"'
alias memory='free -h'
alias network='ip -br -c addr show'
alias connections='ss -tulpn'
alias processes='ps aux --sort=-%cpu | head -10'

# Utility aliases
alias sudo='sudo '
alias tree='tree -Csu -a --du --dirsfirst'
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
alias batc='bat --config-dir; bat --cache-dir'
alias batp='bat -p -S'
alias getip="curl -s ifconfig.me ; echo"
alias getip2='curl -s 2ip.ru ; echo'
   # curl -s https://yandex.ru/internet | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}'
alias localip='ip -br addr show | grep -v "127.0.0.1"'
alias h='history'
alias j='jobs -l'
alias r='rlogin'
alias which='type -all'
alias duk='du -kh'
alias dfk='df -kTh'
alias ipc='ip -c addr show'
alias ipa='ip -br -c addr show'
alias ipr='ip addr show | grep -E "192.168.(87|46|45)\.(2|1)"'
alias lsblk-more='lsblk --output TYPE,PATH,NAME,FSAVAIL,FSUSE%,SIZE,MOUNTPOINT,UUID,FSTYPE,PTTYPE,PARTUUID'
alias mc-visudo='sudo EDITOR=mcedit visudo'


