# Установка драйверов для Chuwi MiniBook X в Ximper Linux

## 1. Исходная ситуация

**Устройство:** Chuwi MiniBook X (ноутбук-трансформер с сенсорным экраном 8.8", 1200x1920)
**ОС:** Ximper Linux 0.9.3 (на базе ALT Linux / Sisyphus)
**Ядро:** 6.12.63

**Какое оборудование требовало драйверов:**
- Сенсорный экран (тачскрин)
- Тачпад
- Датчик Холла (определение сложенного состояния — планшетный режим)
- Подсветка клавиатуры
- Автоповорот экрана

## 2. Где нашли драйверы

**Источник:** GitHub-репозиторий сообщества
```
https://github.com/petitstrawberry/minibook-support.git
```

**Почему именно он:**
- Специализирован под Chuwi MiniBook X
- Содержит готовые демоны (сервисы) для всей специфической периферии
- Поддерживает современные ядра (6.x)
- Используется владельцами этого устройства на разных дистрибутивах

## 3. Что внутри репозитория

Репозиторий содержит три отдельных сервиса (демона):

| Компонент | Назначение |
|-----------|------------|
| **`trackpadd`** | Драйвер/демон для тачпада и калибровки сенсорного экрана |
| **`keyboardd`** | Управление подсветкой клавиатуры |
| **`tabletmoded`** | Обработка датчика Холла (переключение в режим планшета) |

## 4. Процесс компиляции и установки

### Установка необходимых инструментов:
```bash
apt-get install git gcc make
```
*Git — чтобы скачать исходники, gcc — компилятор, make — система сборки.*

### Клонирование репозитория:
```bash
mkdir -p projects/git
cd projects/git
git clone https://github.com/petitstrawberry/minibook-support.git
cd minibook-support
```
*Скачиваем исходный код с GitHub.*

### Компиляция:
```bash
make
```
*Компилятор gcc собирает исполняемые файлы из исходников. Предупреждения (warnings) в процессе — нормально, на работу не влияют.*

**Что происходит при компиляции:**
1. Сначала компилируется общая библиотека `libcommon.a` (общий код для всех демонов)
2. Затем компилируются сами демоны: `trackpadd`, `keyboardd`, `tabletmoded`
3. Создаются исполняемые файлы в папках `trackpadd/bin/`, `keyboardd/bin/`, `tabletmoded/bin/`

### Установка:
```bash
make install
```
**Что делает установка:**
- Копирует скомпилированные бинарники в `/usr/bin/`
- Копирует systemd-юниты (файлы служб) в `/etc/systemd/system/`
- Автоматически запускает и добавляет в автозагрузку все три сервиса

## 5. Итог: какие драйверы получили

| Устройство | Драйвер/Решение | Статус |
|------------|-----------------|--------|
| Сенсорный экран | `trackpadd` | ✅ Работает |
| Тачпад | `trackpadd` | ✅ Работает |
| Датчик Холла (планшетный режим) | `tabletmoded` | ✅ Работает |
| Подсветка клавиатуры | `keyboardd` | ✅ Работает |
| Калибровка цветов | `gnome-color-manager` (из репозитория) | ✅ Установлен |

## 6. Проверка работы

```bash
systemctl status trackpadd keyboardd tabletmoded
```
Показывает, что все три сервиса активны (`active (running)`). Акселерометр работает после перезагрузки. Хочу отметить, что положение экрана ландшафтное, не портретное, даже без драйверов на Ximper Linux сразу.

--------------------------------------------
<br/>
<br/>



# Установка драйверов для Chuwi MiniBook X в Endevour OS Linux

Выполнить нужно все предыдущие действия. На Endevour акселерометр автоматически не работает, пока не нашёл как задать ему работу автоматически, приходится руками производитб вращеие экрана. При подклчюении внешнего монитор, расположение снова экрана снова правильное по умолчанию - ландшафтное. Не знаю почему. 

 Однако, есть странные баги с переключением языка, его попросту нет после установки, даже если в момент уставноки задаёшь язык и переключение языка по Caps.

## Настройка переключения раскладки клавиатуры (Caps Lock или Alt+Shift) в EndeavourOS (Budgie)

### Введение
В окружении Budgie (которое основано на технологиях GNOME) за переключение раскладки отвечают два уровня:
*   **Системный уровень** (для экрана входа в систему).
*   **Пользовательский уровень** (для вашей рабочей сессии после входа).

### Шаг 1. Определяем, что сейчас используется

Прежде чем менять, полезно понять текущую ситуацию. Это поможет избежать конфликтов.

1.  **Откройте терминал.**
2.  **Проверьте системные настройки X11 (классический сервер):**
    ```bash
    localectl status
    ```
    Найдите строчку `X11 Layout` и `X11 Options`. Это то, что система пытается применить на уровне Xorg .

3.  **Проверьте настройки экрана входа (Greeter):**
    ```bash
    cat /etc/default/keyboard
    ```
    Этот файл часто используется дисплейным менеджером (GDM, LightDM) для экрана входа .

4.  **Проверьте настройки пользовательской сессии (Budgie/GNOME):**
    ```bash
    gsettings get org.gnome.desktop.input-sources sources
    gsettings get org.gnome.desktop.wm.keybindings switch-input-source
    ```
    Это самые важные команды. Они показывают, что *на самом деле* использует ваше окружение рабочего стола .

5.  **Проверьте, срабатывает ли вообще комбинация:**
    ```bash
    xev
    ```
    Эта команда откроет тестовое окно. Нажмите нужную комбинацию (Alt+Shift или Caps Lock) и посмотрите вывод в терминале. Если вы видите `ISO_Next_Group`, значит, клавиши переключения распознаются системой правильно . Для выхода нажмите `Ctrl+C`.


### Шаг 2. Очищаем старые настройки (чтобы не было конфликтов)

Чтобы новый способ работал без сбоев, приведём все настройки к единому виду.

1.  **Сбросьте настройки пользовательской сессии:**
    ```bash
    gsettings reset org.gnome.desktop.input-sources sources
    gsettings reset org.gnome.desktop.wm.keybindings switch-input-source
    gsettings reset org.gnome.desktop.wm.keybindings switch-input-source-backward
    ```

2.  **Убедитесь, что системные настройки не конфликтуют** (мы перенастроим их позже). Пока можно оставить как есть.



### Шаг 3. Настройка переключения по клавише Caps Lock

Этот способ удобен тем, что клавиша всегда под рукой. **Важно:** при такой настройке клавиша Caps Lock перестанет включать "режим заглавных букв". Если вам нужен Caps Lock для этой цели, используйте Alt+Shift.

#### 3.1. Настройка системы (для экрана входа)
Выполните команду в терминале:
```bash
sudo localectl --no-convert set-x11-keymap us,ru pc105 "" grp:caps_toggle
```

#### 3.2. Проверка и правка конфигурационного файла
Откройте файл `/etc/default/keyboard`:
```bash
sudo mcedit /etc/default/keyboard
```
Приведите его к такому виду:
```
# KEYBOARD CONFIGURATION FILE
XKBMODEL="pc105"
XKBLAYOUT="us,ru"
XKBVARIANT=""
XKBOPTIONS="grp:caps_toggle"
BACKSPACE="guess"
```
Сохраните файл (`F2`, `F10`).

#### 3.3. Настройка пользовательской сессии (Budgie)
Теперь нужно сказать Budgie/GNOME, как переключать раскладку.
```bash
# Устанавливаем раскладки: английская (первая), русская (вторая)
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ru')]"

# Устанавливаем переключение по Caps Lock (специальный код 'Caps_Lock')
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['Caps_Lock']"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Shift>Caps_Lock']"
```
**Пояснение:** Первая команда (`switch-input-source`) переключает на следующий язык (с EN на RU). Вторая (`switch-input-source-backward`) переключает на предыдущий (с RU на EN) по `Shift+Caps Lock` — это полезно, если вы случайно переключились не туда.


### Шаг 4. Настройка переключения по комбинации Alt+Shift

Это классический способ, привычный многим пользователям.

#### 4.1. Настройка системы (для экрана входа)
```bash
sudo localectl --no-convert set-x11-keymap us,ru pc105 "" grp:alt_shift_toggle
```

#### 4.2. Проверка и правка конфигурационного файла
Откройте файл `/etc/default/keyboard`:
```bash
sudo mcedit /etc/default/keyboard
```
Приведите его к виду:
```
# KEYBOARD CONFIGURATION FILE
XKBMODEL="pc105"
XKBLAYOUT="us,ru"
XKBVARIANT=""
XKBOPTIONS="grp:alt_shift_toggle"
BACKSPACE="guess"
```
Сохраните и выйдите.

#### 4.3. Настройка пользовательской сессии (Budgie)
```bash
# Устанавливаем раскладки
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ru')]"

# Устанавливаем переключение по Alt+Shift
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Alt>Shift_L', '<Shift>Alt_L']"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Alt>Shift_R', '<Shift>Alt_R']"
```



### Шаг 5. Применение изменений и перезагрузка

После того как вы выбрали один из способов (или настроили оба поочерёдно, но лучше выбрать один), необходимо перезагрузить систему, чтобы изменения применились на всех уровнях:

```bash
reboot
```

---

### Шаг 6. Проверка результата

После перезагрузки:
1.  **Посмотрите на экран входа:** Попробуйте нажать настроенную комбинацию (Caps Lock или Alt+Shift). Поле ввода пароля должно реагировать сменой языка (обычно появляется индикатор EN/RU).
2.  **Войдите в систему.**
3.  **Посмотрите на панель Budgie:** В правом верхнем углу должен быть индикатор раскладки.
4.  **Откройте текстовый редактор** и проверьте переключение.

### Что делать, если не работает?

*   **Конфликт комбинаций.** Убедитесь, что вы не используете Caps Lock одновременно как переключение языка и как модификатор в каких-то программах.
*   **Xorg vs Wayland.** Хотя Budgie по умолчанию может использовать Xorg, выполните в терминале `echo $XDG_SESSION_TYPE`. Если показывает `wayland`, попробуйте при входе в систему (на экране шестерёнки) выбрать сессию "Budgie on Xorg".
*   **Забыли про `gsettings`.** Самая частая ошибка — настроить только системные файлы и забыть про `gsettings`. Именно `gsettings` управляет поведением в рабочей сессии .
*   **Сброс после обновления.** Иногда обновления могут сбросить настройки `gsettings`. Просто выполните команды из **Шага 3.3** или **4.3** повторно.

--------------------------------------------
<br/>



# **ПОЛНАЯ ИНСТРУКЦИЯ: УПРАВЛЕНИЕ ЭНЕРГОСБЕРЕЖЕНИЕМ ЭКРАНА**
## **EndeavourOS / Budgie (настройки через терминал)**

---

## **ЧАСТЬ 1. ТЕОРИЯ: ДВЕ РАЗНЫЕ ФУНКЦИИ**

В системе работают **два независимых механизма**, которые мы путали:

| Функция | Команда | Что делает | По умолчанию |
|--------|---------|------------|--------------|
| **Полное отключение** | `sleep-inactive-ac-timeout` | Экран **полностью гаснет** (черный экран) | `3600` (1 час) |
| **Действие** | `sleep-inactive-ac-type` | Что делать: `suspend` (сон) или `nothing` | `'suspend'` |
| **Частичное затемнение** | `idle-dim` | Экран **становится тусклее** (dimming) | `true` (включено) |
| **Уровень затемнения** | `idle-brightness` | На сколько % темнеет (30 = яркость 30%) | `30` |

**Важно:** Это разные настройки! Можно отключить полное отключение, но оставить затемнение — тогда экран будет тускнеть, но не гаснуть.

---

## **ЧАСТЬ 2. ДИАГНОСТИКА: УЗНАТЬ ТЕКУЩИЕ НАСТРОЙКИ**

Выполните эти команды, чтобы понять, что сейчас включено:

```bash
# 1. Время до ПОЛНОГО отключения экрана (в секундах)
gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout

# 2. Действие при ПОЛНОМ отключении (suspend = сон, nothing = ничего)
gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type

# 3. Включено ли ЧАСТИЧНОЕ затемнение (true = да, false = нет)
gsettings get org.gnome.settings-daemon.plugins.power idle-dim

# 4. Уровень ЧАСТИЧНОГО затемнения (30 = яркость 30%)
gsettings get org.gnome.settings-daemon.plugins.power idle-brightness
```

---

## **ЧАСТЬ 3. ЧТО МЫ СДЕЛАЛИ (ПОДРОБНО)**

### **Шаг 1. Узнали время до полного отключения**
```bash
gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout
```
**Результат:** `3600` (1 час) — экран гас полностью через час бездействия.

### **Шаг 2. Узнали, что система делает при бездействии**
```bash
gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type
```
**Результат:** `'suspend'` — система пыталась уйти в сон.

### **Шаг 3. Отключили полное отключение экрана**
```bash
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
```
**Зачем:** `0` = "никогда не гасить экран полностью".

### **Шаг 4. Отключили уход в сон**
```bash
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
```
**Зачем:** Чтобы система не пыталась усыпить компьютер.

### **Шаг 5. Проверили затемнение (НОВОЕ)**
Мы не трогали `idle-dim`, поэтому скорее всего оно осталось `true` (включено).

---

## **ЧАСТЬ 4. ВАРИАНТЫ НАСТРОЕК (ВЫБИРАЙТЕ СВОЙ)**

### **ВАРИАНТ A: Только для просмотра видео (полный комфорт)**
*Экран всегда яркий, никогда не гаснет, не темнеет*

```bash
# Отключить ПОЛНОЕ отключение экрана
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

# Отключить ЧАСТИЧНОЕ затемнение
gsettings set org.gnome.settings-daemon.plugins.power idle-dim false
```

### **ВАРИАНТ B: Экран тускнеет, но не гаснет**
*Экран становится тусклым (экономия энергии), но не выключается*

```bash
# Отключить ПОЛНОЕ отключение
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

# ЧАСТИЧНОЕ затемнение оставить включенным (true)
gsettings set org.gnome.settings-daemon.plugins.power idle-dim true

# Настроить уровень затемнения (50 = яркость 50%)
gsettings set org.gnome.settings-daemon.plugins.power idle-brightness 50
```
*Число можно менять: 30 (темно), 50 (средне), 80 (чуть темнее), 100 (без изменений)*

### **ВАРИАНТ C: Энергосбережение (как было, но мягче)**
*Компьютер засыпает, но позже и с менее резким затемнением*

```bash
# Увеличить время до ПОЛНОГО отключения (2 часа = 7200 сек)
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 7200

# Оставить действие "сон"
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'suspend'

# Сделать затемнение менее резким
gsettings set org.gnome.settings-daemon.plugins.power idle-dim true
gsettings set org.gnome.settings-daemon.plugins.power idle-brightness 60
```

### **ВАРИАНТ D: Экономия батареи (для работы от аккумулятора)**
*Команды для режима "от батареи" (замените `-ac` на `-battery`)*

```bash
# Пример для батареи: таймаут 10 минут (600 сек)
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 600
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'suspend'
```

---

## **ЧАСТЬ 5. КАК ВЕРНУТЬ ВСЁ ОБРАТНО (ПОЛНЫЙ СБРОС)**

### **Если хотите вернуть заводские настройки EndeavourOS:**

```bash
# 1. Вернуть ПОЛНОЕ отключение (1 час)
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 3600

# 2. Вернуть действие "сон"
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'suspend'

# 3. Вернуть ЧАСТИЧНОЕ затемнение (включено)
gsettings set org.gnome.settings-daemon.plugins.power idle-dim true

# 4. Вернуть уровень затемнения (30%)
gsettings set org.gnome.settings-daemon.plugins.power idle-brightness 30
```

### **Проверка после возврата:**
```bash
gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout
gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type
gsettings get org.gnome.settings-daemon.plugins.power idle-dim
gsettings get org.gnome.settings-daemon.plugins.power idle-brightness
```
**Должны увидеть:** `3600`, `'suspend'`, `true`, `30`

---

## **ЧАСТЬ 6. ЕСЛИ НУЖЕН ПОЛНЫЙ СБРОС ВСЕХ НАСТРОЕК ПИТАНИЯ**

```bash
# Сбросить ВСЕ настройки питания к значениям по умолчанию
gsettings reset org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout
gsettings reset org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type
gsettings reset org.gnome.settings-daemon.plugins.power idle-dim
gsettings reset org.gnome.settings-daemon.plugins.power idle-brightness
```

---

## **ЧАСТЬ 7. ТРЕБУЕТСЯ увеличить продолжительность работы экрана**
```bash
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 2400
gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0 #никогда не выключать
```


| Команда | Что делает | Пример значения |
|--------|------------|-----------------|
| `sleep-inactive-ac-timeout` | Время до полного отключения (сек) | `0` = никогда, `3600` = 1 час |
| `sleep-inactive-ac-type` | Действие при отключении | `'suspend'` = сон, `'nothing'` = ничего |
| `idle-dim` | Включить затемнение | `true` = да, `false` = нет |
| `idle-brightness` | Яркость после затемнения (%) | `30` = 30%, `80` = 80% |

---

## **ИТОГ: ЧТО МЫ СДЕЛАЛИ И КАК ЖИТЬ ДАЛЬШЕ**

✅ **Мы сделали:** Отключили полное отключение экрана и уход в сон  
✅ **Не трогали:** Частичное затемнение (оно может быть включено)  
✅ **Теперь вы знаете:** Как управлять обеими функциями отдельно

**Рекомендация:** Если при просмотре видео экран всё еще темнеет (частично), выполните:
```bash
gsettings set org.gnome.settings-daemon.plugins.power idle-dim false
```




