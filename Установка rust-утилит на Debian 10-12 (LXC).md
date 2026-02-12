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

# Ошибка OOM killer

Если возникает следующая оишбка
```bash
   Compiling zellij-client v0.43.1
   Compiling zellij v0.43.1
error: could not compile `zellij` (bin "zellij")

Caused by:
  process didn't exit successfully: `rustc --crate-name zellij --edition=2021 /home/kkorablin/.cargo/registry/src/index.crates.io-1949cf8c6b5b557f/zellij-0.43.1/src/main.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=141 --crate-type bin --emit=dep-info,link -C opt-level=3 -C lto --cfg 'feature="default"' --cfg 'feature="plugins_from_target"' --cfg 'feature="vendored_curl"' --cfg 'feature="web_server_capability"' --check-cfg 'cfg(docsrs,test)' --check-cfg 'cfg(feature, values("default", "disable_automatic_asset_installation", "plugins_from_target", "singlepass", "unstable", "vendored_curl", "web_server_capability"))' -C metadata=b17e15a5ca6e8e2d -C extra-filename=-abe0ad9c56734921 --out-dir /tmp/cargo-installEmXcLE/release/deps -C strip=symbols -L dependency=/tmp/cargo-installEmXcLE/release/deps --extern anyhow=/tmp/cargo-installEmXcLE/release/deps/libanyhow-58c3bab3cbed0251.rlib --extern clap=/tmp/cargo-installEmXcLE/release/deps/libclap-41d3659850b8c44b.rlib --extern dialoguer=/tmp/cargo-installEmXcLE/release/deps/libdialoguer-bbcad3b9e95ea6cd.rlib --extern humantime=/tmp/cargo-installEmXcLE/release/deps/libhumantime-c9c4bb7e715d396e.rlib --extern interprocess=/tmp/cargo-installEmXcLE/release/deps/libinterprocess-a701251718b3110e.rlib --extern isahc=/tmp/cargo-installEmXcLE/release/deps/libisahc-15633944a016cb8a.rlib --extern log=/tmp/cargo-installEmXcLE/release/deps/liblog-3e5cd55873673320.rlib --extern miette=/tmp/cargo-installEmXcLE/release/deps/libmiette-81ca077d4b1f8033.rlib --extern names=/tmp/cargo-installEmXcLE/release/deps/libnames-960dfcdc02af3002.rlib --extern nix=/tmp/cargo-installEmXcLE/release/deps/libnix-ea6ea67f6063f4a3.rlib --extern suggest=/tmp/cargo-installEmXcLE/release/deps/libsuggest-bf3b07e1f1c0ec97.rlib --extern thiserror=/tmp/cargo-installEmXcLE/release/deps/libthiserror-4f8bd496d9e395cb.rlib --extern zellij_client=/tmp/cargo-installEmXcLE/release/deps/libzellij_client-58c29502b1fe04d2.rlib --extern zellij_server=/tmp/cargo-installEmXcLE/release/deps/libzellij_server-25ce25301776d4a2.rlib --extern zellij_utils=/tmp/cargo-installEmXcLE/release/deps/libzellij_utils-649501101e737416.rlib --cap-lints allow -L native=/tmp/cargo-installEmXcLE/release/build/curl-sys-b017a7ac169293fa/out/build -L native=/tmp/cargo-installEmXcLE/release/build/libnghttp2-sys-d556a3bd32556482/out/i/lib -L native=/tmp/cargo-installEmXcLE/release/build/openssl-sys-a979304015175d14/out/openssl-build/install/lib -L native=/tmp/cargo-installEmXcLE/release/build/aws-lc-sys-dc5e76cd148efe21/out -L native=/tmp/cargo-installEmXcLE/release/build/libsqlite3-sys-32b2759d1bcf1285/out -L native=/tmp/cargo-installEmXcLE/release/build/wasmtime-a88d1129e4af7b7a/out` (signal: 9, SIGKILL: kill)
error: failed to compile `zellij v0.43.1`, intermediate artifacts can be found at `/tmp/cargo-installEmXcLE`.
To reuse those artifacts with a future compilation, set the environment variable `CARGO_TARGET_DIR` to that path.
```

Попробуйте Уменьшить нагрузку на память
```bash
# Ограничить количество параллельных заданий
cargo install zellij --jobs 1

# Или с меньшим уровнем оптимизации
CARGO_PROFILE_RELEASE_OPT_LEVEL=0 cargo install zellij --jobs 1
```


