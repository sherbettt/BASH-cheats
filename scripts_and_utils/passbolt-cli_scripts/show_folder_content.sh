#!/bin/bash
# analyze_folder.sh - полный анализ папки

FOLDER_ID="a4e86d9a-d123-4042-9f98-fa722f20179c"
USER_ID="955ab5fe-7638-46d3-8027-aea3bb13d993"
PARENT_FOLDER_ID="833541ff-b8a3-49d6-9ac2-70d268ba7f5d"

echo "========================================="
echo "АНАЛИЗ ПАПКИ $(passbolt get folder --id $FOLDER_ID -j 2>/dev/null | jq -r '.name')"
echo "ID папки: $FOLDER_ID"
echo "========================================="
echo ""

# 0. Информация о папке Support level1 private folder
echo "📁 Support level1 private folder"
passbolt get folder --id 833541ff-b8a3-49d6-9ac2-70d268ba7f5d
echo ""

echo "📂 ПОДПАПКИ в Support level1 private folder"
passbolt list folders | grep "833541ff-b8a3-49d6-9ac2-70d268ba7f5d"
echo ""

# 1. Информация о папке
echo "📁 ИНФОРМАЦИЯ О ПАПКЕ $(passbolt get folder --id $FOLDER_ID -j 2>/dev/null | jq -r '.name') :"
passbolt get folder --id $FOLDER_ID -j 2>/dev/null | jq '.'
echo ""

# 2. Подпапки
echo "📂 ПОДПАПКИ в $(passbolt get folder --id $FOLDER_ID -j 2>/dev/null | jq -r '.name') :"
# passbolt list folders --filter 'folder_parent_id == "a4e86d9a-d123-4042-9f98-fa722f20179c"'
passbolt list folders -j 2>/dev/null | \
  jq -r --arg fid "$FOLDER_ID" '.[] | select(.folder_parent_id == $fid) | "  - \(.name) (\(.id))"' | \
  sort
echo ""

# 3. Ресурсы
echo "🔐 РЕСУРСЫ папки $(passbolt get folder --id $FOLDER_ID -j 2>/dev/null | jq -r '.name') :"
# passbolt list resources --filter 'folder_parent_id == "a4e86d9a-d123-4042-9f98-fa722f20179c"' -j | jq -r '.[] | "\(.id) | \(.name)"'
passbolt list resources -j 2>/dev/null | \
  jq -r --arg fid "$FOLDER_ID" '.[] | select(.folder_parent_id == $fid) | "  - \(.name) | \(.username) | \(.uri)"' | sort | column -t
echo ""

# 4. Права доступа
echo "👑 ВЛАДЕЛЬЦЫ папки $(passbolt get folder --id $FOLDER_ID -j 2>/dev/null | jq -r '.name') :"
# passbolt get folder permission --id a4e86d9a-d123-4042-9f98-fa722f20179c
passbolt get folder permission --id $FOLDER_ID -j 2>/dev/null | \
  jq -r '.[] | select(.aro=="User" ) | .aro_foreign_key' | \
  while read user_id; do
    USER=$(passbolt get user --id $user_id -j 2>/dev/null)
    if [ -n "$USER" ] && [ "$USER" != "null" ]; then
      echo "  - $(echo $USER | jq -r '"\(.first_name) \(.last_name) (\(.username))"')"
    fi
  done


echo ""
echo "Пользователь Кирилл Кораблин:"
passbolt list user --filter "id == '$USER_ID'"
passbolt list user -j 2>/dev/null | jq -r --arg id "$USER_ID" '.[] | select(.id == $id)'
echo ""

echo "найти пользователя Кирилл Кораблин по id:"
passbolt list user -j | jq -r --arg id "955ab5fe-7638-46d3-8027-aea3bb13d993" '.[] | select(.id == $id) | .username'
echo ""

echo "поиск пользователя Кирилл Кораблин: записать в функцию"
passbolt list user -j 2>/dev/null | jq -r --arg fn 955ab5fe-7638-46d3-8027-aea3bb13d993 '.[] | select((.first_name + " " + .last_name) == $fn) | .id'
echo ""

echo "вывести username пользователя Кирилл Кораблин"
passbolt list user -j 2>/dev/null | jq -r --arg id "955ab5fe-7638-46d3-8027-aea3bb13d993" '.[] | select(.id == $id) | .username'
echo ""

echo "Найти по фамилии (точное совпадение)"
passbolt list user -j 2>/dev/null | jq -r --arg surname "Кораблин" \
  '.[] | select(.last_name == $surname) | "\(.first_name) \(.last_name) | \(.username) | \(.id)"'
echo ""

echo "Найти по фамилии (частичное совпадение)"
passbolt list user -j 2>/dev/null | \
  jq -r --arg part "Кораб" \
  '.[] | select(.last_name | contains($part)) | "\(.first_name) \(.last_name) | \(.username)"'
echo ""

#echo "Список пользователей в Passbolt"
#passbolt list users -j | jq -r '.[] | "\(.id) | \(.username) | \(.role) | \(.first_name) | \(.last_name)"' |   column -t -s '|'

## вывести одно поле
# passbolt get folder permission --id a4e86d9a-d123-4042-9f98-fa722f20179c -j 2>/dev/null | jq -r '.[] | select(.aro=="User" ) | .aro_foreign_key'
## вывести несколько полей
# passbolt get folder permission --id a4e86d9a-d123-4042-9f98-fa722f20179c -j 2>/dev/null | jq -r '.[] | select(.aro=="User") | " \(.aro_foreign_key) |  \(.aco)"'
# passbolt get folder permission --id a4e86d9a-d123-4042-9f98-fa722f20179c -j 2>/dev/null | jq -r '.[] | select(.aro=="User") | "ID: \(.aro_foreign_key) | ACO: \(.aco)"'
