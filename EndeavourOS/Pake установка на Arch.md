# Инструкция по установке и использованию Pake на EndeavourOS (Arch Linux)

## 📖 Введение

**Pake** — это утилита для превращения любого веб-сайта в отдельное десктоп-приложение. В отличие от Electron, Pake использует Rust и Tauri, что делает приложения лёгкими (обычно ~5 МБ) и быстрыми.

***См. https://github.com/tw93/Pake***

---

## 📦 Часть 1: Установка необходимых компонентов

### 1.1 Установка pnpm (менеджер пакетов Node.js)

**Ошибка:** При попытке установить Pake через `pnpm install -g pake-cli` получал `pnpm: command not found`

**Решение:** Устанавливаем pnpm через системный пакетный менеджер:

```bash
sudo pacman -S pnpm
```

Настройка глобальной директории для pnpm:

```bash
pnpm setup
source ~/.bashrc  # или source ~/.zshrc
```

**Результат:**

```bash
$ pnpm --version
10.26.2
```

### 1.2 Установка Rust (компилятор)

Pake требует Rust для сборки приложений:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
```

**Проверка:**

```bash
$ rustc --version
rustc 1.85.0 (дата...)
```

### 1.3 Установка системных зависимостей

Tauri (фреймворк Pake) требует следующие библиотеки:

```bash
sudo pacman -S base-devel webkit2gtk-4.1 gtk3 libayatana-appindicator pkg-config gst-plugins-base gst-plugins-good gst-libav
```

**Важно:** Без `webkit2gtk-4.1` приложение будет компилироваться, но окно с веб-страницей открываться не будет.

---

## 📥 Часть 2: Скачивание исходников Pake

### 2.1 Скачивание через wget

```bash
cd ~/Applications
wget https://github.com/tw93/Pake/archive/refs/tags/V3.11.0.tar.gz
```

**Результат:**

```
V3.11.0.tar.gz  14 MB [сохранён]
```

### 2.2 Распаковка

```bash
tar -xzf V3.11.0.tar.gz
cd Pake-3.11.0
```

### 2.3 Установка зависимостей проекта

```bash
pnpm install
```

**Что происходит:** pnpm скачивает все Node.js зависимости (223 пакета). Процесс может занять 20-30 секунд.

```
Packages: +223
Done in 22.6s using pnpm v10.26.2
```

---

## 🔨 Часть 3: Сборка Pake

### 3.1 Первая попытка сборки

```bash
pnpm run build
```

**Процесс сборки:**

1. Компиляция Rust кода (~2 минуты 46 секунд)
2. Создание бинарника в `src-tauri/target/release/pake`
3. Попытка собрать .deb и .AppImage пакеты

**Проблема:** Сборка зависла на этапе:

```
Downloading https://github.com/tauri-apps/binary-releases/releases/download/apprun-old/AppRun-x86_64
```

**Причина:** Файл скачивается с GitHub, но скорость крайне низкая (или соединение обрывается).

**Решение:** Прервать сборку (`Ctrl+C`) — бинарник уже готов! Упаковка в .deb/.AppImage необязательна.

### 3.2 Проверка собранного бинарника

```bash
$ ls -la src-tauri/target/release/pake
-rwxr-xr-x 1 kkorablin kkorablin 14M мая 8 10:42 pake

$ file src-tauri/target/release/pake
ELF 64-bit LSB pie executable, x86-64, dynamically linked, stripped
```

---

## 🚀 Часть 4: Запуск и проблемы

### 4.1 Первый запуск

```bash
./src-tauri/target/release/pake https://github.com --name GitHub
```

**Результат:** Ничего не происходит, терминал зависает.

### 4.2 Проблема: окно не открывается

После добавления `--debug` вижу только предупреждения:

```
(pake:98123): libayatana-appindicator-WARNING: libayatana-appindicator is deprecated
```

Но окно так и не появляется.

**Поиск причины:**

```bash
ldd src-tauri/target/release/pake | grep "not found"
# (пусто — все библиотеки на месте)
```

**Решение:** Нужно указать переменные окружения для GTK и WebKit:

```bash
export GDK_BACKEND=x11
export WEBKIT_DISABLE_COMPOSITING_MODE=1
./src-tauri/target/release/pake https://github.com --name GitHub
```

**Результат:** Окно открылось! 🎉

### 4.3 Проблема: игнорирование URL

**Симптом:** При запуске `./pake https://yandex.ru` всё равно открывается `https://weekly.tw93.fun` (сайт разработчика).

**Причина:** В собранном бинарнике URL по умолчанию зашит в конфигурации и аргументы командной строки игнорируются.

**Решение 1 (костыль):** Меняем URL в конфиге вручную

```bash
nano src-tauri/pake.json
```

Находим строку:
```json
"url": "https://weekly.tw93.fun/en",
```

Меняем на нужный URL:
```json
"url": "https://github.com/sherbettt/BASH-cheats/tree/main",
```

Пересобираем:

```bash
cargo build --release --manifest-path src-tauri/Cargo.toml
```

**Теперь запуск без аргументов открывает мою страницу!**

**Решение 2 (скрипт-обёртка):** Для запуска разных сайтов без пересборки

