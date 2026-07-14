#!/bin/bash

# Определяем цвета
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -eux

echo -e "${YELLOW}Удалить старые ключи${NC}"
rm -f /etc/apt/trusted.gpg.d/runtel.gpg
rm -f /etc/apt/keyrings/runtel.gpg
ls -alF /etc/apt/trusted.gpg.d/
ls -alF /etc/apt/keyrings/
echo "------"

echo -e "${YELLOW}Удалить дублирующиеся файлы репозиториев${NC}"
rm -f /etc/apt/sources.list.d/runtel.list
rm -f /etc/apt/sources.list.d/repo_runtel_ru.list
ls -alF /etc/apt/sources.list.d/
echo "------"

echo "Создать директорию для ключей (если её нет)"
mkdir -p /etc/apt/keyrings
ls -alF /etc/apt/keyrings

echo "Скачать ключ и конвертировать в правильный формат"
wget -qO- http://repo.runtel.ru/runtel.gpg | gpg --dearmor > /etc/apt/keyrings/runtel-archive-keyring.gpg

echo "Скопировать ключ в доверенные ключи APT (для совместимости)"
cp /etc/apt/keyrings/runtel-archive-keyring.gpg /etc/apt/trusted.gpg.d/
echo "------"

echo "${GREEN}Проверить, что ключ установлен${NC}"
gpg --show-keys /etc/apt/keyrings/runtel-archive-keyring.gpg
echo""

echo "Создать файл в формате deb822"
cat > /etc/apt/sources.list.d/runtel.sources << 'EOF'
# Runtel repositories - Debian 13 Trixie
Types: deb
URIs: http://repo.runtel.ru
Suites: trixie
Components: main dev
Signed-By: /etc/apt/keyrings/runtel-archive-keyring.gpg
EOF

echo "Обновить списки"
apt clean
apt update -y
