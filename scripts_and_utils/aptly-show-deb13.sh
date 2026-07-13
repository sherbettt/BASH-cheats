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

printf "${YELLOW}=== aptly repo show runtel-trixie-dev ===${NC}\n"
aptly repo show runtel-trixie-dev
echo

printf "${YELLOW}=== aptly repo show runtel-trixie ===${NC}\n"
aptly repo show runtel-trixie
echo

printf "${YELLOW}=== aptly repo search runtel-trixie (25 objects) ===${NC}\n"
aptly repo search runtel-trixie | head -25
echo

printf "${YELLOW}=== aptly repo show -with-packages runtel-trixie ===${NC}\n"
aptly repo show -with-packages runtel-trixie | head -25
echo

printf "${YELLOW}=== Update publication ===${NC}\n"
aptly publish update trixie
echo

printf "${RED}=== debs folder should be cleared after Ansible playbook ===${NC}\n"
ls -alF /tmp/debs/
ls -alF /tmp/debs/deb13/
echo -e "${MAGENTA}================${NC}"
