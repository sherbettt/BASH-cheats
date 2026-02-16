Отлично, структура у вас хорошая. Я добавлю новые утилиты для мониторинга CPU и памяти, распределив их по существующим разделам и создав новый раздел для мониторинга. Вот обновленная версия статьи:

---

# Установка dysk на Debian 10 (LXC)

## 1. Скачать готовый бинарник
```bash
curl -LO https://github.com/Canop/dysk/releases/download/v3.6.0b/dysk_3.6.0.zip
#или
wget https://github.com/Canop/dysk/releases/download/v3.6.0b/dysk_3.6.0.zip
unzip dysk_3.6.0.zip
```

## 2. Установить в систему
```bash
sudo cp build/x86_64-unknown-linux-musl/dysk /usr/local/bin/
sudo chmod +x /usr/local/bin/dysk
```

## 3. Опционально: man и автодополнение
```bash
# man-страница
sudo mkdir -p /usr/local/share/man/man1
sudo cp build/man/dysk.1 /usr/local/share/man/man1/

# автодополнение для bash
sudo cp build/completion/dysk.bash /etc/bash_completion.d/
source /etc/bash_completion.d/dysk.bash
```

## 4. Проверка
```bash
dysk --version
dysk
```

**Примечание**: Не требуется обновление Rust/cargo — используем готовую статическую сборку `x86_64-unknown-linux-musl`, работает на любой системе Linux.

<br/>

----------------------------

# Установка Rust-утилит для дисков на Debian (LXC)

## 1. Базовое обновление Rust (рекомендуется)
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
rustup install stable
rustup default stable
```
```bash
#см.
https://crates.io/
```

**Важно: Добавьте ~/.cargo/bin в PATH:**
```bash
# Для bash
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Для zsh
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Для устранения надоедливого "correct" в zsh (для procs)
echo 'alias procs="nocorrect procs"' >> ~/.zshrc
```

## 2. Установка утилит

**Вариант А — через cargo (после обновления Rust):**
```bash
# dysk — df с цветами и графикой
cargo install dysk

# dust — дерево размеров папок
cargo install du-dust

# dua — интерактивный анализ с навигацией
cargo install dua-cli

# diskus — быстрый подсчет размера папки
cargo install diskus
```

**Вариант Б — готовые бинарники (без обновления Rust):**
```bash
# dysk
wget https://github.com/Canop/dysk/releases/download/v3.6.0b/dysk_3.6.0.zip
unzip dysk_3.6.0.zip
sudo cp build/x86_64-unknown-linux-musl/dysk /usr/local/bin/

# dust
wget https://github.com/bootandy/dust/releases/download/v1.1.1/dust-v1.1.1-x86_64-unknown-linux-musl.tar.gz
tar -xzf dust-v1.1.1-x86_64-unknown-linux-musl.tar.gz
sudo cp dust-v1.1.1-x86_64-unknown-linux-musl/dust /usr/local/bin/

# dua-cli
wget https://github.com/Byron/dua-cli/releases/download/v2.30.0/dua-v2.30.0-x86_64-unknown-linux-musl.tar.gz
tar -xzf dua-v2.30.0-x86_64-unknown-linux-musl.tar.gz
sudo cp dua /usr/local/bin/

# diskus
wget https://github.com/sharkdp/diskus/releases/download/v0.7.0/diskus-v0.7.0-x86_64-unknown-linux-musl.tar.gz
tar -xzf diskus-v0.7.0-x86_64-unknown-linux-musl.tar.gz
sudo cp diskus /usr/local/bin/

# gdu (Go-утилита, готовый бинарник)
wget https://github.com/dundee/gdu/releases/download/v5.30.0/gdu_linux_amd64_static.tgz
tar -xzf gdu_linux_amd64_static.tgz
sudo cp gdu_linux_amd64_static /usr/local/bin/gdu
```

## 3. Проверка
```bash
dysk --version
dust --version
dua --version
diskus --version
gdu --version
```

## 4. Базовое использование
```bash
dysk -a                    # информация о всех дисках
dust                       # дерево размеров в текущей папке
dua i                      # интерактивный режим
diskus                     # общий размер текущей папки
gdu /путь                  # TUI-анализатор (как ncdu)
```

Все утилиты используют статическую сборку (`musl`) и работают на любой системе Linux без зависимостей.

-----------------------
<br/>

# Полезные Rust-утилиты (кроме дисковых)

## 🖥️ **Система/Процессы**
```bash
# procs — аналог ps, цветной и понятный
cargo install procs

# bottom — графический монитор процессов (TUI)
cargo install bottom

# zellij — терминальный мультиплексор (аналог tmux)
cargo install zellij

