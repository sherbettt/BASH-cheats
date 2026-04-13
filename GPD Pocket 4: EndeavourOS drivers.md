Инструкция написана **под вашу конфигурацию**:
- Ноутбук: **GPD Pocket 4** (модель G1628-04)
- ОС: **EndeavourOS** (Arch Linux)
- Окружение: **GNOME 50.0**, Wayland
- Железо: AMD Ryzen AI 9 HX 370 + Radeon 890M

---


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
✅ **Автоповорот экрана работает** (через расширение GNOME)  
✅ Система полностью готова к планшетному режиму  

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
sudo nano /etc/udev/hwdb.d/61-sensor-local.hwdb
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

## 📦 Шаг 4. Фиксация ландшафтной ориентации при загрузке

### Проблема
После перезагрузки экран возвращается в портретный режим.

### Что делаем
Создаём конфигурацию дисплея для GNOME.

### Команда
```bash
cat > ~/.config/monitors.xml << 'EOF'
<monitors version="2">
  <configuration>
    <logicalmonitor>
      <x>0</x>
      <y>0</y>
      <scale>1</scale>
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

### Результат
После перезагрузки экран всегда в ландшафте.

---

## 📦 Шаг 5. Установка утилиты автоповорота и клавиатуры

### Проблема
GNOME сам по себе не поворачивает экран и не включает клавиатуру при повороте.

### Что делаем
Ставим скрипт `umpc-display-rotate` от сообщества GPD.

### Команды
```bash
# зависимости
sudo pacman -S libinput

# скачиваем и компилируем
cd /tmp
git clone https://codeberg.org/elloskelling/linux-gpd-pocket-4.git
cd linux-gpd-pocket-4
gcc -O2 umpc-display-rotate.c -o umpc-display-rotate -lm
sudo cp umpc-display-rotate /usr/local/bin/
sudo chmod +x /usr/local/bin/umpc-display-rotate

# автозапуск
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/umpc-rotate.desktop << EOF
[Desktop Entry]
Type=Application
Name=UMPC Display Rotate
Exec=/usr/local/bin/umpc-display-rotate
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
```

### Что делает этот скрипт
- слушает данные с акселерометра
- автоматически поворачивает экран
- **включает экранную клавиатуру** в планшетном режиме
- работает через `iio-sensor-proxy`, без расширений GNOME

---

## ⚠️ ВАЖНОЕ ПРИМЕЧАНИЕ ПО СКРИПТУ `umpc-display-rotate`

В процессе настройки выяснилось, что скрипт `umpc-display-rotate` **не работает на Wayland** (GNOME 50 использует Wayland по умолчанию). Он написан для X11 и не может корректно поворачивать экран, а также выдаёт ошибку `output eDP not found`, потому что ищет `eDP` вместо `eDP-1`.

**Если скрипт у вас не заработал** — это нормально. Переходите к следующему шагу, где описано рабочее решение через расширение GNOME.

Вы можете удалить скрипт из автозагрузки:
```bash
rm ~/.config/autostart/umpc-rotate.desktop
killall umpc-display-rotate
```

---

## 📦 Шаг 5.2. РАБОЧЕЕ РЕШЕНИЕ: расширение GNOME для автоповорота

### Проблема
Скрипт `umpc-display-rotate` не работает на Wayland. Нужно альтернативное решение.

### Решение
Устанавливаем расширение `gnome-shell-extension-screen-autorotate`, которое работает нативно с Wayland.

### Команды
```bash
# Установка через AUR
paru -S gnome-shell-extension-screen-autorotate

# Включение расширения
gnome-extensions enable screen-rotate@shyzus.github.io

