## скрипт для автоматического мониторинга

Создадим утилиту для быстрой проверки системы:

```bash
sudo mcedit /usr/local/bin/os-status
```

```bash
#!/bin/bash
echo "=== OS System Status ==="
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime -p)"
echo "Load: $(cat /proc/loadavg | awk '{print $1}')"
echo "Memory: $(free -h | awk '/Mem:/ {print $3 "/" $2}')"
echo "Disk: $(df -h / | awk 'NR==2 {print $4 " free"}')"
```

```bash
sudo chmod +x /usr/local/bin/os-status
```

Очистить кэш
```bash
hash -r
```

Проверить переменную PATH
```bash
echo -e ${PATH//:/\\n}
```
Если там есть **`/usr/local/bin`**, то можно напрямую обращаться к **`os-status`**.
