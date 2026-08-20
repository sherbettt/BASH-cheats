#!/bin/bash

set -e

# Определение цветов для оформления вывода
GREEN='\033[0;32m'   # Зеленый - для команд
BLUE='\033[0;34m'    # Синий - для заголовков
NC='\033[0m'         # No Color - сброс цвета

services=(
        runtel-dialog-common-cpu
        runtel-dialog-common-gpu-vulkan
        runtel-dialog-llm-cpu
        runtel-dialog-llm-gpu-vulkan
        runtel-plugin-vits-tts
        runtel-tinypbx
)

systemctl status "${services[@]/%/.service}" -l --no-pager || true
echo ""  


for p in "${services[@]}"; do
    echo -e "${GREEN}▶ systemctl is-enabled $p${NC}"
    systemctl is-enabled "$p" 2>/dev/null || echo "disabled/not found"
done
echo ""  

for p in "${services[@]}"; do
    echo -e "${GREEN}▶ apt policy $p${NC}"
    apt-cache policy "$p" 2>/dev/null | head -5 || echo "  not found"
    echo "" 
done

