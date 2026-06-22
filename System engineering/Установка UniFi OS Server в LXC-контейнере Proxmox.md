## Ссылки для скачивания UniFi OS Server

Установочный файл можно получить двумя основными способами:

*   **Официальная страница загрузок Ubiquiti:** Это основной и самый надежный источник. Перейдите на страницу [Software Downloads - Ubiquiti](https://www.ui.com/download/download)  и найдите раздел "UniFi OS Server". Скачайте версию для вашей архитектуры (обычно `linux-x64`).
*   **https://ui.com/download**
*   **https://ui.com/download/releases/network-server**
*   **https://community.ui.com/releases**
*   **https://help.ui.com/hc/en-us/articles/34210126298775-Self-Hosting-UniFi**
*   **Прямая ссылка из официальной документации:** В руководстве по установке также указан способ получения прямой ссылки на странице загрузок. Ссылка будет выглядеть примерно так: `https://fw-download.ubnt.com/data/unifi-os-server/...` .

> **⚠️ Важное примечание для пользователей из РФ:**
> Сайты и серверы загрузок Ubiquiti могут быть недоступны или работать с перебоями на территории РФ. В этом случае **для скачивания установочного файла и работы с веб-интерфейсом UniFi OS Server потребуется использовать VPN-соединение**. Без VPN процесс загрузки и первоначальной настройки может быть нестабильным или невозможным.

-------------------------------------------------

# Установка UniFi OS Server в LXC-контейнере Proxmox

## ⚠️ Ключевые моменты

1. **Контейнер должен быть привилегированным** (`unprivileged: 0`). В непривилегированном режиме установка невозможна из-за ограничений на создание swap, применение sysctl и работу с TUN-устройствами.
2. **Swap обязателен** — минимум 2 ГБ. Без него установщик выдаст предупреждение, а в процессе работы могут возникнуть проблемы с нехваткой памяти.
3. **Podman должен быть версии 4.3.1+**. Устанавливается через `apt install podman slirp4netns`.
4. **После переключения режима контейнера ломается SSH** — нужно исправить права на `/root/.ssh/`.
5. **Перед повторной установкой полностью очищайте систему** от следов предыдущей установки (пользователь, каталоги, служба).
6. **Для работы нужны TUN-устройства** (`/dev/net/tun`). Если их нет — создайте вручную.
7. **IP-адрес** `192.168.87.153` может отличаться — используйте свой.

---

## 📋 Исходные данные

| Параметр | Значение |
|----------|----------|
| **Хост** | Proxmox VE (ядро 6.8.12-20-pve) |
| **Контейнер** | LXC (Debian 13/trixie) |
| **IP контейнера** | 192.168.87.153/24 |
| **Цель** | Установить UniFi OS Server 5.1.15 |

---

## Часть 1. Подготовка хоста Proxmox и конфигурация LXC

### 1.1. Остановка и настройка контейнера

```bash
# Останавливаем контейнер
pct stop 192

# Открываем конфигурационный файл
mcedit /etc/pve/nodes/pmx6/lxc/192.conf
```

**Итоговый конфиг контейнера (`192.conf`):**

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
unprivileged: 0                      # <--- обязательно!
lxc.cgroup2.devices.allow: c 10:200 rwm   # <--- для TUN-устройства
```

**Пояснение параметров:**

| Параметр | Значение | Зачем |
|----------|----------|-------|
| `unprivileged: 0` | Привилегированный режим | Разрешает создание swap, применение sysctl, доступ к TUN |
| `swap: 2048` | 2 ГБ подкачки | Для стабильной работы UniFi OS Server |
| `memory: 5125` | ~5 ГБ RAM | Минимум для работы |
| `lxc.cgroup2.devices.allow: c 10:200 rwm` | Разрешает доступ к TUN | Нужно для работы сетевого стека контейнера |

### 1.2. Запуск контейнера

```bash
# Запускаем контейнер с новой конфигурацией
pct start 192

# Заходим внутрь контейнера
pct enter 192
```

---

## Часть 2. Установка Podman и создание swap

### 2.1. Установка Podman

```bash
# Обновляем список пакетов
apt-get update

# Устанавливаем Podman и slirp4netns
apt-get install -y podman slirp4netns

# Проверяем версию (должна быть 4.3.1+)
podman --version
# Вывод: podman version 5.4.2
```

**Зачем:** UniFi OS Server работает в контейнерах Podman. Без него установка невозможна.

### 2.2. Создание swap-пространства

```bash
# Создаём файл подкачки размером 2 ГБ
fallocate -l 2G /swapfile

# Устанавливаем права доступа (только root)
chmod 600 /swapfile

# Форматируем файл как swap-раздел
mkswap /swapfile

# Активируем swap
swapon /swapfile

# Добавляем в fstab для автоматического включения при загрузке
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Проверяем, что swap активен
free -h
# Ожидаемый вывод: Swap: 2.0Gi
```

**Почему это важно:** Установщик проверяет наличие swap и выдаёт предупреждение, если его нет. Без swap установка может быть нестабильной.

---

## Часть 3. Исправление SSH и прав на файлы

### 3.1. Почему ломается SSH

При переключении контейнера из непривилегированного режима (`unprivileged: 1`) в привилегированный (`unprivileged: 0`):

- В непривилегированном режиме UID root внутри контейнера маппится на UID 100000 на хосте
- После переключения UID внутри контейнера совпадают с хостом
- Файлы, созданные в непривилегированном режиме, остаются с UID 100000
- В привилегированном режиме они должны принадлежать root (UID 0)

### 3.2. Исправление прав

```bash
# Проверяем текущие права
ls -la /root/.ssh/
# Может показывать владельца 100000:100000

# Исправляем права для SSH
chown -R root:root /root/.ssh
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys

# Перезапускаем SSH-сервер
systemctl restart ssh

# Проверяем, что SSH работает
systemctl status ssh
```

### 3.3. Исправление прав на критичные системные файлы

```bash
# Исправляем владельца для ключевых файлов
chown root:root /bin/su
chown root:root /etc/sudo.conf
chown root:root /usr/bin/sudo
chmod 4755 /usr/bin/sudo   # SUID-бит

# Проверяем
ll /bin/su          # -rwsr-xr-x 1 root root
ll /usr/bin/sudo    # -rwsr-xr-x 1 root root
ll /etc/sudo.conf   # -rw-r--r-- 1 root root
```

---

## Часть 4. Подготовка к установке

### 4.1. Полная очистка от предыдущих установок

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
ls -la /etc/systemd/system/uosserver.service  # "No such file"
```

**Почему это важно:** Если не удалить старые файлы, установщик попытается обновить существующую версию и выдаст ошибку `Version matches the installed version`.

### 4.2. Создание TUN-устройства

TUN-устройство нужно для работы сетевого стека Podman внутри контейнера.

```bash
# Создаём каталог /dev/net (если его нет)
mkdir -p /dev/net

# Создаём TUN-устройство с правильными мажор/минор номерами
mknod /dev/net/tun c 10 200

# Устанавливаем права доступа
chmod 666 /dev/net/tun

# Проверяем
ls -la /dev/net/tun
# Ожидаемый вывод: crw-rw-rw- 1 root root 10, 200 Jun 18 05:54 /dev/net/tun
```

---

## Часть 5. Установка UniFi OS Server

### 5.1. Запуск установщика

```bash
# Переходим в каталог с установщиком
cd /root/programs

# Качаем, если не делали ещё
wget https://fw-download.ubnt.com/data/unifi-os-server/24e0-linux-x64-5.1.15-926621de-c9d7-48cd-8921-a0ff3eebd3f4.15-x64

# Даём права на выполнение
chmod +x 24e0-linux-x64-5.1.15-926621de-c9d7-48cd-8921-a0ff3eebd3f4.15-x64

# Запускаем установку
./24e0-linux-x64-5.1.15-926621de-c9d7-48cd-8921-a0ff3eebd3f4.15-x64
```

### 5.2. Что происходит во время установки

1. Проверка swap-пространства
2. Проверка Podman
3. Проверка свободного места на диске
4. Создание пользователя `uosserver`
5. Создание каталогов `/var/lib/uosserver/` и `/home/uosserver/`
6. Копирование бинарных файлов
7. Настройка системной службы `uosserver.service`
8. Загрузка контейнерного образа
9. Запуск службы

### 5.3. Ожидаемый результат

После завершения установки служба будет активна:

```bash
systemctl status uosserver
# Вывод: Active: active (running)
```

---

## Часть 6. Проверка работы

### 6.1. Проверка службы и портов

```bash
# Проверяем статус службы
systemctl status uosserver

# Проверяем, что порт 11443 открыт
ss -tulpn | grep 11443
# Ожидаемый вывод: tcp LISTEN 0 128 *:11443 *:* users:(("pasta",pid=690,fd=160))

# Смотрим логи в реальном времени
journalctl -u uosserver -f
```

### 6.2. Полный список портов, которые использует UniFi OS Server

| Порт | Назначение |
|------|------------|
| **11443** | Веб-интерфейс (HTTPS) |
| **8080** | Принятие устройств (HTTP) |
| **8444** | Каптивный портал (Guest Portal) |
| **3478** | STUN (UDP) |
| **6789** | Speedtest |
| **8880** | HTTP-редирект |
| **8881** | HTTPS-редирект |
| **8882** | Резервный порт |

### 6.3. Доступ к веб-интерфейсу

Откройте в браузере:
```
https://192.168.87.153:11443/
```

**Важно:** Браузер покажет предупреждение о небезопасном соединении — это нормально для самоподписанного сертификата. Нажмите **"Продолжить"** или **"Принять риск"**.

---

## Часть 7. Таблица всех проблем и решений

| # | Проблема | Ошибка | Решение |
|---|----------|--------|---------|
| 1 | Нет Podman | `Missing container runtime /usr/bin/podman` | `apt install -y podman slirp4netns` |
| 2 | Нет swap | `Insufficient swap space` | Создать swap в привилегированном контейнере |
| 3 | Swap не создаётся | `swapon failed: Operation not permitted` | Переключить `unprivileged: 0` |
| 4 | Сломался SSH | Ошибка аутентификации | `chown -R root:root /root/.ssh` |
| 5 | Ошибка sysctl | `net.ipv4.ping_group_range: Invalid argument` | Привилегированный режим решает автоматически |
| 6 | Ошибка установщика | `Version matches the installed version` | Полная очистка системы |
| 7 | Ошибка newuidmap | `newuidmap: write to uid_map failed` | `chmod u+s /usr/bin/newuidmap` |
| 8 | Нет TUN-устройства | `Failed to open() /dev/net/tun` | `mknod /dev/net/tun c 10 200` |

---

## Часть 8. Полезные команды для управления

```bash
# Статус службы
systemctl status uosserver

# Перезапуск службы
systemctl restart uosserver

# Остановка службы
systemctl stop uosserver

# Просмотр логов в реальном времени
journalctl -u uosserver -f

# Проверка всех портов
ss -tulpn | grep -E "11443|8080|8444|3478"

# Проверка контейнеров Podman
podman ps

# Вход в контейнер для диагностики
podman exec -it uosserver /bin/bash
```

---


## Часть 9. Управление службой и контейнером

### 9.1. Управление системной службой uosserver

UniFi OS Server работает как системная служба (systemd). Вот основные команды для управления ей:

```bash
# Проверка статуса службы
systemctl status uosserver

# Запуск службы
systemctl start uosserver

# Остановка службы
systemctl stop uosserver

# Перезапуск службы
systemctl restart uosserver

# Включение автозагрузки
systemctl enable uosserver

# Отключение автозагрузки
systemctl disable uosserver
```

**Пример вывода `systemctl status uosserver`:**
```
● uosserver.service - UniFi OS Server Service
     Loaded: loaded (/etc/systemd/system/uosserver.service; enabled)
     Active: active (running) since Thu 2026-06-18 05:54:38 UTC
   Main PID: 622 (uosserver-servi)
      Tasks: 8 (limit: 154210)
     Memory: 10.2M
     CGroup: /system.slice/uosserver.service
             ├─622 /var/lib/uosserver/bin/uosserver-service
             └─627 /var/lib/uosserver/bin/discovery
```

***ВАЖНО! После перезагрузки контейнера пропадет TUN и не работает веб-интерфейс. Как это решить - читай ниже в статье.***


### 9.2. Просмотр логов

**Чтение логов через journalctl:**

```bash
# Просмотр логов в реальном времени (как tail -f)
journalctl -u uosserver -f

# Просмотр последних 50 строк логов
journalctl -u uosserver -n 50

# Просмотр логов за последние 10 минут
journalctl -u uosserver --since "10 minutes ago"

# Просмотр логов за сегодня
journalctl -u uosserver --since today

# Просмотр логов с цветным выводом (удобно для чтения)
journalctl -u uosserver -f | ccze -A
```

**Где ещё хранятся логи:**

```bash
# Основные логи службы
ls -la /var/lib/uosserver/logs/

# Логи Podman-контейнера
podman logs uosserver

# Логи в реальном времени из контейнера
podman logs -f uosserver
```

### 9.3. Управление Podman-контейнером

Возникает ошибка cannot chdir to /root возникает, потому что sudo -u uosserver не меняет домашнюю директорию, а sudo -i -u uosserver — меняет.

UniFi OS Server работает внутри Podman-контейнера с именем `uosserver`. Вот основные команды для управления им:

```bash
# Войти в сессию пользователя uosserver (рекомендуемый способ)
sudo -i -u uosserver

# Список запущенных контейнеров
podman ps

# Список всех контейнеров (включая остановленные)
podman ps -a

# Просмотр логов контейнера
podman logs uosserver

# Просмотр логов в реальном времени
podman logs -f uosserver

# Остановка контейнера
podman stop uosserver

# Запуск контейнера
podman start uosserver

# Перезапуск контейнера
podman restart uosserver

# Вход в контейнер для диагностики (интерактивный режим)
podman exec -it uosserver /bin/bash

# Просмотр информации о контейнере
podman inspect uosserver
sudo -i -u uosserver podman inspect uosserver | grep -ie "running"

# Просмотр статистики использования ресурсов
podman stats uosserver
```

Однострочники
```bash
sudo -i -u uosserver podman ps
sudo -i -u uosserver podman ps -a               # Список всех контейнеров
sudo -i -u uosserver podman logs uosserver      # логи (Ctrl+C для выхода)
sudo -i -u uosserver podman logs -f uosserver
sudo -i -u uosserver podman restart uosserver   # Перезапск контейнера
```

### 9.4. Проверка сетевых портов

```bash
# Проверка всех портов, используемых UniFi OS Server
ss -tulpn | grep -E "11443|8080|8444|3478|6789|8880|8881|8882"

# Проверка конкретного порта (например, 11443)
ss -tulpn | grep 11443

# Проверка с помощью netstat (если установлен)
netstat -tulpn | grep 11443
```

**Пример вывода для порта 11443:**
```
tcp   LISTEN 0      128                *:11443            *:*    users:(("pasta",pid=690,fd=160))
```

### 9.5. Проверка состояния контейнера

```bash
# Проверка, что контейнер работает
podman ps | grep uosserver

# Проверка, что все процессы внутри контейнера работают
podman exec uosserver ps aux

# Проверка использования памяти контейнером
podman stats --no-stream uosserver
```

---

## Часть 10. Часто используемые команды (шпаргалка)

| Действие | Команда |
|----------|---------|
| Статус службы | `systemctl status uosserver` |
| Запуск службы | `systemctl start uosserver` |
| Остановка службы | `systemctl stop uosserver` |
| Перезапуск службы | `systemctl restart uosserver` |
| Логи в реальном времени | `journalctl -u uosserver -f` |
| Логи за последние 50 строк | `journalctl -u uosserver -n 50` |
| Логи с цветом | `journalctl -u uosserver -f \| ccze -A` |
| Список контейнеров | `podman ps` |
| Логи контейнера | `podman logs uosserver` |
| Вход в контейнер | `podman exec -it uosserver /bin/bash` |
| Проверка портов | `ss -tulpn \| grep 11443` |
| Проверка swap | `free -h` |
| Проверка памяти | `free -m` |

---

## Часть 11. Устранение неполадок

### 11.1. Служба не запускается

```bash
# Проверить статус
systemctl status uosserver

# Посмотреть ошибки в логах
journalctl -u uosserver -n 50

# Проверить, что контейнер существует
podman ps -a | grep uosserver

# Попробовать запустить контейнер вручную
podman start uosserver
```

### 11.2. Веб-интерфейс не открывается

```bash
# Проверить, что служба работает
systemctl status uosserver

# Проверить, что порт 11443 слушает
ss -tulpn | grep 11443

# Проверить логи на наличие ошибок
journalctl -u uosserver -f

# Проверить, что контейнер запущен
podman ps | grep uosserver

# Проверить доступность порта из контейнера
podman exec uosserver curl -k https://localhost:443/api/ping
```

### 11.3. Устройства не видны (Adoption не работает)

```bash
# Проверить, что порт 8080 открыт
ss -tulpn | grep 8080

# Проверить, что устройства в одной сети
ip a

# Проверить, что в контейнере включён discovery
podman exec uosserver ps aux | grep discovery

# Проверить логи контейнера на ошибки
podman logs uosserver | grep -i error
```

---


## 📌 Что такое TUN-устройства и зачем они нужны в контейнере?

**TUN** — это виртуальное сетевое устройство, которое работает на уровне IP-пакетов (Layer 3). Оно эмулирует сетевой интерфейс, но вместо отправки пакетов по физическому кабелю передаёт их напрямую пользовательским программам.

### Зачем TUN в контейнере с UniFi OS Server?

1. **Работа Podman с сетевым стеком**  
   UniFi OS Server использует Podman в режиме сетевой изоляции. TUN-устройство нужно, чтобы контейнер мог создавать собственные виртуальные сетевые интерфейсы и маршрутизировать трафик между ними.

2. **STUN и NAT Traversal**  
   TUN используется для корректной работы STUN-сервера (порт 3478/UDP), который нужен для обхода NAT и обнаружения устройств в разных сетях.

3. **Инкапсуляция трафика**  
   Некоторые функции UniFi (например, Site Magic SD-WAN) требуют создания VPN-туннелей между сайтами. TUN как раз для этого и предназначен — он позволяет "прокладывать" виртуальные каналы поверх существующей сети.

-------


### 📌 Что делать, если после перезагрузки контейнера потерялся TUN и не работает веб-интерфейс

После перезагрузки LXC-контейнера устройство `/dev/net/tun`, созданное вручную через `mknod`, **не сохраняется**. Это приводит к тому, что Podman не может запустить сетевой стек, и контейнер `uosserver` не стартует.

#### Признаки проблемы:
- Веб-интерфейс `https://IP:11443` не открывается.
- Команда `ss -tulpn | grep 11443` не показывает ничего.
- В логах службы `journalctl -u uosserver` видны ошибки:
  ```
  ERROR Timeout: Container did not start within 60 seconds.
  ```
- При попытке запустить контейнер вручную появляется ошибка:
  ```
  Failed to open() /dev/net/tun: No such file or directory
  ```

#### 🔧 Быстрое восстановление (вручную)

Зайдите в контейнер и выполните:
```bash
# 1. Создаём TUN-устройство заново
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 666 /dev/net/tun

# 2. Запускаем контейнер
sudo -i -u uosserver podman start uosserver

# 3. Проверяем, что порты открылись
ss -tulpn | grep -E "11443|8080"
```
После этого веб-интерфейс снова станет доступен.

---

#### Автоматическое восстановление (чтобы не делать это вручную)

Чтобы TUN создавался автоматически при каждой загрузке контейнера, мы добавили **systemd-службу**, которая создаёт устройство до запуска `uosserver`.

**Создайте файл `/etc/systemd/system/tun-device.service`:**

```bash
cat > /etc/systemd/system/tun-device.service << 'EOF'
[Unit]
Description=Create TUN device for Podman
After=local-fs.target
Before=network.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'mkdir -p /dev/net && [ -e /dev/net/tun ] || mknod /dev/net/tun c 10 200 && chmod 666 /dev/net/tun'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
```

**Активируйте службу:**
```bash
systemctl daemon-reload
systemctl enable tun-device.service
systemctl start tun-device.service
```

Теперь после перезагрузки контейнера TUN будет создаваться автоматически, и `uosserver` запустится без ошибок.

---

#### Альтернативный способ — через rc.local (проще)

Если вы не хотите создавать systemd-службу, можно добавить команды в `/etc/rc.local`:

```bash
#!/bin/bash
mkdir -p /dev/net
[ -e /dev/net/tun ] || mknod /dev/net/tun c 10 200
chmod 666 /dev/net/tun
exit 0
```

Не забудьте сделать файл исполняемым:
```bash
chmod +x /etc/rc.local
```

---

#### ✅ Проверка

После настройки автоматического создания TUN перезагрузите контейнер и убедитесь, что:
```bash
ls -la /dev/net/tun   # должно показывать crw-rw-rw-
systemctl status uosserver   # должно быть active (running)
ss -tulpn | grep 11443   # должен быть LISTEN
ss -tulpn | grep -E "11443|8080|8444|3478"
```

------------
<br>


### Вход на сервер
- непосредственно по IP адресу (первый раз)
- в дальнейшем можно и по https://unifi.ui.com/
- конкретно https://unifi.ui.com/consoles/66311754-2f46-4766-b196-b79e5a2b5630/network/default/dashboard (Runtel UniFi Server)
------------
<br>


<p align="center">
  <img src="https://github.com/sherbettt/BASH-cheats/blob/main/images/UniFiOS_Runtel_1.png" alt="UniFiOS_Runtel_1">
</p>

<p align="center">
  <img src="https://github.com/sherbettt/BASH-cheats/blob/main/images/UniFiOS_Runtel_2.png" alt="UniFiOS_Runtel_2">
</p>

<p align="center">
  <img src="https://github.com/sherbettt/BASH-cheats/blob/main/images/UniFiOS_Runtel_3.png" alt="UniFiOS_Runtel_3">
</p>

<p align="center">
  <img src="https://github.com/sherbettt/BASH-cheats/blob/main/images/UniFiOS_Runtel_4.png" alt="UniFiOS_Runtel_4">
</p>

------------------------------------------------------
<br/>



# Обновление UniFi OS Server в LXC-контейнере Proxmox

## Часть 12. Обновление UniFi OS Server с 5.1.15 до 5.1.19

### 12.1. Где скачать обновление

Официальные установщики UniFi OS Server публикуются на странице загрузок Ubiquiti: [https://fw-download.ubnt.com/data/unifi-os-server/](https://fw-download.ubnt.com/data/unifi-os-server/).

**Для версии 5.1.19 использовалась прямая ссылка:**
```
https://fw-download.ubnt.com/data/unifi-os-server/b828-linux-x64-5.1.19-e38d0b0e-b462-403d-9861-f57f25772106.19-x64
```

**Важно:** Для пользователей из РФ скачивание возможно только через VPN, так как официальные серверы Ubiquiti могут быть недоступны.

### 12.2. Подготовка файла на сервере

После скачивания файла на ноутбук он был переименован для удобства:

```bash
# На ноутбуке
mv b828-linux-x64-5.1.19-e38d0b0e-b462-403d-9861-f57f25772106.19-x64 UniFi-OS-Server_5.1.19_Linux_x64.19-x64
```

Затем:
```bash
# С ноутбука на сервер файл скопирован на сервер через `rsync` или `scp`:
rsync -avP UniFi-OS-Server_5.1.19_Linux_x64.19-x64 root@192.168.87.153:/root/programs/

# На сервере
cd /root/programs
chmod +x UniFi-OS-Server_5.1.19_Linux_x64.19-x64
chown root:root UniFi-OS-Server_5.1.19_Linux_x64.19-x64
```

### 12.3. Запуск обновления

Обновление запускается той же командой, что и установка:

```bash
# На сервере
./UniFi-OS-Server_5.1.19_Linux_x64.19-x64
```

Установщик сам определит текущую версию и предложит обновиться:

```
You're about to update UniFi OS Server from 5.1.15 to 5.1.19.
Proceed? (y/N): y
```

**Что происходит во время обновления:**
1. Остановка службы `uosserver`
2. Замена бинарных файлов
3. Удаление старого Podman-контейнера
4. Загрузка нового образа контейнера
5. Запуск нового контейнера
6. Автоматический перезапуск службы

После успешного обновления появляется сообщение:

```
!!! INSTALLATION COMPLETE !!!
UniFi OS Server is running at: https://192.168.87.153:11443/
```

---

## Часть 13. Ручное обновление точек доступа U7 Pro через Debug Console

### 13.1. Почему это нужно

Точки доступа не могут скачать обновления напрямую из-за географических ограничений (блокировка доступа к серверам Ubiquiti в РФ). Поэтому прошивка загружается вручную.

### 13.2. Где скачать прошивку для U7 Pro

Официальные прошивки публикуются на странице релизов: [https://community.ui.com/releases](https://community.ui.com/releases).

Для модели **U7 Pro** нужны файлы с названием, начинающимся на `BZ2.ipq53xx_...`. 
смотрим https://ui.com/download/releases/network-server, ищем примерно **`UniFi firmware 8.6.11 for U7-Mesh`**

В нашем случае использовалась прошивка:
```
BZ2.ipq53xx_8.6.11+18870.260526.1140.bin
```

**Прямая ссылка для скачивания:**
```
https://dl.ui.com/unifi/firmware/G7LR/8.6.11.18870/BZ2.ipq53xx_8.6.11+18870.260526.1140.bin
```

Файл был переименован для удобства:
```bash
mv BZ2.ipq53xx_8.6.11+18870.260526.1140.bin UniFi_firmware_8.6.11_for_U7-Mesh
```

### 13.3. Доступ к точке доступа через Debug Console

ВАЖНО! Чтобы появился доступ к debug консоли, требуется обновить ддля начала UniFI OS до 5.1.19 версии!

Если SSH-пароль неизвестен или не подходит, можно использовать встроенную Debug Console прямо из веб-интерфейса.

**Путь к Debug Console:**

1. Зайдите в веб-интерфейс `https://192.168.87.153:11443/`
2. В левом меню перейдите в раздел **Devices** (Устройства)
3. Выберите нужную точку доступа (например, U7 Pro 220)
4. В правой панели с информацией об устройстве найдите вкладку **Settings** (Настройки)
5. Прокрутите вниз до самого низа
6. Нажмите кнопку **Debug**

<p align="center">
  <img src="https://github.com/sherbettt/BASH-cheats/blob/main/images/UniFI-OS_SSH-hotsopt_5.1.19_console1.png" alt="UniFI-OS_SSH-hotsopt_5.1.19_console1.png">
</p>



<!-- здесь скриншот(ы) -->

Откроется консоль с прямым доступом к точке доступа.

### 13.4. Определение пользователя для входа

В Debug Console нужно определить, какой пользователь используется на точке доступа:

```bash
# Просмотр файла с учётными записями
cat /etc/shadow
```

Пример вывода:
```
VdNKf:$6$QULr.qfD$f9zEk7bTZoeddddyKnu7Ds3UvEuICAnarG1LcKRK457mgor1Gx0CpjwUQ6fgkf0qB3JQrGh0:0:0:99999:7:::
nobody:*:0:0:99999:7:::
```

В данном случае пользователь — `VdNKf` (это может быть `root`, `ui`, `ubnt` или другое имя в зависимости от прошивки).

### 13.5. Смена пароля пользователя

Чтобы иметь возможность войти по SSH, нужно установить пароль для найденного пользователя:

```bash
# Смена пароля для пользователя VdNKf
passwd VdNKf
```

Система попросит ввести новый пароль дважды. После этого вы сможете использовать этот пароль для входа по SSH.

### 13.6. Подключение по SSH и обновление

Теперь можно выйти из Debug Console и подключиться по SSH:

```bash
# Подключение к точке доступа
ssh VdNKf@192.168.97.220
```

**Копирование прошивки на точку доступа:**

```bash
# На сервере UniFI OS (192.168.87.153) выполняем
scp /root/programs/UniFi_firmware_8.6.11_for_U7-Mesh VdNKf@192.168.97.220:/tmp/fwupdate.bin
```

**Запуск обновления:**

```bash
# В SSH-сессии с точкой доступа
syswrapper.sh upgrade2 &

# Или альтернативный способ
upgrade /tmp/fwupdate.bin
```

### 13.7. Ожидание завершения

Процесс обновления занимает 3-5 минут. Точка доступа перезагрузится. После перезагрузки она появится в интерфейсе с новой версией прошивки.

---

## 📌 Краткая шпаргалка

| Действие | Команда | Где выполнять |
|----------|---------|---------------|
| Скачать установщик | `wget https://fw-download.ubnt.com/.../b828-linux-x64-5.1.19-...` | На ноутбуке (с VPN) |
| Скопировать на сервер | `rsync -avP UniFi-OS-Server_5.1.19... root@192.168.87.153:/root/programs/` | На ноутбуке |
| Обновить сервер | `./UniFi-OS-Server_5.1.19_Linux_x64.19-x64` | На сервере |
| Найти пользователя на AP | `cat /etc/shadow` | В Debug Console AP |
| Сменить пароль | `passwd VdNKf` | В Debug Console AP |
| Скопировать прошивку | `scp ... VdNKf@192.168.97.220:/tmp/fwupdate.bin` | На сервере |
| Запустить обновление AP | `syswrapper.sh upgrade2 &` | В SSH AP |

---







