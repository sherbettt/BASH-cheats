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
✅ Система готова к планшетному режиму  

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

## 📦 Шаг 6. Ручной вызов клавиатуры (важно!)

### Проблема
В браузерах (Chrome, Firefox) и Electron-приложениях клавиатура может **не появляться автоматически**.

### Решение (работает всегда)
👉 **Проведите пальцем от нижнего края экрана вверх**

Это универсальный жест GNOME для принудительного вызова экранной клавиатуры.

---

## 🔁 Что мы НЕ стали делать (и почему)

| Действие | Почему пропустили |
|----------|------------------|
| `gnome-shell-extension-auto-rotate` | Не потребовалось, скрипт `umpc-display-rotate` справился |
| `gnome-shell-extension-extended-gestures` | Расширение мертво, несовместимо с GNOME 50 |
| правка `grub` через `fbcon=rotate:1` | Нужно только для TTY / GDM, не влияет на рабочий стол |

---

## ✅ Итог: что мы имеем сейчас

- [x] Экранная клавиатура **появляется сама** в полях ввода
- [x] Клавиатуру можно **вызвать жестом** снизу вверх
- [x] Ориентация при загрузке — **ландшафтная**
- [x] Автоповорот **работает** (скрипт + iio-sensor-proxy)
- [x] Система **готова к планшетному режиму**

---

## 📎 Полезные команды для диагностики (на будущее)

```bash
# Проверить работу датчика
monitor-sensor

# Статус службы датчика
systemctl status iio-sensor-proxy

# Логи автоповорота
journalctl -b | grep -i "umpc\|rotate"

# Включена ли клавиатура
gsettings get org.gnome.desktop.a11y.applications screen-keyboard-enabled
```

---









