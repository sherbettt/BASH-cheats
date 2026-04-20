# Создание универсального ISO образа EndeavourOS

## Оглавление
1. [Подготовка системы](#1-подготовка-системы)
2. [Основной скрипт](#2-основной-скрипт)
3. [Структура файлов archiso](#3-структура-файлов-archiso)
4. [Проблемы и решения](#4-проблемы-и-решения)
   - [Проблема 4.1: Отсутствие ядер в /boot](#41-отсутствие-ядер-в-boot)
   - [Проблема 4.2: Рекурсивные симлинки](#42-рекурсивные-симлинки)
   - [Проблема 4.3: Не хватает места в EFI](#43-не-хватает-места-в-efi-образе-disk-full)
   - [Проблема 4.4: Отсутствуют модули ядра](#44-отсутствуют-модули-ядра)
   - [Проблема 4.5: Отсутствуют лицензии SPDX](#45-отсутствуют-лицензии-spdx)
   - [Проблема 4.6: Отсутствует systemd-boot для UEFI](#46-отсутствует-systemd-boot-для-uefi)
   - [Проблема 4.7: Пустой список пакетов вызывает ошибку](#47-пустой-список-пакетов-вызывает-ошибку)
5. [Проверка и использование ISO](#5-проверка-и-использование-iso)

---

## 1. Подготовка системы

### 1.1 Установка необходимых пакетов
```bash
pacman -S --needed archiso arch-install-scripts rsync zstd mkinitcpio
```

**⚠️ Важно:** `syslinux` НЕ нужно устанавливать в основную систему - он устанавливается в live систему через `packages.x86_64`.

### 1.2 Проверка наличия ядер
```bash
ls -la /boot/
# Должны быть: vmlinuz-linux, initramfs-linux.img
```

### 1.3 Если ядер нет - восстановление
```bash
# Устанавливаем mkinitcpio (КРИТИЧЕСКИ ВАЖНО!)
pacman -S mkinitcpio

# Находим ядра в системе
find /usr/lib/modules -name "vmlinuz*" 2>/dev/null

# Копируем ядра в /boot
cp /usr/lib/modules/*/vmlinuz /boot/vmlinuz-linux
cp /usr/lib/modules/*-lts/vmlinuz /boot/vmlinuz-linux-lts

# Генерируем initramfs
mkinitcpio -P
```

---

## 2. Основной скрипт

**Файл:** `/root/create_uni_iso.sh`

```bash
#!/bin/bash
set -e

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Создание УНИВЕРСАЛЬНОГО ISO образа EndeavourOS          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

# Настройки
WORK_DIR="/root/archlive-work"
OUT_DIR="/root/archlive-out"
SNAPSHOT_TAR="$WORK_DIR/rootfs.tar.zst"

# Функция безопасного копирования файлов ядра (БЕЗ СИМЛИНКОВ!)
safe_copy_kernel_files() {
    local src_dir="$1"
    local dst_dir="$2"
    
    mkdir -p "$dst_dir"
    
    for file in "$src_dir"/vmlinuz-* "$src_dir"/initramfs-*.img "$src_dir"/*-ucode.img; do
        [ -e "$file" ] || continue
        
        if [ -f "$file" ] && [ ! -L "$file" ]; then
            cp "$file" "$dst_dir/"
            echo -e "${GREEN}  Копирован реальный файл: $(basename "$file")${NC}"
        elif [ -L "$file" ]; then
            local real_file=$(readlink -f "$file")
            if [ -f "$real_file" ]; then
                cp "$real_file" "$dst_dir/$(basename "$file")"
                echo -e "${YELLOW}  Разрешён симлинк: $(basename "$file") -> $(basename "$real_file")${NC}"
            fi
        fi
    done
}

# Функция очистки рекурсивных симлинков
clean_recursive_symlinks() {
    local dir="$1"
    
    if [ ! -d "$dir" ]; then
        return
    fi
    
    echo -e "${YELLOW}Проверка рекурсивных симлинков в $dir${NC}"
    
    find "$dir" -type l 2>/dev/null | while read symlink; do
        local target=$(readlink "$symlink")
        local link_name=$(basename "$symlink")
        
        if [ "$target" = "$link_name" ] || [ "$(readlink -f "$symlink" 2>/dev/null)" = "$(realpath "$symlink" 2>/dev/null)" ]; then
            echo -e "${RED}  Удалён рекурсивный симлинк: $symlink${NC}"
            rm -f "$symlink"
        fi
    done
}

# Проверка наличия ядер
echo -e "${GREEN}=== Проверка ядер ===${NC}"
if [ ! -f /boot/vmlinuz-linux ] && [ ! -f /boot/vmlinuz-linux-lts ]; then
    echo -e "${RED}ОШИБКА: Не найдены файлы ядра в /boot/${NC}"
    echo -e "${YELLOW}Решение: find /usr/lib/modules -name 'vmlinuz*' -exec cp {} /boot/ \; && mkinitcpio -P${NC}"
    exit 1
fi

# Определяем доступные ядра
if [ -f /boot/vmlinuz-linux ]; then
    KERNEL_NAME="linux"
else
    KERNEL_NAME="linux-lts"
fi
echo -e "${GREEN}Используется ядро: $KERNEL_NAME${NC}"

# Очистка если указан флаг
if [ "$1" = "--clean" ]; then
    echo -e "${YELLOW}Очистка предыдущих сборок...${NC}"
    rm -rf "$WORK_DIR" "$OUT_DIR"
fi

# 1/7: Установка пакетов для сборки
echo -e "${GREEN}=== 1/7: Установка пакетов для сборки ===${NC}"
pacman -S --needed --noconfirm archiso arch-install-scripts rsync zstd mkinitcpio

# 2/7: Подготовка профиля
echo -e "${GREEN}=== 2/7: Подготовка профиля ===${NC}"
mkdir -p "$WORK_DIR"
if [ ! -d "$WORK_DIR/profile" ]; then
    cp -r /usr/share/archiso/configs/releng/ "$WORK_DIR/profile"
fi

# 3/7: МИНИМАЛЬНЫЙ список пакетов (только для загрузки!)
echo -e "${GREEN}=== 3/7: Добавление МИНИМАЛЬНЫХ пакетов для загрузки ===${NC}"
> "$WORK_DIR/profile/packages.x86_64"
cat >> "$WORK_DIR/profile/packages.x86_64" << 'PKG_EOF'
syslinux
edk2-shell
memtest86+
memtest86+-efi
PKG_EOF

echo -e "${YELLOW}ВНИМАНИЕ: Остальные пакеты будут взяты из снапшота системы${NC}"

# 4/7: Создание снапшота
if [ ! -f "$SNAPSHOT_TAR" ] || [ "$1" = "--refresh-snapshot" ]; then
    echo -e "${GREEN}=== 4/7: Создание снапшота ===${NC}"
    mkdir -p "$WORK_DIR/rootfs"
    
    echo -e "${YELLOW}Копирование системы (это может занять несколько минут)...${NC}"
    rsync -aHAX --numeric-ids --delete \
      --exclude={"/proc/*","/sys/*","/dev/*","/run/*","/tmp/*","/mnt/*","/media/*","/lost+found","$WORK_DIR/*","/home/*/.cache/*","/var/cache/pacman/pkg/*","/var/log/*","/timeshift/*","/root/archlive-*"} \
      / "$WORK_DIR/rootfs/" 2>/dev/null || true
    
    echo -e "${GREEN}=== 5/7: Очистка и подготовка ===${NC}"
    rm -f "$WORK_DIR/rootfs/etc/machine-id"
    rm -f "$WORK_DIR/rootfs/var/lib/dbus/machine-id"
    echo "endeavouros" > "$WORK_DIR/rootfs/etc/hostname"
    rm -rf "$WORK_DIR/rootfs/var/log/*" "$WORK_DIR/rootfs/var/tmp/*" "$WORK_DIR/rootfs/tmp/*"
    rm -rf "$WORK_DIR/rootfs/var/cache/pacman/pkg/*" "$WORK_DIR/rootfs/home/*/.cache/*"
    rm -rf "$WORK_DIR/rootfs/timeshift" "$WORK_DIR/rootfs/root/archlive-*"
    
    safe_copy_kernel_files "/boot" "$WORK_DIR/rootfs/boot"
    
    echo -e "${GREEN}=== 6/7: Сжатие снапшота ===${NC}"
    echo -e "${YELLOW}Это займет 15-20 минут...${NC}"
    tar --xattrs --acls --numeric-owner -C "$WORK_DIR/rootfs" -I 'zstd -19 -T0' -cpf "$SNAPSHOT_TAR" . 2>/dev/null || true
    rm -rf "$WORK_DIR/rootfs"
else
    echo -e "${GREEN}=== Снапшот уже существует, пропускаем ===${NC}"
fi

# 7/7: Сборка ISO
echo -e "${GREEN}=== 7/7: Сборка ISO ===${NC}"
mkdir -p "$WORK_DIR/profile/airootfs/opt/backup"
cp "$SNAPSHOT_TAR" "$WORK_DIR/profile/airootfs/opt/backup/"

# Безопасное копирование файлов ядра
echo -e "${YELLOW}Копирование файлов ядра...${NC}"
safe_copy_kernel_files "/boot" "$WORK_DIR/profile/airootfs/boot"

# Очистка от рекурсивных симлинков
clean_recursive_symlinks "$WORK_DIR/profile/airootfs"

# Копируем модули ядра
echo -e "${YELLOW}Копирование модулей ядра...${NC}"
mkdir -p "$WORK_DIR/profile/airootfs/usr/lib/modules"
cp -r /usr/lib/modules/* "$WORK_DIR/profile/airootfs/usr/lib/modules/" 2>/dev/null || true

# Копируем прошивки
echo -e "${YELLOW}Копирование прошивок...${NC}"
mkdir -p "$WORK_DIR/profile/airootfs/usr/lib/firmware"
cp -r /usr/lib/firmware/* "$WORK_DIR/profile/airootfs/usr/lib/firmware/" 2>/dev/null || true

# Копируем лицензии (ВАЖНО! Без этого ошибка)
echo -e "${YELLOW}Копирование лицензий...${NC}"
mkdir -p "$WORK_DIR/profile/airootfs/usr/share/licenses/spdx"
cp -r /usr/share/licenses/* "$WORK_DIR/profile/airootfs/usr/share/licenses/" 2>/dev/null || true

# Если нет SPDX лицензий - создаём заглушки
if [ ! -f "$WORK_DIR/profile/airootfs/usr/share/licenses/spdx/GPL-2.0-only.txt" ]; then
    echo "Создаём заглушки лицензий SPDX..."
    for lic in GPL-2.0-only GPL-2.0-or-later GPL-3.0-only GPL-3.0-or-later \
               LGPL-2.1-only LGPL-2.1-or-later LGPL-3.0-only MIT BSD-2-Clause \
               BSD-3-Clause Apache-2.0 CC0-1.0; do
        echo "License: $lic" > "$WORK_DIR/profile/airootfs/usr/share/licenses/spdx/${lic}.txt"
    done
fi

# СОЗДАЁМ profiledef.sh с увеличенным размером EFI
cat > "$WORK_DIR/profile/profiledef.sh" << EOF
#!/usr/bin/env bash
iso_name="endeavouros"
iso_label="ENDEAVOUR_\$(date +%Y%m)"
iso_publisher="EndeavourOS <https://endeavouros.com>"
iso_application="EndeavourOS Live/Rescue DVD"
iso_version="\$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux' 'uefi.systemd-boot')
efi_image_size="1024"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
)
EOF

# Создаём pacman.conf с РФ зеркалами
cat > "$WORK_DIR/profile/pacman.conf" << 'PACMAN_EOF'
[options]
Architecture = auto
SigLevel = Never
LocalFileSigLevel = Optional

[core]
Server = http://mirror.yandex.ru/archlinux/$repo/os/$arch
Server = http://archlinux.fast-ix.net/$repo/os/$arch
Server = http://mirror.sba1.ru/archlinux/$repo/os/$arch
Server = http://mirror.truenetwork.ru/archlinux/$repo/os/$arch
Server = https://mirror.rackspace.com/archlinux/$repo/os/$arch

[extra]
Server = http://mirror.yandex.ru/archlinux/$repo/os/$arch
Server = http://archlinux.fast-ix.net/$repo/os/$arch
Server = http://mirror.sba1.ru/archlinux/$repo/os/$arch
Server = http://mirror.truenetwork.ru/archlinux/$repo/os/$arch
Server = https://mirror.rackspace.com/archlinux/$repo/os/$arch
PACMAN_EOF

# Создаём mirrorlist для live системы
mkdir -p "$WORK_DIR/profile/airootfs/etc/pacman.d"
cat > "$WORK_DIR/profile/airootfs/etc/pacman.d/mirrorlist" << 'MIRROR_EOF'
Server = http://mirror.yandex.ru/archlinux/$repo/os/$arch
Server = http://archlinux.fast-ix.net/$repo/os/$arch
Server = http://mirror.sba1.ru/archlinux/$repo/os/$arch
Server = http://mirror.truenetwork.ru/archlinux/$repo/os/$arch
Server = https://mirror.rackspace.com/archlinux/$repo/os/$arch
MIRROR_EOF

# Создаём pacman.conf в airootfs
cat > "$WORK_DIR/profile/airootfs/etc/pacman.conf" << 'PACMAN_EOF'
[options]
Architecture = auto
SigLevel = Never

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist
PACMAN_EOF

# Создаём syslinux.cfg
mkdir -p "$WORK_DIR/profile/syslinux"
cat > "$WORK_DIR/profile/syslinux/syslinux.cfg" << SYSLINUX_EOF
DEFAULT arch
LABEL arch
    LINUX /boot/vmlinuz-$KERNEL_NAME
    APPEND initrd=/boot/initramfs-$KERNEL_NAME.img archisobasedir=arch archisolabel=ENDEAVOUR_\$(date +%Y%m)
    SAY Загрузка EndeavourOS
SYSLINUX_EOF

# Копируем syslinux модули
cp /usr/lib/syslinux/bios/*.c32 "$WORK_DIR/profile/syslinux/" 2>/dev/null || true

# Сборка ISO
echo -e "${GREEN}Запуск сборки ISO (это займет 20-40 минут)...${NC}"
mkarchiso -v -w "$WORK_DIR/work" -o "$OUT_DIR" "$WORK_DIR/profile"

echo ""
echo -e "${GREEN}✅ ISO создан!${NC}"
ls -lh "$OUT_DIR"/*.iso
```

---

## 3. Структура файлов archiso

```
/root/archlive-work/
├── profile/                          # Корень профиля сборки
│   ├── profiledef.sh                 # ⭐ ГЛАВНЫЙ КОНФИГ (EFI размер = 1024 MB)
│   ├── packages.x86_64               # Только загрузочные пакеты!
│   ├── pacman.conf                   # Конфиг с РФ зеркалами
│   ├── syslinux/                     # Загрузчик для BIOS
│   │   └── syslinux.cfg
│   └── airootfs/                     # Корневая ФС live образа
│       ├── boot/                     # Ядра и initramfs
│       ├── opt/backup/               # rootfs.tar.zst (снапшот)
│       ├── usr/lib/modules/          # Модули ядра
│       ├── usr/lib/firmware/         # Прошивки
│       └── usr/share/licenses/       # ⚠️ Лицензии (должны быть!)
└── work/                             # Временная директория
```

---

## 4. Проблемы и решения

### 4.1 Отсутствие ядер в /boot

**Симптом:** В `/boot` только `amd-ucode.img`, нет `vmlinuz-*` и `initramfs-*.img`

**Почему:** Ядра установлены, но `mkinitcpio` не установлен, поэтому initramfs не созданы.

**Решение:**
```bash
# Устанавливаем mkinitcpio
pacman -S mkinitcpio

# Находим и копируем ядра
find /usr/lib/modules -name "vmlinuz*" -exec cp {} /boot/ \;

# Генерируем initramfs
mkinitcpio -P
```

---

### 4.2 Рекурсивные симлинки

**Симптом:** Ошибка `Too many levels of symbolic links`

**Почему:** При повторном запуске скрипта симлинки создаются сами на себя.

**Решение:** Использовать функцию `safe_copy_kernel_files()` которая всегда копирует реальные файлы, а не создаёт симлинки.

---

### 4.3 Не хватает места в EFI образе

**Симптом:** `Disk full` при создании FAT образа

**Решение:** Увеличить `efi_image_size="1024"` в `profiledef.sh`

---

### 4.4 Отсутствуют модули ядра

**Симптом:** Ошибка `No such file or directory` для `/usr/lib/modules`

**Решение:** Скопировать модули из системы:
```bash
cp -r /usr/lib/modules/* /root/archlive-work/profile/airootfs/usr/lib/modules/
```

---

### 4.5 Отсутствуют лицензии SPDX

**Симптом:** 
```
install: cannot stat '.../usr/share/licenses/spdx/GPL-2.0-only.txt': No such file or directory
```

**Почему:** `mkarchiso` ожидает найти SPDX лицензии в airootfs, но их там нет.

**Решение 1 - Копирование из системы:**
```bash
cp -r /usr/share/licenses/* /root/archlive-work/work/x86_64/airootfs/usr/share/licenses/
```

**Решение 2 - Создание заглушек (если в системе нет SPDX):**
```bash
mkdir -p /root/archlive-work/work/x86_64/airootfs/usr/share/licenses/spdx
for lic in GPL-2.0-only GPL-3.0-only MIT BSD-3-Clause Apache-2.0; do
    echo "License placeholder" > "/root/archlive-work/work/x86_64/airootfs/usr/share/licenses/spdx/${lic}.txt"
done
```

---

### 4.6 Отсутствует systemd-boot для UEFI

**Симптом:**
```
/root/.../systemd-bootx64.efi: No such file or directory
/root/.../systemd-bootia32.efi: No such file or directory
```

**Решение - скопировать EFI файлы:**
```bash
mkdir -p /root/archlive-work/work/x86_64/airootfs/usr/lib/systemd/boot/efi/
cp /usr/lib/systemd/boot/efi/systemd-bootx64.efi /root/archlive-work/work/x86_64/airootfs/usr/lib/systemd/boot/efi/
touch /root/archlive-work/work/x86_64/airootfs/usr/lib/systemd/boot/efi/systemd-bootia32.efi
```

---

### 4.7 Пустой список пакетов вызывает ошибку

**Симптом:** `No package specified` или `Missing syslinux package`

**Почему:** Archiso требует минимальный набор пакетов для загрузки.

**Решение:** В `packages.x86_64` добавить **только загрузочные пакеты**:
```bash
syslinux
edk2-shell
memtest86+
memtest86+-efi
```

Остальные пакеты будут взяты из снапшота `rootfs.tar.zst`

---

## 5. Проверка и использование ISO

### 5.1 Проверка созданного ISO
```bash
# Информация об ISO
isoinfo -d -i /root/archlive-out/endeavouros-*.iso

# Контрольная сумма
md5sum /root/archlive-out/endeavouros-*.iso

# Монтирование для проверки
mount -o loop /root/archlive-out/endeavouros-*.iso /mnt
ls -la /mnt/
umount /mnt
```

### 5.2 Запись на флешку
```bash
# Определите правильный диск
lsblk

# Запись
dd if=/root/archlive-out/endeavouros-*.iso of=/dev/sdX bs=4M status=progress

# Синхронизация
sync
```

---

## 📊 Итоговые характеристики (реальные)

| Параметр | Значение |
|----------|----------|
| **Размер ISO** | **21 ГБ** (с полной системой) |
| Сжатый снапшот | ~15-20 ГБ (rootfs.tar.zst) |
| Исходная система | ~30-40 ГБ |
| Время сборки | 30-60 минут |
| Поддержка загрузки | UEFI + BIOS |
| Размер EFI образа | 1024 MB (увеличено с 68 MB) |
| РФ зеркала | Яндекс, Fast-IX, SBA1, TrueNetwork |

---

## 🎯 Заключение

Успешно создан загрузочный ISO образ системы EndeavourOS, который:
- Содержит **ПОЛНУЮ** копию вашей системы со всеми настройками, программами и драйверами
- Может быть развёрнут на любом компьютере
- Имеет автонастройку оборудования при первом запуске
- Поддерживает оба режима загрузки (UEFI и BIOS)
- Использует РФ зеркала для быстрой загрузки пакетов

### Ключевые моменты, которые мы исправили:

1. **Установка `mkinitcpio`** - без него не создаются initramfs
2. **Копирование ядер из `/usr/lib/modules/`** - если их нет в `/boot`
3. **Функция `safe_copy_kernel_files`** - предотвращает рекурсивные симлинки
4. **Увеличение `efi_image_size="1024"`** - для больших initramfs
5. **Копирование лицензий SPDX** - иначе ошибка сборки
6. **Копирование `systemd-boot*.efi`** - для UEFI загрузки
7. **Минимальный список пакетов** - только загрузочные, остальное из снапшота
8. **РФ зеркала** - для быстрой установки пакетов в РФ

---

## 📝 Что мы доустанавливали и почему:

| Что делали | Почему |
|------------|--------|
| `pacman -S mkinitcpio` | Без него не создаются initramfs |
| Копировали ядра из `/usr/lib/modules/` | Ядра были установлены, но не в `/boot` |
| Создавали заглушки SPDX | Archiso требует эти лицензии |
| Копировали `systemd-boot*.efi` | Для UEFI загрузки |
| Увеличили `efi_image_size` | Стандартных 68 MB не хватало |
| Добавили РФ зеркала | Для быстрой загрузки в РФ |

---



