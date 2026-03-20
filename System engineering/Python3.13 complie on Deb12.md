## План действий

Мы скомпилируем Python 3.13 и установим его в `/usr/local`, а затем через `update-alternatives` сделаем его доступным как `python3.13`, **не трогая** системный Python 3.11.

### Шаг 1: Установка зависимостей для компиляции

```bash
sudo apt update
sudo apt install -y \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libgdbm-dev \
    libc6-dev \
    libffi-dev \
    liblzma-dev \
    wget \
    curl
```

### Шаг 2: Скачиваем исходники Python 3.13

```bash
cd /tmp
wget https://www.python.org/ftp/python/3.13.3/Python-3.13.3.tar.xz
tar -xf Python-3.13.3.tar.xz
cd Python-3.13.3
```

### Шаг 3: Конфигурация с оптимизациями

Ключевой момент: используем `--prefix=/usr/local`, чтобы установка не затронула системные пути `/usr/bin`.

```bash
./configure \
    --prefix=/usr/local \
    --enable-optimizations \
    --enable-loadable-sqlite-extensions \
    --with-ensurepip=install \
    --enable-shared \
    LDFLAGS="-Wl,-rpath /usr/local/lib"
```

Параметры:
- `--enable-optimizations` — включает оптимизации (профилирование, PGO). Сборка будет дольше, но Python будет работать быстрее.
- `--enable-shared` — создает общую библиотеку `libpython3.13.so`, что нужно для некоторых модулей.
- `LDFLAGS="-Wl,-rpath /usr/local/lib"` — добавляет путь к библиотеке Python в поиск, чтобы он находил её без дополнительных настроек.

### Шаг 4: Компиляция

```bash
# Используем все ядра процессора для ускорения
make -j$(nproc)
```

Это займет 5-15 минут в зависимости от мощности вашего сервера/компьютера.

### Шаг 5: Установка (без замены системного Python!)

```bash
sudo make altinstall
```

**Критически важно:** используем `make altinstall`, а не `make install`. Это предотвращает перезапись файлов `python3` и `pip3`.

После установки у вас появятся:
- `/usr/local/bin/python3.13`
- `/usr/local/bin/pip3.13`
- `/usr/local/lib/libpython3.13.so.1.0`

### Шаг 6: Настройка update-alternatives (опционально)

`update-alternatives` обычно используется для управления версиями, когда у вас есть несколько вариантов **с одинаковыми именами** команд. Но у нас уже есть уникальное имя `python3.13`, так что это не обязательно. Однако если вы хотите, чтобы команда `python3.13` была доступна через эту систему, можно сделать так:

```bash
# Проверяем, что Python 3.13 действительно установлен
/usr/local/bin/python3.13 --version

# Добавляем в альтернативы (хотя это избыточно, так как имя уже уникально)
sudo update-alternatives --install /usr/local/bin/python python /usr/local/bin/python3.13 130
sudo update-alternatives --install /usr/local/bin/pip pip /usr/local/bin/pip3.13 130
```

Но **важно**: не добавляйте `python3` или `python` в альтернативы с высоким приоритетом, чтобы не сломать системные скрипты, которые ожидают Python 3.11.

### Шаг 7: Проверка и тестирование

```bash
# Проверяем, что это Python 3.13
/usr/local/bin/python3.13 --version

# Проверяем, что системный Python 3.11 остался нетронут
python3 --version
# Должно показать: Python 3.11.2

# Создаем виртуальное окружение с новым Python
cd ~
/usr/local/bin/python3.13 -m venv test_venv
source test_venv/bin/activate
python --version  # Должен показать 3.13
pip --version     # Должен показать pip из виртуального окружения
deactivate
```

### Шаг 8: Настройка PATH (если нужно)

Если вы хотите, чтобы `python3.13` был доступен без полного пути, добавьте в `~/.bashrc`:

```bash
echo 'export PATH=/usr/local/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

### 📋 Итоговая структура

После установки у вас будет:
- **Системный Python:** `/usr/bin/python3.11` (для нужд Debian)
- **Свежий Python 3.13:** `/usr/local/bin/python3.13` (для ваших проектов)

### 💡 Дополнительные советы

1. **Если при импорте модулей возникает ошибка `libpython3.13.so.1.0: cannot open shared object file`**:
   ```bash
   sudo ldconfig
   ```

2. **Для работы pip с приватными репозиториями** можно обновить pip вручную:
   ```bash
   /usr/local/bin/python3.13 -m pip install --upgrade pip
   ```

3. **Если вы используете системные пакеты Python (из apt) и хотите использовать их в виртуальном окружении с Python 3.13** — так делать нельзя, т.к. системные пакеты собраны для Python 3.11. Все зависимости для Python 3.13 нужно ставить через pip внутри виртуального окружения.






