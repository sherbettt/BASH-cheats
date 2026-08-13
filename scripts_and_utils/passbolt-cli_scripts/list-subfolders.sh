#!/bin/bash

# Функция для просмотра подпапок
list-subfolders() {
    local FOLDER_ID="$1"
    
    # Проверяем, существует ли папка
    FOLDER_NAME=$(passbolt get folder --id "$FOLDER_ID" -j 2>/dev/null | jq -r '.name')
    if [ -z "$FOLDER_NAME" ] || [ "$FOLDER_NAME" = "null" ]; then
        echo "❌ Папка с ID '$FOLDER_ID' не найдена!"
        return 1
    fi
    
    echo "📂 Подпапки для папки: $FOLDER_NAME"
    echo "ID папки: $FOLDER_ID"
    echo "----------------------------------------"
    
    passbolt list folders -j 2>/dev/null | \
        jq -r --arg fid "$FOLDER_ID" \
        '.[] | select(.folder_parent_id == $fid) | "\(.id) | \(.name)"' | \
        sort -t '|' -k2 | \
        column -t -s '|'
}

# Если ID не указан, запрашиваем
if [ -z "$1" ]; then
    echo "📋 Введите ID папки:"
    echo "   (можно получить из 'passbolt list folders')"
    echo ""
    read -p "ID папки: " FOLDER_ID
    
    if [ -z "$FOLDER_ID" ]; then
        echo "❌ ID не введен. Выход."
        exit 1
    fi
else
    FOLDER_ID="$1"
fi

# Вызываем функцию
list-subfolders "$FOLDER_ID"
