Добавляем запись в крон:
```cron
## micro /etc/crontab

# Full SKUD restart
30 3    * * *   root    /usr/local/bin/restart-skud.sh >> /var/log/skud-restart.log 2>&1
```

Пишем скрипт проверки состояния служб , которые подключаются к ironlogic контроллеру и конвертерам:
```bash
#!/bin/bash

# определяем цвета
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_RED='\033[1;31m'
BOLD_MAGENTA='\033[1;35m'
BLINK='\033[5m'
NC='\033[0m'

LOG_FILE="/var/log/skud-restart.log"
MAX_LOG_SIZE=15728640  # 15 МБ
#MAX_LOG_SIZE=5242880     # 5 МБ
#MAX_LOG_SIZE=52428800    # 50 МБ

# Ротация логов
if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0) -gt $MAX_LOG_SIZE ]; then
    mv "$LOG_FILE" "${LOG_FILE}.old"
    echo "$(TZ=Europe/Moscow date '+%Y-%m-%d %H:%M:%S'): Лог ротирован" > "$LOG_FILE"
fi

# Функция логирования
log_message() {
    local msg=$1
    local timestamp=$(TZ=Europe/Moscow date '+%Y-%m-%d %H:%M:%S')
    
    # Пишем в лог без ANSI кодов
    echo "$timestamp: $(echo -e "$msg" | sed -r 's/\x1B\[[0-9;]*[mK]//g')" >> "$LOG_FILE"
}

# Функция для вывода и логирования
echo_log() {
    echo -e "$1"
    log_message "$1"
}

echo "=== Full SKUD restart ==="
echo ""
log_message "=== START ==="

ERROR_COUNT=$(journalctl -u controller_sync.service --since "5 minutes ago" | grep -c "ilg_converter_connect.*lost")

echo_log "${BLINK}${BOLD_MAGENTA}Найдено ошибок за последние 5 мин: $ERROR_COUNT${NC}"

if [ $ERROR_COUNT -gt 0 ]; then
    echo_log "${BOLD_RED}Обнаружены проблемы подключения к конвертеру (кол-во ошибок: $ERROR_COUNT)${NC}"
    echo_log "${BOLD_YELLOW}Пытаемся рестартовать сервисы skud.service и controller_sync.service${NC}"
    
    systemctl restart skud.service controller_sync.service
    RC=$?
    
    if [ $RC -eq 0 ]; then
        echo_log "${BOLD_GREEN}Рестарт выполнен успешно${NC}"
        log_message "Рестарт выполнен. Ошибок: $ERROR_COUNT"
    else
        echo_log "${BOLD_RED}ОШИБКА рестарта! Код: $RC${NC}"
        log_message "ОШИБКА рестарта! Код: $RC. Ошибок: $ERROR_COUNT"
    fi
else
    echo_log "${BOLD_GREEN}Подключения к конвертеру без ошибок${NC}"
    echo_log "${BOLD_YELLOW}Обязательный рестарт для cron задачи${NC}"
    
    systemctl restart skud.service controller_sync.service
    RC=$?
    
    if [ $RC -eq 0 ]; then
        echo_log "${BOLD_GREEN}Рестарт выполнен успешно${NC}"
        log_message "Плановый рестарт выполнен. Ошибок: $ERROR_COUNT"
    else
        echo_log "${BOLD_RED}ОШИБКА рестарта! Код: $RC${NC}"
        log_message "ОШИБКА планового рестарта! Код: $RC. Ошибок: $ERROR_COUNT"
    fi
fi

echo_log "${BOLD_YELLOW}Ждём 60 секунд...${NC}"
sleep 60

# Сохраняем статус в лог
log_message "=== STATUS ==="
systemctl status skud.service controller_sync.service -l --no-pager >> "$LOG_FILE" 2>&1
log_message "=== STATUS END ==="

# Показываем на экране
systemctl status skud.service controller_sync.service -l --no-pager
echo "================"

# Дополнительная диагностика
echo_log "${BOLD_YELLOW}Проверка конвертеров:${NC}"

for ip in "192.168.97.232" "192.168.97.161"; do
    echo_log "Проверка $ip:"
    
    # Ping
    if ping -c 2 -W 2 $ip &>/dev/null; then
        echo_log " Ping: OK ✅"
    else
        echo_log " Ping: FAIL ❌"
    fi
    
    # TCP
    if nc -zv -w 3 $ip 1000 2>&1 | grep -q "succeeded\|Connected"; then
        echo_log "  ✅ TCP 1000: OK"
    else
        echo_log "  ❌ TCP 1000: FAIL"
    fi

    # UDP
    if nc -vuz -w 3 $ip 1000 2>&1 | grep -q "succeeded\|Connected"; then
        echo_log "  ✅ UDP 1000: OK"
    else
        echo_log "  ❌ UDP 1000: FAIL"
    fi
done

log_message "=== END ==="
echo ""
echo "Задача cron на перезагрузку:"
cat -n /etc/crontab | grep "restart-skud.sh"
```



