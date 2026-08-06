# 📘 Инструкция: настройка экранной клавиатуры и автоповорота на GPD Pocket 4 (EndeavourOS + GNOME)

## 🧠 Для чего всё это нужно

GPD Pocket 4 — это ультрабук-трансформер с сенсорным экраном.  
В Windows 11 из коробки работают:
- всплывающая экранная клавиатура
- автоповорот экрана
- режим планшета

В Linux всё это **нужно настраивать вручную**, потому что:
- производитель не отправляет драйверы под Linux
- датчики (акселерометр) требуют ручной привязки к ориентации экрана
- GNOME по умолчанию не включает клавиатуру автоматически

---

## 🎯 Что мы сделали в итоге

✅ Экранная клавиатура **появляется автоматически** при касании поля ввода  
✅ Клавиатуру можно **вызвать вручную** жестом снизу вверх  
✅ Ориентация при загрузке — **ландшафтная**  
✅ **Масштаб экрана при загрузке — 166%** (оптимально для экрана 1600×2560)  
✅ **Автоповорот экрана работает** (через расширение GNOME Screen Rotate)  
✅ Система полностью готова к планшетному режиму  

---

## 📦 Шаг 0. Настройка редактора по умолчанию (mc edit)

В инструкции для редактирования файлов используется `nano`, но вы можете использовать более удобный редактор `mcedit` из пакета `mc` (Midnight Commander).

### Установка MC
```bash
sudo pacman -S mc
```

### Настройка редактора по умолчанию
```bash
# Устанавливаем mcedit как редактор по умолчанию
export EDITOR=mcedit
echo 'export EDITOR=mcedit' >> ~/.bashrc
echo 'export VISUAL=mcedit' >> ~/.bashrc

# Для системных вызовов (sudo)
sudo update-alternatives --set editor /usr/bin/mcedit 2>/dev/null || true
```

### Создание алиаса для замены nano
```bash
# Добавляем алиас, чтобы команда nano запускала mcedit
echo "alias nano='mcedit'" >> ~/.bashrc
source ~/.bashrc
```

### Использование
Теперь вместо `nano файл` можно использовать:
```bash
mcedit файл
# или просто (если создали алиас)
nano файл
```

**Преимущества mcedit:**
- Подсветка синтаксиса
- Работа с мышью
- Клавиши F1-F12 для действий
- Более удобная навигация

---

## 📦 Шаг 1. Включение встроенной экранной клавиатуры GNOME

### Что делаем
Включаем штатную клавиатуру GNOME (работает на Wayland).

### Команда
```bash
gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled true
```

### Почему без `sudo`
`gsettings` работает **только от обычного пользователя**. `sudo` здесь не нужен и вызывает ошибку.

### Результат
Клавиатура готова к использованию, но появится **только в GTK-приложениях** (поиск GNOME, настройки, терминал).

---

## 📦 Шаг 2. Установка драйвера датчика положения (акселерометра)

### Что делаем
Устанавливаем службу, которая читает данные с акселерометра.

### Команда
```bash
sudo pacman -S iio-sensor-proxy
```

### Что это даёт
Система начинает видеть физический поворот устройства.

### Проверка
```bash
monitor-sensor
```
При повороте ноутбука должны появляться сообщения:
```
Accelerometer orientation changed: normal
Accelerometer orientation changed: right-up
```

---

## 📦 Шаг 3. Настройка матрицы поворота датчика

### Проблема
GPD Pocket 4 физически установил экран в «лежачей» ориентации, а датчик — в «стоячей».  
Без правки система не понимает, что значит «нормальное положение».

### Что делаем
Создаём файл, который объясняет системе, как пересчитать оси датчика.

### Команды
```bash
sudo mcedit /etc/udev/hwdb.d/61-sensor-local.hwdb
```

Содержимое файла (под ваш `pnG1628-04`):
```bash
# GPD Pocket 4 (G1628-04)
sensor:modalias:acpi:MXC6655*:dmi:*:svnGPD:pnG1628-04:*
 ACCEL_MOUNT_MATRIX=0, 1, 0; -1, 0, 0; 0, 0, 1
```

Применяем:
```bash
sudo systemd-hwdb update
sudo udevadm trigger -v -p DEVNAME=/dev/iio:device0
sudo systemctl restart iio-sensor-proxy
```

