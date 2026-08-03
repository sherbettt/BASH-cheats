## Инструкция по установке и настройке Reticulum на CachyOS

### Что такое **Reticulum** ?

**Reticulum** — криптографический стек для построения децентрализованных сетей. 
Он позволяет создавать защищённые сети связи, устойчивые к цензуре и работающие даже при низкой пропускной способности .

---

### 1. Установка

```bash
# Установка pip и pipx
paru -S python-pip python-pipx

# Установка Reticulum
pipx install rns
```

### 2. Настройка PATH для Zsh

Так как в CachyOS используется **Zsh** (а не Bash), путь нужно добавлять в `~/.zshrc`:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### 3. Создание конфигурации

При первом запуске `rnsd` создаётся конфигурационный файл `~/.reticulum/config`. Мы настроили его так:

```ini
[reticulum]
  enable_transport = yes    # Узел будет маршрутизировать трафик для других 
  share_instance = yes      # Программы могут использовать общий экземпляр
  instance_name = default

[logging]
  level = info

[interfaces]
  # TCP сервер для приёма соединений
  [[TCP Server]]
    type = TCPServerInterface
    interface_enabled = yes
    listen_ip = 0.0.0.0
    listen_port = 4242
    name = TCPServer

  # TCP клиент (раскомментировать для подключения к другому узлу)
  # [[TCP Client]]
  #   type = TCPClientInterface
  #   interface_enabled = yes
  #   target_host = 192.168.1.100
  #   target_port = 4242
  #   name = TCPClient
```

### 4. Запуск Reticulum

```bash
# Запуск демона в фоне
rnsd &

# Проверка статуса
rnstatus
```

---

### Что такое `rnsd &` и почему мы так запускаем?

**`rnsd`** — это **Reticulum Network Stack Daemon**, основной сервис Reticulum . Он:
- Запускает сетевой стек в фоновом режиме 
- Создаёт общий экземпляр, к которому могут подключаться другие программы 
- Открывает все настроенные интерфейсы (TCP, UDP, Serial, I2P и т.д.) 

**`&`** — это оператор bash/zsh, который **запускает процесс в фоне**. Это позволяет продолжить работу в терминале, пока `rnsd` работает. Альтернативы:
- Запуск без `&` — процесс занимает терминал (удобно для отладки)
- Запуск как systemd сервис — для автозапуска при загрузке 

---

### Клиенты для поиска других узлов в сети

Для поиска и общения с другими узлами можно установить следующие приложения:

#### 1. **Sideband** (графический интерфейс) 

Графический клиент для Android, Linux, macOS и Windows. Поддерживает сообщения, файлы, аудио, карты и многое другое .

**Установка:**
```bash
# На Arch/CachyOS
sudo pacman -Sy python-pipx python-pyaudio base-devel codec2
pipx install sbapp
pipx ensurepath
sideband
```

#### 2. **Nomad Network** (командная строка) 

Терминальный клиент с шифрованными сообщениями, файловым обменом и встроенным браузером .

**Установка:**
```bash
pip install nomadnet
nomadnet
```

#### 3. **MeshChat** 

Веб-интерфейс для Reticulum с поддержкой сообщений, файлов и аудиозвонков.

#### 4. **rnsh** — удалённая оболочка 

Позволяет устанавливать интерактивные удалённые сессии через Reticulum.

```bash
# Установка
pipx install rnsh
```

---

### Как найти других узлов?

После запуска `rnsd` и любого клиента:

1. **`rnpath -t`** — показывает таблицу известных путей (другие узлы) 
2. **`rnprobe <хеш_узла>`** — проверяет связь с конкретным узлом 
3. В **Sideband** или **Nomad Network** узлы отображаются автоматически при их обнаружении

Для подключения к публичной тестовой сети добавьте в конфиг :

```ini
[[RNS Testnet Dublin]]
  type = TCPClientInterface
  enabled = yes
  target_host = dublin.connect.reticulum.network
  target_port = 4965
```

---

### Краткий итог

| Действие | Команда |
|----------|---------|
| Установка Reticulum | `pipx install rns` |
| Настройка PATH | `echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc` |
| Запуск демона | `rnsd &` |
| Проверка статуса | `rnstatus` |
| Поиск узлов | `rnpath -t` |
| Установка Sideband | `pipx install sbapp` |
| Установка Nomad Network | `pip install nomadnet` |

