# Настройка красивого MOTD на Debian

## 📌 Что такое MOTD?

**MOTD** (Message of The Day) — это приветственное сообщение, которое отображается при входе в систему через SSH или локальный терминал. 
В современных Debian-системах оно генерируется динамически из скриптов в директории `/etc/update-motd.d/`.

---

## 🗂️ Структура MOTD

```
/etc/update-motd.d/
├── 00-header      # Заголовок с логотипом
├── 10-uname       # Информация о ресурсах (память, диск, нагрузка)
├── 20-sysinfo     # Системная информация (ОС, ядро, аптайм)
├── 30-network     # Сетевая информация (IP, соединения)
└── 99-footer      # Подвал с подсказками
```

**Важно:** Скрипты выполняются в **числовом порядке** (00, 10, 20, 30, 99).

---

## Шаг 1: Проверка текущего состояния

```bash
# Проверить существующие скрипты
ls -la /etc/update-motd.d/

# Посмотреть текущее приветствие
run-parts /etc/update-motd.d/
```

---

## Шаг 2: Создание скриптов

### 2.1.1 Заголовок с логотипом RUNTEL (`00-header`)
```bash
cat > /etc/update-motd.d/00-header << 'EOF'
#!/bin/sh

# Header with Runtel logo
echo -e "\033[1;31m  ██████╗ ██╗   ██╗███╗   ██╗████████╗███████╗██╗     \033[0m"
echo -e "\033[1;31m  ██╔══██╗██║   ██║████╗  ██║╚══██╔══╝██╔════╝██║     \033[0m"
echo -e "\033[1;31m  ██████╔╝██║   ██║██╔██╗ ██║   ██║   █████╗  ██║     \033[0m"
echo -e "\033[1;31m  ██╔══██╗██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██║     \033[0m"
echo -e "\033[1;31m  ██║  ██║╚██████╔╝██║ ╚████║   ██║   ███████╗███████╗\033[0m"
echo -e "\033[1;31m  ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚══════╝\033[0m"
echo -e "\033[1;36m  RUNTEL GNU/Linux 13 (trixie)\033[0m"
echo ""
EOF

chmod +x /etc/update-motd.d/00-header
```

### 2.1.2 ASCII-арт Debian с цветами (`00-header`)
```bash
cat > /etc/update-motd.d/00-header << 'EOF'
#!/bin/sh

# RUNTEL ASCII art
echo -e "\033[1;31m   ██████╗ ██╗   ██╗███╗   ██╗████████╗███████╗██╗     \033[0m"
echo -e "\033[1;32m   ██╔══██╗██║   ██║████╗  ██║╚══██╔══╝██╔════╝██║     \033[0m"
echo -e "\033[1;33m   ██████╔╝██║   ██║██╔██╗ ██║   ██║   █████╗  ██║     \033[0m"
echo -e "\033[1;34m   ██╔══██╗██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██║     \033[0m"
echo -e "\033[1;35m   ██║  ██║╚██████╔╝██║ ╚████║   ██║   ███████╗███████╗\033[0m"
echo -e "\033[1;36m   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚══════╝\033[0m"
echo ""
echo -e "\033[1;36m  ════════════════════════════════════════════════════════════════\033[0m"
echo -e "\033[1;33m  RUNTEL GNU/Linux 13 (trixie)\033[0m"
echo ""
EOF

chmod +x /etc/update-motd.d/00-header
```
```bash
cat > /etc/update-motd.d/00-header << 'EOF'
#!/bin/sh

# Debian 13 ASCII art
echo -e "\033[1;31m        ██████╗ ███████╗██████╗ ██╗ █████╗ ███╗   ██╗\033[0m"
echo -e "\033[1;32m        ██╔══██╗██╔════╝██╔══██╗██║██╔══██╗████╗  ██║\033[0m"
echo -e "\033[1;33m        ██████╔╝█████╗  ██████╔╝██║███████║██╔██╗ ██║\033[0m"
echo -e "\033[1;34m        ██╔══██╗██╔══╝  ██╔══██╗██║██╔══██║██║╚██╗██║\033[0m"
echo -e "\033[1;35m        ██████╔╝███████╗██████╔╝██║██║  ██║██║ ╚████║\033[0m"
echo -e "\033[1;36m        ╚═════╝ ╚══════╝╚═════╝ ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝\033[0m"
echo ""
echo -e "\033[1;37m                    ████████████████████\033[0m"
echo -e "\033[1;37m                    ██\033[1;31m  \033[1;33m  \033[1;32m  \033[1;36m  \033[1;34m  \033[1;35m  \033[1;37m██\033[0m"
echo -e "\033[1;37m                    ██\033[1;31m  \033[1;33m  \033[1;32m  \033[1;36m  \033[1;34m  \033[1;35m  \033[1;37m██\033[0m"
echo -e "\033[1;37m                    ██\033[1;31m  \033[1;33m  \033[1;32m  \033[1;36m  \033[1;34m  \033[1;35m  \033[1;37m██\033[0m"
echo -e "\033[1;37m                    ████████████████████\033[0m"
echo ""
echo -e "\033[1;36m  ════════════════════════════════════════════════════════\033[0m"
echo -e "\033[1;33m  Debian GNU/Linux 13 (trixie)\033[0m"
echo ""
EOF

chmod +x /etc/update-motd.d/00-header
```