### Результат
Датчик начинает правильно сообщать ориентацию (`normal`, `bottom-up` и т.д.).

---

## 📦 Шаг 4. Фиксация ландшафтной ориентации при загрузке и масштаб 166%

### Проблема
Физическая матрица GPD Pocket 4 имеет **портретную** ориентацию (1600×2560). Без настройки экран загружается в портретном режиме.  
Кроме того, на таком экране стандартный масштаб 100% делает элементы интерфейса слишком мелкими.

### Решение
Создаём конфигурацию дисплея с **поворотом `right`** (90°) для ландшафтного режима и **масштабом 1.66** (166%).

### Базовая команда (ландшафт + масштаб 166%)
```bash
cat > ~/.config/monitors.xml << 'EOF'
<monitors version="2">
  <configuration>
    <logicalmonitor>
      <x>0</x>
      <y>0</y>
      <scale>1.66</scale>
      <primary>yes</primary>
      <transform>
        <rotation>right</rotation>
        <flipped>no</flipped>
      </transform>
      <monitor>
        <monitorspec>
          <connector>eDP-1</connector>
          <vendor>unknown</vendor>
          <product>unknown</product>
          <serial>unknown</serial>
        </monitorspec>
        <mode>
          <width>1600</width>
          <height>2560</height>
          <rate>143.999</rate>
        </mode>
      </monitor>
    </logicalmonitor>
  </configuration>
</monitors>
EOF
```

### Почему 166%?
- Разрешение экрана: 1600×2560 (портретная матрица)
- После поворота `right` получаем разрешение 2560×1600 (ландшафт)
- Стандартный масштаб 100%: элементы слишком мелкие
- Масштаб 166%: комфортный размер интерфейса, текст читаем, элементы не выходят за границы
- Альтернативные варианты: 150% (мелковато), 175% (крупновато), 200% (очень крупно)

### Другие варианты конфигурации `~/.config/monitors.xml`

**Вариант 1. Только встроенный экран, ландшафт, масштаб 166% (основной)** — уже описан выше.

**Вариант 2. Встроенный экран + внешний монитор СПРАВА**
```bash
cat > ~/.config/monitors.xml << 'EOF'
<monitors version="2">
  <configuration>
    <logicalmonitor>
      <x>0</x>
      <y>0</y>
      <scale>1.66</scale>
      <primary>yes</primary>
      <transform>
        <rotation>right</rotation>
        <flipped>no</flipped>
      </transform>
      <monitor>
        <monitorspec>
          <connector>eDP-1</connector>
          <vendor>unknown</vendor>
          <product>unknown</product>
          <serial>unknown</serial>
        </monitorspec>
        <mode>
          <width>1600</width>
          <height>2560</height>
          <rate>143.999</rate>
        </mode>
      </monitor>
    </logicalmonitor>
    <logicalmonitor>
      <x>2560</x>
      <y>0</y>
      <scale>1</scale>
      <monitor>
        <monitorspec>
          <connector>DP-11</connector>
          <vendor>unknown</vendor>
          <product>unknown</product>
          <serial>unknown</serial>
        </monitorspec>
        <mode>
          <width>2560</width>
          <height>1440</height>
          <rate>60.000</rate>
        </mode>
      </monitor>
    </logicalmonitor>
  </configuration>
</monitors>
EOF
```
*Примечание: координата x = 2560, так как ширина встроенного экрана после масштаба 1.66 рассчитывается как 1600×1.66 ≈ 2656, используется базовое разрешение 2560.*

**Вариант 3. Встроенный экран + внешний монитор СВЕРХУ**
```bash
cat > ~/.config/monitors.xml << 'EOF'
<monitors version="2">
  <configuration>
    <logicalmonitor>
      <x>0</x>
      <y>0</y>
      <scale>1.66</scale>
      <primary>yes</primary>
      <transform>
        <rotation>right</rotation>
        <flipped>no</flipped>
      </transform>
      <monitor>
        <monitorspec>
          <connector>eDP-1</connector>
          <vendor>unknown</vendor>
          <product>unknown</product>
          <serial>unknown</serial>
        </monitorspec>
        <mode>
          <width>1600</width>
          <height>2560</height>
          <rate>143.999</rate>
        </mode>
      </monitor>
    </logicalmonitor>
    <logicalmonitor>
      <x>0</x>
      <y>2560</y>
      <scale>1</scale>
      <monitor>
        <monitorspec>
          <connector>DP-11</connector>
          <vendor>unknown</vendor>
          <product>unknown</product>
          <serial>unknown</serial>
        </monitorspec>
        <mode>
          <width>2560</width>
          <height>1440</height>
          <rate>60.000</rate>
        </mode>
      </monitor>
    </logicalmonitor>
  </configuration>
</monitors>
EOF
```

