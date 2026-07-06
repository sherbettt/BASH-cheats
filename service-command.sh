#!/bin/bash

# Определяем цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color (сброс)

echo -e "${GREEN}=== Git Pull ===${NC}"
git pull;
echo "${YELLOW}=== Git Push to gitflic.ru ===${NC}"
git push git@gitflic.ru:kkorablin/bash-cheats.git;
echo "${YELLOW}=== Git Push to gitverse.ru ===${NC}"
git push git@gitverse.ru:sherbettt/BASH-cheats.git;
echo "${YELLOW}=== Git Push to gitlab.runtel.org ===${NC}"
git push git@gitlab.runtel.org:kkorablin/bash-cheats.git;
echo "${RED}=== The End ===${NC}"