### 2.2 Информация о ресурсах (`10-uname`)

```bash
cat > /etc/update-motd.d/10-uname << 'EOF'
#!/bin/sh

# Resources info
echo -e "\033[1;34mResources:\033[0m"
echo -e "  > Memory: \033[1;32m$(free -h | awk '/Mem:/ {print $3 " / " $2 " used"}')\033[0m"
echo -e "  > Disk: \033[1;32m$(df -h / | awk 'NR==2 {print $4 " free of " $2 " (" $5 " used)"}')\033[0m"
echo -e "  > Load: \033[1;33m$(cat /proc/loadavg | awk '{print $1 ", " $2 ", " $3}')\033[0m"
EOF

chmod +x /etc/update-motd.d/10-uname
```

### 2.3 Системная информация (`20-sysinfo`)

```bash
cat > /etc/update-motd.d/20-sysinfo << 'EOF'
#!/bin/sh

# System information
echo -e "\033[1;34mSystem info:\033[0m"
echo -e "  > User: \033[1;93m$(whoami)\033[0m@\033[1;92m$(hostname)\033[0m"
echo -e "  > OS: \033[1;36m$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"' || uname -s)\033[0m"
echo -e "  > Kernel: \033[1;35m$(uname -r)\033[0m"
echo -e "  > Architecture: \033[1;35m$(uname -m)\033[0m"
echo -e "  > Uptime: \033[1;33m$(uptime -p 2>/dev/null | sed 's/up //' || uptime)\033[0m"
echo -e "  > Shell: \033[1;36m$SHELL\033[0m"
echo -e "  > Terminal: \033[1;36m$TERM\033[0m"
EOF

chmod +x /etc/update-motd.d/20-sysinfo
```

### 2.4 Сетевая информация (`30-network`)

```bash
cat > /etc/update-motd.d/30-network << 'EOF'
#!/bin/sh

# Network info
echo -e "\033[1;34mNetwork:\033[0m"
echo -e "  > IP Addresses: \033[1;32m$(hostname -I | xargs)\033[0m"
echo -e "  > Connections: \033[1;33m$(ss -tun | tail -n +2 | wc -l) active\033[0m"
EOF

chmod +x /etc/update-motd.d/30-network
```

### 2.5 Подвал с подсказками (`99-footer`)

```bash
cat > /etc/update-motd.d/99-footer << 'EOF'
#!/bin/sh

# Footer with quick tips
echo -e "\033[1;33mQuick tips:\033[0m"
echo -e "  \033[1;32m•\033[0m \033[1;37mhtop\033[0m - interactive process viewer"
echo -e "  \033[1;32m•\033[0m \033[1;37mdf -h\033[0m - disk space usage"
echo -e "  \033[1;32m•\033[0m \033[1;37mjournalctl -xe\033[0m - system logs"
echo ""
EOF

chmod +x /etc/update-motd.d/99-footer
```

---

## 🎨 Шаг 3: Цветовая схема

Используемые ANSI-коды цветов:

