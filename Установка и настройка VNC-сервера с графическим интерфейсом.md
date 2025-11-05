# Установка и настройка VNC-сервера с графическим интерфейсом

## Установка необходимых пакетов

```bash
# Обновление пакетов и установка необходимого ПО
apt update && apt upgrade -y
apt install -y firefox-esr x11vnc xvfb fluxbox git websockify mc wget
apt install -y Xvfb fluxbox x11vnc websockify

# Клонирование noVNC
git clone https://github.com/novnc/noVNC.git /opt/novnc

# Переименование для удобства
cd /opt/novnc
mv vnc.html index.html
```

## Ручной запуск системы

```bash
# Запуск виртуального дисплея
Xvfb :1 -screen 0 1920x1080x24 & export DISPLAY=:1

# Проверка дисплея
echo $DISPLAY

# Запуск оконного менеджера
fluxbox &

# Запуск VNC-сервера
x11vnc -display :1 -nopw -forever -bg
# Доступен по IP_контейнера:5900

# Запуск noVNC
websockify -D --web /opt/novnc 80 localhost:5900
# Доступен по http://IP_контейнера/
```

## Автоматизация запуска

### Создание скрипта запуска

```bash
nano start.sh
```

Содержимое скрипта `start.sh`:
```bash
#!/bin/bash

# Запуск виртуального дисплея
Xvfb :1 -screen 0 1920x1080x24 &
sleep 2

export DISPLAY=:1

# Запуск оконного менеджера
fluxbox &

# Запуск VNC-сервера
x11vnc -display :1 -nopw -forever -bg -shared
sleep 2

# Запуск noVNC
websockify -D --web /opt/novnc 80 localhost:5900

# Запуск браузера в цикле (перезапуск при падении)
while true; do
    /usr/bin/firefox-esr
    sleep 2
done &

wait
```

### Настройка автоматического выполнения

```bash
# Делаем скрипт исполняемым
chmod +x start.sh

# Добавляем в автозагрузку через cron
crontab -e
# Добавляем строку:
@reboot /root/start.sh

# Перезапуск сервера для проверки
reboot now
```

## Дополнительная установка Google Chrome

```bash
# Скачивание и установка Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i google-chrome-stable_current_amd64.deb
apt --fix-broken install -y
dpkg -i google-chrome-stable_current_amd64.deb
```

### Изменение скрипта для использования Chrome

В скрипте `start.sh` заменить строку запуска браузера на:
```bash
google-chrome-stable --no-sandbox
```

## Порты доступа

- **VNC-сервер**: порт 5900 (`IP_контейнера:5900`)
- **Web-интерфейс noVNC**: порт 80 (`http://IP_контейнера/`)

---

**Примечание**: Для использования Chrome в скрипте необходимо добавить флаг `--no-sandbox` для работы в контейнере.