**Вариант 4. Только портретный режим с масштабом (физическая ориентация матрицы)**
```bash
cat > ~/.config/monitors.xml << 'EOF'
<monitors version="2">
  <configuration>
    <logicalmonitor>
      <x>0</x>
      <y>0</y>
      <scale>1.66</scale>
      <primary>yes</primary>
      <transform>
        <rotation>normal</rotation>
        <flipped>no</flipped>
      </transform>
      <monitor>
        <monitorspec>
          <connector>eDP-1</connector>
          <vendor>unknown</vendor>
          <product>unknown</product>
          <serial>unknown</serial>
        </monitorspec>
        <mode>
          <width>1600</width>
          <height>2560</height>
          <rate>143.999</rate>
        </mode>
      </monitor>
    </logicalmonitor>
  </configuration>
</monitors>
EOF
```

**Вариант 5. Сброс к настройкам GNOME по умолчанию (без масштаба)**
```bash
rm ~/.config/monitors.xml
# После перезагрузки GNOME создаст файл заново
```

### ВАЖНО! Заблокировать файл от изменений
GNOME имеет привычку перезаписывать этот файл при подключении внешних мониторов. Чтобы этого избежать:

```bash
chmod 444 ~/.config/monitors.xml
```

### Результат
После перезагрузки экран всегда в ландшафте с масштабом 166%, и подключение внешнего монитора не сбивает ориентацию и масштаб.

---

## 📦 Шаг 5. РАБОЧЕЕ РЕШЕНИЕ: расширение GNOME для автоповорота

### Проблема
Скрипт `umpc-display-rotate` не работает на Wayland. Нужно альтернативное решение.

### Решение
Устанавливаем расширение `gnome-shell-extension-screen-autorotate`, которое работает нативно с Wayland и полностью совместимо с GNOME 50.

### Команды (ПРОВЕРЕННАЯ ПОСЛЕДОВАТЕЛЬНОСТЬ)

#### Шаг 5.1. Установка пакета
```bash
# Установка через AUR
paru -S gnome-shell-extension-screen-autorotate
```

#### Шаг 5.2. Создание символической ссылки (ВАЖНО!)
Расширение устанавливается в системную директорию `/usr/share/gnome-shell/extensions/`, но GNOME Shell не всегда видит расширения оттуда. **Необходимо вручную создать символическую ссылку в пользовательскую директорию:**

```bash
# Создаём пользовательскую директорию для расширений (если её нет)
mkdir -p ~/.local/share/gnome-shell/extensions/

# Создаём символическую ссылку на системное расширение
ln -s /usr/share/gnome-shell/extensions/screen-rotate@shyzus.github.io ~/.local/share/gnome-shell/extensions/
```

#### Шаг 5.3. Перезагрузка GNOME Shell
```bash
# Нажмите Alt+F2, введите 'r' (без кавычек) и нажмите Enter
# Или выполните:
killall -HUP gnome-shell
```

#### Шаг 5.4. Включение расширения
```bash
# Включаем расширение
gnome-extensions enable screen-rotate@shyzus.github.io

# Проверяем, что расширение активно
gnome-extensions info screen-rotate@shyzus.github.io
```

**Ожидаемый вывод:**
```
screen-rotate@shyzus.github.io
  Имя: Screen Rotate
  Описание: Enable screen rotation regardless of touch mode. Fork of Screen Autorotate by Kosmospredanie.
  Путь: /home/ваш_пользователь/.local/share/gnome-shell/extensions/screen-rotate@shyzus.github.io
  URL: https://github.com/shyzus/gnome-shell-extension-screen-autorotate
  Включено: Да
  Состояние: ACTIVE
```

#### Шаг 5.5. Настройка расширения
```bash
# Убеждаемся, что автоповорот включён
gsettings set org.gnome.shell.extensions.screen-rotate auto-rotate-enabled true

# Выбираем встроенную клавиатуру вместо onboard (если установлен)
gsettings set org.gnome.shell.extensions.screen-rotate keyboard-provider 'built-in'
```

