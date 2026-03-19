# Установка и настройка Chuwi MiniBook X в Linux



## Часть 1. Установка драйверов для Chuwi MiniBook X в Ximper Linux

### 1.1. Исходная ситуация

**Устройство:** Chuwi MiniBook X (ноутбук-трансформер с сенсорным экраном 8.8", 1200x1920)

**ОС:** Ximper Linux 0.9.3 (на базе ALT Linux / Sisyphus)

**Ядро:** 6.12.63

**Какое оборудование требовало драйверов:**
- Сенсорный экран (тачскрин)
- Тачпад
- Датчик Холла (определение сложенного состояния — планшетный режим)
- Подсветка клавиатуры
- Автоповорот экрана

### 1.2. Где нашли драйверы

**Источник:** GitHub-репозиторий сообщества
```
https://github.com/petitstrawberry/minibook-support.git
```

**Почему именно он:**
- Специализирован под Chuwi MiniBook X
- Содержит готовые демоны (сервисы) для всей специфической периферии
- Поддерживает современные ядра (6.x)
- Используется владельцами этого устройства на разных дистрибутивах

### 1.3. Что внутри репозитория

Репозиторий содержит три отдельных сервиса (демона):

| Компонент | Назначение |
|-----------|------------|
| **`trackpadd`** | Драйвер/демон для тачпада и калибровки сенсорного экрана |
| **`keyboardd`** | Управление подсветкой клавиатуры |
| **`tabletmoded`** | Обработка датчика Холла (переключение в режим планшета) |

### 1.4. Процесс компиляции и установки

#### Установка необходимых инструментов:
```bash
apt-get install git gcc make
```
*Git — чтобы скачать исходники, gcc — компилятор, make — система сборки.*

#### Клонирование репозитория:
```bash
mkdir -p projects/git
cd projects/git
git clone https://github.com/petitstrawberry/minibook-support.git
cd minibook-support
```
*Скачиваем исходный код с GitHub.*

#### Компиляция:
```bash
make
```
*Компилятор gcc собирает исполняемые файлы из исходников. Предупреждения (warnings) в процессе — нормально, на работу не влияют.*

**Что происходит при компиляции:**
1. Сначала компилируется общая библиотека `libcommon.a` (общий код для всех демонов)
2. Затем компилируются сами демоны: `trackpadd`, `keyboardd`, `tabletmoded`
3. Создаются исполняемые файлы в папках `trackpadd/bin/`, `keyboardd/bin/`, `tabletmoded/bin/`

#### Установка:
```bash
make install
```

**Что делает установка:**
- Копирует скомпилированные бинарники в `/usr/bin/`
- Копирует systemd-юниты (файлы служб) в `/etc/systemd/system/`
- Автоматически запускает и добавляет в автозагрузку все три сервиса

### 1.5. Итог: какие драйверы получили

| Устройство | Драйвер/Решение | Статус |
|------------|-----------------|--------|
| Сенсорный экран | `trackpadd` | ✅ Работает |
| Тачпад | `trackpadd` | ✅ Работает |
| Датчик Холла (планшетный режим) | `tabletmoded` | ✅ Работает |
| Подсветка клавиатуры | `keyboardd` | ✅ Работает |
| Калибровка цветов | `gnome-color-manager` (из репозитория) | ✅ Установлен |

### 1.6. Проверка работы

```bash
systemctl status trackpadd keyboardd tabletmoded
```

Показывает, что все три сервиса активны (`active (running)`). Акселерометр работает после перезагрузки. *Важно отметить:* положение экрана ландшафтное (не портретное) даже без драйверов на Ximper Linux установлено сразу.

---

## Часть 2. Установка драйверов для Chuwi MiniBook X в EndeavourOS Linux

### 2.1. Особенности установки

Для EndeavourOS необходимо выполнить все действия из **Части 1** (компиляция и установка из репозитория `minibook-support`), так как они дистрибутив-независимы.

**Важное отличие:** На EndeavourOS акселерометр автоматически не работает. Ниже в **Части 5** описано решение этой проблемы.

---

## Часть 3. Настройка переключения раскладки клавиатуры в EndeavourOS (Budgie)

### 3.1. Введение

В окружении Budgie (которое основано на технологиях GNOME) за переключение раскладки отвечают два уровня:
* **Системный уровень** (для экрана входа в систему)
* **Пользовательский уровень** (для вашей рабочей сессии после входа)

### 3.2. Диагностика текущих настроек

```bash
# Проверка системных настроек X11
localectl status

# Проверка настроек экрана входа
cat /etc/default/keyboard

# Проверка настроек пользовательской сессии (ВАЖНО!)
gsettings get org.gnome.desktop.input-sources sources
gsettings get org.gnome.desktop.wm.keybindings switch-input-source

# Тест клавиш переключения
xev
```

### 3.3. Очистка старых настроек

```bash
gsettings reset org.gnome.desktop.input-sources sources
gsettings reset org.gnome.desktop.wm.keybindings switch-input-source
gsettings reset org.gnome.desktop.wm.keybindings switch-input-source-backward
```

### 3.4. Вариант A: Настройка переключения по клавише Caps Lock

*Примечание: клавиша Caps Lock перестанет включать "режим заглавных букв".*

#### Системный уровень (экран входа):
```bash
sudo localectl --no-convert set-x11-keymap us,ru pc105 "" grp:caps_toggle
```

#### Проверка конфигурационного файла:
```bash
sudo nano /etc/default/keyboard
```
Приведите файл к виду:
```
# KEYBOARD CONFIGURATION FILE
XKBMODEL="pc105"
XKBLAYOUT="us,ru"
XKBVARIANT=""
XKBOPTIONS="grp:caps_toggle"
BACKSPACE="guess"
```

#### Пользовательская сессия (Budgie):
```bash
# Устанавливаем раскладки
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ru')]"

# Устанавливаем переключение по Caps Lock
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['Caps_Lock']"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Shift>Caps_Lock']"
```

### 3.5. Вариант B: Настройка переключения по Alt+Shift

#### Системный уровень:
```bash
sudo localectl --no-convert set-x11-keymap us,ru pc105 "" grp:alt_shift_toggle
```

#### Конфигурационный файл:
```bash
sudo nano /etc/default/keyboard
```
Содержимое:
```
# KEYBOARD CONFIGURATION FILE
XKBMODEL="pc105"
XKBLAYOUT="us,ru"
XKBVARIANT=""
XKBOPTIONS="grp:alt_shift_toggle"
BACKSPACE="guess"
```

#### Пользовательская сессия:
```bash
# Устанавливаем раскладки
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ru')]"

# Устанавливаем переключение по Alt+Shift
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Alt>Shift_L', '<Shift>Alt_L']"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Alt>Shift_R', '<Shift>Alt_R']"
```

### 3.6. Применение и проверка

**Перезагрузка:**
```bash
reboot
```

**Проверка результата:**
1. Экран входа — проверьте переключение языка
2. Панель Budgie — наличие индикатора раскладки
3. Текстовый редактор — тест переключения

### 3.7. Решение проблем

| Проблема | Решение |
|----------|---------|
| Конфликт комбинаций | Проверьте, не используется ли Caps Lock в других приложениях |
| Wayland вместо Xorg | `echo $XDG_SESSION_TYPE`. Выберите "Budgie on Xorg" при входе |
| Сброс после обновления | Повторно выполните команды `gsettings` |

---

## Часть 4. ПОЛНАЯ ИНСТРУКЦИЯ: УПРАВЛЕНИЕ ЭНЕРГОСБЕРЕЖЕНИЕМ ЭКРАНА (EndeavourOS / Budgie)

### 4.1. Теория: три независимые функции

В системе работают **три независимых механизма** управления питанием экрана:

| Функция | Команда | Что делает | По умолчанию |
|--------|---------|------------|--------------|
| **Частичное затемнение** | `idle-dim` | Экран **становится тусклее** (dimming) | `true` (включено) |
| **Уровень затемнения** | `idle-brightness` | На сколько % темнеет (30 = яркость 30%) | `30` |
| **Полное отключение** | `sleep-inactive-ac-timeout` | Экран **полностью гаснет** (черный экран) | `3600` (1 час) |
| **Действие** | `sleep-inactive-ac-type` | Что делать: `suspend` (сон) или `nothing` | `'suspend'` |

**Важно:** Это разные настройки! Можно настроить время до затемнения отдельно от времени до полного отключения.

### 4.2. Диагностика текущих настроек

```bash
# Время до ПОЛНОГО отключения экрана (в секундах)
gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout

# Действие при ПОЛНОМ отключении
gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type

# Включено ли ЧАСТИЧНОЕ затемнение
gsettings get org.gnome.settings-daemon.plugins.power idle-dim

# Уровень ЧАСТИЧНОГО затемнения
gsettings get org.gnome.settings-daemon.plugins.power idle-brightness
```

### 4.3. Что было сделано (подробно)

| Шаг | Команда | Результат |
|-----|---------|-----------|
| 1 | `gsettings get ... sleep-inactive-ac-timeout` | `3600` (1 час) |
| 2 | `gsettings get ... sleep-inactive-ac-type` | `'suspend'` (сон) |
| 3 | `gsettings set ... sleep-inactive-ac-timeout 0` | Отключено полное отключение |
| 4 | `gsettings set ... sleep-inactive-ac-type 'nothing'` | Отключен уход в сон |

### 4.4. Настройка времени до частичного затемнения

**Важно:** В GNOME/Budgie **нет отдельной команды** для установки времени до затемнения. Затемнение происходит одновременно с блокировкой экрана и управляется через настройки энергосбережения.

Однако вы можете управлять этим временем двумя способами:

#### Способ 1: Через графический интерфейс Budgie
1. Откройте **Настройки системы** (Budgie Menu → Настройки)
2. Перейдите в раздел **Питание** (Power)
3. Найдите пункт **"Затемнять экран через"** или **"Пустой экран через"** (Dim screen after / Blank screen after)
4. Установите нужное значение: 1 минута, 2 минуты, 5 минут, 10 минут и т.д.

#### Способ 2: Через dconf (точная настройка)
Если вам нужны точные значения (например, 60, 120 или 600 секунд), используйте dconf:

```bash
# Установить время до блокировки/затемнения на 60 секунд (1 минута)
gsettings set org.gnome.desktop.session idle-delay 60

# Установить на 120 секунд (2 минуты)
gsettings set org.gnome.desktop.session idle-delay 120

# Установить на 600 секунд (10 минут)
gsettings set org.gnome.desktop.session idle-delay 600

# Отключить затемнение (никогда)
gsettings set org.gnome.desktop.session idle-delay 0
```

**Пояснение:** Параметр `idle-delay` управляет временем бездействия, после которого срабатывает затемнение (если `idle-dim=true`) и блокировка экрана.

### 4.5. Проверка текущего времени до затемнения

```bash
gsettings get org.gnome.desktop.session idle-delay
```

### 4.6. Варианты настроек (выберите свой)

#### ВАРИАНТ A: Только для просмотра видео (полный комфорт)
*Экран всегда яркий, никогда не гаснет, не темнеет*

```bash
# Отключить ПОЛНОЕ отключение экрана
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

# Отключить ЧАСТИЧНОЕ затемнение
gsettings set org.gnome.settings-daemon.plugins.power idle-dim false

# Отключить бездействие (никогда не затемнять)
gsettings set org.gnome.desktop.session idle-delay 0
```

#### ВАРИАНТ B: Экран тускнеет через 1 минуту, но не гаснет
```bash
# Отключить ПОЛНОЕ отключение
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

# Включить ЧАСТИЧНОЕ затемнение
gsettings set org.gnome.settings-daemon.plugins.power idle-dim true

# Затемнение через 60 секунд
gsettings set org.gnome.desktop.session idle-delay 60

# Уровень затемнения 40%
gsettings set org.gnome.settings-daemon.plugins.power idle-brightness 40
```

#### ВАРИАНТ C: Экран тускнеет через 2 минуты, гаснет через 1 час
```bash
# Полное отключение через 1 час
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 3600
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'suspend'

# Затемнение через 120 секунд
gsettings set org.gnome.desktop.session idle-delay 120

# Уровень затемнения 30%
gsettings set org.gnome.settings-daemon.plugins.power idle-brightness 30
```

#### ВАРИАНТ D: Экран тускнеет через 10 минут
```bash
# Затемнение через 600 секунд
gsettings set org.gnome.desktop.session idle-delay 600

# Остальные настройки по желанию
gsettings set org.gnome.settings-daemon.plugins.power idle-dim true
gsettings set org.gnome.settings-daemon.plugins.power idle-brightness 50
```

### 4.7. Таблица соответствия: секунды → минуты

| Секунд | Минут | Команда |
|--------|-------|---------|
| 60 | 1 минута | `gsettings set org.gnome.desktop.session idle-delay 60` |
| 120 | 2 минуты | `gsettings set org.gnome.desktop.session idle-delay 120` |
| 300 | 5 минут | `gsettings set org.gnome.desktop.session idle-delay 300` |
| 600 | 10 минут | `gsettings set org.gnome.desktop.session idle-delay 600` |
| 900 | 15 минут | `gsettings set org.gnome.desktop.session idle-delay 900` |
| 1800 | 30 минут | `gsettings set org.gnome.desktop.session idle-delay 1800` |
| 3600 | 1 час | `gsettings set org.gnome.desktop.session idle-delay 3600` |

### 4.8. Возврат к заводским настройкам

```bash
# Время до затемнения (5 минут, типичное значение)
gsettings set org.gnome.desktop.session idle-delay 300

# Полное отключение (1 час)
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 3600

# Действие "сон"
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'suspend'

# Затемнение включено
gsettings set org.gnome.settings-daemon.plugins.power idle-dim true

# Уровень затемнения 30%
gsettings set org.gnome.settings-daemon.plugins.power idle-brightness 30
```

### 4.9. Полный сброс всех настроек питания

```bash
gsettings reset org.gnome.desktop.session idle-delay
gsettings reset org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout
gsettings reset org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type
gsettings reset org.gnome.settings-daemon.plugins.power idle-dim
gsettings reset org.gnome.settings-daemon.plugins.power idle-brightness
```

### 4.10. Шпаргалка: быстрые команды

| Действие | Команда |
|----------|---------|
| Узнать время до затемнения | `gsettings get org.gnome.desktop.session idle-delay` |
| Затемнение через 60 сек | `gsettings set org.gnome.desktop.session idle-delay 60` |
| Затемнение через 120 сек | `gsettings set org.gnome.desktop.session idle-delay 120` |
| Затемнение через 600 сек | `gsettings set org.gnome.desktop.session idle-delay 600` |
| Отключить затемнение | `gsettings set org.gnome.desktop.session idle-delay 0` |
| Узнать время до отключения | `gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout` |
| Отключить полное отключение | `gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0` |

---

## Часть 5. ВКЛЮЧЕНИЕ АВТОМАТИЧЕСКОГО ПОВОРОТА ЭКРАНА В ENDEAVOUROS

### 5.1. Проблема

На Ximper Linux автоповорот экрана работает сразу после установки драйверов. На EndeavourOS с окружением Budgie (на базе GNOME) автоповорот по умолчанию **не активен**, хотя драйверы из `minibook-support` установлены.

**Причина:** В EndeavourOS отсутствует или не активирован компонент, передающий данные с акселерометра в окружение рабочего стола.

### 5.2. Решение: iio-sensor-proxy

Автоповорот экрана в современных Linux-системах обеспечивает сервис **`iio-sensor-proxy`** . Он работает в паре с окружением рабочего стола (GNOME, KDE, Budgie) и предоставляет данным сенсоров единый интерфейс D-Bus .

### 5.3. Пошаговая инструкция

#### Шаг 1: Установка iio-sensor-proxy
```bash
sudo pacman -S iio-sensor-proxy
```

#### Шаг 2: Запуск и включение автозагрузки
```bash
# Запустить сервис сейчас
sudo systemctl start iio-sensor-proxy

# Добавить в автозагрузку
sudo systemctl enable iio-sensor-proxy
```

#### Шаг 3: Проверка статуса
```bash
systemctl status iio-sensor-proxy
```
Вы должны увидеть: `Active: active (running)`

#### Шаг 4: Проверка работы сенсоров
```bash
monitor-sensor
```
Эта команда показывает в реальном времени данные с акселерометра. Поверните ноутбук — вы должны увидеть изменение ориентации:
```
Waiting for iio-sensor-proxy to appear
Accelerometer orientation changed: normal
Accelerometer orientation changed: left-up
Accelerometer orientation changed: bottom-up
etc.
```
*Примечание:* `monitor-sensor` может не показывать данные, если Budgie уже "забрал" эксклюзивный доступ к сенсору. Это нормально.

#### Шаг 5: Проверка автоповорота
1. Перезагрузите систему: `reboot`
2. После входа в систему попробуйте повернуть ноутбук.
3. Экран должен автоматически поворачиваться.

### 5.4. Устранение возможных проблем

#### Проблема 1: Сервис не запускается или деактивируется
Если `systemctl status iio-sensor-proxy` показывает `inactive (dead)`:
```bash
# Проверьте логи
journalctl -u iio-sensor-proxy --no-pager

# Перезапустите сервис
sudo systemctl restart iio-sensor-proxy
```

#### Проблема 2: Ошибки "Not a switch" или "Invalid bitmask entry"
Некоторые сообщения в логах могут быть ложными и не влиять на работу . Если автоповорот работает, игнорируйте их.

#### Проблема 3: Автоповорот не работает после сна
Известная проблема: после выхода из сна iio-sensor-proxy может "потерять" сенсор . Временное решение — перезапуск сервиса:
```bash
sudo systemctl restart iio-sensor-proxy
```
Для автоматизации можно создать systemd-юнит или скрипт, но это выходит за рамки базовой настройки.

#### Проблема 4: В Budgie нет переключателя автоповорота
В GNOME и Budgie автоповорот включается автоматически при наличии работающего iio-sensor-proxy. Отдельного переключателя в интерфейсе может не быть. Если автоповорот не работает, проверьте:
1. Что вы используете **сессию Wayland** (автоповорот лучше работает на Wayland) 
2. При входе в систему выберите "Budgie on Wayland" (если доступно)

### 5.5. Проверка окружения (Xorg vs Wayland)
```bash
echo $XDG_SESSION_TYPE
```
* Если показывает `wayland` — отлично
* Если `x11` — попробуйте при следующем входе выбрать сессию Wayland

### 5.6. Альтернативы для других окружений

| Окружение | Поддержка автоповорота |
|-----------|------------------------|
| GNOME / Budgie | Встроенная, через iio-sensor-proxy |
| KDE Plasma | Встроенная, через iio-sensor-proxy  |
| XFCE | Требуется ручная настройка (скрипты + xrandr)  |

### 5.7. Итог

✅ **Установите iio-sensor-proxy**
✅ **Запустите и добавьте в автозагрузку**
✅ **Перезагрузитесь**










