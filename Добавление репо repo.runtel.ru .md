# Инструкция по добавлению репозитория runtel.ru и установке OpenSIPS на Debian 12

## 1. Добавление GPG-ключа репозитория

**Вариант A: Скачивание ключа с сервера**
```bash
wget -O /etc/apt/keyrings/runtel.gpg http://repo.runtel.ru/runtel.gpg
```

**Вариант B: Использование локального файла (если уже скачан)**
```bash
# Копируем ключ из домашней директории
cp ~/Programs/runtel.gpg /etc/apt/keyrings/runtel.gpg
```

**Вариант C: Старый метод (deprecated, но работает)**
```bash
wget -q -O - http://repo.runtel.ru/runtel.gpg | apt-key add -
```

## 2. Настройка sources.list

Редактируем файл `/etc/apt/sources.list`:
```bash
mcedit /etc/apt/sources.list
```

Добавляем в конец файла (или раскомментируем и правим существующую строку):
```
# Репозиторий runtel.ru с указанием ключа
deb [signed-by=/etc/apt/keyrings/runtel.gpg] http://repo.runtel.ru bookworm main
```

**Альтернативные варианты записи:**

Если используется старый метод apt-key:
```
deb http://repo.runtel.ru bookworm main
```

Для отключения проверки ключа (не рекомендуется):
```
deb [allow-insecure=yes] http://repo.runtel.ru bookworm main
```

## 3. Обновление списка пакетов

```bash
apt update
```

**Возможные ошибки и решения:**

1. Если видите ошибку `NO_PUBKEY 325CE60C3AD367DE`:
   ```bash
   # Проверьте наличие ключа
   ll /etc/apt/keyrings/runtel.gpg
   
   # Если ключ есть, убедитесь в правильности пути в signed-by
   # или используйте старый метод:
   apt-key add /etc/apt/keyrings/runtel.gpg
   apt update
   ```

2. Если видите предупреждение о legacy trusted.gpg:
   ```bash
   # Это не критично, пакеты будут работать
   apt update 2>&1 | grep -v "DEPRECATION"
   ```

## 4. Поиск и установка OpenSIPS

```bash
# Поиск доступных версий
apt search opensips

# Установка OpenSIPS
apt install opensips

# Или установка с дополнительными модулями
apt install opensips opensips-mysql-module opensips-postgres-module
```

## 5. Проверка установки

```bash
# Проверка версии
opensips -V

# Проверка статуса службы
systemctl status opensips

# Запуск службы
systemctl start opensips

# Включение автозапуска
systemctl enable opensips
```

## 6. Дополнительные модули (опционально)

```bash
# Поиск доступных модулей
apt search opensips- | grep module

# Установка часто используемых модулей
apt install opensips-mysql-module opensips-postgres-module opensips-tls-module
```

## 7. Конфигурационные файлы

После установки основные файлы будут расположены:
- `/etc/opensips/opensips.cfg` - основной конфигурационный файл
- `/etc/opensips/opensipsctlrc` - конфигурация утилит управления
- `/lib/systemd/system/opensips.service` - служба systemd
- `/usr/sbin/opensips` - основной исполняемый файл

## 8. Устранение неполадок

**Проблема:** Ключ добавляется, но репозиторий не работает
```bash
# Проверьте права на файл ключа
chmod 644 /etc/apt/keyrings/runtel.gpg

# Проверьте синтаксис sources.list
apt-get check
```

**Проблема:** Нужно временно отключить репозиторий
```bash
# Закомментируйте строку в /etc/apt/sources.list
# deb [signed-by=/etc/apt/keyrings/runtel.gpg] http://repo.runtel.ru bookworm main

apt update
```

## 9. Полный скрипт установки

```bash
#!/bin/bash
# Полная установка OpenSIPS из репозитория runtel.ru

# 1. Добавление ключа
wget -O /etc/apt/keyrings/runtel.gpg http://repo.runtel.ru/runtel.gpg

# 2. Добавление репозитория
echo "deb [signed-by=/etc/apt/keyrings/runtel.gpg] http://repo.runtel.ru bookworm main" >> /etc/apt/sources.list

# 3. Обновление и установка
apt update
apt install opensips -y

# 4. Запуск службы
systemctl enable --now opensips

echo "Установка завершена!"
```

