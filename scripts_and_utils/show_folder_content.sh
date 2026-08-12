#!/bin/bash
# analyze_folder.sh - полный анализ папки

FOLDER_ID="a4e86d9a-d123-4042-9f98-fa722f20179c"

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
  jq -r --arg fid "$FOLDER_ID" '.[] | select(.folder_parent_id == $fid) | "  - \(.name) | \(.username) | \(.uri)"' | \
  sort
echo ""

# 4. Права доступа
echo "👑 Владельцы папки $(passbolt get folder --id $FOLDER_ID -j 2>/dev/null | jq -r '.name') :"
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
#echo "Список пользователей в Passbolt"
#passbolt list users -j | jq -r '.[] | "\(.id) | \(.username) | \(.role) | \(.first_name) | \(.last_name)"' |   column -t -s '|'

