## 📚 Инструкция по работе с fwupd 

### 🔧 Основные утилиты fwupd

В состав пакета fwupd входят три основные утилиты:

| Утилита | Назначение |
|---------|------------|
| **fwupdmgr** | Основная утилита для пользователей — управление прошивками |
| **fwupdtool** | Расширенный инструмент для разработчиков и администраторов |
| **fwupd-dbxtool** | Специализированный инструмент для работы с UEFI dbx |

---

## 📖 Полный справочник команд

### 1. fwupdmgr — основной инструмент пользователя

#### 📋 Информационные команды
```bash
fwupdmgr get-devices              # Список всех устройств
fwupdmgr get-topology             # То же, что get-devices
fwupdmgr get-plugins              # Список активных плагинов
fwupdmgr get-remotes              # Список настроенных репозиториев
fwupdmgr get-history              # История обновлений прошивок
fwupdmgr hwids                    # Идентификаторы оборудования
fwupdmgr security                 # Атрибуты безопасности хоста
fwupdmgr get-bios-settings        # Настройки BIOS
```

#### 🔄 Обновление метаданных и поиск обновлений
```bash
sudo fwupdmgr refresh             # Обновить метаданные
sudo fwupdmgr refresh --force     # Принудительное обновление
fwupdmgr get-updates              # Проверить доступные обновления
fwupdmgr get-releases DEVICE_ID   # Получить релизы для устройства
fwupdmgr search "ключевое слово"  # Поиск прошивок в метаданных
```

#### ⚙️ Установка и управление прошивками
```bash
sudo fwupdmgr update              # Обновить все устройства
sudo fwupdmgr update DEVICE_ID    # Обновить конкретное устройство
sudo fwupdmgr upgrade DEVICE_ID   # Псевдоним update
sudo fwupdmgr install FILE.cab    # Установить прошивку из файла
sudo fwupdmgr local-install FILE.cab  # Локальная установка CAB-файла
sudo fwupdmgr downgrade DEVICE_ID # Понизить версию прошивки
sudo fwupdmgr reinstall DEVICE_ID # Переустановить текущую прошивку
sudo fwupdmgr switch-branch DEVICE_ID BRANCH  # Переключить ветку
```

#### 🔐 Управление безопасностью
```bash
sudo fwupdmgr security-fix ID     # Исправить атрибут безопасности
sudo fwupdmgr security-undo ID    # Отменить исправление
sudo fwupdmgr set-approved-firmware HASH  # Установить список одобренных прошивок
sudo fwupdmgr get-approved-firmware       # Получить список одобренных
```

#### ⚡ Управление репозиториями
```bash
sudo fwupdmgr enable-remote REMOTE_ID     # Включить репозиторий
sudo fwupdmgr disable-remote REMOTE_ID    # Выключить репозиторий
sudo fwupdmgr modify-remote REMOTE_ID KEY VALUE  # Изменить настройки
sudo fwupdmgr clean-remote REMOTE_ID      # Очистить репозиторий
```

#### 🛠️ Дополнительные команды
```bash
sudo fwupdmgr activate DEVICE_ID   # Активировать устройства
sudo fwupdmgr unlock DEVICE_ID     # Разблокировать устройство
sudo fwupdmgr verify DEVICE_ID     # Проверить криптографический хеш
sudo fwupdmgr verify-update DEVICE_ID  # Обновить сохранённый хеш
sudo fwupdmgr clear-results DEVICE_ID  # Очистить результаты обновления
fwupdmgr check-reboot-needed       # Проверить, нужна ли перезагрузка
sudo fwupdmgr quit                 # Остановить демон fwupd
```

#### 📝 Параметры для всех команд
```bash
-y, --assume-yes          # Автоматически отвечать "да"
--force                   # Принудительное выполнение
--allow-older             # Разрешить понижение версии
--allow-reinstall         # Разрешить переустановку
--json                    # Вывод в формате JSON
--verbose, -v             # Подробный вывод
--filter                  # Фильтрация устройств
--no-reboot-check         # Не проверять перезагрузку
```

---

### 2. fwupdtool — расширенный инструмент