| Код | Цвет | Применение |
|-----|------|------------|
| `\033[1;31m` | Красный жирный | Логотип RUNTEL |
| `\033[1;34m` | Синий жирный | Заголовки разделов |
| `\033[1;32m` | Зелёный жирный | Память, диск, IP |
| `\033[1;33m` | Жёлтый жирный | Нагрузка, аптайм, соединения |
| `\033[1;36m` | Циан жирный | ОС, Shell, Terminal |
| `\033[1;35m` | Пурпурный жирный | Ядро, архитектура |
| `\033[1;93m` | Ярко-жёлтый | Имя пользователя |
| `\033[1;92m` | Ярко-зелёный | Имя хоста |
| `\033[1;37m` | Белый жирный | Команды в подсказках |
| `\033[0m` | Сброс цвета | Закрытие цветовой последовательности |

---

## 🧪 Шаг 4: Проверка

```bash
# Запустить все скрипты и увидеть результат
run-parts /etc/update-motd.d/

# Или выйти и зайти заново
exit
ssh root@debian13-builder
```

---

## 🛠️ Шаг 5: Управление MOTD

### Включить/отключить отдельные скрипты:

```bash
# Отключить скрипт
chmod -x /etc/update-motd.d/30-network

# Включить скрипт обратно
chmod +x /etc/update-motd.d/30-network
```

### Отключить ВСЁ динамическое приветствие:

```bash
chmod -x /etc/update-motd.d/*
```

### Включить обратно:

```bash
chmod +x /etc/update-motd.d/*
```

### Удалить конкретный скрипт:

```bash
rm /etc/update-motd.d/30-network
```

---

## 📦 Шаг 6: Дополнительные идеи для кастомизации

### Добавить дату и время:

```bash
cat > /etc/update-motd.d/15-datetime << 'EOF'
#!/bin/sh
echo -e "\033[1;34mCurrent time:\033[0m \033[1;33m$(date '+%A, %B %d, %Y - %H:%M:%S')\033[0m"
EOF
chmod +x /etc/update-motd.d/15-datetime
```

### Добавить топ процессов по CPU:

```bash
cat > /etc/update-motd.d/25-topcpu << 'EOF'
#!/bin/sh
echo -e "\033[1;34mTop CPU processes:\033[0m"
ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "  > %-20s CPU: %5s%%\n", $11, $3}'
EOF
chmod +x /etc/update-motd.d/25-topcpu
```

### Добавить информацию о температуре (если есть sensors):

```bash
cat > /etc/update-motd.d/35-temperature << 'EOF'
#!/bin/sh
if command -v sensors &> /dev/null; then
    echo -e "\033[1;34mTemperature:\033[0m"
    sensors | grep -E "Core|Package" | awk '{printf "  > %s: %s\n", $1, $3}'
fi
EOF
chmod +x /etc/update-motd.d/35-temperature
```

---

## 🔧 Шаг 7: Устранение проблем

### Проблема: Видно `-e` в выводе

**Решение:** Убедитесь, что скрипты имеют `#!/bin/sh` или `#!/bin/bash` в первой строке и что `echo` вызывается с флагом `-e`.

### Проблема: MOTD не отображается

**Решение:** Проверьте настройки PAM:
```bash
grep pam_motd /etc/pam.d/sshd
# Должно быть что-то вроде:
# session    optional     pam_motd.so motd=/run/motd.dynamic
```

### Проблема: Дублируется статический MOTD

**Решение:** Проверьте, что в `/etc/motd` нет лишнего текста, или сделайте его пустым:
```bash
> /etc/motd
```

---

## 📝 Шаг 8: Что мы написали (краткое резюме)

Мы создали **5 скриптов**, которые вместе формируют красивое информативное приветствие:

1. **`00-header`** — ASCII-логотип RUNTEL с названием ОС
2. **`10-uname`** — информация о ресурсах (память, диск, нагрузка)
3. **`20-sysinfo`** — системная информация (пользователь, ОС, ядро, архитектура, аптайм, shell, терминал)
4. **`30-network`** — сетевая информация (IP-адреса, активные соединения)
5. **`99-footer`** — подвал с полезными командами

**Итог:** При входе в систему вы видите красочное, информативное и структурированное приветствие, которое помогает быстро оценить состояние системы!

---

## 🎯 Готово!

Теперь у вас есть красивое, информативное и полностью настраиваемое приветствие! 🎉

Любые изменения можно вносить, редактируя соответствующие скрипты в `/etc/update-motd.d/`.