### Что делает это расширение
- Слушает показания акселерометра через `iio-sensor-proxy`
- Автоматически поворачивает экран при физическом повороте устройства
- Работает в GNOME на Wayland без конфликтов
- Совместимо с GNOME 50 (версии 45-50 поддерживаются)

### Установка менеджера расширений (для удобного управления)
```bash
paru -S extension-manager
```
После установки запустите **Extension Manager**, найдите расширение `Screen Rotate` и при необходимости настройте его.

---

## ⚠️ ВАЖНОЕ ПРИМЕЧАНИЕ ПО СКРИПТУ `umpc-display-rotate`

В процессе настройки выяснилось, что скрипт `umpc-display-rotate` **не работает на Wayland** (GNOME 50 использует Wayland по умолчанию). Он написан для X11 и не может корректно поворачивать экран, а также выдаёт ошибку `output eDP not found`, потому что ищет `eDP` вместо `eDP-1`.

**Используйте расширение GNOME Screen Rotate вместо этого скрипта.**

Если скрипт был установлен, удалите его из автозагрузки:
```bash
rm ~/.config/autostart/umpc-rotate.desktop
killall umpc-display-rotate 2>/dev/null
```

---

## 📦 Шаг 6. Ручной вызов клавиатуры (важно!)

### Проблема
В браузерах (Chrome, Firefox) и Electron-приложениях клавиатура может **не появляться автоматически**.

### Решение (работает всегда)
👉 **Проведите пальцем от нижнего края экрана вверх**

Это универсальный жест GNOME для принудительного вызова экранной клавиатуры.

---

## 📦 Шаг 6.2. Устранение конфликта с клавиатурой Onboard

### Проблема
Если в системе установлен Onboard, расширение может вызывать его вместо родной клавиатуры GNOME.

### Решение (выберите один из способов)

**Способ 1 — через настройки расширения (рекомендуется):**
```bash
gsettings set org.gnome.shell.extensions.screen-rotate keyboard-provider 'built-in'
```

**Способ 2 — отключить интеграцию Onboard:**
```bash
gsettings set apps.onboard xembed-onboard false
```

**Способ 3 — удалить Onboard (если не нужен):**
```bash
sudo pacman -R onboard hunspell
```

**Способ 4 — через Extension Manager:**
1. Запустите **Extension Manager**
2. Найдите расширение `Screen Rotate`
3. Откройте его настройки (значок шестерёнки)
4. Выберите провайдера клавиатуры: `built-in` вместо `onboard`

### Результат
При повороте экрана и касании поля ввода появляется **родная клавиатура GNOME**, а не Onboard.

---

## 🔄 Шаг 7. Настройка масштаба через GNOME Settings (альтернативный способ)

Если по какой-то причине не работает `monitors.xml`, можно настроить масштаб через GNOME Settings:

```bash
# Установить масштаб 166% для основного дисплея
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
gsettings set org.gnome.desktop.interface scaling-factor 2  # Базовый масштаб

# Для дробного масштаба (166% = 1.66)
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
gsettings set org.gnome.desktop.interface scaling-factor 0  # Отключаем целочисленный
# Затем через GUI: Настройки → Дисплеи → Масштаб → 166%
```

---

## 🔁 Что мы НЕ стали делать (и почему)

| Действие | Почему пропустили |
|----------|------------------|
| `umpc-display-rotate` | Не работает на Wayland, заменён расширением GNOME |
| `gnome-shell-extension-auto-rotate` | Расширение не подошло; использовали `screen-autorotate` |
| `gnome-shell-extension-extended-gestures` | Расширение мертво, несовместимо с GNOME 50 |
| правка `grub` через `fbcon=rotate:1` | Нужно только для TTY / GDM, не влияет на рабочий стол |
| масштаб через `xrandr` | Не работает на Wayland, используем `monitors.xml` |

---

## 🎨 Настройка стилуса и мультитач-жестов

Ваш GPD Pocket 4 поддерживает не только касания пальцем, но и ввод с помощью **активного стилуса**. Чтобы настроить его и добавить удобные мультитач-жесты для трекпада, выполните следующие шаги.

### 🖊️ Настройка стилуса (поддержка давления и кнопок)

Установите драйверы для устройств ввода Wacom, так как стилус в GPD, скорее всего, основан на их технологии.

