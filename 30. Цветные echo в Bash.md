Чтобы сделать цветными `echo` в Bash, нужно использовать **ANSI escape-коды**. Вот несколько способов:

## Способ 1: Прямое использование ANSI-кодов
```bash
#!/bin/bash

# Определяем цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color (сброс)

echo -e "${BLUE}=== Pull form github.com ===${NC}"
git pull git@github.com:sherbettt/PS-cheats.git
echo -e "${GREEN}=== Push to gitflic.ru ===${NC}"
git push git@gitflic.ru:kkorablin/ps-cheats.git
echo -e "${YELLOW}=== Push to gitverse.ru ===${NC}"
git push git@gitverse.ru:sherbettt/PS-cheats.git
echo -e "${MAGENTA}=== Push to gitlab.runtel.org ===${NC}"
git push git@gitlab.runtel.org:kkorablin/ps-cheats.git
```

## Способ 2: Использовать printf
```bash
#!/bin/bash

# Определяем цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

#echo -e "${GREEN}=== Git Pull ===${NC}"
printf "${GREEN}=== Git Pull ===${NC}\n"
git pull;

printf "${YELLOW}=== Git Push to gitflic.ru ===${NC}\n"
git push git@gitflic.ru:kkorablin/bash-cheats.git;

printf "${YELLOW}=== Git Push to gitverse.ru ===${NC}\n"
git push git@gitverse.ru:sherbettt/BASH-cheats.git;

printf "${YELLOW}=== Git Push to gitlab.runtel.org ===${NC}\n"
git push git@gitlab.runtel.org:kkorablin/bash-cheats.git;

printf "${RED}=== The End ===${NC}\n"
```

## Способ 3: С использованием функции (более удобно)
```bash
#!/bin/bash

# Функция для цветного вывода
print_color() {
    local color=$1
    local message=$2
    local NC='\033[0m'
    echo -e "${color}${message}${NC}"
}

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'

print_color "$BLUE" "=== Pull form github.com ==="
git pull git@github.com:sherbettt/PS-cheats.git
print_color "$GREEN" "=== Push to gitflic.ru ==="
git push git@gitflic.ru:kkorablin/ps-cheats.git
print_color "$YELLOW" "=== Push to gitverse.ru ==="
git push git@gitverse.ru:sherbettt/PS-cheats.git
print_color "$MAGENTA" "=== Push to gitlab.runtel.org ==="
git push git@gitlab.runtel.org:kkorablin/ps-cheats.git
```

## Способ 4: С проверкой на успешность команд
```bash
#!/bin/bash

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Pull form github.com ===${NC}"
git pull git@github.com:sherbettt/PS-cheats.git
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Pull successful${NC}"
else
    echo -e "${RED}✗ Pull failed${NC}"
fi

echo -e "${GREEN}=== Push to gitflic.ru ===${NC}"
git push git@gitflic.ru:kkorablin/ps-cheats.git
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Push successful${NC}"
else
    echo -e "${RED}✗ Push failed${NC}"
fi

# ... и так далее для остальных
```

## Таблица цветов

| Цвет | Код | Описание |
|------|-----|----------|
| Красный | `\033[0;31m` | Текст красного цвета |
| Зеленый | `\033[0;32m` | Текст зеленого цвета |
| Желтый | `\033[1;33m` | Ярко-желтый текст |
| Синий | `\033[0;34m` | Текст синего цвета |
| Пурпурный | `\033[0;35m` | Маджента |
| Голубой | `\033[0;36m` | Циан |

**Важно:** Используйте флаг `-e` с `echo` для интерпретации escape-последовательностей и не забывайте сбрасывать цвет с помощью `\033[0m`.

--------------------
<br/>



Расширенный набор цветов для вашего bash-скрипта:

```bash
#!/bin/bash

# Стандартные цвета (обычный текст)
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

# Яркие цвета (жирный текст)
BOLD_BLACK='\033[1;30m'
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'
BOLD_MAGENTA='\033[1;35m'
BOLD_CYAN='\033[1;36m'
BOLD_WHITE='\033[1;37m'

# Приглушённые цвета (тёмные)
DIM_BLACK='\033[2;30m'
DIM_RED='\033[2;31m'
DIM_GREEN='\033[2;32m'
DIM_YELLOW='\033[2;33m'
DIM_BLUE='\033[2;34m'
DIM_MAGENTA='\033[2;35m'
DIM_CYAN='\033[2;36m'
DIM_WHITE='\033[2;37m'

# Цвета фона
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

# Яркие цвета фона
BG_BOLD_BLACK='\033[100m'
BG_BOLD_RED='\033[101m'
BG_BOLD_GREEN='\033[102m'
BG_BOLD_YELLOW='\033[103m'
BG_BOLD_BLUE='\033[104m'
BG_BOLD_MAGENTA='\033[105m'
BG_BOLD_CYAN='\033[106m'
BG_BOLD_WHITE='\033[107m'

# Дополнительные стили
BOLD='\033[1m'          # Жирный
DIM='\033[2m'           # Приглушённый
ITALIC='\033[3m'        # Курсив (не везде работает)
UNDERLINE='\033[4m'     # Подчёркнутый
BLINK='\033[5m'         # Мигающий
REVERSE='\033[7m'       # Инвертированный
HIDDEN='\033[8m'        # Скрытый (невидимый)
STRIKE='\033[9m'        # Зачёркнутый

# Сброс всех стилей
RESET='\033[0m'

# Пример использования
echo -e "${RED}Красный${RESET}"
echo -e "${BOLD_RED}Яркий красный${RESET}"
echo -e "${BG_YELLOW}${BLACK}Чёрный на жёлтом${RESET}"
echo -e "${UNDERLINE}${BLUE}Подчёркнутый синий${RESET}"
echo -e "${BOLD}${MAGENTA}Жирный пурпурный${RESET}"
echo -e "${DIM}${GREEN}Приглушённый зелёный${RESET}"
echo -e "${REVERSE}${CYAN}Инвертированный циан${RESET}"
echo -e "${ITALIC}${YELLOW}Курсивный жёлтый (если поддерживается)${RESET}"
```

