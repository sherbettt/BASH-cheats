# ~/.bashrc
# The individual per-interactive-shell startup file.

# Если не интерактивный shell - выходим
case $- in
    *i*) ;;
      *) return;;
esac

# =============================================================================
# ГЛОБАЛЬНЫЕ НАСТРОЙКИ
# =============================================================================

# Source global definitions
if [ -r /etc/bashrc ]; then
    . /etc/bashrc
fi

# =============================================================================
# НАСТРОЙКИ ИСТОРИИ
# =============================================================================

# Не сохранять duplicate lines или lines starting with space
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# Размер истории
HISTSIZE=5000
HISTFILESIZE=10000

# Сохранять многострочные команды как одну строку
shopt -s cmdhist

# Проверять размер окна после каждой команды
shopt -s checkwinsize

# =============================================================================
# ЦВЕТА И ПОДСВЕТКА
# =============================================================================

# Enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# ЯРКИЕ ЦВЕТА ДЛЯ LS (папки - ярко-синие)
export LS_COLORS='rs=0:di=01;94:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:'

# Цвета для man pages
export MANPAGER="less -R --use-color -Dd+r -Du+b"
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin search highlight
export LESS_TERMCAP_se=$'\E[0m'        # reset search highlight
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

# Цвета для GCC
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

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

# Просмотр файлов с подсветкой синтаксиса
if command -v bat &> /dev/null; then
    alias cat='bat --paging=never --style=plain'
    alias batp='bat -p -S'
    alias batc='bat --config-dir; bat --cache-dir'
elif command -v batcat &> /dev/null; then
    alias cat='batcat --paging=never --style=plain'
    alias batp='batcat -p -S'
    alias batc='batcat --config-dir; batcat --cache-dir'
fi

if command -v pygmentize &> /dev/null; then
    alias pcat='pygmentize -g'
fi

if command -v highlight &> /dev/null; then
    alias ccat='highlight --out-format=xterm256 --syntax=yaml --style=molokai'
fi

# Apt алиасы (для Debian/Ubuntu)
if command -v apt &> /dev/null; then
    alias apta='sudo apt update -y && sudo apt upgrade -y && sudo apt dist-upgrade -y'
    alias repo='grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/*'
fi

# Power commands
alias shutdown="sudo shutdown -P now"
alias reboot="sudo shutdown -r now"

# =============================================================================
# ПРОМПТ (PS1) С ЦВЕТАМИ
# =============================================================================

# Функция для определения цвета пользователя
set_prompt() {
    local reset_color='\[\033[00m\]'           # Сброс цвета
    local yellow='\[\033[1;93m\]'              # Ярко-желтый для элементов оформления
    
    if [ "$(id -u)" -eq 0 ]; then
        # ROOT пользователь - √
        local line1_color='\[\033[1;91m\]'     # Ярко-красный
        local line2_color='\[\033[1;92m\]'     # Ярко-зеленый
        local user_display="\u@\h √"           # Пользователь@Хост + предупреждение
    else
        # Обычный пользователь
        local line1_color='\[\033[1;92m\]'     # Ярко-зеленый
        local line2_color='\[\033[1;93m\]'     # Ярко-оранжевый
        local user_display="\u"                # Только пользователь
    fi
    
    # Короткий путь (только текущая папка)
    local current_dir="\W"
    
    # Полный путь (абсолютный путь)
    # local current_dir="\w"
    
    PS1="${yellow}┌─${reset_color} ${line1_color}${user_display}${reset_color}\n${yellow}└─${reset_color} ${line2_color}\t ${current_dir} ▶${reset_color} "
}

# Установка промпта
PROMPT_COMMAND=set_prompt

# =============================================================================
# ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ
# =============================================================================

# Поиск в истории
histgrep() {
    grep --color=auto "$@" ~/.bash_history
}

# Поиск файла
ff() {
    find . -type f -iname "*$*" 2>/dev/null
}

# Подсчет файлов
countfiles() {
    find . -type f | wc -l
}

# Извлечение архивов
extract() {
    if [ -f "$1" ] ; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Создание резервной копии файла
backup() {
    cp "$1" "$1.bak"
}

# Погода
weather() {
    curl -s "wttr.in/$1"
}

# =============================================================================
# ЗАВЕРШЕНИЕ
# =============================================================================

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Приветственное сообщение
echo -e "\033[1;36mBash config loaded successfully!\033[0m"
echo -e "\033[1;33mTerminal features:\033[0m"
echo -e "  • Colors: \033[1;32mOK\033[0m"
echo -e "  • LS colors: \033[1;94mBright blue folders\033[0m"
echo -e "  • Syntax highlighting: \033[1;35mAvailable\033[0m"



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
#set_bright_colors