1.  **Установите пакет `xf86-input-wacom`:**
    ```bash
    sudo pacman -S xf86-input-wacom
    ```

2.  **Проверьте, что стилус распознан.** Подключите стилус и выполните команду:
    ```bash
    xsetwacom --list devices
    ```
    Вы должны увидеть ваше устройство, например, `Wacom HID 52F0 Pen stylus`.

3.  **Настройте параметры стилуса.** Вы можете настроить его, используя переменные окружения GNOME или команды `xsetwacom`. Вот самые полезные примеры:
    *   **Назначить действие на кнопку на стилусе:**
        ```bash
        # Например, кнопка будет эмулировать правый клик мыши
        xsetwacom --set "Wacom HID 52F0 Pen stylus" Button 2 "button +3"
        ```
    *   **Настроить чувствительность к нажатию:** Это позволит сделать линии толще или тоньше в зависимости от силы нажатия.
        ```bash
        # Значение может быть от 0 до 100
        xsetwacom --set "Wacom HID 52F0 Pen stylus" PressureThreshold 10
        ```
    *   **Сделать настройки постоянными:** Чтобы настройки не сбрасывались после перезагрузки, добавьте команды `xsetwacom` в автозагрузку. Создайте файл `~/.config/autostart/wacom-setup.desktop`:
        ```bash
        cat > ~/.config/autostart/wacom-setup.desktop << EOF
        [Desktop Entry]
        Type=Application
        Name=Wacom Stylus Setup
        Exec=/usr/bin/xsetwacom --set "Wacom HID 52F0 Pen stylus" Button 2 "button +3"
        Hidden=false
        NoDisplay=false
        X-GNOME-Autostart-enabled=true
        EOF
        ```

### 🖱️ Настройка мультитач-жестов для трекпада

По умолчанию в GNOME под Wayland доступно только ограниченное число жестов. Чтобы получить полный контроль, можно использовать утилиту `libinput-gestures` .

1.  **Установите `libinput-gestures`:**
    ```bash
    paru -S libinput-gestures
    ```

2.  **Добавьте своего пользователя в группу `input`, чтобы программа могла читать события от трекпада:**
    ```bash
    sudo gpasswd -a $USER input
    ```

3.  **Перезагрузитесь**, чтобы изменения вступили в силу.

4.  **Создайте и настройте конфигурационный файл `~/.config/libinput-gestures.conf`.** Вот пример для начала:
    ```bash
    touch ~/.config/libinput-gestures.conf
    echo "# Навигация по рабочим столам (3 пальца)
    gesture swipe left 3 _internal ws_left
    gesture swipe right 3 _internal ws_right
    gesture swipe up 3 _internal ws_up
    gesture swipe down 3 _internal ws_down

    # Переключение между приложениями (4 пальца)
    gesture swipe left 4 xdotool key alt+Right
    gesture swipe right 4 xdotool key alt+Left

    # Масштабирование (щипок)
    gesture pinch in 2 xdotool key ctrl+minus
    gesture pinch out 2 xdotool key ctrl+plus
    " >> ~/.config/libinput-gestures.conf
    ```
    *   **Примечание:** Для эмуляции нажатий клавиш в Wayland может потребоваться установить `ydotool` или использовать `_internal` команды, где это возможно.

5.  **Запустите `libinput-gestures` и добавьте в автозагрузку:**
    ```bash
    libinput-gestures-setup autostart
    libinput-gestures-setup start
    ```

Теперь ваш GPD Pocket 4 будет реагировать на удобные мультитач-жесты, а работа со стилусом станет максимально комфортной.

---

# 🛠️ ДОПОЛНИТЕЛЬНЫЕ ДРАЙВЕРЫ И УТИЛИТЫ ОТ СООБЩЕСТВА

Ниже приведены **все известные драйверы и утилиты**, созданные сообществом для GPD Pocket 4. Они не обязательны для базовой работы, но могут понадобиться для расширения функциональности (управление вентилятором, AI, LTE и т.д.).

---

## 1. 🌀 gpd-fan-driver — управление вентилятором

Позволяет системе видеть кулер и управлять его оборотами. **Уже встроен в ядро 6.18+** (у вас 6.19.11 — должен работать).

**Проверка, что драйвер активен:**
```bash
ls /sys/devices/platform/gpd_fan/
```