### Дополнительные 256-цветные коды (для современных терминалов):
```bash
# 256 цветов (формат: \033[38;5;<номер_цвета>m для текста)
COLOR_1='\033[38;5;1m'    # Красный
COLOR_82='\033[38;5;82m'  # Ярко-зелёный
COLOR_208='\033[38;5;208m' # Оранжевый
COLOR_196='\033[38;5;196m' # Ярко-красный
COLOR_51='\033[38;5;51m'   # Бирюзовый
COLOR_226='\033[38;5;226m' # Жёлтый
COLOR_93='\033[38;5;93m'   # Фиолетовый

# Для фона: \033[48;5;<номер_цвета>m
BG_COLOR_1='\033[48;5;1m'
BG_COLOR_82='\033[48;5;82m'

# Градиентный пример
echo -e "${COLOR_196}Ярко-красный${RESET}"
echo -e "${COLOR_208}Оранжевый${RESET}"
echo -e "${COLOR_226}Жёлтый${RESET}"
echo -e "${COLOR_82}Зелёный${RESET}"
echo -e "${COLOR_51}Бирюзовый${RESET}"
```

### HEX-подобные цвета (True Color, 24-bit):
```bash
# Формат: \033[38;2;<R>;<G>;<B>m для текста
HEX_RED='\033[38;2;255;0;0m'
HEX_GREEN='\033[38;2;0;255;0m'
HEX_BLUE='\033[38;2;0;0;255m'
HEX_ORANGE='\033[38;2;255;165;0m'
HEX_PINK='\033[38;2;255;192;203m'
HEX_PURPLE='\033[38;2;128;0;128m'
HEX_TEAL='\033[38;2;0;128;128m'

# Для фона: \033[48;2;<R>;<G>;<B>m
BG_HEX_RED='\033[48;2;255;0;0m'
BG_HEX_BLUE='\033[48;2;0;0;255m'

echo -e "${HEX_ORANGE}Оранжевый (True Color)${RESET}"
```

### Готовые цветовые схемы:
```bash
# Информационные цвета
INFO="${CYAN}"
SUCCESS="${GREEN}"
WARNING="${YELLOW}"
ERROR="${RED}"
DEBUG="${MAGENTA}"
HIGHLIGHT="${BOLD}${WHITE}"

# Фоновые комбинации
INFO_BG="${BG_BLUE}${WHITE}"
SUCCESS_BG="${BG_GREEN}${BLACK}"
WARNING_BG="${BG_YELLOW}${BLACK}"
ERROR_BG="${BG_RED}${WHITE}"

# Пример с выводом
echo -e "${INFO_BG} ИНФОРМАЦИЯ ${RESET} Система запущена"
echo -e "${SUCCESS_BG} УСПЕХ ${RESET} Операция завершена"
echo -e "${WARNING_BG} ПРЕДУПРЕЖДЕНИЕ ${RESET} Низкий заряд батареи"
echo -e "${ERROR_BG} ОШИБКА ${RESET} Не удалось подключиться"
```

### Функция для цветного вывода:
```bash
# Удобные функции
color_echo() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${RESET}"
}

# Использование
color_echo "$RED" "Это красный текст"
color_echo "$BOLD_GREEN" "Это яркий зелёный текст"
color_echo "${BG_YELLOW}${BLACK}" "Чёрный на жёлтом фоне"
```

### Пример градиентного вывода:
```bash
# Функция для плавного перехода цветов
gradient_text() {
    local text="$1"
    local start_color="$2"
    local end_color="$3"
    
    # Здесь можно реализовать плавный переход между цветами
    # Используя 256-цветную палитру или True Color
    echo -e "${start_color}${text}${RESET}"
}

gradient_text "Градиентный текст" "$COLOR_196" "$COLOR_51"
```
🎨
Этот набор даёт вам полный контроль над цветами в терминале. Выберите подходящие для ваших нужд! 
