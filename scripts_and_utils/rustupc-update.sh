#!/bin/bash

# Определяем цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# cargo install cargo-update
printf "${YELLOW}=== rustup update stable ===${NC}\n"
rustup update stable

cargo --version
rustc --version
rustup --version

printf "${YELLOW}=== rust utils list ===${NC}\n"
cargo install --list

printf "${YELLOW}=== cargo update utils ===${NC}\n"
cargo install-update -a
