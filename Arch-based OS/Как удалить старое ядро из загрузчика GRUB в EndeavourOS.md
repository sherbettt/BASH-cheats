# Как удалить старое ядро из загрузчика GRUB в Arch Linux / EndeavourOS
## 📋 **Описание проблемы**

После удаления старого ядра Linux (например, `linux-lts`) из системы, его записи часто остаются в меню загрузчика GRUB. Это происходит потому, что конфигурация GRUB не обновляется автоматически при удалении пакетов ядра.

**Симптомы:**
- В меню GRUB отображаются несколько вариантов загрузки
- Присутствуют записи с удалёнными версиями ядра (например, `6.18.24-lts`)
- Система загружается нормально, но меню захламлено

**Версии ПО в данной статье:**
- ОС: EndeavourOS (Arch Linux)
- Ядро: 6.19.14-arch1-1
- Загрузчик: GRUB 2.14
- Тип системы: UEFI

---

## 🔍 **Шаг 1: Диагностика текущего состояния**

### 1.1 Проверка активного ядра
```bash
uname -a
```
Вывод покажет текущее загруженное ядро:
```
Linux gpd4 6.19.14-arch1-1 #1 SMP PREEMPT_DYNAMIC Thu, 23 Apr 2026 06:57:02 +0000 x86_64 GNU/Linux
```

### 1.2 Список установленных ядер
```bash
ls /boot/vmlinuz-*
```
или
```bash
pacman -Q | grep linux
```

### 1.3 Локализация EFI-раздела
```bash
mount | grep -i efi
```
Вывод покажет, куда смонтирован EFI-раздел (в нашем случае `/efi`):
```
efivarfs on /sys/firmware/efi/efivars type efivarfs (rw,...)
/dev/nvme0n1p1 on /efi type vfat (rw,relatime,...)
```

### 1.4 Проверка структуры диска
```bash
lsblk
```

---

## 🗂️ **Шаг 2: Понимание структуры загрузчика (UEFI)**

### Важное различие:
- **BIOS/Legacy**: GRUB находится в `/boot/grub`
- **UEFI**: GRUB находится на EFI-разделе (обычно `/efi` или `/boot/efi`)

**В нашем случае:**
- EFI-раздел смонтирован: `/efi`
- Директория GRUB: `/efi/EFI/endeavouros`
- Конфигурационный файл: `/efi/EFI/endeavouros/grub.cfg`

### Почему `/boot/grub/grub.cfg` не использовался?
Хотя команда `grub-mkconfig` по умолчанию создаёт файл в `/boot/grub/grub.cfg`, при загрузке UEFI систем GRUB читает конфигурацию именно с EFI-раздела.

---

## ⚙️ **Шаг 3: Удаление старого ядра из системы**

### 3.1 Удаление пакета LTS-ядра
```bash
sudo pacman -Rs linux-lts
```

### 3.2 Удаление файлов ядра (если остались)
```bash
sudo rm /boot/vmlinuz-linux-lts
sudo rm /boot/initramfs-linux-lts.img
```

### 3.3 Проверка, что старых файлов нет
```bash
ls /boot/vmlinuz-*
ls /boot/initramfs-*.img
```

**Ожидаемый результат:**
```
/boot/vmlinuz-linux
/boot/initramfs-linux.img
```

---

## 🔧 **Шаг 4: Переустановка GRUB с правильными параметрами**

### 4.1 Создание директории GRUB (если отсутствует)
```bash
sudo mkdir -p /boot/grub
```

### 4.2 Переустановка GRUB на EFI-раздел
```bash
sudo grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=endeavouros
```
**Параметры:**
- `--target=x86_64-efi` : архитектура и тип загрузчика
- `--efi-directory=/efi` : путь к EFI-разделу
- `--bootloader-id=endeavouros` : идентификатор загрузчика

**Вывод при успехе:**
```
Установка завершена. Ошибок нет.
```

### 4.3 Генерация новой конфигурации
```bash
sudo grub-mkconfig -o /efi/EFI/endeavouros/grub.cfg
```

**Ожидаемый вывод:**
```
Генерируется файл настройки grub …
Найден образ linux: /boot/vmlinuz-linux
Найден образ initrd: /boot/amd-ucode.img /boot/initramfs-linux.img
Добавляется элемент загрузочного меню для настроек микропрограммы UEFI …
завершено
```

---

## ✅ **Шаг 5: Проверка результата**

### 5.1 Просмотр нового конфигурационного файла
```bash
sudo cat /efi/EFI/endeavouros/grub.cfg | grep -i "lts\|6.18"
```
Если команда не вывела ничего — старых записей больше нет.

### 5.2 Альтернативная проверка
```bash
sudo grep -E "menuentry.*linux" /efi/EFI/endeavouros/grub.cfg
```

**Ожидаемый вывод:** только записи с текущим ядром `6.19.14`

