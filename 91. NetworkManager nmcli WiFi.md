## 1. Просмотр доступных WiFi сетей

```bash
# Простой список сетей
nmcli device wifi list

# Более подробная информация
nmcli device wifi list --rescan yes

# Список с дополнительными деталями
nmcli -f SSID,BSSID,SIGNAL,SECURITY device wifi list
```

## 2. Подключение к WiFi сети

### Способ 1: Подключение с паролем в команде
```bash
nmcli device wifi connect "Имя_сети" password "ваш_пароль"
```

### Способ 2: Подключение с запросом пароля
```bash
nmcli device wifi connect "Имя_сети" --ask
```

### Способ 3: Если сеть скрыта
```bash
nmcli device wifi connect "Имя_сети" password "ваш_пароль" hidden yes
```

## 3. Полезные команды для управления подключениями

```bash
# Показать текущие подключения
nmcli connection show

# Показать статус сетевых устройств
nmcli device status

# Отключиться от сети
nmcli device disconnect wlan0  # замените wlan0 на ваш интерфейс

# Забыть сохраненную сеть
nmcli connection delete "Имя_сети"
```

## 4. Пример полного процесса

```bash
# Сканировать и показать сети
nmcli device wifi list

# Подключиться к выбранной сети
nmcli device wifi connect "MyWiFiNetwork" password "mypassword123"

# Проверить статус подключения
nmcli connection show --active
```

## 5. Дополнительные опции

```bash
# Принудительное сканирование сетей
nmcli device wifi rescan

# Показать информацию о конкретной сети
nmcli device wifi list ifname wlan0  # для конкретного интерфейса

# Сохранить подключение для автоматического соединения
nmcli connection modify "Имя_сети" connection.autoconnect yes
```

## Важные моменты:

- Убедитесь, что WiFi адаптер включен: `nmcli radio wifi on`
- Если возникают проблемы, проверьте: `nmcli general status`
- Для некоторых операций может потребоваться `sudo`

