#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

systemctl status runtel-cdr-v2.service runtel-core-v2.service runtel-event-hunter-v2.service runtel-event-sender-v2.service runtel-iface-v2.service runtel-task-v2.service -l --no-pager
echo ""

for p in runtel-cdr-v2 runtel-core-v2 runtel-event-hunter-v2 runtel-iface-v2 runtel-task-v2 runtel-event-sender-v2 runtel-web-v2; do
    echo -e "${GREEN}▶ apt policy $p${NC}"
    apt-cache policy "$p" | head -3
    echo ""
done
