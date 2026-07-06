#!/bin/bash

# Определяем цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

#echo -e "${GREEN}=== Git Pull ===${NC}"
printf "${GREEN}=== Git Pull ===${NC}\n"
git pull;

printf "${YELLOW}=== Git Push to gitflic.ru ===${NC}\n"
git push git@gitflic.ru:kkorablin/bash-cheats.git;

printf "${YELLOW}=== Git Push to gitverse.ru ===${NC}\n"
git push git@gitverse.ru:sherbettt/BASH-cheats.git;

printf "${YELLOW}=== Git Push to gitlab.runtel.org ===${NC}\n"
git push git@gitlab.runtel.org:kkorablin/bash-cheats.git;

printf "${RED}=== The End ===${NC}\n"
