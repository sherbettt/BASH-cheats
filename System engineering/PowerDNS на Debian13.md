Статьи с подсказками:
- [Настройка кластера PowerDNS на Rocky Linux](https://www.dmosk.ru/instruktions.php?object=powerdns-cluster)
- [altlinux.org/PowerDNS](https://www.altlinux.org/PowerDNS)
---------
<br/>



## 1. Прописать репозитории

Переходим на оф. ресурс https://repo.powerdns.com/ и смотрим примеры установок. В нашем случае — stable установка.

**PowerDNS Authoritative Server — version 5.0.X (stable)**

### Как правильно добавить репозиторий

Исходя из официальной инструкции на repo.powerdns.com:

```bash
# 1. Создайте файл репозитория
sudo bash -c 'cat > /etc/apt/sources.list.d/pdns.list <<EOF
deb [signed-by=/etc/apt/keyrings/auth-50-pub.asc] http://repo.powerdns.com/debian trixie-auth-50 main
EOF'

# 2. Создайте файл приоритетов (чтобы APT предпочитал пакеты PowerDNS)
sudo bash -c 'cat > /etc/apt/preferences.d/auth-50 <<EOF
Package: pdns-*
Pin: origin repo.powerdns.com
Pin-Priority: 600
EOF'

# 3. Установите ключ и обновитесь
sudo install -d /etc/apt/keyrings
curl https://repo.powerdns.com/FD380FBB-pub.asc | sudo tee /etc/apt/keyrings/auth-50-pub.asc
sudo apt update
```

### Репозиторий для pdns-recursor (опционально)

Для рекурсора также есть официальный репозиторий (версия 5.4.x stable):

```bash
# Добавьте в тот же /etc/apt/sources.list.d/pdns.list вторую строку
deb [signed-by=/etc/apt/keyrings/rec-54-pub.asc] http://repo.powerdns.com/debian trixie-rec-54 main

# И соответствующий файл приоритетов /etc/apt/preferences.d/rec-54
# и ключ для рекурсора (такой же ключ FD380FBB)
```

<details>
<summary>❗ Пример от вендора (оригинальная инструкция)</summary>

**PowerDNS Authoritative Server — version 5.0.X (stable)**

Create the file `/etc/apt/sources.list.d/pdns.list` with this content:
```
deb [signed-by=/etc/apt/keyrings/auth-50-pub.asc] http://repo.powerdns.com/debian trixie-auth-50 main
```

Put this in `/etc/apt/preferences.d/auth-50`:
```
Package: pdns-*
Pin: origin repo.powerdns.com
Pin-Priority: 600
```

Execute the following commands:
```
sudo install -d /etc/apt/keyrings; curl https://repo.powerdns.com/FD380FBB-pub.asc | sudo tee /etc/apt/keyrings/auth-50-pub.asc &&
sudo apt-get update &&
sudo apt-get install pdns-server
```
</details>

---

## 2. Установка зависимостей

```bash
# Поиск доступных пакетов
nala search pdns-server pdns-backend-pgsql pdns-recursor
```

### 2.1 Установка PostgreSQL

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl enable --now postgresql
```

### 2.2 Установка PowerDNS (из официального репозитория)

```bash
sudo apt install pdns-server pdns-backend-pgsql pdns-recursor
```

### 2.3 Создание базы данных и пользователя

```bash
sudo -u postgres psql <<EOF
CREATE USER pdns WITH PASSWORD 'ваш_пароль_БД';
CREATE DATABASE pdns_db WITH OWNER pdns;
\q
EOF
```

### 2.4 Импорт схемы PowerDNS

```bash
# Проверка наличия файла схемы
ls /usr/share/doc/pdns-backend-pgsql/schema.pgsql.sql

# Импорт схемы в базу данных
sudo -u postgres psql -d pdns_db -f /usr/share/doc/pdns-backend-pgsql/schema.pgsql.sql
```

### 2.5 Настройка PowerDNS Authoritative Server

```bash
sudo mcedit /etc/powerdns/pdns.conf
```

Минимальный пример конфигурации (`/etc/powerdns/pdns.conf`):

```ini
launch=gpgsql
gpgsql-host=localhost
gpgsql-user=pdns
gpgsql-password=ваш_пароль_БД
gpgsql-dbname=pdns_db

local-address=0.0.0.0
local-port=53

api=yes
api-key=ваш_секретный_api_ключ
webserver=yes
webserver-address=0.0.0.0
webserver-port=8081
webserver-allow-from=0.0.0.0/0
```

### 2.6 Настройка PowerDNS Recursor

```bash
sudo mcedit /etc/powerdns/recursor.conf
```

Минимальный пример конфигурации (`/etc/powerdns/recursor.conf`):

```ini
allow-from=0.0.0.0/0
local-address=0.0.0.0
local-port=53
forward-zones-recurse=.=1.1.1.1;8.8.8.8
setuid=pdns-recursor
```

### 2.7 Запуск и проверка статуса

```bash
# Запуск сервисов
sudo systemctl enable --now pdns pdns-recursor

# Проверка статуса
sudo systemctl status pdns
sudo systemctl status pdns-recursor

# Проверка работы DNS (для authoritative)
dig @localhost version.bind chaos txt

# Проверка работы рекурсора
dig @localhost google.com +short
```

---







