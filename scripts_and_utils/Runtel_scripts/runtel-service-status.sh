#!/bin/bash

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

services=(runtel-cdr-v2 runtel-core-v2 runtel-event-hunter-v2 runtel-iface-v2 runtel-task-v2 runtel-event-sender-v2 runtel-web-v2)

# Статус
systemctl status "${services[@]/%/.service}" -l --no-pager || true
echo ""

# Enabled
for p in "${services[@]}"; do
    echo -e "${GREEN}▶ systemctl is-enabled $p${NC}"
    systemctl is-enabled "$p" 2>/dev/null || echo "disabled/not found"
done
echo ""

# Пакеты
for p in "${services[@]}"; do
    echo -e "${GREEN}▶ apt policy $p${NC}"
    apt-cache policy "$p" 2>/dev/null | head -3 || echo "  not found"
    echo ""
done
