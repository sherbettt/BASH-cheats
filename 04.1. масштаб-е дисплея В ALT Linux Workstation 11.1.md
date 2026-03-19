# Настройка масштабирования дисплея в Ximper Linux / ALT Linux Workstation

В Ximper Linux (и других дистрибутивах на основе ALT Linux) есть несколько способов настроить масштабирование дисплея более точно, чем стандартные предустановленные значения. Ниже приведены рабочие методы, проверенные на Ximper Linux 0.9.4 с окружением GNOME.

## 0. **Важное предупреждение (из личного опыта)**

Если вы меняли дисплейный менеджер (например, переходили с SDDM на Greetd/Regreet), настройки масштабирования могут сброситься. В этом случае:

1. Переключитесь на текстовую консоль: **`Ctrl+Alt+F2`** (или F3-F6)
2. Войдите в систему
3. Верните рабочий дисплейный менеджер:
   ```bash
   sudo systemctl disable greetd
   sudo systemctl enable lightdm
   sudo reboot
   ```
   
Или настройте Regreet правильно (см. статью про восстановление входа).

## 1. **Через настройки GNOME (графический способ)**

Если у вас GNOME (как в Ximper Linux по умолчанию):
- Откройте **`Параметры`** → **`Экран`**
- В разделе **"Масштаб"** может быть ползунок или дополнительные опции
- Если доступны только фиксированные значения (100%, 200%), включите дробное масштабирование:

### Включить дробное масштабирование:
```bash
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
```

После перезагрузки сессии (**`Alt+F2`** → `r` → Enter) в настройках появятся дробные значения (125%, 150%, 175%).

## 2. **Через gsettings (командная строка)**

Если интерфейс тормозит или вы хотите точной настройки:

### Для целочисленного масштабирования:
```bash
# 100% (1)
gsettings set org.gnome.desktop.interface scaling-factor 1

# 200% (2)
gsettings set org.gnome.desktop.interface scaling-factor 2
```

### Для дробного масштабирования (после включения experimental-features):
```bash
# Масштаб текста 1.25 (эквивалент 125%)
gsettings set org.gnome.desktop.interface text-scaling-factor 1.25

# Масштаб текста 0.9 (уменьшение, если экран слишком крупный)
gsettings set org.gnome.desktop.interface text-scaling-factor 0.9
```

### Посмотреть текущие настройки:
```bash
gsettings get org.gnome.desktop.interface scaling-factor
gsettings get org.gnome.mutter experimental-features
echo $XDG_SESSION_TYPE  # Покажет wayland или x11
```

## 3. **Как переключиться с X11 на Wayland (для видеокарт AMD/Intel)**

Если у вас видеокарта AMD (как в примере) или Intel, Wayland работает отлично и даёт больше возможностей для масштабирования.

### Проверьте свою видеокарту:
```bash
lspci | grep -E "VGA|3D"
# Пример вывода для AMD: 
# 03:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Lucienne (rev c2)
```

### Переключение на Wayland:

1. **Выйдите из текущей сессии:**
   ```bash
   gnome-session-quit --logout
   ```

2. **На экране входа LightDM** найдите **шестеренку (⚙️)** — обычно в правом верхнем или нижнем углу

3. В выпадающем меню выберите **"GNOME"** или **"GNOME on Wayland"** (не выбирайте "GNOME on Xorg")

4. Войдите в систему

5. **Проверьте, что вы в Wayland:**
   ```bash
   echo $XDG_SESSION_TYPE
   # Должно показать: wayland
   ```

### Если пункта с Wayland нет в меню:

Проверьте, установлены ли Wayland-сессии:
```bash
ls /usr/share/wayland-sessions/
# Там должен быть файл gnome-wayland.desktop
```

Если папка пуста, установите поддержку:
```bash
sudo epmi gnome-session-wayland
```

### Если хотите, чтобы Wayland запускался всегда:

Отредактируйте `/etc/lightdm/lightdm.conf`:
```bash
sudo nano /etc/lightdm/lightdm.conf
```

Добавьте или раскомментируйте в секции `[Seat:*]`:
```ini
[Seat:*]
user-session=gnome-wayland
```

## 4. **Через xrandr (для X11)**

Если вы работаете в сессии X11 и не хотите переходить на Wayland:

### Посмотреть доступные дисплеи:
```bash
xrandr --query
```

