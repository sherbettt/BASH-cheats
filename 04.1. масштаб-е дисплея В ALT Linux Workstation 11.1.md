В ALT Linux Workstation 11.1 есть несколько способов настроить масштабирование дисплея более точно, чем стандартные предустановленные значения.

## 1. **Через настройки GNOME (графический способ)**

Если у вас GNOME:
- Откройте `Настройки` → `Дисплеи`
- В разделе "Масштаб" может быть ползунок или дополнительные опции
- Если доступны только фиксированные значения (100%, 125%, 150%), попробуйте:

### Включить дробное масштабирование:
```bash
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
```
После перезагрузки или выхода/входа в систему должны появиться дробные значения.

## 2. **Через xrandr (для X11)**

Для более точного контроля масштабирования:

### Посмотреть доступные дисплеи:
```bash
xrandr --query
```

### Установить точный масштаб (пример):
```bash
# Для дисплея eDP-1 с масштабом 1.25
xrandr --output eDP-1 --scale 1.25x1.25

# Или разный масштаб по осям
xrandr --output eDP-1 --scale 1.3x1.15
```

### Создать скрипт для удобства:
```bash
#!/bin/bash
# ~/.local/bin/set-scale.sh
xrandr --output $(xrandr | grep " connected" | cut -d' ' -f1) --scale $1x$1
```

## 3. **Через Wayland (если используется)**

В файле `/etc/environment` добавьте:
```bash
# Для масштаба 1.15 (115%)
GDK_SCALE=1.15
QT_SCALE_FACTOR=1.15

# Или с округлением для разных приложений
GDK_DPI_SCALE=0.85  # Уменьшит размер шрифтов
```

## 4. **Настройка через dconf-editor**

Установите и используйте dconf-editor:
```bash
sudo apt-get install dconf-editor
```

Затем:
- Откройте `dconf-editor`
- Перейдите в `org/gnome/desktop/interface`
- Измените `scaling-factor` (0 = авто, 1 = 100%, 2 = 200%)

## 5. **Для конкретных приложений**

### Firefox:
- Введите `about:config` в адресной строке
- Найдите `layout.css.devPixelsPerPx`
- Установите значение, например `1.25`

### Chrome/Chromium:
Запустите с параметром:
```bash
chromium --force-device-scale-factor=1.15
```

## 6. **Рекомендуемое решение**

1. Сначала определите, какая у вас графическая система:
```bash
echo $XDG_SESSION_TYPE
```

2. **Для X11** используйте `xrandr` с дробными значениями:
```bash
# Пример: масштаб 115%
xrandr --output eDP-1 --scale 1.15x1.15 --panning 1920x1080
```

3. **Для Wayland** добавьте в `~/.profile`:
```bash
export GDK_SCALE=1.15
export QT_SCALE_FACTOR=1.15
export ELM_SCALE=1.15
```

## Автоматизация

Добавьте нужную команду в автозагрузку:
1. Создайте файл `~/.config/autostart/scale.desktop`:
```ini
[Desktop Entry]
Type=Application
Name=Display Scaling
Exec=xrandr --output eDP-1 --scale 1.15x1.15
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
```

**Примечание:** Вам может потребоваться перезапустить графическую сессию для применения некоторых изменений.
