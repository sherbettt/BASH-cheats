#!/bin/bash

PARENT_FOLDER_ID="833541ff-b8a3-49d6-9ac2-70d268ba7f5d"
FOLDER_ID="a4e86d9a-d123-4042-9f98-fa722f20179c"
FOLDER_NAME=$(passbolt get folder --id $FOLDER_ID -j 2>/dev/null | jq -r '.name')
USER_ID="955ab5fe-7638-46d3-8027-aea3bb13d993"    # Кирилл Кораблин

echo "========================================="
echo "АНАЛИЗ ПАПКИ $FOLDER_NAME"
echo "ID папки: $FOLDER_ID"
echo "========================================="
echo ""

# 0. Информация о папке Support level1 private folder
echo "📁 ИМЯ РОДИТЕЛЬСКОЙ ПАПКИ"
#passbolt get folder --id $PARENT_FOLDER_ID
PARENT_FOLDER_NAME=$(passbolt list folders -j 2>/dev/null | jq -r --arg fid "$PARENT_FOLDER_ID" '.[] | select(.id == $fid) | "\(.name)"')
echo "$PARENT_FOLDER_NAME"
echo ""

echo "📂 ПОДПАПКИ в $PARENT_FOLDER_NAME"
#passbolt list folders | grep "833541ff-b8a3-49d6-9ac2-70d268ba7f5d"
#passbolt list folders --filter "folder_parent_id == '833541ff-b8a3-49d6-9ac2-70d268ba7f5d'"
#passbolt list folders --filter "folder_parent_id == '833541ff-b8a3-49d6-9ac2-70d268ba7f5d'" -j | jq -r '.[] | "\(.id) | \(.name)"' | sort -t '|' -k2 | column -t -s '|'

passbolt list folders -j 2>/dev/null | jq -r --arg fid "$PARENT_FOLDER_ID" '.[] | select(.folder_parent_id == $fid) | "  - \(.name) (\(.id))"' | sort | column -t
echo ""



# 1. Информация о пользователе Кирилл Кораблин
echo "👤 ПОЛНОЕ ИНФО о пользователь $USER_ID (Кирилл Кораблин):"
#passbolt list user --filter "id == '$USER_ID'"
passbolt list user -j 2>/dev/null | jq -r --arg id "$USER_ID" '.[] | select(.id == $id)'
echo ""

echo "Вывести (имя + фамилия) $USER_ID (Кирилл Кораблин):"
USERNAME_FN_LN=$(passbolt list user -j | jq -r --arg id "955ab5fe-7638-46d3-8027-aea3bb13d993" '.[] | select(.id == $id) | "\(.first_name) \(.last_name)"')
echo "$USERNAME_FN_LN"
echo ""

echo "Вывести username пользователя $USERNAME_FN_LN по id=$USER_ID:"
USERNAME=$(passbolt list user -j | jq -r --arg id "$USER_ID" '.[] | select(.id == $id) | .username')
echo "$USERNAME"
echo ""

echo "Найти по фамилии (точное совпадение) через аргумент jq"
passbolt list user -j 2>/dev/null | jq -r --arg surname "Кораблин" '.[] | select(.last_name == $surname) | "\(.first_name) \(.last_name) | \(.username) | \(.id)"'
echo ""

echo "Найти по фамилии (частичное совпадение) через аргумент jq"
passbolt list user -j 2>/dev/null | jq -r --arg part "Кораб" '.[] | select(.last_name | contains($part)) | "\(.first_name) \(.last_name) | \(.username)"'
echo ""


# 2. Информация о папке
echo "📁 ПОЛНАЯ ИНФОРМАЦИЯ О ПАПКЕ '$(passbolt get folder --id $FOLDER_ID -j 2>/dev/null | jq -r '.name')' :"
passbolt get folder --id $FOLDER_ID -j 2>/dev/null | jq '.'
echo ""

echo "❓ Ищем пользователя, чьё имя+фамилия совпадают с именем папки ? ¿"
OWNER_ID=$(passbolt list user -j 2>/dev/null | jq -r --arg fn "$FOLDER_NAME" '.[] | select((.first_name + " " + .last_name) == $fn) | .id')
OWNER_USER=$(passbolt list user -j 2>/dev/null | jq -r --arg fn "$FOLDER_NAME" '.[] | select((.first_name + " " + .last_name) == $fn) | "\(.username) - \(.first_name) \(.last_name)" '
)
echo "Найденный USERNAME: $OWNER_USER"
echo "Найденный ID: $OWNER_ID"
echo ""


# 3. Подпапки
echo "📂 ПОДПАПКИ в $(passbolt get folder --id $FOLDER_ID -j 2>/dev/null | jq -r '.name') :"
# passbolt list folders --filter 'folder_parent_id == "a4e86d9a-d123-4042-9f98-fa722f20179c"'
passbolt list folders -j 2>/dev/null | jq -r --arg fid "$FOLDER_ID" '.[] | select(.folder_parent_id == $fid) | "  - \(.name) (\(.id))"' | sort
echo ""

# 4. Ресурсы
echo "🔐 РЕСУРСЫ папки $(passbolt get folder --id $FOLDER_ID -j 2>/dev/null | jq -r '.name') :"
# passbolt list resources --filter 'folder_parent_id == "a4e86d9a-d123-4042-9f98-fa722f20179c"' -j | jq -r '.[] | "\(.id) | \(.name)"'
passbolt list resources -j 2>/dev/null | \
  jq -r --arg fid "$FOLDER_ID" '.[] | select(.folder_parent_id == $fid) | "  - \(.name) | \(.username) | \(.uri)"' | sort | column -t
echo ""

# 5. Права доступа
echo "👑 ВЛАДЕЛЬЦЫ папки $(passbolt get folder --id $FOLDER_ID -j 2>/dev/null | jq -r '.name') :"
# passbolt get folder permission --id a4e86d9a-d123-4042-9f98-fa722f20179c
passbolt get folder permission --id $FOLDER_ID -j 2>/dev/null | jq -r '.[] | select(.aro=="User") | .aro_foreign_key' | \
  while read user_id; do
    USER=$(passbolt get user --id $user_id -j 2>/dev/null)
    if [ -n "$USER" ] && [ "$USER" != "null" ]; then
      NAME=$(echo $USER | jq -r '"\(.first_name) \(.last_name)"')
      USERNAME=$(echo $USER | jq -r '.username')
      ROLE=$(echo $USER | jq -r '.role')
      echo "Role: $ROLE | Пользователь: $NAME | ID: $user_id | Username: $USERNAME"
    fi
  done | column -t -s '|' -t
echo ""


#echo "Список пользователей в Passbolt"
#passbolt list users -j | jq -r '.[] | "\(.id) | \(.username) | \(.role) | \(.first_name) | \(.last_name)"' |   column -t -s '|'

## вывести одно поле
# passbolt get folder permission --id a4e86d9a-d123-4042-9f98-fa722f20179c -j 2>/dev/null | jq -r '.[] | select(.aro=="User" ) | .aro_foreign_key'
## вывести несколько полей
# passbolt get folder permission --id a4e86d9a-d123-4042-9f98-fa722f20179c -j 2>/dev/null | jq -r '.[] | select(.aro=="User") | " \(.aro_foreign_key) |  \(.aco)"'
# passbolt get folder permission --id a4e86d9a-d123-4042-9f98-fa722f20179c -j 2>/dev/null | jq -r '.[] | select(.aro=="User") | "ID: \(.aro_foreign_key) | ACO: \(.aco)"'
