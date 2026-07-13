#!/bin/bash

# Определяем цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'


WORKSPACE_JENKINS="/var/lib/jenkins/workspace/"
echo -e "${CYAN}folder: ${BLUE}WORKSPACE_JENKINS=$WORKSPACE_JENKINS ${NC}"

dfrs -H -c

if [ -d "$WORKSPACE_JENKINS" ]; 
then
    rm -rf ${WORKSPACE_JENKINS}runtel-*
    echo -e "${GREEN}WS has been cleared ${NC}"
    ls -alF $WORKSPACE_JENKINS
    dysk
    dfrs -H -c
    # df -kH -T / /home /boot /var 2>/dev/null | grep -v "^tmpfs"
else
    echo -e "${RED}Directory can not be found ${NC}"
    exit 1
fi
