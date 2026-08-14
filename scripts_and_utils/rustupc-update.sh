#!/bin/bash

# Определяем цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Провекра зависимостей
echo -e "${YELLOW}Checking dependencies...${NC}"
if ! command -v pkg-config &> /dev/null; then
    echo -e "${YELLOW}Installing pkg-config...${NC}"
    apt-get update && apt-get install -y pkg-config
fi

if ! dpkg -l | grep -q libssl-dev; then
    echo -e "${YELLOW}Installing libssl-dev...${NC}"
    apt-get update && apt-get install -y libssl-dev
fi

cargo install cargo-update
printf "${YELLOW}=== rustup update stable ===${NC}\n"
rustup update stable

cargo --version
rustc --version
rustup --version

printf "${YELLOW}=== rust utils list ===${NC}\n"
cargo install --list

printf "${YELLOW}=== cargo update utils ===${NC}\n"
cargo install-update -a