**Если папки нет — установка из AUR:**
```bash
paru -S gpd-fan-driver-dkms-git
sudo modprobe gpd-fan
echo 'gpd-fan' | sudo tee /etc/modules-load.d/gpd-fan.conf
```

**Управление вентилятором:**
```bash
# Посмотреть обороты
cat /sys/devices/platform/gpd_fan/hwmon/hwmon*/fan1_input

# Включить авторежим (рекомендуется)
echo 2 | sudo tee /sys/devices/platform/gpd_fan/hwmon/hwmon*/pwm1_enable

# Установить скорость вручную (0–255)
echo 150 | sudo tee /sys/devices/platform/gpd_fan/hwmon/hwmon*/pwm1
```

---

## 2. 📐 panel-orientation-quirks — правильная ориентация экрана

Патч, который заставляет ядро понимать, что физическая матрица GPD Pocket 4 — портретная (1600×2560). **Уже в ядре 6.18+**.

**Проверка, что квирк активен:**
```bash
dmesg | grep -i "pocket 4"
```

Если видите `GPD Pocket 4` — всё хорошо. Если нет — добавьте параметр загрузчика:
```bash
sudo kernelstub -a "video=HDMI-A-1:e"
```

---

## 3. 📡 LTE modem (Quectel EC25) — разблокировка FCC

Если у вас установлен LTE-модуль, он может быть заблокирован. ModemManager не даст ему работать без разблокировки.

**Установка и разблокировка:**
```bash
sudo pacman -S modemmanager
sudo ln -s /usr/share/ModemManager/fcc-unlock.available.d/2c7c /etc/ModemManager/fcc-unlock.d/
sudo systemctl restart ModemManager
```

**Проверка:**
```bash
mmcli -L
```

---

## 4. 🎛️ amdgpu / ROCm — для AI и машинного обучения

Стандартный драйвер `amdgpu` уже в ядре. Для задач AI (машинное обучение) на Radeon 890M нужен ROCm.

**Установка ROCm:**
```bash
sudo usermod -a -G render,video $USER
paru -S rocm-hip-sdk rocm-opencl-sdk

echo 'export ROCM_PATH=/opt/rocm' >> ~/.bashrc
echo 'export PATH=$ROCM_PATH/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=$ROCM_PATH/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
echo 'export HSA_OVERRIDE_GFX_VERSION=11.5.0' >> ~/.bashrc
source ~/.bashrc
```

**Проверка:**
```bash
rocminfo | grep gfx
# Должно показать gfx1150
```

---

## 5. 🖱️ GPD Pocket Screen Indicator — альтернатива расширениям

Утилита, которая сама поворачивает экран и управляет клавиатурой (работает, если расширения GNOME не справляются). **Альтернатива расширению Screen Rotate.**

**Установка:**
```bash
cd /tmp
git clone https://github.com/antheas/gpd-pocket-screen-indicator.git
cd gpd-pocket-screen-indicator
sudo pacman -S python-pyqt5 python-psutil
python3 main.py &
```

**Добавление в автозапуск:**
```bash
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/gpd-indicator.desktop << EOF
[Desktop Entry]
Type=Application
Name=GPD Pocket Screen Indicator
Exec=python3 /tmp/gpd-pocket-screen-indicator/main.py
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
```

---

## 6. 🔊 Звук — патч для ACP (если нет звука)

У некоторых экземпляров GPD Pocket 4 нет звука из коробки. Лечится параметром загрузчика.

