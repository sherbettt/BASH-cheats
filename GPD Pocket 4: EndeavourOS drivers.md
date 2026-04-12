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

## 📦 Шаг 4. Фиксация ландшафтной ориентации при загрузке

### Проблема
Физическая матрица GPD Pocket 4 имеет **портретную** ориентацию (1600×2560). Без настройки экран загружается в портретном режиме.

### Решение
Создаём конфигурацию дисплея с **поворотом `right`** (90°), чтобы получить ландшафтный рабочий стол.

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

### ВАЖНО! Заблокировать файл от изменений
GNOME имеет привычку перезаписывать этот файл при подключении внешних мониторов. Чтобы этого избежать:

```bash
chmod 444 ~/.config/monitors.xml
```

### Результат
После перезагрузки экран всегда в ландшафте, и подключение внешнего монитора не сбивает ориентацию.

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

# 📄 ПРИЛОЖЕНИЕ: разные варианты `~/.config/monitors.xml`

Ниже приведены **готовые конфигурации** для разных сценариев. Выберите нужный, замените содержимое файла и выполните `chmod 444 ~/.config/monitors.xml`.

---

## Вариант 1. Только встроенный экран, ландшафт (основной)

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
chmod 444 ~/.config/monitors.xml
```

---

## Вариант 2. Встроенный экран + внешний монитор СПРАВА

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
      <x>1600</x>
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
chmod 444 ~/.config/monitors.xml
```

---

## Вариант 3. Встроенный экран + внешний монитор СВЕРХУ (как вы просили)

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
chmod 444 ~/.config/monitors.xml
```

**Пояснение:** `y="2560"` означает, что внешний монитор начинается там, где заканчивается встроенный (1600×2560 → высота 2560 пикселей). Внешний монитор будет **над** встроенным.

---

## Вариант 4. Только портретный режим (если нужно вернуть "как в железе")

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
          <width>1600</width>
          <height>2560</height>
          <rate>143.999</rate>
        </mode>
      </monitor>
    </logicalmonitor>
  </configuration>
</monitors>
EOF
chmod 444 ~/.config/monitors.xml
```

---

## Вариант 5. Сброс к настройкам по умолчанию (удалить файл)

```bash
rm ~/.config/monitors.xml
```

После этого GNOME создаст файл заново при следующем изменении настроек дисплея.

---

## ⚠️ Важное замечание про блокировку файла

- `chmod 444` делает файл **только для чтения**. GNOME не сможет его изменить при подключении/отключении мониторов.
- Если нужно внести изменения — сначала разблокируйте: `chmod 644 ~/.config/monitors.xml`
- После изменений снова заблокируйте: `chmod 444 ~/.config/monitors.xml`

---

## 🧠 Финальные ответы на ваши вопросы

> теперь у меня всегда будет портретное положение на основном экране?

**Нет.** Если вы используете **Вариант 1, 2 или 3** (с `rotation=right`), у вас всегда будет **ландшафтное** положение.

> а в режиме планшета будет переворачиваться?

**Да.** Расширение `screen-autorotate` будет поворачивать экран при физическом повороте ноутбука, независимо от того, что написано в `monitors.xml`. `monitors.xml` задаёт только **ориентацию при загрузке**.

> что изменилось в варианте "монитор сверху"?

В **Варианте 3** внешний монитор расположен **над** встроенным (`y="2560"`), а не справа. Это удобно, если внешний монитор физически стоит выше ноутбука.










