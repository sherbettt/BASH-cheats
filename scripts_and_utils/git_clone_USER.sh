#!/bin/bash

# ==================== НАСТРОЙКА ЦВЕТОВ ДЛЯ ВЫВОДА ====================

# Стандартные цвета (обычный текст)
RED='\033[0;31m'          # Красный цвет
GREEN='\033[0;32m'        # Зеленый цвет
YELLOW='\033[0;33m'       # Желтый цвет
BLUE='\033[0;34m'         # Синий цвет
MAGENTA='\033[0;35m'      # Пурпурный цвет
CYAN='\033[0;36m'         # Голубой цвет

# Яркие цвета (жирный текст)
BOLD_RED='\033[1;31m'     # Яркий красный (жирный)
BOLD_GREEN='\033[1;32m'   # Яркий зеленый (жирный)
BOLD_YELLOW='\033[1;33m'  # Яркий желтый (жирный)
BOLD_BLUE='\033[1;34m'    # Яркий синий (жирный)
BOLD_MAGENTA='\033[1;35m' # Яркий пурпурный (жирный)
BOLD_CYAN='\033[1;36m'    # Яркий голубой (жирный)

# Сброс всех стилей (возврат к стандартному оформлению)
NC='\033[0m'              # No Color - отключает все стили

# ==================== СОЗДАНИЕ БАЗОВОЙ ДИРЕКТОРИИ ====================

# Создаем базовую директорию для всех репозиториев
# -p означает "создать все родительские директории, если их нет"
# $USER - переменная окружения с именем текущего пользователя
BASE_DIR="/home/$USER/projects/$USER"
mkdir -p "$BASE_DIR"      # Создаем директорию (если уже есть - пропускаем)

# Переходим в созданную директорию
# || exit 1 - если cd не удался (например, нет прав), выходим с кодом ошибки 1
cd "$BASE_DIR" || exit 1

# ==================== ФУНКЦИЯ ДЛЯ РАБОТЫ С РЕПОЗИТОРИЯМИ ====================

# Функция принимает два аргумента:
#   $1 - имя репозитория (например, "Ansible-cheats")
#   $2 - URL для клонирования (например, "git@github.com:sherbettt/Ansible-cheats.git")
clone_or_update() {
    # Локальные переменные внутри функции
    local repo_name="$1"                    # Имя репозитория
    local repo_url="$2"                     # URL репозитория
    local repo_dir="$BASE_DIR/$repo_name"   # Полный путь к директории репозитория

    # Выводим заголовок с именем репозитория в ярком зеленом цвете
    printf "${BOLD_GREEN}=== Processing: $repo_name ===${NC}\n"

    # Проверяем, существует ли директория репозитория
    # -d проверяет, что это директория и она существует
    if [ -d "$repo_dir" ]; then
        # === РЕПОЗИТОРИЙ УЖЕ СУЩЕСТВУЕТ - ДЕЛАЕМ PULL ===

        # Выводим сообщение желтым цветом
        printf "${YELLOW}Repository exists, updating...${NC}\n"

        # Переходим в директорию репозитория
        # || return 1 - если не удалось перейти, выходим из функции с кодом 1
        cd "$repo_dir" || return 1

        # Выполняем git pull для обновления
        git pull

        # Возвращаемся в базовую директорию
        # || return 1 - если не удалось вернуться, выходим из функции с кодом 1
        cd "$BASE_DIR" || return 1

        # Выводим сообщение об успешном обновлении зеленым цветом
        printf "${GREEN}✓ Updated $repo_name${NC}\n"
    else
        # === РЕПОЗИТОРИЯ НЕТ - КЛОНИРУЕМ ===

        # Выводим сообщение голубым цветом
        printf "${CYAN}Cloning new repository...${NC}\n"

        # Клонируем репозиторий по URL в указанную директорию
        git clone "$repo_url" "$repo_dir"

        # Проверяем код возврата последней команды (git clone)
        # $? - содержит код возврата последней выполненной команды
        # 0 - успех, любое другое число - ошибка
        if [ $? -eq 0 ]; then
            # Если клонирование успешно - выводим зеленое сообщение
            printf "${GREEN}✓ Cloned $repo_name${NC}\n"
        else
            # Если ошибка - выводим красное сообщение
            printf "${RED}✗ Failed to clone $repo_name${NC}\n"
            # Возвращаем код ошибки 1 из функции
            return 1
        fi
    fi

    # Выводим пустую строку для визуального разделения между репозиториями
    echo ""
}

# ==================== СПИСОК РЕПОЗИТОРИЕВ ====================

# Массив строк, где каждая строка содержит: "имя URL"
# Пробел используется как разделитель между именем и URL
repositories=(
    "Ansible-cheats git@github.com:sherbettt/Ansible-cheats.git"
    "BASH-cheats git@github.com:sherbettt/BASH-cheats.git"
    "create_ssh_users git@github.com:sherbettt/create_ssh_users.git"
    "deb-prepare git@github.com:sherbettt/deb-prepare.git"
    "Disk-monitoring git@github.com:sherbettt/Disk-monitoring.git"
    "GIT-cheats git@github.com:sherbettt/GIT-cheats.git"
    "Groovy-cheats git@github.com:sherbettt/Groovy-cheats.git"
    "Jenkins-cheats git@github.com:sherbettt/Jenkins-cheats.git"
    "killall_process git@github.com:sherbettt/killall_process.git"
    "MikroTik-hAP-ax- git@github.com:sherbettt/MikroTik-hAP-ax-.git"
    "PS-cheats git@github.com:sherbettt/PS-cheats.git"
    "qm_ct_check git@github.com:sherbettt/qm_ct_check.git"
    "guessinggame git@github.com:sherbettt/guessinggame.git"
    #"guessinggame https://github.com/sherbettt/guessinggame.git"
)

# ==================== ОСНОВНОЙ ЦИКЛ ОБРАБОТКИ ====================

# Цикл for проходится по каждому элементу массива repositories
for repo in "${repositories[@]}"; do
    # Разбиваем строку на две части по пробелу
    # IFS=' ' - устанавливаем разделитель полей в пробел
    # read -r name url - читаем строку и распределяем по переменным name и url
    # <<< "$repo" - передаем строку на вход read (здесь-строка)
    IFS=' ' read -r name url <<< "$repo"

    # Вызываем функцию с именем и URL репозитория
    clone_or_update "$name" "$url"
done

# ==================== ЗАВЕРШЕНИЕ ====================

# Выводим финальное сообщение об успешном завершении
printf "${BOLD_GREEN}=== All repositories processed! ===${NC}\n"


# $1 и $2 - это позиционные параметры (positional parameters), которые означают порядок передачи аргументов в функцию или скрипт.
# Когда вы вызываете функцию:
#  clone_or_update "Ansible-cheats" "git@github.com:sherbettt/Ansible-cheats.git"
#                  ^^^^^^^^^^^^^^^ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#                        $1                           $2

# local - объявляет переменные видимыми только внутри функции
# $? - код возврата последней выполненной команды (0 = успех)
# || - логическое ИЛИ, выполняется если предыдущая команда завершилась с ошибкой
# IFS=' ' - временно меняет разделитель полей для разбора строки
# <<< "$repo" - "здесь-строка" (here-string), передает строку как входные данные
# -d - проверяет, существует ли директория
# -eq - оператор сравнения "равно" для чисел

