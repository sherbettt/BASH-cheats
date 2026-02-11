# Установка dysk на Debian 10 (LXC) — краткая инструкция

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

