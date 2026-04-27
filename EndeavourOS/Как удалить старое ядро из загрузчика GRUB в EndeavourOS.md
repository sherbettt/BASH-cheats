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