#### 📦 Работа с прошивками
```bash
fwupdtool firmware-parse FILE     # Разобрать файл прошивки
fwupdtool firmware-extract FILE   # Извлечь образы из прошивки
fwupdtool firmware-export FILE    # Экспортировать в XML
fwupdtool firmware-convert INPUT OUTPUT  # Конвертировать формат
fwupdtool firmware-build XML FILE # Собрать прошивку
fwupdtool firmware-sign FILE CERT KEY  # Подписать прошивку
fwupdtool firmware-patch FILE OFFSET DATA  # Исправить образ
```

#### 💾 Чтение и запись прошивок
```bash
sudo fwupdtool firmware-read FILE DEVICE_ID   # Прочитать прошивку с устройства
sudo fwupdtool firmware-dump FILE DEVICE_ID   # Сдампить сырой образ
sudo fwupdtool install FILE DEVICE_ID         # Установить прошивку
sudo fwupdtool install-blob FILE DEVICE_ID    # Установить сырой образ
```

#### 🖥️ Работа с UEFI
```bash
fwupdtool efiboot-info            # Список загрузочных записей EFI
fwupdtool efiboot-files           # Список загрузочных файлов EFI
fwupdtool efiboot-order INDEX1,INDEX2  # Установить порядок загрузки
sudo fwupdtool efiboot-create INDEX NAME TARGET  # Создать запись
sudo fwupdtool efiboot-delete INDEX      # Удалить запись
fwupdtool efivar-list GUID        # Список переменных EFI
```

#### 🧪 Эмуляция и тестирование
```bash
fwupdtool emulation-tag DEVICE_ID    # Добавить для эмуляции
fwupdtool emulation-untag DEVICE_ID  # Убрать из эмуляции
fwupdtool emulation-save FILE        # Сохранить данные эмуляции
fwupdtool emulation-load FILE        # Загрузить данные эмуляции
fwupdtool enable-test-devices        # Включить тестовые устройства
fwupdtool disable-test-devices       # Выключить тестовые устройства
```

#### 🔧 Управление драйверами
```bash
sudo fwupdtool attach DEVICE_ID     # Подключить в режим прошивки
sudo fwupdtool detach DEVICE_ID     # Отключить в режим загрузчика
sudo fwupdtool bind-driver SUBSYSTEM DRIVER  # Привязать драйвер
sudo fwupdtool unbind-driver        # Отвязать драйвер
```

#### 🛡️ JCat (подписи)
```bash
fwupdtool jcat-info FILE            # Информация о JCat-файле
fwupdtool jcat-sign FILE SOURCE CERT KEY  # Подписать JCat
fwupdtool jcat-self-sign FILE SOURCE      # Самоподпись
fwupdtool jcat-verify FILE           # Проверить подпись
fwupdtool jcat-import FILE DATA KEY  # Импортировать подпись
fwupdtool jcat-export FILE          # Экспортировать подписи
```

#### 📊 Системные команды
```bash
fwupdtool get-devices               # Список устройств
fwupdtool get-updates               # Доступные обновления
fwupdtool get-history               # История обновлений
fwupdtool security                  # Атрибуты безопасности
fwupdtool smbios-dump FILE          # Записать SMBIOS
fwupdtool tpm-eventlog              # Журнал событий TPM
fwupdtool monitor                   # Мониторинг событий
fwupdtool watch                     # Отслеживание изменений
```

#### ⚙️ Работа с настройками BIOS
```bash
fwupdtool get-bios-settings         # Получить настройки BIOS
sudo fwupdtool set-bios-setting SETTING VALUE  # Установить настройку
```

---

### 3. fwupd-dbxtool — работа с UEFI dbx

```bash
fwupd-dbxtool --list                # Список записей в dbx
sudo fwupd-dbxtool --apply          # Применить обновление dbx
sudo fwupd-dbxtool --dbx FILE       # Указать файл dbx
sudo fwupd-dbxtool --esp-path PATH  # Указать путь к ESP
sudo fwupd-dbxtool --force          # Принудительное применение
fwupd-dbxtool --version             # Показать версию dbx
```

---

## 🎯 Практические сценарии использования

### Сценарий 1: Ежемесячная проверка обновлений
```bash
# 1. Обновить метаданные
sudo fwupdmgr refresh

# 2. Проверить доступные обновления
fwupdmgr get-updates

# 3. Если есть обновления — установить
sudo fwupdmgr update

# 4. Перезагрузиться при необходимости
sudo reboot
```

### Сценарий 2: Установка прошивки из файла
```bash
# Установить прошивку из CAB-файла
sudo fwupdmgr local-install /path/to/firmware.cab

# Или указать конкретное устройство
sudo fwupdmgr local-install /path/to/firmware.cab DEVICE_ID
```

