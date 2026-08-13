#!/bin/bash

# Функция для просмотра подпапок
list-subfolders() {
    local FOLDER_ID="$1"
    if [ -z "$FOLDER_ID" ]; then
        echo "Использование: list-subfolders <folder_id>"
        return 1
    fi
    
    echo "📂 Подпапки:"
    passbolt list folders -j 2>/dev/null | \
        jq -r --arg fid "$FOLDER_ID" \
        '.[] | select(.folder_parent_id == $fid) | "\(.id) | \(.name)"' | \
        sort -t '|' -k2 | \
        column -t -s '|'
}

# Использование:
# ./list-subfolders 833541ff-b8a3-49d6-9ac2-70d268ba7f5d

list-subfolders "$1"
