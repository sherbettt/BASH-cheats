#!/bin/bash

USER_ID="955ab5fe-7638-46d3-8027-aea3bb13d993"  # Кирилл Кораблин

echo "Ресурсы, где пользователь является владельцем:"
passbolt list resources -j 2>/dev/null | jq -r '.[].id' | while read resource_id; do
    PERM=$(passbolt get resource permission --id $resource_id -j 2>/dev/null | \
           jq --arg uid "$USER_ID" '.[] | select(.aro_foreign_key == $uid and .type==15)')
    
    if [ -n "$PERM" ] && [ "$PERM" != "null" ]; then
        RESOURCE=$(passbolt get resource --id $resource_id -j 2>/dev/null)
        NAME=$(echo $RESOURCE | jq -r '.name')
        USERNAME=$(echo $RESOURCE | jq -r '.username')
        echo "  - $NAME ($USERNAME)"
    fi
done