### Сценарий 3: Откат проблемной прошивки
```bash
# 1. Посмотреть историю
fwupdmgr get-history

# 2. Понизить версию
sudo fwupdmgr downgrade DEVICE_ID

# 3. Если нужно принудительно
sudo fwupdmgr downgrade DEVICE_ID --allow-older --force
```

### Сценарий 4: Работа с UEFI dbx
```bash
# Проверить текущую версию dbx
fwupd-dbxtool --list

# Обновить dbx через fwupdmgr
sudo fwupdmgr update

# Или напрямую через dbxtool
sudo fwupd-dbxtool --apply --force
```

### Сценарий 5: Диагностика проблем
```bash
# Проверить статус службы
systemctl status fwupd

# Проверить логи
journalctl -u fwupd -f

# Проверить настройки BIOS
fwupdmgr get-bios-settings

# Проверить безопасность
fwupdmgr security

# Проверить, нужна ли перезагрузка
fwupdmgr check-reboot-needed
```

---

## ⚠️ Важные параметры и флаги

### Общие флаги для fwupdmgr и fwupdtool:

| Флаг | Описание |
|------|----------|
| `--force` | Принудительное выполнение (отключает некоторые проверки) |
| `--allow-older` | Разрешает установку более старых версий |
| `--allow-reinstall` | Разрешает переустановку текущей версии |
| `--allow-branch-switch` | Разрешает переключение веток прошивки |
| `-y, --assume-yes` | Автоматически подтверждает все действия |
| `--json` | Вывод результатов в JSON-формате |
| `--verbose, -v` | Подробный вывод с отладочной информацией |
| `--no-reboot-check` | Отключает проверку необходимости перезагрузки |
| `--no-safety-check` | Отключает проверки безопасности устройства |
| `--filter PATTERN` | Фильтрует устройства (например, `~needs-reboot`) |

### Специфичные для fwupdtool:

| Флаг | Описание |
|------|----------|
| `--plugins PLUGINS` | Вручную включить определённые плагины |
| `--public-keys PATH` | Путь к каталогу открытых ключей |
| `--prepare` | Запустить подготовку составного плагина |
| `--cleanup` | Запустить очистку составного плагина |
| `--disable-ssl-strict` | Игнорировать строгие SSL-проверки |

---

## 📝 Примеры использования в вашей работе

### Для ThinkBook 14 G7 ARP:
```bash
# Базовая проверка
sudo fwupdmgr refresh
fwupdmgr get-updates
sudo fwupdmgr update
sudo reboot
```

### Для ThinkPad P14s Gen 6 AMD:
```bash
# Расширенная проверка
sudo fwupdmgr refresh --force
fwupdmgr get-updates --show-all
sudo fwupdmgr update --allow-reinstall
fwupdmgr check-reboot-needed
```

### Работа с отладкой:
```bash
# Включить подробный вывод
sudo fwupdmgr update --verbose

# Сохранить вывод в файл
sudo fwupdmgr get-devices --json > devices.json

# Проверить конкретное устройство
fwupdmgr get-releases DEVICE_GUID
```

---

## 🗂️ Где хранятся файлы

| Путь | Назначение |
|------|------------|
| `/etc/fwupd/` | Конфигурационные файлы |
| `/var/lib/fwupd/` | Данные и метаданные |
| `/var/lib/fwupd/remotes.d/` | Репозитории |
| `/usr/share/fwupd/` | Общие файлы |
| `/boot/efi/` | ESP-раздел (для UEFI) |
| `/var/log/fwupd/` | Логи (если включены) |

---

## 🔗 Полезные ссылки

- [Официальная документация fwupd](https://fwupd.org/)
- [LVFS - Linux Vendor Firmware Service](https://lvfs.ubuntu.com/)
- [Репозиторий на GitHub](https://github.com/fwupd/fwupd)

---

## 📌 Заключение

**fwupd** предоставляет мощный и гибкий набор инструментов для управления прошивками в Linux. Основные команды:

- `fwupdmgr` — для повседневного использования
- `fwupdtool` — для расширенных задач и разработки
- `fwupd-dbxtool` — для работы с Secure Boot dbx

Регулярно проверяйте обновления (раз в 1-2 месяца) и всегда следуйте правилам безопасности при обновлении прошивок!

---

