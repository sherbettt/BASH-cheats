# Полное руководство по сборке и настройке FPTN из исходников на Arch Linux (EndeavourOS)

## Содержание
1. [Введение](#введение)
2. [Подготовка системы](#подготовка-системы)
3. [Сборка проекта (успешный сценарий)](#сборка-проекта-успешный-сценарий)
4. [Проблемы и их решения](#проблемы-и-их-решения)
5. [Установка в систему](#установка-в-систему)
6. [Настройка и запуск CLI-клиента](#настройка-и-запуск-cli-клиента)
7. [Результаты работы](#результаты-работы)

---

## Введение

В этом руководстве описана полная процедура сборки проекта **FPTN** (Fast Private Tunnel Network) версии 0.3.40 из исходных кодов на системе **EndeavourOS** (Arch Linux).

**Особенности проекта:**
- Язык: **C++20**
- Система сборки: **CMake**
- Управление зависимостями: **Conan**
- Требования: **Boost.Asio** с поддержкой корутин

**Исходный код:** https://github.com/fptn-project/fptn/releases/tag/0.3.40

**Цель:** Получение работоспособного VPN-клиента с возможностью подключения через токен от Telegram-бота.

---

## Часть 1: Подготовка системы

### 1.1 Установка базовых инструментов

Перед началом сборки необходимо установить базовый набор инструментов разработчика.

```bash
# Установка всех базовых инструментов сборки
sudo pacman -S base-devel

# Установка CMake и компилятора GCC
sudo pacman -S cmake gcc

# Установка Python и pipx для Conan
sudo pacman -S python-pipx
```

**Что установили:**
- `base-devel` - метапакет, включающий make, gcc, autoconf, automake и другие инструменты
- `cmake` - система управления сборкой (версия 4.3.1+)
- `gcc` - компилятор C++ (нужен для C++20)
- `python-pipx` - изолированный установщик Python-приложений

### 1.2 Установка системных зависимостей

Проект требует несколько системных библиотек, которые не управляются через Conan.

```bash
# Установка необходимых системных библиотек
sudo pacman -S boost openssl libidn2 libunistring
```

**Назначение каждой библиотеки:**
| Библиотека | Назначение |
|------------|------------|
| `boost` | Асинхронное программирование, корутины, ASIO |
| `openssl` | Криптография, TLS/SSL |
| `libidn2` | Интернациональные доменные имена (IDNA) |
| `libunistring` | Работа с Unicode строками (зависимость libidn2) |

### 1.3 Установка Conan

Conan — менеджер пакетов для C++, который автоматически загрузит и соберет все зависимости проекта.

```bash
# Установка Conan через pipx
pipx install conan

# Добавление Conan в PATH (если не добавилось автоматически)
export PATH="$HOME/.local/bin:$PATH"

# Проверка установки
conan --version
```

**Ожидаемый вывод:** `Conan version 2.x.x`

### 1.4 Создание профиля Conan

Профиль определяет настройки компилятора, архитектуру и другие параметры сборки.

```bash
# Создание профиля по умолчанию
conan profile detect

# Просмотр созданного профиля
conan profile show default
```

**Пример вывода профиля:**
```
[settings]
arch=x86_64
build_type=Release
compiler=gcc
compiler.cppstd=gnu17
compiler.libcxx=libstdc++11
compiler.version=15
os=Linux
```

---

## Часть 2: Сборка проекта (успешный сценарий)

### 2.1 Распаковка исходников

```bash
# Переход в директорию с проектом
cd ~/Programs/FPTN/fptn-0.3.40

# Просмотр структуры проекта
ls -la
```

**Структура содержит:**
- `CMakeLists.txt` - главный файл сборки
- `conanfile.py` - файл зависимостей для Conan
- `src/` - исходные коды
- `tests/` - тесты
- `deploy/` - скрипты для создания пакетов

### 2.2 Установка зависимостей через Conan

**Важно:** Для сборки CLI-версии (без GUI) используем `with_gui_client=False`.

```bash
# Установка зависимостей (только CLI, без GUI)
conan install . --output-folder=build --build=missing \
  -o with_gui_client=False --settings build_type=Release
```

**Параметры команды:**
| Параметр | Значение | Назначение |
|----------|----------|------------|
| `.` | текущая директория | Путь к conanfile.py |
| `--output-folder=build` | папка build | Куда генерировать файлы |
| `--build=missing` | - | Собирать отсутствующие пакеты |
| `-o with_gui_client=False` | отключить GUI | Собираем только CLI |
| `--settings build_type=Release` | Release | Оптимизированная сборка |

**Что делает Conan:**
1. Анализирует зависимости из `conanfile.py`
2. Загружает пакеты из репозиториев (conancenter)
3. Собирает пакеты, которых нет в кэше
4. Генерирует `conan_toolchain.cmake` в корне проекта
5. Генерирует `CMakePresets.json` для удобной конфигурации

**Успешный вывод должен заканчиваться:**
```
Install finished successfully
conanfile.py (fptn/0.0.0): Generating aggregated env files
```

### 2.3 Конфигурация CMake

Для конфигурации используем preset, сгенерированный Conan.

```bash
# Конфигурация через preset (рекомендуемый способ)
cmake --preset conan-release
```

**Что делает эта команда:**
- Автоматически подключает `conan_toolchain.cmake`
- Устанавливает тип сборки `Release`
- Находит все зависимости (spdlog, fmt, protobuf, boost и др.)
- Генерирует Makefile'ы в папке `build/`

**Альтернативный способ (без presets):**
```bash
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=../conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Release
```

**Признаки успешной конфигурации:**
```
-- Configuring done
-- Generating done
-- Build files have been written to: /home/.../fptn-0.3.40/build
```

### 2.4 Сборка проекта

```bash
# Запуск сборки с использованием всех ядер процессора
cmake --build . --parallel $(nproc)

# Или через make
make -j$(nproc)
```

**Параметры:**
- `--parallel $(nproc)` - использовать все доступные ядра CPU
- `nproc` - команда, возвращающая количество ядер процессора

**Процесс сборки включает:**
1. Сборку `libtuntap` (для TUN/TAP интерфейсов)
2. Сборку `ntp_client` (синхронизация времени)
3. Сборку `fptn-protocol-lib_static.a` (статическая библиотека)
4. Сборку тестов (`ChannelTest`, `IPv4GeneratorTest`, `MetricTest` и др.)
5. Сборку исполняемых файлов:
   - `fptn-client-cli` - клиент командной строки
   - `fptn-server` - сервер
   - `fptn-passwd` - утилита паролей

**Успешное завершение:**
```
[100%] Built target fptn-server
[100%] Built target fptn-passwd
[100%] Built target fptn-client-cli
```

### 2.5 Проверка результатов сборки

```bash
# Просмотр собранных файлов в директории сборки
ls -la src/fptn-client/fptn-client-cli
ls -la src/fptn-server/fptn-server
ls -la src/fptn-passwd/fptn-passwd

# Проверка типа файлов
file src/fptn-client/fptn-client-cli
```

**Ожидаемый вывод:**
```
src/fptn-client/fptn-client-cli: ELF 64-bit LSB executable, x86-64, dynamically linked
src/fptn-server/fptn-server: ELF 64-bit LSB executable, x86-64, dynamically linked
src/fptn-passwd/fptn-passwd: ELF 64-bit LSB executable, x86-64, dynamically linked
```

---

## Часть 3: Проблемы и их решения

### Проблема 1: Неправильное использование Conan toolchain

**Симптомы:**
```
CMake Error at src/fptn-protocol-lib/CMakeLists.txt:28 (find_package):
  By not providing "Findspdlog.cmake" in CMAKE_MODULE_PATH this project has
  asked CMake to find a package configuration file provided by "spdlog"
```

**Причина:** CMake не может найти зависимости (spdlog, fmt, protobuf), установленные Conan, потому что не используется Conan toolchain.

**Решение:** Всегда используйте toolchain при вызове cmake:
```bash
# Правильный способ
conan install . --output-folder=build --build=missing
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=../conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Release

# Или через presets (рекомендуется)
cmake --preset conan-release
```

### Проблема 2: Undefined reference к функциям libunistring

**Симптомы:**
```
/usr/bin/ld: libidn2.a(decode.o): undefined reference to `u8_to_u32'
/usr/bin/ld: libidn2.a(decode.o): undefined reference to `u32_cpy'
/usr/bin/ld: libidn2.a(decode.o): undefined reference to `u32_cpy_alloc'
collect2: error: ld returned 1 exit status
```

**Причина:** Библиотека `libidn2` скомпилирована с привязкой к `libunistring` (библиотека для работы с Unicode), но линковщик не может найти её функции.

**Решение:** Установить системную версию libunistring:
```bash
# Установка системной версии libunistring
sudo pacman -S libunistring

# Пересборка проекта
make clean
conan install . --build=missing
cmake --preset conan-release
make -j$(nproc)
```

**Почему это работает:** Функции `u8_to_u32`, `u32_cpy` и другие предоставляются библиотекой `libunistring`, которая теперь доступна линковщику.

### Проблема 3: Сборка GUI требует Qt6 и sqlite3

**Симптомы:**
```
qt/6.7.3: No compatible configuration found
sqlite3/3.53.0: Error downloading file https://sqlite.org/2026/sqlite-amalgamation-3530000.zip
```

**Причина:** GUI-версия требует Qt6 и sqlite3, которые Conan не может скачать из-за сетевых проблем.

**Решение:** Использовать CLI-версию (без GUI):
```bash
# Отключаем GUI при установке зависимостей
conan install . --output-folder=build --build=missing \
  -o with_gui_client=False --settings build_type=Release
```

### Проблема 4: Предупреждения компилятора -Wmaybe-uninitialized

**Симптомы:**
```
warning: '<anonymous>' may be used uninitialized [-Wmaybe-uninitialized]
```

**Причина:** Проект использует корутины C++20, и компилятор GCC не всегда может корректно отследить инициализацию переменных в асинхронном коде.

**Решение:** Эти предупреждения можно игнорировать, они не влияют на работоспособность.

---

## Часть 4: Установка в систему

### 4.1 Установка через CMake

```bash
# Установка в /usr/local/bin (требует прав root)
sudo cmake --install . --prefix /usr/local
```

**Что делает команда:**
- Копирует `fptn-client-cli` в `/usr/local/bin/`
- Копирует `fptn-server` в `/usr/local/bin/`
- Копирует `fptn-passwd` в `/usr/local/bin/`

### 4.2 Проверка установки

```bash
# Проверка, что файлы скопировались
ls -la /usr/local/bin/fptn-*

# Проверка, что они в PATH
which fptn-client-cli
which fptn-server
which fptn-passwd

# Проверка динамических зависимостей
ldd /usr/local/bin/fptn-client-cli
```

**Ожидаемый вывод ldd:**
```
linux-vdso.so.1
libunistring.so.5 => /usr/lib/libunistring.so.5
libstdc++.so.6 => /usr/lib/libstdc++.so.6
libm.so.6 => /usr/lib/libm.so.6
libgcc_s.so.1 => /usr/lib/libgcc_s.so.1
libc.so.6 => /usr/lib/libc.so.6
```

### 4.3 Альтернативная установка (ручное копирование)

Если по каким-то причинам `cmake --install` не работает:

```bash
# Ручное копирование
sudo cp src/fptn-client/fptn-client-cli /usr/local/bin/
sudo cp src/fptn-server/fptn-server /usr/local/bin/
sudo cp src/fptn-passwd/fptn-passwd /usr/local/bin/

# Установка прав
sudo chmod +x /usr/local/bin/fptn-*
```

---

## Часть 5: Настройка и запуск CLI-клиента

### 5.1 Получение токена

Токен доступа получается через Telegram-бота проекта FPTN. Найдите официального бота (ссылка есть на GitHub или в Telegram-канале проекта) и следуйте инструкциям для получения токена.

**Формат токена:** `fptnb:...` (длинная строка)

### 5.2 Сохранение токена в файл

Для удобства сохраним токен в файл, чтобы не вводить его каждый раз.

```bash
# Создание файла с токеном
cat > ~/.fptn_token << 'EOF'
ВАШ_ТОКЕН_ОТ_TELEGRAM_БОТА_ПОЛНОСТЬЮ
EOF

# Защита файла (только владелец может читать)
chmod 600 ~/.fptn_token

# Проверка
cat ~/.fptn_token
```

**Зачем:** Безопасное хранение токена и удобство использования в скриптах.

### 5.3 Создание директории для скриптов

```bash
# Создание директории ~/bin для пользовательских скриптов
mkdir -p ~/bin

# Добавление ~/bin в PATH (если ещё не добавлено)
export PATH="$HOME/bin:$PATH"
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
```

**Зачем:** `~/bin` автоматически добавляется в PATH во многих дистрибутивах, позволяя запускать скрипты из любой директории.

### 5.4 Скрипт для подключения (fptn-on)

```bash
cat > ~/bin/fptn-on << 'EOF'
#!/bin/bash
# FPTN VPN - скрипт подключения

echo "Подключение к FPTN VPN..."

# Запуск клиента с токеном из файла
sudo /usr/local/bin/fptn-client-cli \
    --access-token "$(cat ~/.fptn_token)" \
    --tun-interface-name "fptn0"
EOF

chmod +x ~/bin/fptn-on
```

**Что делает скрипт:**
1. Выводит сообщение о подключении
2. Читает токен из файла `~/.fptn_token`
3. Запускает клиент с правами root (нужно для TUN интерфейса)
4. Создаёт TUN интерфейс с именем `fptn0`

### 5.5 Скрипт для отключения (fptn-off)

```bash
cat > ~/bin/fptn-off << 'EOF'
#!/bin/bash
# FPTN VPN - скрипт отключения

echo "Отключение FPTN VPN..."

# Убиваем процесс клиента
sudo pkill -f "fptn-client-cli"

# Небольшая пауза для корректного завершения
sleep 1

# Удаляем TUN интерфейс (если остался)
sudo ip link delete fptn0 2>/dev/null

echo "VPN отключен"
EOF

chmod +x ~/bin/fptn-off
```

**Что делает скрипт:**
1. Находит и завершает процесс `fptn-client-cli`
2. Ждёт 1 секунду для корректного закрытия соединения
3. Удаляет TUN интерфейс (ошибки перенаправляются в `/dev/null`)

### 5.6 Скрипт для проверки статуса (fptn-status)

```bash
cat > ~/bin/fptn-status << 'EOF'
#!/bin/bash
# FPTN VPN - скрипт проверки статуса

if pgrep -f "fptn-client-cli" > /dev/null; then
    echo "✅ VPN подключен"
    
    if ip link show fptn0 2>/dev/null; then
        echo "TUN интерфейс: активен"
        ip addr show fptn0 | grep inet
    fi
else
    echo "❌ VPN отключен"
fi
EOF

chmod +x ~/bin/fptn-status
```

**Что делает скрипт:**
1. Проверяет, запущен ли процесс клиента
2. Если запущен, проверяет наличие TUN интерфейса
3. Показывает IP-адреса интерфейса (IPv4 и IPv6)

### 5.7 Проверка созданных скриптов

```bash
# Просмотр всех скриптов
ls -la ~/bin/fptn-*

# Проверка содержимого
cat ~/bin/fptn-on
cat ~/bin/fptn-off
cat ~/bin/fptn-status
```

### 5.8 Запуск VPN

```bash
# Подключение к VPN
fptn-on
```

**Что происходит при запуске:**
1. Создаётся TUN интерфейс `fptn0`
2. Назначается IP-адрес (обычно 10.0.0.1/30)
3. Настраиваются маршруты
4. Весь трафик начинает идти через VPN

**Для остановки:** Нажмите `Ctrl+C` в терминале с VPN, или выполните в другом терминале `fptn-off`.

### 5.9 Проверка работы в другом терминале

Пока VPN активен, откройте другой терминал и выполните:

```bash
# Проверка статуса
fptn-status

# Проверка IP-адреса (должен измениться)
curl ifconfig.me

# Проверка интерфейса
ip addr show fptn0

# Проверка маршрутов
ip route show | grep fptn0
```

### 5.10 Альтернативный запуск с параметрами

```bash
# Запуск с явным указанием IP интерфейса
sudo /usr/local/bin/fptn-client-cli \
    --access-token "$(cat ~/.fptn_token)" \
    --tun-interface-name "fptn0" \
    --tun-interface-ip "10.0.0.2"

# Запуск с подробным выводом (для отладки)
sudo /usr/local/bin/fptn-client-cli \
    --access-token "$(cat ~/.fptn_token)" \
    --verbose

# Запуск с указанием метода обхода
sudo /usr/local/bin/fptn-client-cli \
    --access-token "$(cat ~/.fptn_token)" \
    --bypass-method sni
```

### 5.11 Создание алиасов для быстрого доступа (опционально)

```bash
# Добавление алиасов в ~/.bashrc
cat >> ~/.bashrc << 'EOF'

# FPTN aliases
alias fptn-on='sudo /usr/local/bin/fptn-client-cli --access-token "$(cat ~/.fptn_token)"'
alias fptn-off='sudo pkill -f fptn-client-cli'
alias fptn-status='pgrep -f fptn-client-cli && echo "VPN RUNNING" || echo "VPN STOPPED"'
EOF

# Применение изменений
source ~/.bashrc
```

---

## Часть 6: Результаты работы

### 6.1 Проверка статуса подключения

```bash
$ fptn-status
✅ VPN подключен
TUN интерфейс: активен
    inet 10.0.0.1/30 scope global fptn0
    inet6 fd00::1/126 scope global 
    inet6 fe80::c282:d3e:9836:e193/64 scope link
```

### 6.2 Проверка внешнего IP-адреса

```bash
$ curl ifconfig.me
138.124.100.151
```

**Вывод показывает, что трафик идёт через VPN-сервер, а не через ваш реальный IP.**

### 6.3 Проверка времени ответа

```bash
$ time curl ifconfig.me
138.124.100.151

real    0m8,409s
user    0m0,005s
sys     0m0,008s
```

### 6.4 Итоговые бинарные файлы

| Файл | Размер | Расположение | Назначение |
|------|--------|--------------|------------|
| `fptn-client-cli` | 39 MB | `/usr/local/bin/` | VPN-клиент |
| `fptn-server` | 43 MB | `/usr/local/bin/` | VPN-сервер |
| `fptn-passwd` | 9.7 MB | `/usr/local/bin/` | Утилита паролей |

### 6.5 Созданные скрипты

| Файл | Расположение | Назначение |
|------|--------------|------------|
| `fptn-on` | `~/bin/` | Подключение VPN |
| `fptn-off` | `~/bin/` | Отключение VPN |
| `fptn-status` | `~/bin/` | Проверка статуса |

### 6.6 Файлы конфигурации

| Файл | Расположение | Назначение |
|------|--------------|------------|
| `.fptn_token` | `~/` | Хранение токена доступа |

---

## Заключение

### Что было сделано:

1. **Установлены зависимости:**
   - `base-devel`, `cmake`, `gcc` - инструменты сборки
   - `python-pipx` - для установки Conan
   - `boost`, `openssl`, `libidn2`, `libunistring` - системные библиотеки

2. **Установлен и настроен Conan:**
   - `pipx install conan` - установка
   - `conan profile detect` - создание профиля

3. **Собраны бинарные файлы:**
   - `conan install -o with_gui_client=False` - только CLI
   - `cmake --preset conan-release` - конфигурация
   - `cmake --build . --parallel $(nproc)` - сборка

4. **Установлены в систему:**
   - `sudo cmake --install . --prefix /usr/local`

5. **Настроен CLI-клиент:**
   - Сохранён токен в `~/.fptn_token`
   - Созданы скрипты `fptn-on`, `fptn-off`, `fptn-status`
   - Добавлена директория `~/bin` в PATH

### Ключевые выводы:

1. **Conan обязателен** - без него CMake не находит зависимости
2. **libunistring - критическая зависимость** для libidn2
3. **CLI-версия работает стабильно** и не требует Qt6
4. **Токен от Telegram-бота** успешно используется для аутентификации

### Команды для повседневного использования:

| Команда | Действие |
|---------|----------|
| `fptn-on` | Включить VPN |
| `fptn-off` | Выключить VPN |
| `fptn-status` | Проверить статус |
| `curl ifconfig.me` | Проверить внешний IP |

---

