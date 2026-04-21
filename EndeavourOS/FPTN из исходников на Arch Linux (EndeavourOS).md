# FPTN из исходников на Arch Linux (EndeavourOS)

## Введение

Была произведена сборка проекта **FPTN** (Fast Private Tunnel Network) версии 0.3.40 из исходных кодов. Проект использует **C++20**, **CMake**, **Conan** для управления зависимостями, а также требует **Boost.Asio**. 

Смотри исходники https://github.com/fptn-project/fptn

## Этап 1: Подготовка системы

### Установка необходимых инструментов

```bash
# Установка базовых инструментов сборки
sudo pacman -S base-devel cmake gcc python-pipx

# Установка дополнительных зависимостей
sudo pacman -S boost openssl libidn2 libunistring

# Установка Conan (менеджер пакетов для C++)
pipx install conan
```

**Комментарий:** Conan необходим для автоматической загрузки и сборки зависимостей проекта. Boost требуется для asio и корутин, libidn2 - для работы с интернациональными доменами.

## Этап 2: Первая попытка сборки и возникшие проблемы

### Настройка Conan

```bash
cd ~/Programs/FPTN/fptn-0.3.40
conan profile detect  # Создание профиля Conan
```

### Проблема 1: Неправильное использование Conan toolchain

**Ошибка:**
```
CMake Error at src/fptn-protocol-lib/CMakeLists.txt:28 (find_package):
  By not providing "Findspdlog.cmake" in CMAKE_MODULE_PATH this project has
  asked CMake to find a package configuration file provided by "spdlog"
```

**Причина:** CMake не мог найти зависимости, установленные Conan, потому что не использовал Conan toolchain.

**Решение:** Использовать toolchain при вызове cmake:

```bash
# Conan устанавливает зависимости и генерирует conan_toolchain.cmake
conan install . --build=missing --output-folder=build

# Важно: использовать сгенерированный toolchain
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=../conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Release
```

**Зачем:** Conan toolchain содержит пути ко всем установленным библиотекам и настройки компилятора.

## Этап 3: Проблемы с линковкой libidn2

### Проблема 2: Undefined reference к функциям libunistring

**Ошибка:**
```
/usr/bin/ld: libidn2.a(decode.o): undefined reference to `u8_to_u32'
/usr/bin/ld: libidn2.a(decode.o): undefined reference to `u32_cpy'
/usr/bin/ld: libidn2.a(decode.o): undefined reference to `u32_cpy_alloc'
```

**Причина:** libidn2 из Conan был собран с привязкой к libunistring (библиотека для работы с Unicode), но линковщик не мог найти её функции.

**Решение 1 (временное):** Явное добавление libunistring при линковке

```bash
# Добавляем флаг линковки напрямую
cmake . -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_EXE_LINKER_FLAGS="-lunistring"
```

**Решение 2 (окончательное):** Установка libunistring через пакетный менеджер

```bash
# Установка системной версии libunistring
sudo pacman -S libunistring

# Пересборка
conan install . --build=missing
cmake --build . --parallel $(nproc)
```

**Зачем:** libunistring предоставляет функции для работы с Unicode строками (`u8_to_u32` - преобразование UTF-8 в UTF-32, `u32_cpy` - копирование UTF-32 строк и т.д.), необходимые libidn2 для корректной обработки интернациональных доменов.

## Этап 4: Предупреждения компилятора

### Предупреждение 1: Wmaybe-uninitialized

**Текст предупреждения:**
```
warning: '<anonymous>' may be used uninitialized [-Wmaybe-uninitialized]
```

**Причина:** Проект использует корутины C++20, и компилятор не всегда может корректно отследить инициализацию переменных в асинхронном коде.

**Решение:** Эти предупреждения были проигнорированы, так как они не влияют на работоспособность. В CMakeLists.txt проекта установлен флаг `-Werror`, но для корутинного кода это ложные срабатывания.

**Комментарий:** В файле `CMakeLists.txt` есть строка:
```cmake
set(CMAKE_COMPILE_WARNING_AS_ERROR ON)  # Превращает все предупреждения в ошибки
```

Это усложняет сборку, так как даже незначительные предупреждения останавливают компиляцию.

### Предупреждение 2: FetchContent deprecated warnings

**Текст:**
```
Calling FetchContent_Populate(Base64) is deprecated, call FetchContent_MakeAvailable(Base64) instead.
```

**Причина:** Используются устаревшие методы FetchContent в CMake.

**Решение:** Эти предупреждения не исправлялись, так как требуют изменения исходного кода проекта (файлы `depends/cmake/FetchBase64.cmake` и `depends/cmake/NtpClient.cmake`).

## Этап 5: Успешная сборка и установка

### Финальные команды сборки:

```bash
# Очистка предыдущих попыток
rm -rf build CMakeCache.txt CMakeFiles

# Установка зависимостей через Conan
conan install . --build=missing

# Конфигурация CMake с toolchain
cmake --preset conan-release

# Сборка всех компонентов
cmake --build . --parallel $(nproc)

# Установка в систему
sudo cmake --install . --prefix /usr/local
```

**Комментарий:** `--preset conan-release` автоматически использует правильный toolchain и настройки, сгенерированные Conan.

### Результаты сборки:

```bash
# Проверка созданных бинарных файлов
$ ll /usr/local/bin/fptn-*
-rwxr-xr-x 1 root root 39M fptn-client-cli
-rwxr-xr-x 1 root root 43M fptn-server  
-rwxr-xr-x 1 root root 9.7M fptn-passwd

# Проверка динамических зависимостей
$ ldd /usr/local/bin/fptn-client-cli
linux-vdso.so.1
libunistring.so.5
libstdc++.so.6
libc.so.6
```

## Этап 6: Статическая сборка (для переносимости)

### Попытка статической линковки:

```bash
cmake . -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_EXE_LINKER_FLAGS="-static-libgcc -static-libstdc++"
```

**Результат:** Частичная статическая сборка. Некоторые библиотеки (glibc) не могут быть статически слинкованы в современных дистрибутивах.

**Зачем:** Статическая сборка позволяет переносить бинарники между разными системами без установки зависимостей.

## Основные выводы

1. **Conan обязателен** - без него CMake не находит зависимости
2. **libunistring - критическая зависимость** для libidn2
3. **Флаг -Werror усложняет сборку** из-за ложных предупреждений в корутинном коде
4. **Бинарники зависят от версии glibc** - для переноса на старые системы нужна пересборка
5. **CMake presets упрощают конфигурацию** - достаточно `--preset conan-release`

## Итоговый размер бинарных файлов

- fptn-client-cli: 39 MB
- fptn-server: 43 MB  
- fptn-passwd: 9.7 MB

**Общий размер:** ~92 MB (без отладочной информации)

## Рекомендации для будущих сборок

1. Всегда использовать `conan install` перед cmake
2. Применять `--preset conan-release` для корректной конфигурации
3. Для переносимости собирать на целевой платформе или в Docker-контейнере
4. При проблемах с линковкой проверять вывод `ldd` для поиска缺失的 библиотек