### Установить точный масштаб (пример):
```bash
# Для дисплея eDP-1 (обычно ноутбучный экран) с масштабом 1.15
xrandr --output eDP-1 --scale 1.15x1.15

# Если изображение выходит за края, добавьте panning:
xrandr --output eDP-1 --scale 1.15x1.15 --panning 1920x1080
```

### Создать скрипт для удобства:
```bash
#!/bin/bash
# ~/.local/bin/set-scale.sh
MONITOR=$(xrandr | grep " connected" | cut -d' ' -f1)
xrandr --output $MONITOR --scale $1x$1 --panning $(xrandr | grep -A1 $MONITOR | tail -1 | awk '{print $1}' | tr 'x' ' ')x$1
```

Сделайте скрипт исполняемым:
```bash
chmod +x ~/.local/bin/set-scale.sh
# Использование: set-scale.sh 1.15
```

## 5. **Через переменные окружения (для Wayland и приложений)**

В файле `~/.profile` или `~/.bash_profile` добавьте:

```bash
# Для Wayland и GTK-приложений
export GDK_DPI_SCALE=1.25  # Только для GTK, работает с дробными значениями

# Для Qt-приложений
export QT_SCALE_FACTOR=1.25
export QT_AUTO_SCREEN_SCALE_FACTOR=0

# Для всех приложений (ELM, Electron и др.)
export ELM_SCALE=1.25
export ELECTRON_FORCE_SCALE=1.25
```

**Важно:** В Wayland `GDK_SCALE` работает только с целыми числами (1, 2), а `GDK_DPI_SCALE` — с дробными. В X11 всё иначе.

## 6. **Через dconf-editor (продвинутый способ)**

Установите и используйте dconf-editor:
```bash
sudo epmi dconf-editor  # или apt-get install dconf-editor
```

Затем:
- Откройте `dconf-editor`
- Перейдите в **`/org/gnome/desktop/interface/`**
- Измените:
  - `scaling-factor` (0 = авто, 1 = 100%, 2 = 200%)
  - `text-scaling-factor` (дробное значение, например 1.2)

## 7. **Для конкретных приложений**

### Firefox:
- Введите `about:config` в адресной строке
- Найдите `layout.css.devPixelsPerPx`
- Установите значение, например `1.25`

### Chrome/Chromium:
Запустите с параметром или создайте ярлык:
```bash
chromium --force-device-scale-factor=1.25
```

### VS Code:
В настройках (`settings.json`) добавьте:
```json
"window.zoomLevel": 1
"window.zoomLevel": 1.25
```

## 8. **Автоматизация (автозагрузка)**

### Для X11 (через xrandr):
Создайте файл `~/.config/autostart/scale.desktop`:
```ini
[Desktop Entry]
Type=Application
Name=Display Scaling
Exec=/home/kkorablin/.local/bin/set-scale.sh 1.15
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
```

### Для Wayland (через переменные):
Добавьте в `~/.profile` или `~/.config/environment.d/99-scale.conf`:
```bash
export GDK_DPI_SCALE=1.15
export QT_SCALE_FACTOR=1.15
```

## 9. **Если ничего не помогает (сброс настроек)**

Если масштабирование сломалось после обновлений или смены дисплейного менеджера:

```bash
# Сбросить настройки GNOME
dconf reset -f /org/gnome/

# Или удалить файл конфигурации мониторов
rm ~/.config/monitors.xml

# Перезагрузиться
sudo reboot
```

После перезагрузки система заново определит мониторы и предложит настройки.

---

## **Рекомендация для Ximper Linux 0.9.4 с GNOME и AMD/Intel графикой**

1. **Переключитесь на Wayland** (через меню входа — шестеренку ⚙️)

2. **Проверьте тип сессии:**
   ```bash
   echo $XDG_SESSION_TYPE
   # Должно быть wayland
   ```

3. **Включите дробное масштабирование** (если ещё не включено):
   ```bash
   gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
   ```

4. **Настройте масштаб через интерфейс** (Параметры → Экран) или командой:
   ```bash
   # Например, для масштаба 125%
   gsettings set org.gnome.desktop.interface text-scaling-factor 1.25
   ```

5. **Для единообразия во всех приложениях** добавьте в `~/.profile`:
   ```bash
   export GDK_DPI_SCALE=1.25
   export QT_SCALE_FACTOR=1.25
   ```

**Примечание:** После изменения дисплейного менеджера (например, при переходе с SDDM на Greetd) настройки экрана могут сброситься — не паникуйте, просто настройте масштаб заново одним из описанных способов. Владельцы AMD/Intel графики могут смело использовать Wayland — он работает стабильно и даёт больше гибкости.

---

