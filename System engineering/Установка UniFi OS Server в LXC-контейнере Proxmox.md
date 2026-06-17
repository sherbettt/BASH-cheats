## 📋  Установка UniFi OS Server в LXC-контейнере Proxmox

### 🔍 Исходные данные
- **Хост**: Proxmox VE (ядро 6.8.12-20-pve)
- **Контейнер**: LXC (Debian 13/trixie)
- **IP контейнера**: 192.168.87.153/24
- **Цель**: Установить UniFi OS Server 5.1.15 для управления точками доступа UniFi U7

---

### 🚨 Проблема 1: Отсутствие Podman

**Ситуация**: При запуске установщика получили:
```
ERROR Failed to install UniFi OS Server err=Missing container runtime /usr/bin/podman
```

**Решение**: Установка Podman и его зависимостей:
```bash
# Обновляем список пакетов
sudo apt-get update

# Устанавливаем Podman (контейнерный движок) и slirp4netns (для сетевой изоляции)
sudo apt-get install -y podman slirp4netns

# Проверяем установку
podman --version
# Вывод: podman version 5.4.2
```

**Зачем**: UniFi OS Server работает в контейнерах (Podman). Без Podman установка невозможна.

---

### 🚨 Проблема 2: Нет swap-пространства

**Ситуация**: Установщик выдал предупреждение:
```
WARN | WARNING: Insufficient swap space detected
WARN | It is recommended for system stability to have a minimal amount of swap configured.
```

**Попытка 1**: Создать swap внутри контейнера стандартным способом:
```bash
fallocate -l 2G /swapfile   # Создаём файл подкачки
chmod 600 /swapfile          # Устанавливаем права (только root)
mkswap /swapfile             # Форматируем как swap-раздел
swapon /swapfile             # Активируем swap
```
**Результат**: Ошибка `swapon: /swapfile: swapon failed: Operation not permitted`

**Причина**: В непривилегированном контейнере (`unprivileged: 1`) запрещено создавать swap.

**Попытка 2**: Настроить swap через cgroup в конфиге LXC:
```bash
# Редактируем /etc/pve/nodes/pmx6/lxc/192.conf
lxc.cgroup2.memory.swap.max: 2147483648  # 2 ГБ в байтах
```
**Результат**: Контейнер запустился, но swap не появился. Ошибка при запуске:
```
cgfsng_setup_limits: 3523 Invalid argument - Failed to set "memory.swap.high" to "1.8G"
```

**Решение**: Переключить контейнер в привилегированный режим:
```bash
# На хосте Proxmox
pct stop 192
mcedit /etc/pve/nodes/pmx6/lxc/192.conf
# Меняем строку:
unprivileged: 1   # было
unprivileged: 0   # стало
pct start 192
```
или ещё один результирующий конфиг контейнера
```bash
arch: amd64
cores: 2
features: nesting=1
hostname: ubiquti-hotspots
memory: 5125
net0: name=eth0,bridge=vmbr0,firewall=1,gw=192.168.87.1,hwaddr=BC:24:11:4F:AE:49,ip=192.168.87.153/24,type=veth
ostype: debian
rootfs: ssd_1tb:192/vm-192-disk-0.raw,size=38G
swap: 2048
unprivileged: 0
```

**Почему**: В привилегированном контейнере (`unprivileged: 0`) работают loop-устройства и разрешено создавать swap.

**После переключения** создаём swap заново (теперь успешно):
```bash
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab   # Автозагрузка при старте
free -h
# Вывод: Swap: 2.0Gi
```

---

### 🚨 Проблема 3: Сломался SSH-доступ

**Ситуация**: После переключения в привилегированный режим SSH перестал работать. Причина — в правах на файлы (UID изменился).

```bash
# Проверяем права
ls -la /root/.ssh/
# Вывод: файлы принадлежат 100000:100000 (бывший маппинг)

# Исправляем права
chown -R root:root /root/.ssh
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
systemctl restart ssh
```

**Почему**: В непривилегированном режиме UID внутри контейнера маппится на 100000+ на хосте. В привилегированном — UID совпадают, и файлы root должны принадлежать root.

---

### 🚨 Проблема 4: Ошибка sysctl (net.ipv4.ping_group_range)

**Ситуация**: При попытке установки установщик упал с ошибкой:
```
ERROR Command ""sysctl" "-p" "/etc/sysctl.d/99-uosserver.conf"" failed: sysctl: setting key "net.ipv4.ping_group_range": Invalid argument
```

**Попытка решения** (не сработала в непривилегированном контейнере):
```bash
echo "net.ipv4.ping_group_range = 0 2147483647" > /etc/sysctl.d/99-uosserver.conf
sysctl -p /etc/sysctl.d/99-uosserver.conf
# Ошибка: Invalid argument
```

**Решение**: Переключение в привилегированный контейнер (решило проблему автоматически).

**Зачем этот параметр**: Разрешает процессам без прав root отправлять ICMP-пакеты (ping). Нужен для работы некоторых сетевых функций UniFi.

---

### 🚨 Проблема 5: Установщик видит старую версию

**Ситуация**: После частичной установки установщик отказывался работать:
```
ERROR Failed to install UniFi OS Server err=Version matches the installed version. Use --force-install to override.
```