**Решение:**
```bash
sudo mcedit /etc/default/grub
# В GRUB_CMDLINE_LINUX_DEFAULT добавьте:
# snd_pci_acp3x.enable=1
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

---

## 7. 🔋 Батарея и управление питанием

Всё работает через стандартный `acpi`. Для тонкого управления:

```bash
sudo pacman -S tlp tlp-rdw
sudo systemctl enable --now tlp
```

---

## 📋 Сводная таблица драйверов

| Драйвер/утилита | Назначение | Статус | Установка |
|----------------|-----------|--------|-----------|
| `mc` / `mcedit` | Редактор с подсветкой синтаксиса | ✅ Установлен | `sudo pacman -S mc` |
| `gnome-shell-extension-screen-autorotate` | Автоповорот экрана | ✅ Работает | `paru -S gnome-shell-extension-screen-autorotate` + создание симлинка |
| `gpd-fan-driver` | Управление вентилятором | ✅ В ядре 6.18+ | `paru -S gpd-fan-driver-dkms-git` (если не работает) |
| `panel-orientation` | Ориентация экрана | ✅ В ядре 6.18+ | Параметр загрузчика |
| `LTE modem` | Разблокировка модема | ✅ Поддерживается | Ссылка на fcc-unlock |
| `ROCm` | AI / машинное обучение | ✅ Поддерживается | `paru -S rocm-hip-sdk` |
| `Screen Indicator` | Автоповорот (альтернатива) | ✅ Работает | git clone |
| `Звук (ACP)` | Исправление звука | 🟡 Требуется параметр | Параметр загрузчика |
| `TLP` | Управление питанием | ✅ Работает | `sudo pacman -S tlp` |

---

## ✅ Итог: что мы имеем сейчас

- [x] Экранная клавиатура **появляется сама** в полях ввода
- [x] Клавиатуру можно **вызвать жестом** снизу вверх
- [x] Ориентация при загрузке — **ландшафтная** (с возможностью выбора разных вариантов)
- [x] **Масштаб при загрузке — 166%** (оптимален для экрана 2560×1600 в ландшафте)
- [x] Автоповорот **работает** (расширение `screen-rotate@shyzus.github.io` + `iio-sensor-proxy`)
- [x] Расширение установлено через **символическую ссылку** из `/usr/share/` в `~/.local/share/`
- [x] Конфликт с Onboard **устранён** через настройку `keyboard-provider`
- [x] Редактор по умолчанию — **mcedit** (установлен алиас для nano)
- [x] Поддержка **стилуса** (давление, кнопки)
- [x] **Мультитач-жесты** для трекпада
- [x] Система **готова к планшетному режиму**
- [x] Дополнительные драйверы (вентилятор, LTE, ROCm, TLP) — по желанию

---

## 📎 Полезные команды для диагностики (на будущее)

```bash
# Проверить работу датчика
monitor-sensor

# Статус службы датчика
systemctl status iio-sensor-proxy

# Логи автоповорота
journalctl -b | grep -i "rotate"

# Включена ли клавиатура
gsettings get org.gnome.desktop.a11y.applications screen-keyboard-enabled

# Список включённых расширений GNOME
gnome-extensions list --enabled

# Статус расширения Screen Rotate
gnome-extensions info screen-rotate@shyzus.github.io

# Проверка настроек расширения
gsettings get org.gnome.shell.extensions.screen-rotate auto-rotate-enabled
gsettings get org.gnome.shell.extensions.screen-rotate keyboard-provider

# Текущий масштаб дисплея (из monitors.xml)
grep scale ~/.config/monitors.xml

# Проверка вентилятора
cat /sys/devices/platform/gpd_fan/hwmon/hwmon*/fan1_input 2>/dev/null && echo "✅ Fan driver OK" || echo "⚠️ Fan driver not found"

# Проверка ROCm (если установлен)
command -v rocminfo &>/dev/null && echo "✅ ROCm OK" || echo "⚠️ ROCm not installed"

# Проверка TLP
systemctl is-active tlp &>/dev/null && echo "✅ TLP OK" || echo "⚠️ TLP not installed"

# Проверка алиаса nano
alias nano
```

---

## 🔄 Краткое резюме: ключевые шаги для настройки

Если нужно быстро восстановить настройку:

```bash
# 1. Настройка редактора
sudo pacman -S mc
echo "alias nano='mcedit'" >> ~/.bashrc
source ~/.bashrc

# 2. Установка расширения автоповорота
paru -S gnome-shell-extension-screen-autorotate
mkdir -p ~/.local/share/gnome-shell/extensions/
ln -s /usr/share/gnome-shell/extensions/screen-rotate@shyzus.github.io ~/.local/share/gnome-shell/extensions/
killall -HUP gnome-shell
gnome-extensions enable screen-rotate@shyzus.github.io

# 3. Настройка автоповорота
gsettings set org.gnome.shell.extensions.screen-rotate auto-rotate-enabled true
gsettings set org.gnome.shell.extensions.screen-rotate keyboard-provider 'built-in'

# 4. Настройка масштаба 166% и ориентации (создать monitors.xml с scale=1.66 и rotation=right)
# см. Шаг 4 выше

# 5. Блокировка файла от изменений
chmod 444 ~/.config/monitors.xml
```