# Проверка, что расширение активно
gnome-extensions list --enabled | grep rotate
```

### Что делает это расширение
- Слушает показания акселерометра через `iio-sensor-proxy`
- Автоматически поворачивает экран при физическом повороте устройства
- Работает в GNOME на Wayland без конфликтов

### Установка менеджера расширений (для удобного управления)
```bash
yay -S extension-manager
```
После установки запустите **Extension Manager**, найдите расширение `Screen Autorotate` и при необходимости настройте его.

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
После установки расширения `screen-autorotate` при повороте экрана **появляется клавиатура Onboard**, а не родная клавиатура GNOME.

### Причина
Расширение по умолчанию вызывает `onboard`, если он установлен в системе.

### Решение (выберите один из способов)

**Способ 1 — отключить интеграцию Onboard (быстро):**
```bash
gsettings set apps.onboard xembed-onboard false
```

**Способ 2 — удалить Onboard (если не нужен):**
```bash
sudo pacman -R onboard hunspell
```

**Способ 3 — через Extension Manager:**
1. Запустите **Extension Manager**
2. Найдите расширение `Screen Autorotate`
3. Откройте его настройки (значок шестерёнки)
4. Выберите провайдера клавиатуры: `built-in` вместо `onboard`

### Результат
При повороте экрана и касании поля ввода появляется **родная клавиатура GNOME**, а не Onboard.

---

## 🔁 Что мы НЕ стали делать (и почему)

| Действие | Почему пропустили |
|----------|------------------|
| `gnome-shell-extension-auto-rotate` | Расширение не подошло; использовали `screen-autorotate` |
| `gnome-shell-extension-extended-gestures` | Расширение мертво, несовместимо с GNOME 50 |
| правка `grub` через `fbcon=rotate:1` | Нужно только для TTY / GDM, не влияет на рабочий стол |
| использование `umpc-display-rotate` | Не работает на Wayland, заменён расширением GNOME |

---

## ✅ Итог: что мы имеем сейчас

- [x] Экранная клавиатура **появляется сама** в полях ввода
- [x] Клавиатуру можно **вызвать жестом** снизу вверх
- [x] Ориентация при загрузке — **ландшафтная**
- [x] Автоповорот **работает** (расширение `screen-autorotate` + `iio-sensor-proxy`)
- [x] Конфликт с Onboard **устранён**
- [x] Система **готова к планшетному режиму**

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
```

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

Утилита, которая сама поворачивает экран и управляет клавиатурой (работает, если расширения GNOME не справляются).

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
sudo nano /etc/default/grub
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
| `gpd-fan-driver` | Управление вентилятором | ✅ В ядре 6.18+ | `paru -S gpd-fan-driver-dkms-git` (если не работает) |
| `panel-orientation` | Ориентация экрана | ✅ В ядре 6.18+ | Параметр загрузчика |
| `LTE modem` | Разблокировка модема | ✅ Поддерживается | Ссылка на fcc-unlock |
| `ROCm` | AI / машинное обучение | ✅ Поддерживается | `paru -S rocm-hip-sdk` |
| `Screen Indicator` | Автоповорот (альтернатива) | ✅ Работает | git clone |
| `Звук (ACP)` | Исправление звука | 🟡 Требуется параметр | Параметр загрузчика |
| `TLP` | Управление питанием | ✅ Работает | `sudo pacman -S tlp` |

---

## 🧪 Финальная проверка всех драйверов

```bash
# Проверка вентилятора
cat /sys/devices/platform/gpd_fan/hwmon/hwmon*/fan1_input 2>/dev/null && echo "✅ Fan driver OK" || echo "⚠️ Fan driver not found"

# Проверка акселерометра
systemctl is-active iio-sensor-proxy && echo "✅ iio-sensor-proxy OK" || echo "⚠️ iio-sensor-proxy not running"

# Проверка ROCm (если установлен)
command -v rocminfo &>/dev/null && echo "✅ ROCm OK" || echo "⚠️ ROCm not installed"

# Проверка TLP
systemctl is-active tlp &>/dev/null && echo "✅ TLP OK" || echo "⚠️ TLP not installed"
```

---










