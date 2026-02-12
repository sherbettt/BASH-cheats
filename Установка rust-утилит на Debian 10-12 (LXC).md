# Установка dysk на Debian 10 (LXC)

## 1. Скачать готовый бинарник
```bash
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

Важно: Добавьте ~/.cargo/bin в PATH:
```bash
# Для bash
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Для zsh
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
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

## 📝 **Текст/Заметки**
```bash
# mdbook — генерация книг из Markdown
cargo install mdbook

# navi — шпаргалки в терминале
cargo install navi

# tealdeer — быстрый tldr (help-примеры)
cargo install tealdeer
```

## 🎮 **Игры/Развлечения**
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

## 📦 **Установка готовых бинарников (без Rust)**
Все эти утилиты также доступны на GitHub Releases:
- https://github.com/search?q=starship
- https://github.com/search?q=fd
- https://github.com/search?q=ripgrep
- и т.д. — ищем `название-утилиты releases`

---------------------------------
<br/>