# bandwhich — кто жрет сеть (TUI)
cargo install bandwhich
```

### 📊 **Мониторинг CPU и памяти (подробнее)**

В отличие от базовых утилит выше, эти инструменты специализируются именно на мониторинге ресурсов:

| Утилита | Описание | Установка | Использование |
|---------|----------|-----------|---------------|
| **bottom** (`btm`) | Самый популярный TUI-монитор с графиками CPU, RAM, сети, температуры. Всё настраивается. | `cargo install bottom`<br>или бинарник:<br>`wget https://github.com/ClementTsang/bottom/releases/download/0.10.2/bottom_x86_64-unknown-linux-musl.tar.gz` | `btm` — запуск<br>`?` — справка по клавишам<br>`m` — переключить графики<br>`Ctrl+c` — выход |
| **procs** | Современная замена `ps`. Удобный поиск, дерево процессов, цветной вывод. | `cargo install procs`<br>или бинарник:<br>`wget https://github.com/dalance/procs/releases/download/v0.14.10/procs-v0.14.10-x86_64-unknown-linux-musl.zip` | `procs` — все процессы<br>`procs nginx` — поиск по имени<br>`procs --tree` — дерево процессов<br>`procs --watch` — обновление каждые 2с |
| **stomata-cli** | Поиск "пожирателей" памяти. Позволяет "провалиться" в процесс для деталей. | `cargo install stomata-cli` | `stomata -i` — интерактивный режим<br>`stomata -p 1234` — анализ конкретного PID |
| **procmon** | Простой монитор с информацией о CPU, памяти, потоках и приоритете. | `cargo install procmon` | `procmon` — запуск<br>`procmon --pid 1234` — только PID |
| **ytop** | TUI-монитор с графиками в стиле "top". | `cargo install ytop`<br>или бинарник:<br>`wget https://github.com/cjbassi/ytop/releases/download/0.7.3/ytop-0.7.3-x86_64-unknown-linux-musl.tar.gz` | `ytop` — запуск<br>стрелки — навигация |
| **Resources** | GUI-приложение на GTK4. Показывает графики CPU, RAM, GPU, сети, дисков. | `flatpak install flathub net.nokyan.Resources` | Запуск из меню приложений |

## 📁 **Файлы/Навигация**
```bash
# fd — аналог find, но быстрее и красивее
cargo install fd-find

# bat — аналог cat с подсветкой синтаксиса
cargo install bat

# eza — аналог ls (замена exa)
cargo install eza

# ripgrep — аналог grep, очень быстрый
cargo install ripgrep

# broot — навигация по дереву папок (TUI)
cargo install broot
```

### 📁 **Базовое использование файловых утилит**
```bash
fd .git                    # найти все папки .git
fd -e rs main              # найти файлы .rs с "main" в имени
bat file.rs                # показать файл с подсветкой
bat -A file.txt            # показать невидимые символы
eza -la --tree             # дерево файлов с деталями
rg "TODO:" ./src           # поиск текста в файлах
rg -i "error" --type rust  # регистронезависимый поиск в .rs
broot                      # запустить навигатор
```

## 🚀 **Производительность/Дебаг**
```bash
# hyperfine — бенчмаркинг команд
cargo install hyperfine

# flamegraph — профайлинг
cargo install flamegraph

# hexyl — hex-просмотрщик
cargo install hexyl

# grex — генератор regex из примеров
cargo install grex
```

### 🚀 **Примеры использования**
```bash
hyperfine 'ls -la'                     # замер времени выполнения
hyperfine --runs 10 'sleep 1'          # 10 замеров
hexyl file.bin                         # просмотр в hex
grex "1.2.3.4" "10.0.0.1"              # сгенерировать regex для IP
```

## 📦 **Работа с данными**
```bash
# jql — jq на Rust (JSON процессор)
cargo install jql

# xsv — работа с CSV
cargo install xsv

# qsv — быстрый CSV toolkit (форк xsv)
cargo install qsv

# hck — сокращенный cut
cargo install hck
```

### 📦 **Примеры работы с данными**
```bash
jql '.field' file.json                  # извлечь поле из JSON
xsv table file.csv                       # табличный вывод CSV
xsv slice -s 10 -e 20 file.csv           # строки 10-20
hck -f 1,3 file.txt                       # поля 1 и 3
```

## 🌐 **Сеть/HTTP**
```bash
# httpie — HTTP клиент (аналог curl)
cargo install httpie

# websocat — websocket клиент
cargo install websocat

# dog — DNS клиент
cargo install dog

# mprober — мониторинг сети/системы
cargo install mprober
```

### 🌐 **Примеры сетевых запросов**
```bash
http example.org                          # GET запрос
http POST example.org name="test"         # POST с данными
dog example.org A                          # DNS запрос типа A
websocat ws://echo.websocket.org           # подключение к WebSocket
```