---

## 🔄 **Шаг 6: Перезагрузка и финальная проверка**

```bash
sudo reboot
```

После перезагрузки в меню GRUB должны остаться только:
- `EndeavourOS (6.19.14-arch1-1)`
- `EndeavourOS (fallback)` (опционально)
- `UEFI Firmware Settings`

---

## 📚 **Полезные команды для будущего**

### Быстрое обновление конфигурации GRUB после обновления ядра:
```bash
sudo grub-mkconfig -o /efi/EFI/endeavouros/grub.cfg
```

### Просмотр всех установленных ядер:
```bash
pacman -Q | grep "^linux"
```

### Установка LTS-ядра как запасного:
```bash
sudo pacman -S linux-lts linux-lts-headers
sudo grub-mkconfig -o /efi/EFI/endeavouros/grub.cfg
```

### Просмотр записей в EFI:
```bash
sudo efibootmgr -v
```

---

## ⚠️ **Типичные ошибки и их решение**

### Ошибка 1: `grub-mkconfig: /boot/grub/grub.cfg.new: Нет такого файла`
**Причина:** отсутствует директория `/boot/grub`  
**Решение:** `sudo mkdir -p /boot/grub`

### Ошибка 2: `grub-install: /boot не похоже на раздел EFI`
**Причина:** неправильно указан путь к EFI-разделу  
**Решение:** найти правильный путь через `mount | grep efi`

### Ошибка 3: `Отказано в доступе` при чтении файлов GRUB
**Причина:** недостаточно прав  
**Решение:** использовать `sudo`

---

## 💡 **Дополнительные советы**

### Создание алиаса для быстрого обновления
Добавьте в `~/.bashrc` или `~/.zshrc`:
```bash
alias grub-update='sudo grub-mkconfig -o /efi/EFI/endeavouros/grub.cfg'
```

### Автоматическое обновление с помощью хука pacman
Создайте файл `/etc/pacman.d/hooks/grub-update.hook`:
```ini
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = linux
Target = linux-lts
Target = linux-zen

[Action]
Description = Обновление конфигурации GRUB
When = PostTransaction
Exec = /usr/bin/grub-mkconfig -o /efi/EFI/endeavouros/grub.cfg
```

---

## 📖 **Заключение**

Проблема с "битыми" записями в GRUB возникает из-за того, что конфигурация загрузчика не обновляется автоматически при удалении ядер. В UEFI-системах важно помнить, что реальный конфигурационный файл находится на EFI-разделе (обычно `/efi/EFI/*/grub.cfg`), а не в `/boot/grub/`.

**Ключевые выводы:**
1. Всегда проверяйте точку монтирования EFI-раздела
2. Используйте правильный путь при генерации конфигурации
3. После удаления ядра всегда обновляйте GRUB
4. Храните эту инструкцию для будущих случаев 🚀

---

## 🔄 **Дополнение: Реальный кейс - переключение с GRUB на systemd-boot в EndeavourOS**

### Контекст ситуации
В процессе работы над системой EndeavourOS выяснилось, что стандартным загрузчиком в новых установках является **systemd-boot**, а не GRUB. Это важное уточнение, так как многие инструкции для Arch Linux по умолчанию предполагают использование GRUB.

### Диагностика: как определить, какой загрузчик используется

```bash
# Проверка наличия GRUB
which grub-mkconfig
# Если команда не найдена - GRUB не установлен

# Проверка systemd-boot
bootctl status
# Если команда выполняется и показывает информацию - используется systemd-boot

# Проверка типа системы
ls /sys/firmware/efi/efivars/
# Если папка существует - UEFI система
```

### Реальный случай: работа с systemd-boot

В нашем практическом примере система использовала **systemd-boot**, а не GRUB. Вот как решалась задача переключения на LTS-ядро:

#### Шаг 1: Проверка установленных ядер
```bash
pacman -Q | grep linux
```
Вывод показал, что оба ядра уже установлены:
```
linux 7.0.8.arch1-1      # актуальное ядро
linux-lts 6.18.31-1      # LTS ядро (уже установлено)
```

#### Шаг 2: Понимание структуры systemd-boot

В systemd-boot конфигурация хранится по другому пути:
```bash
# Просмотр конфигурации загрузчика
sudo cat /efi/loader/loader.conf

# Просмотр доступных записей загрузки
sudo ls /efi/loader/entries/
```

**Структура systemd-boot:**
- Конфиг загрузчика: `/efi/loader/loader.conf`
- Записи загрузки: `/efi/loader/entries/*.conf`
- Формат имени записи: `{UUID}-{версия}-{тип}.conf`

#### Шаг 3: Поиск LTS-записи

