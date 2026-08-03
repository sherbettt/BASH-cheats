# Полное руководство по установке и настройке Reticulum на CachyOS (Arch Linux)

## Содержание
1. [Что такое Reticulum](#что-такое-reticulum)
2. [Установка Reticulum](#установка-reticulum)
3. [Настройка PATH для Zsh](#настройка-path-для-zsh)
4. [Конфигурация Reticulum](#конфигурация-reticulum)
5. [Запуск и управление](#запуск-и-управление)
6. [Клиенты Reticulum](#клиенты-reticulum)
7. [Установка Sideband](#установка-sideband)
8. [Решение проблем](#решение-проблем)
9. [Итоговый список команд](#итоговый-список-команд)

---

## Что такое Reticulum

**Reticulum** — это криптографический стек для построения децентрализованных сетей на доступном оборудовании. Он позволяет создавать собственные защищённые сети связи, устойчивые к цензуре и контролю, работающие даже в сложных условиях с низкой пропускной способностью (от 150 бит/с) .

**Ключевые особенности:**
- Без центрального управления — адреса создаются самостоятельно
- Все пакеты шифруются по умолчанию, нет адресов отправителя
- Сквозное шифрование с совершенной прямой секретностью
- Работает поверх любых каналов: Wi-Fi, Ethernet, LoRa, Packet Radio, I2P, TCP/IP

---

## Установка Reticulum

### 1. Установка pip и pipx

В CachyOS (как и в Arch Linux) используется пакетный менеджер `pacman` и его AUR-обёртка `paru`:

```bash
# Установка базовых инструментов Python
paru -S python-pip python-pipx
```

Если `paru` не установлен:
```bash
sudo pacman -S python-pip python-pipx
```

### 2. Установка Reticulum

```bash
# Основная версия с зависимостями
pipx install rns

# Или чистая версия без зависимостей (для минималистичных систем)
pipx install rnspure
```

После установки вы увидите список доступных команд:
```
- git-remote-rns  - rncp    - rngcs   - rngit   - rnid
- rnir            - rnodeconf - rnpath - rnpkg  - rnprobe
- rnsd            - rnsh    - rnstatus - rnx
```

---

## Настройка PATH для Zsh

В CachyOS по умолчанию используется **Zsh**, а не Bash. Поэтому настройка PATH должна быть в `~/.zshrc`:

```bash
# Добавляем ~/.local/bin в PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

# Перезагружаем конфигурацию Zsh
source ~/.zshrc

# Проверяем
which rnstatus
# Должно показать: /home/kkorablin/.local/bin/rnstatus
```

**Важно:** Если вы используете Bash, добавьте эту строку в `~/.bashrc`.

### Очистка кеша команд (если команда не находится)

```bash
# Очистка кеша путей в Zsh
rehash

# Или полная перезагрузка Zsh
exec zsh
```

---

## Конфигурация Reticulum

### 1. Создание конфигурационного файла

При первом запуске `rnsd` автоматически создаёт конфиг в `~/.reticulum/config`:

```bash
rnsd
# Будет создан файл /home/kkorablin/.reticulum/config
# Остановите процесс Ctrl+C для редактирования
```

### 2. Базовый конфиг для TCP-связи

Отредактируйте конфиг:

```bash
micro ~/.reticulum/config
# или
kate ~/.reticulum/config
# или
nano ~/.reticulum/config
```

Минимальный рабочий конфиг для связи через TCP/IP:

```ini
[reticulum]
  enable_transport = Yes
  share_instance = Yes
  instance_name = default

[logging]
  loglevel = 4
  level = info

[interfaces]
  # TCP сервер для приёма соединений
  [[TCP Server]]
    type = TCPServerInterface
    interface_enabled = yes
    listen_ip = 0.0.0.0
    listen_port = 4242
    name = TCPServer

  # TCP клиент для подключения к другим узлам (раскомментируйте и настройте)
  # [[TCP Client]]
  #   type = TCPClientInterface
  #   interface_enabled = yes
  #   target_host = 192.168.1.100
  #   target_port = 4242
  #   name = TCPClient
```

### 3. AutoInterface (для автоматического обнаружения)

Если ваш роутер поддерживает мультикаст, можно использовать AutoInterface:

```ini
  [[Default Interface]]
    type = AutoInterface
    enabled = Yes
```

**Примечание:** На некоторых Wi-Fi сетях мультикаст может быть заблокирован. В этом случае используйте TCP интерфейс.

---

## Запуск и управление

### Запуск демона в фоне

```bash
# Запуск в фоне (рекомендуется)
rnsd &

# Запуск в терминале (для отладки)
rnsd
```

**Что такое `rnsd &`?**
- **`rnsd`** — Reticulum Network Stack Daemon, основной сервис
- **`&`** — оператор запуска процесса в фоне, чтобы терминал оставался свободным

### Проверка статуса

```bash
# Статус демона и интерфейсов
rnstatus

# Таблица известных путей (другие узлы)
rnpath -t

# Проверка связи с узлом
rnprobe <хеш_адреса>

# Генерация идентификатора
rnid
```

### Остановка

```bash
# Поиск процесса
ps aux | grep rnsd

# Остановка по PID
kill <PID>

# Или через pkill
pkill rnsd
```

### Автозапуск через systemd

Создайте файл сервиса:

```bash
sudo micro /etc/systemd/system/rnsd.service
```

Содержимое:

```ini
[Unit]
Description=Reticulum Network Stack Daemon
After=network.target

[Service]
Type=simple
User=kkorablin
ExecStart=/home/kkorablin/.local/bin/rnsd
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Запуск:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now rnsd
sudo systemctl status rnsd
```

---

## Клиенты Reticulum

Для поиска и общения с другими узлами доступны следующие клиенты:

| Клиент | Интерфейс | Описание |
|--------|-----------|----------|
| **Sideband** | Графический | Полнофункциональный клиент с поддержкой сообщений, аудио, файлов и карт |
| **Nomad Network** | Терминальный | Текстовая версия с шифрованными сообщениями и файловым обменом |
| **MeshChat** | Веб-интерфейс | Легковесный чат в браузере |
| **rnsh** | Терминальный | Удалённая оболочка через Reticulum |

---

## Установка Sideband

### Вариант 1: Из AUR (рекомендуется для CachyOS/Arch)

```bash
# Установка через paru
paru -S sideband

# Или с автоматическим подтверждением
paru -S --noconfirm sideband

# Запуск
sideband
```

### Вариант 2: Через pipx (если AUR недоступен)

```bash
# Установка через pipx
pipx install sbapp

# Запуск
sideband
```

### Установка зависимостей для Sideband

Если Sideband не запускается с ошибками о модулях:

```bash
# Для Wayland (основная проблема на CachyOS)
sudo pacman -S xorg-server-xwayland python-pygame

# Для звука
sudo pacman -S alsa-utils pulseaudio-alsa python-pyaudio

# Kivy зависимости
sudo pacman -S python-kivy python-kivy-garden codec2

# Установка дополнительных Python-модулей
pip install --user pygame kivy-garden
```

### Запуск с отладкой

```bash
# Включить отладку
sideband -d

# Принудительно использовать X11 вместо Wayland
export DISPLAY=:0
sideband
```

---

## Установка Nomad Network (альтернатива)

Если Sideband не работает, используйте терминальный клиент:

```bash
# Установка
pip install nomadnet

# Запуск
nomadnet
```

---

## Решение проблем

### Проблема: команда rnstatus не найдена

```bash
# Проверьте PATH
echo $PATH | grep local

# Если нет - добавьте
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Очистите кеш
rehash
```

### Проблема: ошибка мультикаста

```
[Error] AutoInterface[Default Interface] No multicast echoes received
```

**Решение:** Используйте TCP интерфейс вместо AutoInterface.

### Проблема: Sideband не видит окно

```
[CRITICAL] [Window] Unable to find any valuable Window provider
```

**Решение:**
```bash
# Установите XWayland
sudo pacman -S xorg-server-xwayland

# Запустите с X11
export DISPLAY=:0
sideband
```

### Проблема: порт 4242 не слушает

```bash
# Проверьте, слушает ли порт
sudo ss -tlnp | grep 4242

# Откройте порт в фаерволе (если включён)
sudo iptables -A INPUT -p tcp --dport 4242 -j ACCEPT

# Для nftables (CachyOS использует nftables)
sudo nft add rule inet filter input tcp dport 4242 accept
```

---

## Итоговый список команд

| Действие | Команда |
|----------|---------|
| Установка Reticulum | `pipx install rns` |
| Настройка PATH | `echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc` |
| Создание конфига | `rnsd` (первый запуск) |
| Запуск демона | `rnsd &` |
| Проверка статуса | `rnstatus` |
| Поиск узлов | `rnpath -t` |
| Проверка связи | `rnprobe <хеш>` |
| Генерация ID | `rnid` |
| Установка Sideband (AUR) | `paru -S sideband` |
| Установка Sideband (pipx) | `pipx install sbapp` |
| Установка Nomad Network | `pip install nomadnet` |
| Запуск Sideband | `sideband` |
| Запуск Nomad Network | `nomadnet` |
| Остановка Reticulum | `pkill rnsd` |
| Автозапуск | `sudo systemctl enable --now rnsd` |

---

## Ссылки

- Официальный сайт: [reticulum.network](https://reticulum.network)
- Документация: [Reticulum Manual](https://reticulum.network/manual/)
- GitHub: [github.com/markqvist/Reticulum](https://github.com/markqvist/Reticulum)

---

*Статья составлена на основе реальной установки на CachyOS с использованием Zsh и systemd. Версия Reticulum: 1.4.2.*
