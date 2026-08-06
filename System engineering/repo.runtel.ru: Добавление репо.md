# Полное руководство по добавлению репозитория repo.runtel.ru и установке OpenSIPS

## 📋 Содержание
1. [Общая информация](#общая-информация)
2. [Инструкция для Debian 12 (Bookworm)](#инструкция-для-debian-12-bookworm)
3. [Инструкция для Debian 13 (Trixie)](#инструкция-для-debian-13-trixie)
4. [Поиск и установка OpenSIPS](#поиск-и-установка-opensips)
5. [Устранение неполадок](#устранение-неполадок)

---

# Общая информация

## Проблема

При добавлении репозитория `http://repo.runtel.ru` возникает ошибка:
```
NO_PUBKEY 325CE60C3AD367DE
W: Ошибка GPG: http://repo.runtel.ru bookworm InRelease: Следующие подписи не могут быть проверены...
```

**Основные параметры:**
- **ID ключа:** `325CE60C3AD367DE`
- **Файл ключа:** `runtel.gpg`
- **Источник ключа:** `http://repo.runtel.ru/runtel.gpg`

---

# Инструкция для Debian 12 (Bookworm)

## 📦 Способ 1: Добавление GPG-ключа

### Вариант A: Скачивание ключа с сервера
```bash
# Создаём директорию для ключей (если её нет)
mkdir -p /etc/apt/keyrings

# Скачиваем ключ
wget -O /etc/apt/keyrings/runtel.gpg http://repo.runtel.ru/runtel.gpg

# Проверяем, что ключ скачался (размер должен быть ~3KB)
ls -la /etc/apt/keyrings/runtel.gpg
```

### Вариант B: Использование локального файла
```bash
# Если ключ уже скачан в другую директорию
mkdir -p /etc/apt/keyrings
cp ~/Programs/runtel.gpg /etc/apt/keyrings/runtel.gpg
```

### Вариант C: Старый метод (deprecated, но работает)
```bash
# Добавление ключа напрямую в системную связку
wget -q -O - http://repo.runtel.ru/runtel.gpg | apt-key add -
```
> **⚠️ Примечание:** Появится предупреждение `apt-key is deprecated`, но репозиторий будет работать.

### Вариант D: Современный метод с конвертацией
```bash
# Скачиваем и конвертируем ключ одной командой
wget -O- http://repo.runtel.ru/runtel.gpg | gpg --dearmor > /etc/apt/keyrings/runtel.gpg
```

---

## 🔧 Способ 2: Настройка sources.list

### Вариант A: Единый файл /etc/apt/sources.list
```bash
# Редактируем основной файл репозиториев
nano /etc/apt/sources.list
# или
mcedit /etc/apt/sources.list

# Добавляем в КОНЕЦ файла одну из строк:
```

**Варианты строк для добавления:**

```bash
# 1. Современный метод с signed-by (рекомендуется)
deb [signed-by=/etc/apt/keyrings/runtel.gpg] http://repo.runtel.ru bookworm main

# 2. Если нужно добавить дополнительные компоненты
deb [signed-by=/etc/apt/keyrings/runtel.gpg] http://repo.runtel.ru bookworm main dev contrib non-free

# 3. Старый метод (если использовали apt-key add)
deb http://repo.runtel.ru bookworm main

# 4. Временное решение без проверки ключа (не рекомендуется)
deb [allow-insecure=yes] http://repo.runtel.ru bookworm main
```

### Вариант B: Отдельный файл в sources.list.d/
```bash
# Создаём отдельный файл для репозитория runtel
nano /etc/apt/sources.list.d/runtel.list
```

**Содержимое файла:**

```bash
# 1. Современный метод с signed-by
deb [signed-by=/etc/apt/keyrings/runtel.gpg] http://repo.runtel.ru bookworm main

# 2. Если нужно несколько компонентов
deb [signed-by=/etc/apt/keyrings/runtel.gpg] http://repo.runtel.ru bookworm main dev
```

---

## 🚀 Комбинированные варианты

### Вариант I: Современный (рекомендуемый)
```bash
# 1. Скачиваем ключ
mkdir -p /etc/apt/keyrings
wget -O /etc/apt/keyrings/runtel.gpg http://repo.runtel.ru/runtel.gpg

# 2. Добавляем репозиторий в отдельный файл
echo "deb [signed-by=/etc/apt/keyrings/runtel.gpg] http://repo.runtel.ru bookworm main" > /etc/apt/sources.list.d/runtel.list

# 3. Обновляем
apt update
```

### Вариант II: Всё в одном файле
```bash
# 1. Скачиваем ключ
mkdir -p /etc/apt/keyrings
wget -O /etc/apt/keyrings/runtel.gpg http://repo.runtel.ru/runtel.gpg

# 2. Добавляем строку в /etc/apt/sources.list
echo "deb [signed-by=/etc/apt/keyrings/runtel.gpg] http://repo.runtel.ru bookworm main" >> /etc/apt/sources.list

# 3. Обновляем
apt update
```

### Вариант III: Старый метод (с предупреждением)
```bash
# 1. Добавляем ключ старым способом
wget -q -O - http://repo.runtel.ru/runtel.gpg | apt-key add -

# 2. Создаём файл репозитория
echo "deb http://repo.runtel.ru bookworm main" > /etc/apt/sources.list.d/runtel.list

# 3. Обновляем (будет предупреждение DEPRECATION)
apt update
```

### Вариант IV: Экстренный (без проверки ключа)
```bash
# ⚠️ ТОЛЬКО ДЛЯ ТЕСТИРОВАНИЯ!
echo "deb [allow-insecure=yes] http://repo.runtel.ru bookworm main" > /etc/apt/sources.list.d/runtel.list
apt update --allow-insecure-repositories
```

---

## 🔍 Проверка после установки

```bash
# 1. Проверить, что ключ установлен
apt-key list | grep -A 2 -B 2 "325CE60C3AD367DE"  # для старого метода
# или
ls -la /etc/apt/trusted.gpg.d/ | grep runtel      # для нового метода
# или
ls -la /etc/apt/keyrings/runtel.gpg               # проверка наличия файла

# 2. Проверить, что репозиторий добавлен
apt-cache policy | grep -A 3 "runtel"

# 3. Найти пакеты из репозитория
apt-cache search runtel | head -5
```

---

# Инструкция для Debian 13 (Trixie)

## 🔄 Ключевые отличия от Debian 12

1. **Формат deb822**: Используются файлы `.sources` вместо `.list`
2. **Имя дистрибутива**: `trixie` вместо `bookworm`
3. **Путь к ключу**: `/etc/apt/keyrings/runtel-archive-keyring.gpg`
4. **Структура файла**: Многострочный формат с ключами `Types:`, `URIs:`, `Suites:`, `Components:`, `Signed-By:`

---

## 📦 Шаг 1: Очистка старых ключей и файлов

```bash
# Удалить старые ключи
rm -f /etc/apt/trusted.gpg.d/runtel.gpg
rm -f /etc/apt/keyrings/runtel.gpg

# Удалить дублирующиеся файлы репозиториев
rm -f /etc/apt/sources.list.d/runtel.list
rm -f /etc/apt/sources.list.d/repo_runtel_ru.list
```

---

## 🔑 Шаг 2: Скачать и установить ключ репозитория

```bash
# Создать директорию для ключей (если её нет)
mkdir -p /etc/apt/keyrings

# Скачать ключ и конвертировать в правильный формат
wget -qO- http://repo.runtel.ru/runtel.gpg | gpg --dearmor > /etc/apt/keyrings/runtel-archive-keyring.gpg

# Скопировать ключ в доверенные ключи APT (для совместимости)
cp /etc/apt/keyrings/runtel-archive-keyring.gpg /etc/apt/trusted.gpg.d/

# Проверить, что ключ установлен
gpg --show-keys /etc/apt/keyrings/runtel-archive-keyring.gpg
```

---

## 📝 Шаг 3: Настройка файла репозитория (deb822 формат)

```bash
# Создать файл в формате deb822
cat > /etc/apt/sources.list.d/runtel.sources << 'EOF'
# Runtel repositories - Debian 13 Trixie
Types: deb
URIs: http://repo.runtel.ru
Suites: trixie
Components: main dev
Signed-By: /etc/apt/keyrings/runtel-archive-keyring.gpg
EOF
```

---

## 🔄 Шаг 4: Очистка кэша и обновление

```bash
# Очистить кэш APT
apt clean
rm -rf /var/lib/apt/lists/*

# Обновить списки пакетов
apt update
```

---

## ✅ Шаг 5: Проверка репозитория

```bash
# Проверить, что репозиторий виден
apt-cache policy | grep -A 10 "repo.runtel.ru"

# Проверить наличие пакетов
apt-cache search runtel
```

---

## 🚀 Обновленный Ansible playbook для Debian 13

```yaml
---
- name: Deb13 - установка необходимых утилит
  hosts: all
  become: yes
  tasks:
    - name: Update apt package cache first
      apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: Create /etc/apt/sources.list.d/ (deb822 format)
      file:
        path: /etc/apt/sources.list.d/
        state: directory
        owner: root
        group: root
        mode: '0755'

    - name: Remove old sources.list
      file:
        path: /etc/apt/sources.list
        state: absent
      ignore_errors: yes

    - name: Create directory for APT keyrings
      file:
        path: /etc/apt/keyrings
        state: directory
        owner: root
        group: root
        mode: '0755'

    - name: Download Runtel repository key
      get_url:
        url: http://repo.runtel.ru/runtel.gpg
        dest: /etc/apt/keyrings/runtel-archive-keyring.gpg
        mode: '0644'
        force: yes
      register: key_download

    - name: Convert key to dearmored format if needed
      shell: |
        gpg --dearmor /etc/apt/keyrings/runtel-archive-keyring.gpg > /etc/apt/keyrings/runtel-archive-keyring.gpg.tmp
        mv /etc/apt/keyrings/runtel-archive-keyring.gpg.tmp /etc/apt/keyrings/runtel-archive-keyring.gpg
      when: key_download is success
      ignore_errors: yes

    - name: Copy key to trusted.gpg.d for compatibility
      copy:
        src: /etc/apt/keyrings/runtel-archive-keyring.gpg
        dest: /etc/apt/trusted.gpg.d/runtel-archive-keyring.gpg
        remote_src: yes
        mode: '0644'
      when: key_download is success

    - name: Configure Debian repositories with RF mirrors (deb822)
      copy:
        content: |
          # Debian 13 Trixie - Official repositories
          Types: deb
          URIs: http://mirror.yandex.ru/debian/
          Suites: trixie trixie-updates
          Components: main contrib non-free non-free-firmware
          Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

          Types: deb
          URIs: http://ftp.ru.debian.org/debian/
          Suites: trixie
          Components: main contrib non-free non-free-firmware
          Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

          Types: deb
          URIs: http://mirror.truenetwork.ru/debian/
          Suites: trixie
          Components: main contrib non-free non-free-firmware
          Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

          # Security updates
          Types: deb
          URIs: http://security.debian.org/debian-security
          Suites: trixie-security
          Components: main contrib non-free non-free-firmware
          Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

          # Backports
          Types: deb
          URIs: http://mirror.yandex.ru/debian/
          Suites: trixie-backports
          Components: main contrib non-free non-free-firmware
          Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
        dest: /etc/apt/sources.list.d/debian.sources
        mode: '0644'

    - name: Configure Runtel repositories in deb822 format
      copy:
        content: |
          # Runtel repositories - Debian 13 Trixie
          Types: deb
          URIs: http://repo.runtel.ru
          Suites: trixie
          Components: main dev
          Signed-By: /etc/apt/keyrings/runtel-archive-keyring.gpg
        dest: /etc/apt/sources.list.d/runtel.sources
        mode: '0644'
      when: key_download is success

    - name: Fallback - Configure Runtel repositories without key (if download failed)
      copy:
        content: |
          # Runtel repositories - Debian 13 Trixie (без проверки подписи)
          Types: deb
          URIs: http://repo.runtel.ru
          Suites: trixie
          Components: main dev
          # Signed-By: /etc/apt/keyrings/runtel-archive-keyring.gpg
        dest: /etc/apt/sources.list.d/runtel.sources
        mode: '0644'
      when: key_download is failed
      ignore_errors: yes

    - name: Update apt package cache after repository configuration
      apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: Check /etc/resolv.conf
      ansible.builtin.slurp:
        src: /etc/resolv.conf
      register: resolv_conf
      changed_when: false

    - name: DEBUG /etc/resolv.conf
      debug:
        msg: "Содержимое /etc/resolv.conf:\n{{ resolv_conf.content | b64decode }}"

    - name: Install common utilities for Debian 13
      apt:
        name: "{{ packages }}"
        state: present
        update_cache: yes
        cache_valid_time: 3600
      vars:
        packages:
          - sudo
          - curl
          - wget
          - neovim
          - vim
          - vim-syntastic
          - mc
          - rsync
          - iptables
          - netfilter-persistent
          - sngrep
          - tmux
          - nmap
          - bind9-dnsutils
          - dnsutils
          - traceroute
          - highlight
          - ccze
          - sysstat
          - strace
          - htop
          - btop
          - atop
          - ncdu
          - gdu
          - tree
          - jq
          - yq
          - gnupg2
          - rsyslog
          - apt-transport-https
          - ca-certificates
      ignore_errors: yes

    - name: Create /etc/nginx directory
      file:
        path: /etc/nginx
        state: directory
        owner: root
        group: root
        mode: '0755'

    - name: Copy certificates via copy module
      copy:
        src: "../keys/{{ item }}"
        dest: "/etc/nginx/{{ item }}"
        owner: root
        group: root
        mode: '0644'
      loop:
        - cprt.pem
        - runtel.pem
        - runtelorg.pem
      ignore_errors: yes

    - name: Verify repository configuration
      shell: |
        echo "=== Debian Official Repositories (deb822) ==="
        cat /etc/apt/sources.list.d/debian.sources
        echo
        echo "=== Runtel Repositories (deb822) ==="
        cat /etc/apt/sources.list.d/runtel.sources 2>/dev/null || echo "No Runtel sources found"
        echo
        echo "=== Available repositories ==="
        apt-cache policy | grep -E "^[0-9]+:|http://repo.runtel.ru" || echo "Check apt-cache policy manually"
        echo
        echo "=== Key info ==="
        ls -la /etc/apt/keyrings/runtel-archive-keyring.gpg 2>/dev/null || echo "Key file not found"
      register: repos_check
      changed_when: false
      ignore_errors: yes

    - name: Display repository check results
      debug:
        msg: "{{ repos_check.stdout_lines }}"

    - name: Info message
      debug:
        msg:
          - "Debian 13 (Trixie) настроен в формате deb822"
          - "Конфигурация репозиториев: /etc/apt/sources.list.d/debian.sources"
          - "Репозиторий Runtel: /etc/apt/sources.list.d/runtel.sources"
          - "Ключ репозитория: /etc/apt/keyrings/runtel-archive-keyring.gpg"
          - "Все утилиты успешно установлены"
          - "Сертификаты скопированы в /etc/nginx/"
          - ""
          - "Для проверки репозиториев выполните:"
          - " apt-cache policy | grep -A 5 runtel"
          - " apt-cache search runtel"
          - " apt update -y"
```

---

## 🧪 Ручная проверка на хосте

```bash
# Проверить ключ
gpg --show-keys /etc/apt/keyrings/runtel-archive-keyring.gpg

# Проверить репозиторий
apt-cache policy | grep -A 10 runtel

# Проверить доступные пакеты
apt-cache search runtel
```

---

# Поиск и установка OpenSIPS

## 📦 Установка

```bash
# Поиск доступных версий
apt search opensips

# Установка OpenSIPS
apt install opensips

# Или установка с дополнительными модулями
apt install opensips opensips-mysql-module opensips-postgres-module
```

---

## ✅ Проверка установки

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

---

## 🔌 Дополнительные модули (опционально)

```bash
# Поиск доступных модулей
apt search opensips- | grep module

# Установка часто используемых модулей
apt install opensips-mysql-module opensips-postgres-module opensips-tls-module
```

---

## ⚙️ Конфигурационные файлы

После установки основные файлы будут расположены:
- `/etc/opensips/opensips.cfg` - основной конфигурационный файл
- `/etc/opensips/opensipsctlrc` - конфигурация утилит управления
- `/lib/systemd/system/opensips.service` - служба systemd
- `/usr/sbin/opensips` - основной исполняемый файл

---

# Устранение неполадок

## 🔧 Возможные ошибки и их решение

### Ошибка 1: NO_PUBKEY 325CE60C3AD367DE

```bash
# Ключ не установлен или не виден системой
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 325CE60C3AD367DE

# или скачайте ключ заново
rm -f /etc/apt/keyrings/runtel.gpg
wget -O /etc/apt/keyrings/runtel.gpg http://repo.runtel.ru/runtel.gpg
apt-key add /etc/apt/keyrings/runtel.gpg
```

---

### Ошибка 2: Файл ключа пустой (0 байт)

```bash
# Удаляем пустой файл и скачиваем заново
rm -f /etc/apt/keyrings/runtel.gpg
wget -O /etc/apt/keyrings/runtel.gpg http://repo.runtel.ru/runtel.gpg

# Проверяем размер
ls -la /etc/apt/keyrings/runtel.gpg  # должен быть ~3143 байт
```

---

### Ошибка 3: Предупреждение DEPRECATION

```bash
# Это не ошибка, а предупреждение об устаревшем методе
# Можно игнорировать или перейти на новый метод:

# 1. Удаляем старый ключ
apt-key del "325CE60C3AD367DE"

# 2. Устанавливаем ключ новым методом
mkdir -p /etc/apt/keyrings
wget -O /etc/apt/keyrings/runtel.gpg http://repo.runtel.ru/runtel.gpg

# 3. Правим файл репозитория
sed -i 's|deb http://repo.runtel.ru|deb [signed-by=/etc/apt/keyrings/runtel.gpg] http://repo.runtel.ru|' /etc/apt/sources.list.d/runtel.list

# 4. Обновляем
apt update
```

---

### Ошибка 4: Ключ добавляется, но репозиторий не работает

```bash
# Проверьте права на файл ключа
chmod 644 /etc/apt/keyrings/runtel.gpg

# Проверьте синтаксис sources.list
apt-get check
```

---

## 🔄 Полезные команды для управления репозиториями

```bash
# Включить/отключить репозиторий
mv /etc/apt/sources.list.d/runtel.list /etc/apt/sources.list.d/runtel.list.bak  # отключить
mv /etc/apt/sources.list.d/runtel.list.bak /etc/apt/sources.list.d/runtel.list  # включить

# Посмотреть все репозитории
grep -r "^deb" /etc/apt/sources.list /etc/apt/sources.list.d/

# Удалить репозиторий полностью (Debian 12)
rm /etc/apt/sources.list.d/runtel.list
rm /etc/apt/keyrings/runtel.gpg
apt-key del "325CE60C3AD367DE"  # если использовали старый метод

# Удалить репозиторий полностью (Debian 13)
rm /etc/apt/sources.list.d/runtel.sources
rm /etc/apt/keyrings/runtel-archive-keyring.gpg
rm /etc/apt/trusted.gpg.d/runtel-archive-keyring.gpg
```

---

## 📌 Важные замечания

1. **ID ключа:** `325CE60C3AD367DE` - уникальный идентификатор ключа runtel
2. **Дистрибутив:** 
   - Debian 12: `bookworm`
   - Debian 13: `trixie`
3. **Компоненты:** `main` - основные пакеты, `dev` - пакеты для разработки
4. **Безопасность:** метод с `signed-by` наиболее безопасен, так как ключ привязан к конкретному репозиторию
5. **Предупреждение DEPRECATION:** появляется только при использовании `apt-key add`, не влияет на работу, но лучше перейти на новый метод

---

## 🚀 Краткая шпаргалка

### Debian 12 (Bookworm)

```bash
# Минимальный рабочий вариант (современный)
mkdir -p /etc/apt/keyrings
wget -O /etc/apt/keyrings/runtel.gpg http://repo.runtel.ru/runtel.gpg
echo "deb [signed-by=/etc/apt/keyrings/runtel.gpg] http://repo.runtel.ru bookworm main" > /etc/apt/sources.list.d/runtel.list
apt update

# Если не работает - экстренный вариант
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 325CE60C3AD367DE
apt update
```

### Debian 13 (Trixie)

```bash
# Минимальный рабочий вариант (deb822)
mkdir -p /etc/apt/keyrings
wget -qO- http://repo.runtel.ru/runtel.gpg | gpg --dearmor > /etc/apt/keyrings/runtel-archive-keyring.gpg
cp /etc/apt/keyrings/runtel-archive-keyring.gpg /etc/apt/trusted.gpg.d/
cat > /etc/apt/sources.list.d/runtel.sources << 'EOF'
Types: deb
URIs: http://repo.runtel.ru
Suites: trixie
Components: main dev
Signed-By: /etc/apt/keyrings/runtel-archive-keyring.gpg
EOF
apt update
```

---

## 📋 Полный скрипт установки OpenSIPS

### Debian 12 (Bookworm)

```bash
#!/bin/bash
# Полная установка OpenSIPS из репозитория runtel.ru

# 1. Добавление ключа
mkdir -p /etc/apt/keyrings
wget -O /etc/apt/keyrings/runtel.gpg http://repo.runtel.ru/runtel.gpg

# 2. Добавление репозитория
echo "deb [signed-by=/etc/apt/keyrings/runtel.gpg] http://repo.runtel.ru bookworm main" > /etc/apt/sources.list.d/runtel.list

# 3. Обновление и установка
apt update
apt install opensips -y

# 4. Запуск службы
systemctl enable --now opensips

echo "Установка завершена!"
```

### Debian 13 (Trixie)

```bash
#!/bin/bash
# Полная установка OpenSIPS из репозитория runtel.ru

# 1. Добавление ключа
mkdir -p /etc/apt/keyrings
wget -qO- http://repo.runtel.ru/runtel.gpg | gpg --dearmor > /etc/apt/keyrings/runtel-archive-keyring.gpg
cp /etc/apt/keyrings/runtel-archive-keyring.gpg /etc/apt/trusted.gpg.d/

# 2. Добавление репозитория (deb822 формат)
cat > /etc/apt/sources.list.d/runtel.sources << 'EOF'
Types: deb
URIs: http://repo.runtel.ru
Suites: trixie
Components: main dev
Signed-By: /etc/apt/keyrings/runtel-archive-keyring.gpg
EOF

# 3. Обновление и установка
apt update
apt install opensips -y

# 4. Запуск службы
systemctl enable --now opensips

echo "Установка завершена!"
```

---

## 📊 Сравнение Debian 12 и Debian 13

| Параметр | Debian 12 (Bookworm) | Debian 13 (Trixie) |
|----------|---------------------|-------------------|
| **Формат репозиториев** | `.list` (однострочный) | `.sources` (deb822) |
| **Имя дистрибутива** | `bookworm` | `trixie` |
| **Файл репозитория** | `/etc/apt/sources.list.d/runtel.list` | `/etc/apt/sources.list.d/runtel.sources` |
| **Структура записи** | `deb [signed-by=...] http://... bookworm main` | Многострочный формат с ключами |
| **Пример конфигурации** | `deb [signed-by=/etc/apt/keyrings/runtel.gpg] http://repo.runtel.ru bookworm main` | `Types: deb`<br>`URIs: http://repo.runtel.ru`<br>`Suites: trixie`<br>`Components: main dev`<br>`Signed-By: /etc/apt/keyrings/runtel-archive-keyring.gpg` |
| **Путь к ключу** | `/etc/apt/keyrings/runtel.gpg` | `/etc/apt/keyrings/runtel-archive-keyring.gpg` |
