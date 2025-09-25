# ~/.bashrc - минималистичный

# Если не интерактивный shell - выходим
case $- in
    *i*) ;;
      *) return;;
esac

# История
HISTSIZE=1000
HISTFILESIZE=2000

# Проверять размер окна
shopt -s checkwinsize

# =============================================================================
# ЦВЕТА ПАПОК
# =============================================================================

# Светло-пурпурные папки
export LS_COLORS='di=01;95:ex=01;32:*.zip=01;31:*.tar=01;31:*.jpg=01;35:*.png=01;35'

# =============================================================================
# АЛИАСЫ С ПОДСВЕТКОЙ
# =============================================================================

# Source aliases file
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Основные команды с подсветкой
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -alF --color=auto --group-directories-first'
alias la='ls -A --color=auto --group-directories-first'
alias l='ls -CF --color=auto --group-directories-first'
alias lz='ls -la --color=auto --group-directories-first'

# Улучшенный ls с временем
alias llt='ls -alF --time-style=+%F_%X --color=auto --group-directories-first'

# Команды с подсветкой
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'
alias dmesg='dmesg --color=always'
alias pacman='pacman --color=auto'

# Безопасность
alias sudo='sudo '

# Утилиты
alias tree='tree -Csu -a --du --dirsfirst'
alias cls='clear'
alias path='echo -e ${PATH//:/\\n}'
alias freeh='free --si -h'
alias duh='du -kh'
alias dfh='df -kTh'
alias h='history'
alias j='jobs -l'

# Сетевые алиасы
alias getip="curl -s ifconfig.me"
alias getip2='curl -s 2ip.ru'
alias localip='ip -c addr show | grep "inet " | grep -v 127.0.0.1'
alias ipc='ip -c addr show'
alias ipa='ip -br -c addr show'

# Системные мониторы
alias lsblk-more='lsblk --output TYPE,PATH,NAME,FSAVAIL,FSUSE%,SIZE,MOUNTPOINT,UUID,FSTYPE,PTTYPE,PARTUUID'

# Редакторы
export EDITOR='/usr/bin/mcedit'
export VISUAL='$EDITOR'
alias mc-visudo='sudo EDITOR=mcedit visudo'

# =============================================================================
# ПРОСТОЙ ПРОМПТ
# =============================================================================

if [ "$(id -u)" -eq 0 ]; then
    PS1='\[\033[1;91m\]\u@\h:\w\$\[\033[00m\] '
else
    PS1='\[\033[1;92m\]\u@\h:\w\$\[\033[00m\] '
fi
