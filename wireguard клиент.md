### Установить wg клиент:
```bash
epm search wireguard
epm -q wireguard-tools
```
### Проверьте установленные пакеты:
```bash
# Посмотрите что установлено из wireguard
dpkg -l | grep wireguard
rpm -qa | grep wireguard

# Проверьте содержимое пакета wireguard-tools
dpkg -L wireguard-tools
```

### Если wg-quick действительно отсутствует:

```bash
# Попробуйте найти пакет с wg-quick
apt search wg-quick
apt search wireguard

# Или установите из исходников
sudo apt-get install git build-essential
git clone https://git.zx2c4.com/wireguard-tools/
cd wireguard-tools/src
make
sudo make install
```

### 0. Альтернативно - скопируйте в /etc/wireguard/:
```bash
# Скопируйте конфиг в системную директорию
sudo cp wgclient_kkorablin.conf /etc/wireguard/wg0.conf

# Запустите по имени интерфейса
sudo wg-quick up wg0
```


### 1. Переименуйте конфиг файл:
Конфигурационный файл должен иметь имя в формате `ИНТЕРФЕЙС.conf`

```bash
# Посмотрите какое имя интерфейса указано в конфиге
cat wgclient_kkorablin.conf | grep "Interface\|Имя интерфейса"
```

### 2. Если в конфиге указано имя интерфейса (например wg0):
```bash
# Переименуйте файл соответственно
mv wgclient_kkorablin.conf wg0.conf
```

### 3. Или создайте правильное имя:
Обычно используется `wg0.conf`, `wg1.conf` и т.д.

```bash
# Переименуйте в стандартное имя
mv wgclient_kkorablin.conf wg0.conf
```

### 4. Запустите подключение:
```bash
# Теперь должно работать
sudo wg-quick up wg0.conf
```


### Проверка работы:
```bash
# После успешного подключения
sudo wg show
ping -c 4 8.8.8.8
```

----------------

Вот все основные команды `wg-quick` для управления WireGuard подключениями:

## Основные команды управления

### 1. **Подключение (up)**
```bash
# Подключиться с конфигом из текущей директории
sudo wg-quick up ./wg0.conf

# Подключиться с конфигом из /etc/wireguard/
sudo wg-quick up wg0

# Подключиться с указанием интерфейса
sudo wg-quick up ./config.conf wg0
```

### 2. **Отключение (down)**
```bash
# Отключиться от конфига в текущей директории
sudo wg-quick down ./wg0.conf

# Отключиться от интерфейса
sudo wg-quick down wg0

# Принудительное отключение
sudo wg-quick down wg0 --force
```

### 3. **Просмотр статуса (show)**
```bash
# Показать статус интерфейса
sudo wg show wg0

# Показать статус всех интерфейсов
sudo wg show
```

### 4. **Сохранение конфигурации (save)**
```bash
# Сохранить текущую конфигурацию в файл
sudo wg-quick save wg0
```

### 5. **Экспорт конфигурации (strip)**
```bash
# Экспортировать чистую конфигурацию (без динамических данных)
sudo wg-quick strip wg0
```

## Команды для systemd (автозагрузка)

### 6. **Управление сервисом**
```bash
# Включить автозагрузку
sudo systemctl enable wg-quick@wg0

# Запустить сервис
sudo systemctl start wg-quick@wg0

# Остановить сервис
sudo systemctl stop wg-quick@wg0

# Проверить статус сервиса
sudo systemctl status wg-quick@wg0

# Перезапустить сервис
sudo systemctl restart wg-quick@wg0

# Отключить автозагрузку
sudo systemctl disable wg-quick@wg0
```

### 7. **Просмотр логов**
```bash
# Логи сервиса
journalctl -u wg-quick@wg0 -f

# Логи с деталями
journalctl -u wg-quick@wg0 -xe
```

## Команды для диагностики

### 8. **Проверка подключения**
```bash
# Проверить связность
ping -c 4 8.8.8.8

# Проверить DNS
nslookup google.com

# Посмотреть сетевые интерфейсы
ip addr show wg0

# Посмотреть маршруты
ip route show

# Проверить порт
sudo lsof -i :51820
```

### 9. **Управление конфигами**
```bash
# Список доступных конфигов
ls /etc/wireguard/*.conf

# Проверить синтаксис конфига
sudo wg-quick strip wg0 > /dev/null && echo "Config OK"

# Создать новый интерфейс
sudo wg-quick up ./new_config.conf wg1
```

## Полезные алиасы
Добавьте в `~/.bashrc`:
```bash
alias wg-up='sudo wg-quick up'
alias wg-down='sudo wg-quick down'
alias wg-status='sudo wg show'
alias wg-restart='sudo wg-quick down wg0 && sudo wg-quick up wg0'
```

## Примеры использования

### Быстрое подключение/отключение:
```bash
# Подключиться
sudo wg-quick up wg0

# Проверить
sudo wg show

# Отключиться
sudo wg-quick down wg0
```

### Перезагрузка подключения:
```bash
sudo wg-quick down wg0 && sudo wg-quick up wg0
```

### Проверка конфига перед применением:
```bash
sudo wg-quick strip wg0
sudo wg-quick up wg0 --dry-run
```

Все команды требуют `sudo` прав, так как работа с сетевыми интерфейсами требует привилегий root.