**Решение**: Полная очистка системы:
```bash
# Останавливаем и удаляем службу
systemctl stop uosserver 2>/dev/null
systemctl disable uosserver 2>/dev/null
rm -f /etc/systemd/system/uosserver.service

# Удаляем пользователя и каталоги
userdel -r uosserver 2>/dev/null
rm -rf /home/uosserver
rm -rf /var/lib/uosserver
rm -f /usr/local/bin/uosserver

# Проверяем, что всё чисто
which uosserver  # должно быть пусто
ls -la /etc/systemd/system/uosserver.service  # должно быть "No such file"
```

**Почему**: Установщик создаёт системного пользователя `uosserver`, каталоги и службу. При повторном запуске он видит, что версия совпадает, и требует флаг `--force-install`, но даже с ним он может пытаться остановить службу, которой нет.

---

### ✅ Итоговое состояние перед установкой

```bash
# 1. Контейнер привилегированный
cat /etc/pve/nodes/pmx6/lxc/192.conf | grep unprivileged
# Вывод: unprivileged: 0

# 2. Swap создан и активен
free -h
# Вывод: Swap: 2.0Gi

# 3. Podman установлен
podman --version
# Вывод: podman version 5.4.2

# 4. Все следы предыдущих установок удалены
ls -la /home/uosserver  # No such file
ls -la /var/lib/uosserver  # No such file
ls -la /usr/local/bin/uosserver  # No such file

# 5. SSH работает (права исправлены)
ssh root@192.168.87.153  # Успешно
```

---

### 🚀 Команда для финальной установки

```bash
# Переходим в каталог с установщиком
cd /root/programs

# Запускаем установку
./24e0-linux-x64-5.1.15-926621de-c9d7-48cd-8921-a0ff3eebd3f4.15-x64

# После установки проверяем службу
systemctl status uosserver

# Проверяем порты
ss -tulpn | grep 11443

# Открываем в браузере
# https://192.168.87.153:11443/
```

---

### 📌 Ключевые выводы

1. **Для установки UniFi OS Server в LXC нужен привилегированный контейнер** (`unprivileged: 0`)
2. **Swap обязателен** (минимум 2 ГБ)
3. **При переключении режима контейнера ломается SSH** — нужно исправить права на `/root/.ssh/`
4. **Перед повторной установкой нужно полностью очистить систему** от следов предыдущей установки

----------------------------------
<br>



## ✅ Правильная последовательность действий для установки UniFi OS Server в LXC (Proxmox)

### 1️⃣ Подготовка хоста Proxmox
```bash
# Останавливаем контейнер
pct stop 192

# Редактируем конфигурацию контейнера
mcedit /etc/pve/nodes/pmx6/lxc/192.conf
```
**Меняем/добавляем параметры:**
```
unprivileged: 0
swap: 2048
memory: 5125
```

### 2️⃣ Запуск контейнера и установка Podman
```bash
# Запускаем контейнер
pct start 192

# Заходим в контейнер
pct enter 192

# Устанавливаем Podman и зависимости
apt-get update
apt-get install -y podman slirp4netns

# Проверяем установку
podman --version   # Должно быть 4.3.1+
```

### 3️⃣ Создание swap внутри контейнера
```bash
# Создаём файл подкачки
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Добавляем автозагрузку
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Проверяем
free -h   # Должно показывать Swap: 2.0Gi
```

### 4️⃣ Исправление SSH (если не работает)
```bash
# Исправляем права для SSH
chown -R root:root /root/.ssh
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
systemctl restart ssh
```

### 5️⃣ Очистка от предыдущих установок
```bash
# Останавливаем и удаляем службу
systemctl stop uosserver 2>/dev/null
systemctl disable uosserver 2>/dev/null
rm -f /etc/systemd/system/uosserver.service

# Удаляем пользователя и каталоги
userdel -r uosserver 2>/dev/null
rm -rf /home/uosserver
rm -rf /var/lib/uosserver
rm -f /usr/local/bin/uosserver
```

### 6️⃣ Установка UniFi OS Server
```bash
# Переходим в каталог с установщиком
cd /root/programs

# Даём права на выполнение
chmod +x 24e0-linux-x64-5.1.15-926621de-c9d7-48cd-8921-a0ff3eebd3f4.15-x64

# Запускаем установку
./24e0-linux-x64-5.1.15-926621de-c9d7-48cd-8921-a0ff3eebd3f4.15-x64
```

### 7️⃣ Проверка работы
```bash
# Проверяем статус службы
systemctl status uosserver

# Проверяем открытые порты
ss -tulpn | grep 11443

# Смотрим логи
journalctl -u uosserver -f
```

### 8️⃣ Доступ к веб-интерфейсу
```
Открываем в браузере:
https://192.168.87.153:11443/
```

---

## 📌 Ключевые параметры конфигурации контейнера
```bash
arch: amd64
cores: 2
features: nesting=1
hostname: ubiquti-hotspots
memory: 5125
swap: 2048
unprivileged: 0
```

---

## ⚠️ Важные моменты
1. **Обязательно** переключить контейнер в привилегированный режим (`unprivileged: 0`)
2. **Swap** должен быть минимум 2 ГБ
3. **Podman** должен быть версии 4.3.1+
4. После переключения режима **исправить права SSH**
5. Перед переустановкой **очистить все следы**
6. IP-адрес **192.168.87.153** может отличаться — используйте свой

----------------------------------
<br>






