#!/bin/bash

find-by-surname() {
    local SURNAME="$1"
    if [ -z "$SURNAME" ]; then
        echo "Использование: find-by-surname <фамилия>"
        return 1
    fi
    passbolt list user -j 2>/dev/null | \
        jq -r --arg surname "$SURNAME" \
        '.[] | select(.last_name | contains($surname)) | "\(.first_name) \(.last_name) | \(.username) | \(.id)"'
}

# ВЫЗЫВАЕМ ФУНКЦИЮ с аргументом
# ./find-by-surname Сидоров
