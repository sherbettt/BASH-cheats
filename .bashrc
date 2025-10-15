# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

#export EDITOR=/usr/bin/vim
export EDITOR=/usr/bin/mcedit
export VISUAL=$EDITOR

# Simple color PS1
# Компактный яркий PS1 с полным путем
#PS1='\[\033[1;32m\]\u\[\033[1;36m\]@\[\033[1;35m\]\h \[\033[1;33m\]\w \[\033[1;31m\]\$\[\033[0m\] '

# Или с псевдографикой в одну строку:
#PS1='\[\033[1;37m\]┌─\[\033[1;32m\]\u\[\033[1;36m\]@\[\033[1;35m\]\h \[\033[1;33m\]\w\n\[\033[1;37m\]└─\[\033[1;31m\]\$\[\033[0m\] '


# Complex PS1
# Яркие цвета для PS1
INPUT_COLOR="\[\033[0m\]"
DIR_COLOR="\[\033[1;38;5;208m\]"      # Ярко-оранжевый (жирный)
LINE_COLOR="\[\033[1;37m\]"           # Ярко-белая граница
USER_COLOR="\[\033[1;38;5;46m\]"      # Ярко-зелёный
HOST_COLOR="\[\033[1;38;5;39m\]"      # Ярко-голубой
SYMBOL_COLOR="\[\033[1;38;5;196m\]"   # Ярко-красный

# Псевдографика (Unicode)
LINE_VERTICAL="\342\224\200"          # "─"
LINE_CORNER_1="\342\224\214"          # "┌"
LINE_CORNER_2="\342\224\224"          # "└"

# Для обычного пользователя (2 строки с полным путем)
PS1="\
${LINE_COLOR}${LINE_CORNER_1}${LINE_VERTICAL} ${USER_COLOR}\u${HOST_COLOR}@\h\n\
${LINE_COLOR}${LINE_CORNER_2}${LINE_VERTICAL} ${DIR_COLOR}\w ${SYMBOL_COLOR}\$ ${INPUT_COLOR}"

# Для root (3 строки с полным путем)
if [[ ${EUID} == 0 ]]; then
    PS1="\
${LINE_COLOR}${LINE_CORNER_1}${LINE_VERTICAL} ${USER_COLOR}\u\n\
${LINE_COLOR}${LINE_VERTICAL}${LINE_VERTICAL} ${HOST_COLOR}\h\n\
${LINE_COLOR}${LINE_CORNER_2}${LINE_VERTICAL} ${DIR_COLOR}\w ${SYMBOL_COLOR}# ${INPUT_COLOR}"
fi


# Функция для краткого статуса в PS1
#get_quick_status() {
#    echo -n "[💾$(df -h / --output=pcent 2>/dev/null | tail -1 | tr -d ' ')]"
#}

# PS1 с системной информацией
#PS1="\[\033[1;37m\]┌─\[\033[1;32m\]\u\[\033[1;36m\]@\[\033[1;35m\]\h \$(get_quick_status) \[\033[1;33m\]\w\n\[\033[1;37m\]└─\[\033[1;31m\]\\$\[\033[0m\] "


# ===== СИСТЕМНАЯ ИНФОРМАЦИЯ =====

# Основная функция
show_system_info() {
    echo -e "\033[1;34m=== СИСТЕМНАЯ ИНФОРМАЦИЯ ===\033[0m"
    
    # Диски
    echo -e "\033[1;32m● ДИСКИ:\033[0m"
    df -h / /home /boot 2>/dev/null | grep -v tmpfs | awk 'NR==1 || /\/dev\//'
    
    # Память
    echo -e "\n\033[1;32m● ПАМЯТЬ:\033[0m"
    free -h | awk 'NR==1{print "          " $0} NR==2{print "ОЗУ:    " $0} NR==3{print "Своп:   " $0}'
    
    # Сеть
    echo -e "\n\033[1;32m● СЕТЬ:\033[0m"
    ip -br -c addr show | grep -v "LOOPBACK" | head -3
    
    # Время работы
    echo -e "\n\033[1;32m● ВРЕМЯ РАБОТЫ:\033[0m"
    uptime -p
    echo
}

# Компактная версия
quick_system_info() {
    echo -e "\033[1;36m💾 $(df -h / --output=pcent | tail -1 | tr -d ' ') | 🎯 $(free -h | awk 'NR==2{print $3"/"$2}') | 🌐 $(ip -4 -br addr show | grep -v LOOPBACK | awk '{print $3}' | head -1)\033[0m"
}

# Алиасы
alias sysinfo='show_system_info'
alias sysquick='quick_system_info'

# Автопоказ при SSH подключении
if [ -n "$SSH_CONNECTION" ] && [ -z "$SYSTEM_INFO_SHOWN" ]; then
    show_system_info
    export SYSTEM_INFO_SHOWN=1
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

