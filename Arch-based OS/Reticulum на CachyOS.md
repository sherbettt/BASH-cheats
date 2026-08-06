# Полное руководство по установке и использованию Reticulum на CachyOS

## Содержание
1. [Что такое Reticulum](#что-такое-reticulum)
2. [Установка Reticulum](#установка-reticulum)
3. [Настройка PATH для Zsh](#настройка-path-для-zsh)
4. [Конфигурация Reticulum](#конфигурация-reticulum)
5. [Запуск и управление](#запуск-и-управление)
6. [Подключение к публичной сети](#подключение-к-публичной-сети)
7. [Клиенты Reticulum](#клиенты-reticulum)
8. [Nomad Network: отправка сообщений](#nomad-network-отправка-сообщений)
9. [Установка Sideband](#установка-sideband)
10. [Решение проблем](#решение-проблем)
11. [Итоговый список команд](#итоговый-список-команд)

**[reticulum.network](https://reticulum.network/start.html)**

---

## Что такое Reticulum

**Reticulum** — это криптографический стек для построения децентрализованных сетей на доступном оборудовании. Он позволяет создавать собственные защищённые сети связи, устойчивые к цензуре и контролю, работающие даже в сложных условиях с низкой пропускной способностью (от 150 бит/с).

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

## Подключение к публичной сети

### Почему никого нет в сети?

Когда вы только установили Reticulum и запустили Nomad Network, вы не видите других пользователей, потому что ваш узел работает изолированно. Чтобы увидеть других, нужно добавить **публичные точки входа** (entrypoints).

### Добавление публичных узлов

Отредактируйте конфигурационный файл `~/.reticulum/config` и добавьте в секцию `[interfaces]`:

```ini
  # Публичные точки входа (Community Entrypoints)
  [[dismails TCP Interface]]
    type = TCPClientInterface
    interface_enabled = true
    target_host = rns.dismail.de
    target_port = 7822

  [[The Outpost]]
    type = TCPClientInterface
    interface_enabled = true
    target_host = theoutpost.life
    target_port = 4242

  [[Beleth RNS Hub]]
    type = TCPClientInterface
    interface_enabled = true
    target_host = rns.beleth.net
    target_port = 4242

  [[RNS Testnet Amsterdam]]
    type = TCPClientInterface
    enabled = yes
    target_host = amsterdam.connect.reticulum.network
    target_port = 4965
```

### Перезапуск после добавления

```bash
sudo systemctl restart rnsd
```

Через несколько минут в `rnpath -t` и в Nomad Network появятся другие узлы.

---

## Клиенты Reticulum

Для поиска и общения с другими узлами доступны следующие клиенты:

| Клиент | Интерфейс | Описание |
|--------|-----------|----------|
| **Nomad Network** | Терминальный | Полнофункциональный клиент с шифрованными сообщениями, файловым обменом и встроенным браузером |
| **Sideband** | Графический | Клиент с поддержкой сообщений, аудио, файлов и карт |
| **MeshChat** | Веб-интерфейс | Легковесный чат в браузере |
| **rnsh** | Терминальный | Удалённая оболочка через Reticulum |

---

## Nomad Network: отправка сообщений

### Установка Nomad Network

```bash
# Установка через pip
pip install nomadnet

# Или через pipx
pipx install nomadnet
```

### Запуск

```bash
nomadnet
```

### Навигация по интерфейсу

Nomad Network — это терминальное приложение с управлением через клавиатуру:

| Клавиша | Действие |
|---------|----------|
| `F1` | Главное меню |
| `F2` | Список узлов (Network) |
| `F3` | Сообщения (Messaging) |
| `F4` | Файлы (Files) |
| `F5` | Браузер (Browser) |
| `Tab` | Переключение между панелями |
| `Enter` | Выбор/Открытие |
| `Esc` | Назад/Отмена |
| `Ctrl+C` | Выход |

### Как найти узлы

1. Нажмите `F1` для открытия главного меню
2. Выберите `[Network]` или `Show Nodes`
3. Отобразится список всех обнаруженных узлов
4. У каждого узла есть:
   - **Имя** (если настроено)
   - **Хеш-адрес** (уникальный идентификатор)
   - **Статус** (онлайн/офлайн)

### Как отправить сообщение

#### Способ 1: Из списка узлов
1. Откройте список узлов (`F1` → `[Network]` или `F2`)
2. Выберите нужный узел стрелками
3. Нажмите `Enter` для открытия диалога
4. Напишите сообщение и нажмите `Enter`

#### Способ 2: Через меню Messaging
1. Нажмите `F1` для открытия главного меню
2. Выберите `[Messaging]` 
3. Выберите `New Message`
4. Введите хеш-адрес получателя
5. Напишите сообщение и нажмите `Enter`

### Режимы отправки сообщений

В Nomad Network есть два режима доставки сообщений:

| Режим | Иконка | Описание |
|-------|--------|----------|
| **Прямая доставка** | Стрелка вниз ⬇️ | Сообщение отправляется напрямую получателю. Работает только если оба узла онлайн одновременно |
| **Ретрансляция** | Стрелка вверх ⬆️ | Сообщение отправляется через ретранслятор (Propagation Node), который хранит его до появления адресата |

**Переключение режима:**
- В окне отправки сообщения найдите иконку режима
- Нажмите соответствующую клавишу (обычно `Tab` или `Space`) для переключения
- Иконка изменится со стрелки вниз на стрелку вверх и наоборот

### Ретрансляция сообщений (Propagation)

Чтобы сообщения доходили, когда собеседник не в сети, необходимо, чтобы в сети был **ретранслятор** (Propagation Node). Кто-то из участников должен его запустить.

**Настройка ретранслятора в Nomad Network:**

Отредактируйте конфиг `~/.nomadnetwork/config`:

```ini
[nomadnet]
  # Включить ретрансляцию
  enable_propagation = yes
  
  # Имя ретранслятора
  propagation_name = "Мой ретранслятор"
  
  # Время хранения сообщений (в часах)
  propagation_ttl = 168
```

**Важно:** Ретранслятор должен работать 24/7 и иметь стабильное подключение к сети.

### Отправка файлов

1. В главном меню выберите `[Files]` или нажмите `F4`
2. Выберите `Send File`
3. Укажите путь к файлу
4. Введите хеш-адрес получателя
5. Файл будет передан через сеть Reticulum

### Использование встроенного браузера

Nomad Network имеет встроенный браузер для просмотра LXMF-сайтов:

1. Нажмите `F5` для открытия браузера
2. Введите адрес (хеш) сайта
3. Навигация по ссылкам с помощью `Tab` и `Enter`

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

### Проблема: никого нет в сети (Nomad Network пуст)

```bash
# 1. Проверьте, запущен ли демон
sudo systemctl status rnsd

# 2. Проверьте подключение к публичным узлам
rnpath -t

# 3. Добавьте публичные точки входа в конфиг (см. раздел "Подключение к публичной сети")
# 4. Перезапустите демон
sudo systemctl restart rnsd

# 5. Подождите 2-3 минуты для обнаружения узлов
```

---

## Итоговый список команд

| Действие | Команда |
|----------|---------|
| **Установка** | |
| Установка Reticulum | `pipx install rns` |
| Установка Nomad Network | `pip install nomadnet` |
| Установка Sideband (AUR) | `paru -S sideband` |
| Установка I2P | `sudo pacman -S i2pd` |
| **Настройка** | |
| Настройка PATH (Zsh) | `echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc` |
| Редактирование конфига Reticulum | `micro ~/.reticulum/config` |
| Редактирование конфига Nomad | `micro ~/.nomadnetwork/config` |
| **Запуск** | |
| Запуск через systemd | `sudo systemctl enable --now rnsd` |
| Запуск вручную | `rnsd &` |
| Запуск Nomad Network | `nomadnet` |
| Запуск Sideband | `sideband` |
| **Управление** | |
| Статус сервиса | `sudo systemctl status rnsd` |
| Остановка сервиса | `sudo systemctl stop rnsd` |
| Перезапуск | `sudo systemctl restart rnsd` |
| Логи | `sudo journalctl -u rnsd -f` |
| **Диагностика** | |
| Статус сети | `rnstatus` |
| Таблица маршрутов | `rnpath -t` |
| Проверка порта | `sudo ss -tlnp \| grep 4242` |
| Генерация ID | `rnid -g my_identity` |
| Проверка узла | `rnprobe <хеш_адреса>` |
| **Nomad Network (в интерфейсе)** | |
| Главное меню | `F1` |
| Список узлов | `F2` |
| Сообщения | `F3` |
| Файлы | `F4` |
| Браузер | `F5` |
| Отправить сообщение | Выбрать узел → `Enter` → написать → `Enter` |

---

## Что дальше?

1. **Найдите других пользователей** — подключитесь к публичным точкам входа
2. **Настройте ретранслятор** — чтобы получать сообщения офлайн
3. **Установите дополнительные приложения** — попробуйте LXMF, MeshChat
4. **Создайте свою сеть** — объедините компьютеры друзей через TCP интерфейсы
5. **Изучите возможности** — файловый обмен, аудио, встроенный браузер

---

*Статья составлена на основе реальной установки на CachyOS с использованием Zsh и systemd. Версия Reticulum: 1.4.2.*

*Сообщество Reticulum: [Discord](https://discord.gg/reticulum), [Matrix](https://matrix.to/#/#reticulum:matrix.org)*
