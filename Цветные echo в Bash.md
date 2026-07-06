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

## Способ 2: С использованием функции (более удобно)

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

## Способ 3: С проверкой на успешность команд

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

