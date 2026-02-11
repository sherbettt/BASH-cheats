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