```bash
# Поиск всех конфигов
sudo find /efi -name "*.conf" 2>/dev/null

# Найденные файлы:
# /efi/loader/entries/01490b765a9e45a3a5ec0f2d9ca95a7c-7.0.8-arch1-1.conf
# /efi/loader/entries/01490b765a9e45a3a5ec0f2d9ca95a7c-6.18.31-1-lts.conf
```

#### Шаг 4: Изменение загрузки по умолчанию

**Исходный конфиг:**
```bash
sudo cat /efi/loader/loader.conf
```
```
default 01490b765a9e45a3a5ec0f2d9ca95a7c*
timeout 5
console-mode auto
reboot-for-bitlocker 1
```
*Звёздочка `*` означает "последняя загруженная запись"*

**Изменение на LTS:**
```bash
sudo nano /efi/loader/loader.conf
```
Изменили строку `default` на:
```
default 01490b765a9e45a3a5ec0f2d9ca95a7c-6.18.31-1-lts.conf
```

#### Шаг 5: Применение изменений

```bash
# Обновление конфигурации загрузчика
sudo bootctl update

# Перезагрузка
sudo reboot
```

#### Шаг 6: Проверка результата

```bash
uname -r
```
Вывод:
```
6.18.31-1-lts
```

### Важные различия между GRUB и systemd-boot

| Характеристика | GRUB | systemd-boot |
|----------------|------|--------------|
| **Сложность** | Высокая | Простой и минималистичный |
| **Конфигурация** | `/boot/grub/grub.cfg` или `/efi/EFI/*/grub.cfg` | `/efi/loader/loader.conf` |
| **Записи загрузки** | Встроены в grub.cfg | Отдельные файлы в `/efi/loader/entries/` |
| **Автообнаружение ядер** | Требует ручного обновления | Автоматически обнаруживает ядра в /boot |
| **Настройка по умолчанию** | Через GRUB_DEFAULT в /etc/default/grub | Через default в loader.conf |
| **Поддержка LTS** | `GRUB_SAVEDEFAULT=true` | `default @saved` или конкретная запись |

### Особые случаи в systemd-boot

#### Символическая запись `@saved`
Вместо указания конкретного файла можно использовать:
```
default @saved
```
Это позволяет системе запоминать последний выбранный пункт меню.

#### Горячие клавиши в меню загрузки
- `d` - установить выбранный пункт как загрузку по умолчанию
- `t` - изменить таймаут
- `-` / `+` - изменить таймаут (уменьшить/увеличить)

### Альтернативный метод: ручное создание записи

Если LTS-запись отсутствует, её можно создать вручную:

```bash
sudo nano /efi/loader/entries/arch-lts.conf
```
Содержимое:
```
title   Arch Linux (LTS)
linux   /vmlinuz-linux-lts
initrd  /amd-ucode.img
initrd  /initramfs-linux-lts.img
options root=PARTUUID=$(findmnt -no PARTUUID /) rw
```

### Удаление старого ядра при использовании systemd-boot

Для systemd-boot процесс отличается от GRUB:

```bash
# 1. Удаление пакета ядра
sudo pacman -Rns linux

# 2. systemd-boot автоматически удалит записи при следующем обновлении
sudo bootctl update

# 3. Ручное удаление записей (если нужно)
sudo rm /efi/loader/entries/*-7.0.8-arch1-1.conf
```

### Распространённая ошибка при использовании GRUB-инструкций

Многие пользователи EndeavourOS пытаются выполнить:
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```
И получают ошибку `grub-mkconfig: команда не найдена`, потому что:
1. В системе не установлен GRUB
2. Используется systemd-boot по умолчанию

**Правильное решение:** определить текущий загрузчик через `bootctl status` и использовать соответствующие команды.

### Практические выводы из реального кейса

1. **Всегда проверяйте, какой загрузчик используется:**
   - `bootctl status` для systemd-boot
   - `grub-mkconfig --version` для GRUB

2. **Пути конфигурации различаются:**
   - GRUB (UEFI): `/efi/EFI/endeavouros/grub.cfg`
   - systemd-boot: `/efi/loader/loader.conf`

3. **Управление загрузкой по умолчанию:**
   - В GRUB: редактируем `/etc/default/grub` + `grub-mkconfig`
   - В systemd-boot: редактируем `/efi/loader/loader.conf` + `bootctl update`

4. **Удаление старых ядер:**
   - В GRUB: требуется ручное обновление конфигурации
   - В systemd-boot: достаточно удалить пакет, система очистит записи автоматически

5. **Простота systemd-boot:**
   - Меньше настроек
   - Автоматическое обнаружение ядер
   - Быстрее загружается
   - Меньше шансов "сломать загрузчик"

### Заключение по практическому кейсу



**Ключевой урок:** для EndeavourOS (особенно свежих установок) всегда сначала проверяйте загрузчик командой `bootctl status`. Возможно, вы используете systemd-boot, и тогда стандартные инструкции для GRUB будут не только бесполезны, но и могут ввести в заблуждение. 🚀
