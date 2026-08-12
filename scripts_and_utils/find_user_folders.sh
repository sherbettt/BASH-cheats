#!/bin/bash

USER_ID="955ab5fe-7638-46d3-8027-aea3bb13d993"  # Кирилл Кораблин

echo "Папки, где пользователь является владельцем:"
passbolt list folders -j 2>/dev/null | jq -r '.[].id' | while read folder_id; do
    # Проверяем, есть ли у пользователя права OWNER на эту папку
    PERM=$(passbolt get folder permission --id $folder_id -j 2>/dev/null | \
           jq --arg uid "$USER_ID" '.[] | select(.aro_foreign_key == $uid and .type==15)')
    
    if [ -n "$PERM" ] && [ "$PERM" != "null" ]; then
        FOLDER_NAME=$(passbolt get folder --id $folder_id -j 2>/dev/null | jq -r '.name')
        echo "  - $FOLDER_NAME ($folder_id)"
    fi
done

