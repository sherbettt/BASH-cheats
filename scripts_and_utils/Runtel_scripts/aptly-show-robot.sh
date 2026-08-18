#!/bin/bash

# Определяем цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color (сброс)

printf "${YELLOW}=== Local repo (aptly repo lis) ===${NC}\n"
aptly repo list 
echo

printf "${GREEN}\n=== Published repo (aptly publish lis) ===${NC}\n"
aptly publish list 
echo

printf "${YELLOW}=== aptly repo show runtel-bookworm-robot ===${NC}\n"
aptly repo show runtel-bookworm-robot
echo

printf "${YELLOW}=== aptly repo search runtel-bookworm-robot ===${NC}\n"
aptly repo search runtel-bookworm-robot | grep -iE '^runtel-*'
echo

#printf "${YELLOW}=== aptly repo show -with-packages runtel-trixie ===${NC}\n"
#aptly repo show -with-packages runtel-bookworm-robot
#echo

printf "${YELLOW}=== Update publication ===${NC}\n"
aptly publish update bookworm 
echo

printf "${RED}=== debs folder should be cleared after Ansible playbook ===${NC}\n"
ls -alF /tmp/debs/
ls -alF /tmp/debs/robot*
echo -e "${MAGENTA}================${NC}"