## 🎨 **Терминал/UI**
```bash
# starship — кастомный промпт
cargo install starship

# lolcrab — аналог lolcat (цветной вывод)
cargo install lolcrab

# pastel — работа с цветами
cargo install pastel

# termsize — размер терминала
cargo install termsize
```

### 🎨 **Настройка и использование**
```bash
# starship (добавить в ~/.zshrc или ~/.bashrc)
echo 'eval "$(starship init bash)"' >> ~/.bashrc
# или для zsh
echo 'eval "$(starship init zsh)"' >> ~/.zshrc

pastel color blue                          # показать цвет
pastel mix blue red                         # смешать цвета
termsize                                    # показать размер терминала
```

## 🔧 **Инструменты разработки**
```bash
# cargo-edit — управление Cargo.toml
cargo install cargo-edit

# cargo-watch — автопересборка при изменениях
cargo install cargo-watch

# cargo-audit — проверка уязвимостей
cargo install cargo-audit

# cargo-outdated — устаревшие зависимости
cargo install cargo-outdated

# bacon — фоновый линтер/компилятор
cargo install bacon
```

### 🔧 **Использование в проектах**
```bash
cargo add regex                             # добавить зависимость
cargo watch -x run                           # авто-запуск при изменениях
cargo audit                                   # проверка уязвимостей
cargo outdated                                # показать устаревшие крейты
bacon                                          # фоновый линтер
```

## 📝 **Текст/Заметки**
```bash
# mdbook — генерация книг из Markdown
cargo install mdbook

# navi — шпаргалки в терминале
cargo install navi

# tealdeer — быстрый tldr (help-примеры)
cargo install tealdeer
```

### 📝 **Быстрые справки**
```bash
tldr tar                                    # примеры использования tar
tldr --update                                # обновить кэш
navi                                          # поиск шпаргалок
mdbook init mybook                            # создать книгу
mdbook build                                   # собрать книгу
```

## 🎮 **Git и разработка**
```bash
# gitui — TUI для Git
cargo install gitui

# onefetch — инфо о репозитории
cargo install onefetch

# pipes-rs — заставка pipes
cargo install pipes-rs

# cbonsai — бонсай в терминале
cargo install cbonsai
```

### 🎮 **Развлечения и git**
```bash
gitui                                          # Git в терминале
onefetch                                        # статистика репозитория
pipes-rs                                         # заставка "трубы"
cbonsai                                           # растущий бонсай
```

## 📦 **Установка готовых бинарников (без Rust)**
Все эти утилиты также доступны на GitHub Releases. Ищите файлы с `x86_64-unknown-linux-musl` — это статические сборки, работающие на любой системе Linux:

```bash
# Общий шаблон для загрузки
wget https://github.com/AUTHOR/REPO/releases/download/TAG/FILE

# Пример для procs
wget https://github.com/dalance/procs/releases/download/v0.14.10/procs-v0.14.10-x86_64-unknown-linux-musl.zip
```

**Где искать:**
- https://github.com/search?q=starship
- https://github.com/search?q=fd
- https://github.com/search?q=ripgrep
- или просто "название-утилиты releases" в поиске

---------------------------------
<br/>

# Ошибка OOM killer

Если возникает следующая ошибка:
```bash
   Compiling zellij-client v0.43.1
   Compiling zellij v0.43.1
error: could not compile `zellij` (bin "zellij")

Caused by:
  process didn't exit successfully: `rustc ...` (signal: 9, SIGKILL: kill)
error: failed to compile `zellij v0.43.1`
```

Это **SIGKILL (signal 9)** — компилятор убит системой OOM Killer из-за нехватки памяти.

### Решение 1: Уменьшить нагрузку на память
```bash
# Ограничить количество параллельных заданий
cargo install zellij --jobs 1

# Или с меньшим уровнем оптимизации
CARGO_PROFILE_RELEASE_OPT_LEVEL=0 cargo install zellij --jobs 1
```

### Решение 2: Увеличить swap (временно)
```bash
# Создать swap-файл 2GB
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Установка
cargo install zellij

# После установки можно отключить
sudo swapoff /swapfile
sudo rm /swapfile
```

### Решение 3: Готовый бинарник (рекомендуется при нехватке памяти)
```bash
# Скачать предкомпилированный бинарник
wget https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz
tar -xzf zellij-x86_64-unknown-linux-musl.tar.gz
sudo cp zellij /usr/local/bin/
```

### Решение 4: Через системный пакет (для Arch/Manjaro)
```bash
sudo pacman -S zellij
```

---------------------------------
<br/>

# Полезные ссылки

- **crates.io** — репозиторий Rust-пакетов: https://crates.io
- **GitHub Releases** — готовые бинарники: ищите `название-проекта releases`
- **Документация утилит** — обычно в репозитории на GitHub есть README с примерами
