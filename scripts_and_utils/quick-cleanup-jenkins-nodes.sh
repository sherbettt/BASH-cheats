#!/bin/bash
# Безопасная очистка с подтверждением

WS="/var/lib/jenkins/workspace/"
HOSTS="deb13-builder deb12-builder deb11-builder deb10-builder astra-builder redos7-builder"

# Показываем, что будет удалено
echo "This will remove all .deb, .tar.gz, .tar files from:"
for h in $HOSTS; do
    echo "  - $h:$WS"
done

read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted"
    exit 1
fi

# Очистка
for h in $HOSTS; do
    echo "=== Cleaning $h ==="
    ssh root@"$h" "
        echo 'Files to remove:'
        find ${WS} -maxdepth 1 -type f \( -name '*.deb' -o -name '*.tar.gz' -o -name '*.tar' \) -ls 2>/dev/null | wc -l
        
        echo 'Removing...'
        rm -vf ${WS}*.{deb,tar.gz,tar} 2>/dev/null
        
        echo 'After cleanup:'
        df -kh / | tail -1
    "
    echo
done