```bash
cat > ~/bin/pake-go << 'EOF'
#!/bin/bash
if [ -z "$1" ]; then
    echo "Использование: pake-go <URL> [название]"
    exit 1
fi

URL="$1"
NAME="${2:-App}"
CONFIG="$HOME/Applications/Pake-3.11.0/src-tauri/pake.json"
ORIGINAL_URL=$(grep -o '"url": "[^"]*"' "$CONFIG" | head -1 | cut -d'"' -f4)

sed -i 's|"url": "[^"]*"|"url": "'"$URL"'"|' "$CONFIG"
"$HOME/Applications/Pake-3.11.0/src-tauri/target/release/pake" --name "$NAME"
sed -i 's|"url": "[^"]*"|"url": "'"$ORIGINAL_URL"'"|' "$CONFIG"
EOF

chmod +x ~/bin/pake-go
```

**Использование:**

```bash
pake-go "https://yandex.ru" "Яндекс"
pake-go "https://github.com/sherbettt/BASH-cheats/tree/main" "BASH"
```

---

## 📦 Часть 5: Перенос на другой компьютер

### 5.1 Условия для переноса

| Параметр | Требование |
|----------|------------|
| ОС | Та же (EndeavourOS/Arch) |
| Архитектура | x86_64 |
| Библиотеки | webkit2gtk-4.1, gtk3 |

### 5.2 Что переносить

**Достаточно одного файла:**
```
~/Applications/Pake-3.11.0/src-tauri/target/release/pake
```

**Не нужно переносить:**
- Исходники
- `pake.json`
- Node.js зависимости

### 5.3 На втором компьютере

```bash
# 1. Скопировать бинарник
scp user@first-pc:~/Applications/Pake-3.11.0/src-tauri/target/release/pake ~/pake

# 2. Дать права
chmod +x ~/pake

# 3. Установить зависимости (если нет)
sudo pacman -S webkit2gtk-4.1 gtk3

# 4. Запустить
export GDK_BACKEND=x11
./pake
```

### 5.4 Для Debian/Ubuntu

Бинарник, собранный на Arch, **не будет работать** на Debian. Нужно пересобрать:

```bash
# На Debian 13
curl -fsSL https://get.pnpm.io/install.sh | sh
sudo apt install libwebkit2gtk-4.0-dev build-essential libssl-dev libgtk-3-dev
pnpm install -g pake-cli
pake https://github.com/sherbettt/BASH-cheats/tree/main --name BASH-cheats
```

---

## 📋 Часть 6: Итоговые команды

### Быстрый старт (с нуля)

```bash
# 1. Установка зависимостей
sudo pacman -S pnpm base-devel webkit2gtk-4.1 gtk3 libayatana-appindicator
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env

# 2. Скачивание и сборка
cd ~/Applications
wget https://github.com/tw93/Pake/archive/refs/tags/V3.11.0.tar.gz
tar -xzf V3.11.0.tar.gz
cd Pake-3.11.0
pnpm install
cargo build --release --manifest-path src-tauri/Cargo.toml

# 3. Запуск
export GDK_BACKEND=x11
./src-tauri/target/release/pake https://github.com --name GitHub
```

### Скрипт для запуска любых сайтов

```bash
cat > ~/bin/pake << 'EOF'
#!/bin/bash
export GDK_BACKEND=x11
export WEBKIT_DISABLE_COMPOSITING_MODE=1
~/Applications/Pake-3.11.0/src-tauri/target/release/pake "$@"
EOF
chmod +x ~/bin/pake
```

Использование:
```bash
pake https://google.com --name Google
```

---

## ⚠️ Часть 7: Типичные ошибки и их решения

### Ошибка 1: `pnpm: command not found`
```bash
sudo pacman -S pnpm
pnpm setup
source ~/.bashrc
```

### Ошибка 2: Сборка зависает на AppRun-x86_64
**Решение:** Прервать (`Ctrl+C`) — бинарник уже готов.

### Ошибка 3: Окно не открывается (только предупреждения)
```bash
export GDK_BACKEND=x11
export WEBKIT_DISABLE_COMPOSITING_MODE=1
```

### Ошибка 4: `libwebkit2gtk-4.1.so.0: cannot open shared object file`
```bash
sudo pacman -S webkit2gtk-4.1
```

### Ошибка 5: Бинарник игнорирует URL
**Решение:** Исправить URL в `src-tauri/pake.json` и пересобрать ИЛИ использовать скрипт-обёртку.

---

## 📌 Заключение

**Что мы получили в итоге:**

1. ✅ Полностью рабочий бинарник Pake (14 МБ)
2. ✅ Возможность запускать любые сайты как отдельные приложения
3. ✅ Способ переносить приложение на другой компьютер с EndeavourOS
4. ✅ Скрипт для удобного запуска разных сайтов

**Сколько времени заняло:**
- Установка зависимостей: ~5 минут
- Сборка Rust-кода: ~3 минуты
- Отладка проблем: ~30 минут

**Ресурсы:**
- [Официальный репозиторий Pake](https://github.com/tw93/Pake)
- [Документация Tauri](https://tauri.app/)

---



