Статьи с подсказками:
- [Настройка кластера PowerDNS на Rocky Linux](https://www.dmosk.ru/instruktions.php?object=powerdns-cluster)
- [altlinux.org/PowerDNS](https://www.altlinux.org/PowerDNS)
---------
<br/>




## 0. Создаём контейнеры
pwdns1:
- IPv4/CIDR: 192.168.97.57/23
- Gateway(IPv4) 192.168.87.1

pwdns2 (клон контейнера pwdns1):
- IPv4/CIDR: 192.168.97.67/23
- Gateway(IPv4) 192.168.87.1

**Важно:** pwdns2 создан как клон pwdns1, поэтому на нём уже есть установленные пакеты PowerDNS и PostgreSQL с копией базы данных. Это основа для построения Master-Master репликации.

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

## 2. Установка зависимостей (выполняется на ОБЕИХ машинах)

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

### 2.3 Создание базы данных и пользователя (только на pwdns1, на pwdns2 пропустить)

```bash
sudo -u postgres psql <<EOF
CREATE USER pdns WITH PASSWORD '8X8runPwdnS';
CREATE DATABASE pdns_db WITH OWNER pdns;
\q
EOF
```

**На pwdns2 БД уже есть (клон), поэтому создавать не нужно.**

### 2.4 Импорт схемы PowerDNS (только на pwdns1)

```bash
# Проверка установки бэкенда
dpkg -l | grep pdns-backend-pgsql

# Файл схемы (симлинк на реальный файл)
ls -la /usr/share/doc/pdns-backend-pgsql/schema.pgsql.sql

# Импорт схемы в базу данных
sudo -u postgres psql -d pdns_db -f /usr/share/doc/pdns-backend-pgsql/schema.pgsql.sql
```

**На pwdns2 схема уже импортирована (клон), поэтому повторять не нужно.**

### 2.5 Настройка PowerDNS Authoritative Server (на обеих машинах)

```bash
sudo mcedit /etc/powerdns/pdns.conf
```

**Содержимое `/etc/powerdns/pdns.conf` на pwdns1:**

```ini
# Бэкенд PostgreSQL (локальная БД)
launch=gpgsql
gpgsql-host=localhost
gpgsql-user=pdns
gpgsql-password=8X8runPwdnS
gpgsql-dbname=pdns_db

# Сетевые настройки
local-address=0.0.0.0
local-port=53

# Настройки API и веб-интерфейса
api=yes
api-key=xK8mP9nQ2rT5wY7zA1bC3dE5fG7hJ9kL
webserver=yes
webserver-address=0.0.0.0
webserver-port=8081
webserver-allow-from=0.0.0.0/0

# Кластерные настройки (AXFR для второй машины)
allow-axfr-ips=192.168.97.67
```

**Содержимое `/etc/powerdns/pdns.conf` на pwdns2:**

```ini
# Бэкенд PostgreSQL (локальная БД)
launch=gpgsql
gpgsql-host=localhost
gpgsql-user=pdns
gpgsql-password=8X8runPwdnS
gpgsql-dbname=pdns_db

# Сетевые настройки
local-address=0.0.0.0
local-port=53

# Настройки API и веб-интерфейса
api=yes
api-key=xK8mP9nQ2rT5wY7zA1bC3dE5fG7hJ9kL
webserver=yes
webserver-address=0.0.0.0
webserver-port=8081
webserver-allow-from=0.0.0.0/0

# Кластерные настройки (AXFR для первой машины)
allow-axfr-ips=192.168.97.57
```

### 2.6 Настройка PowerDNS Recursor (опционально)

⚠️ **Для кластера Authoritative Server рекурсор не требуется.** Отключаем на обеих машинах:

```bash
sudo systemctl stop pdns-recursor
sudo systemctl disable pdns-recursor
```

### 2.7 Настройка прав доступа в PostgreSQL (только на pwdns1)

**Проблема:** После импорта схемы пользователь `pdns` не имеет прав на чтение таблиц.

**Решение:** Назначьте права пользователю `pdns` на все таблицы:

```bash
sudo -u postgres psql -d pdns_db <<EOF
GRANT ALL ON SCHEMA public TO pdns;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pdns;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO pdns;
ALTER TABLE domains OWNER TO pdns;
ALTER TABLE records OWNER TO pdns;
ALTER TABLE comments OWNER TO pdns;
ALTER TABLE domainmetadata OWNER TO pdns;
ALTER TABLE cryptokeys OWNER TO pdns;
ALTER TABLE tsigkeys OWNER TO pdns;
ALTER TABLE supermasters OWNER TO pdns;
\q
EOF
```

**На pwdns2 права уже настроены (клон).**

### 2.8 Настройка Master-Master репликации PostgreSQL

**Для чего:** Чтобы обе машины имели свои копии базы данных и синхронизировали изменения между собой. Это обеспечивает отказоустойчивость — при падении любой машины вторая продолжает работать.

#### Архитектура Master-Master кластера:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Master-Master кластер                               │
├─────────────────────────────────┬───────────────────────────────────────────┤
│           pwdns1                │              pwdns2                       │
│        192.168.97.57            │          192.168.97.67                    │
├─────────────────────────────────┼───────────────────────────────────────────┤
│ ┌─────────────────────────────┐ │ ┌─────────────────────────────────────┐   │
│ │     PostgreSQL (Master)     │ │ │        PostgreSQL (Master)          │   │
│ │         БД: pdns_db         │◄┼─┼────────►      БД: pdns_db            │   │
│ │   Пользователь: pdns        │ │ │        Пользователь: pdns            │   │
│ │   Репликация: replicator    │ │ │        Репликация: replicator        │   │
│ └─────────────────────────────┘ │ └─────────────────────────────────────┘   │
│ ┌─────────────────────────────┐ │ ┌─────────────────────────────────────┐   │
│ │       PowerDNS              │ │ │           PowerDNS                  │   │
│ │   (pdns-server)             │ │ │       (pdns-server)                 │   │
│ │   localhost:53              │ │ │       localhost:53                  │   │
│ └─────────────────────────────┘ │ └─────────────────────────────────────┘   │
└─────────────────────────────────┴───────────────────────────────────────────┘
```

#### Настройка на pwdns1 (192.168.97.57):

**Файл `/etc/postgresql/17/main/pg_hba.conf` на pwdns1:**

```conf
# PostgreSQL Client Authentication Configuration File
# ===================================================

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# Локальные подключения через Unix socket (только для postgres)
local   all             postgres                                peer

# Локальные подключения всех пользователей через Unix socket
local   all             all                                     peer

# Локальные IPv4 подключения (с этого же сервера)
host    all             all             127.0.0.1/32            scram-sha-256

# Локальные IPv6 подключения (с этого же сервера)
host    all             all             ::1/128                 scram-sha-256

# РЕПЛИКАЦИЯ: пользователь replicator может подключаться с pwdns2 для репликации
host    replication     replicator      192.168.97.67/32        md5

# ДОСТУП К БД: пользователь pdns может подключаться с pwdns2 (для работы PowerDNS)
host    pdns_db         pdns            192.168.97.67/32        md5

# ДОСТУП К БД: пользователь pdns может подключаться с pwdns1 (локально)
host    pdns_db         pdns            192.168.97.57/32        md5
```

**Настройка postgresql.conf на pwdns1:**

```bash
sudo mcedit /etc/postgresql/17/main/postgresql.conf
```

**Добавьте или раскомментируйте:**

```ini
# Слушаем все сетевые интерфейсы
listen_addresses = '*'

# Настройки репликации (WAL)
wal_level = replica
max_wal_senders = 10
wal_keep_size = 64MB
hot_standby = on

# Имя сервера для идентификации в репликации
cluster_name = 'pwdns1'
```

**Создание пользователя для репликации на pwdns1:**

```bash
sudo -u postgres psql <<EOF
CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'replica_pass';
GRANT ALL PRIVILEGES ON DATABASE pdns_db TO replicator;
\q
EOF
```

#### Настройка на pwdns2 (192.168.97.67):

**Файл `/etc/postgresql/17/main/pg_hba.conf` на pwdns2:**

```conf
# PostgreSQL Client Authentication Configuration File
# ===================================================

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# Локальные подключения через Unix socket (только для postgres)
local   all             postgres                                peer

# Локальные подключения всех пользователей через Unix socket
local   all             all                                     peer

# Локальные IPv4 подключения (с этого же сервера)
host    all             all             127.0.0.1/32            scram-sha-256

# Локальные IPv6 подключения (с этого же сервера)
host    all             all             ::1/128                 scram-sha-256

# РЕПЛИКАЦИЯ: пользователь replicator может подключаться с pwdns1 для репликации
host    replication     replicator      192.168.97.57/32        md5

# ДОСТУП К БД: пользователь pdns может подключаться с pwdns1 (для работы PowerDNS)
host    pdns_db         pdns            192.168.97.57/32        md5

# ДОСТУП К БД: пользователь pdns может подключаться с pwdns2 (локально)
host    pdns_db         pdns            192.168.97.67/32        md5
```

**Настройка postgresql.conf на pwdns2:**

```bash
sudo mcedit /etc/postgresql/17/main/postgresql.conf
```

**Добавьте или раскомментируйте:**

```ini
# Слушаем все сетевые интерфейсы
listen_addresses = '*'

# Настройки репликации (WAL)
wal_level = replica
max_wal_senders = 10
wal_keep_size = 64MB
hot_standby = on

# Имя сервера для идентификации в репликации
cluster_name = 'pwdns2'
```

**Создание пользователя для репликации на pwdns2:**

```bash
sudo -u postgres psql <<EOF
CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'replica_pass';
GRANT ALL PRIVILEGES ON DATABASE pdns_db TO replicator;
\q
EOF
```

#### Запуск репликации (настройка Master-Master):

**Остановите PostgreSQL на обеих машинах:**

```bash
sudo systemctl stop postgresql
```

**На pwdns2 очистите данные и скопируйте их с pwdns1:**

```bash
# На pwdns2:
sudo rm -rf /var/lib/postgresql/17/main/*
sudo -u postgres pg_basebackup -h 192.168.97.57 -D /var/lib/postgresql/17/main -U replicator -P -R
```

**На pwdns1 очистите данные и скопируйте их с pwdns2:**

```bash
# На pwdns1:
sudo rm -rf /var/lib/postgresql/17/main/*
sudo -u postgres pg_basebackup -h 192.168.97.67 -D /var/lib/postgresql/17/main -U replicator -P -R
```

**Запустите PostgreSQL на обеих машинах:**

```bash
sudo systemctl start postgresql
sudo systemctl status postgresql
```

#### Проверка репликации:

**На pwdns1:**
```bash
sudo -u postgres psql -c "SELECT client_addr, state FROM pg_stat_replication;"
```

**На pwdns2:**
```bash
sudo -u postgres psql -c "SELECT client_addr, state FROM pg_stat_replication;"
```

Ожидаемый вывод: обе машины должны видеть друг друга в состоянии `streaming`.

### 2.9 Запуск и проверка статуса PowerDNS

#### Запуск PowerDNS на обеих машинах:

```bash
sudo systemctl restart pdns
sudo systemctl status pdns
```

Ожидаемый вывод: `Active: active (running)`

#### Проверка API на обеих машинах:

```bash
curl -H "X-API-Key: xK8mP9nQ2rT5wY7zA1bC3dE5fG7hJ9kL" http://127.0.0.1:8081/api/v1/servers/localhost/zones
```

#### Проверка DNS на обеих машинах:

```bash
dig @127.0.0.1 version.bind chaos txt
```

### 2.10 Финальная проверка кластера

**Создайте тестовую зону на pwdns1:**

```bash
sudo pdnsutil create-zone cluster.test ns1.cluster.test
sudo pdnsutil add-record cluster.test test A 192.168.97.57
```

**Проверьте на pwdns1:**
```bash
dig @192.168.97.57 test.cluster.test +short
# Ожидаемый вывод: 192.168.97.57
```

**Проверьте на pwdns2 (зона должна появиться через репликацию):**
```bash
dig @192.168.97.67 test.cluster.test +short
# Ожидаемый вывод: 192.168.97.57
```

**Создайте запись на pwdns2 и проверьте на pwdns1:**

```bash
# На pwdns2:
sudo pdnsutil add-record cluster.test test2 A 192.168.97.67

# На pwdns1:
dig @192.168.97.57 test2.cluster.test +short
# Ожидаемый вывод: 192.168.97.67
```

### 2.11 Часто возникающие проблемы и их решение

| Проблема | Решение |
|----------|---------|
| `Connection failed` для security.debian.org | Игнорируйте, это не влияет на установку PowerDNS |
| `cannot access '/usr/share/doc/pdns-backend-pgsql/schema.pgsql.sql'` | Установите `pdns-backend-pgsql`: `sudo apt install pdns-backend-pgsql` |
| **`permission denied for table domains`** | **Выполните настройку прав из раздела 2.7** |
| **pdns не запускается, порт 53 занят** | **Отключите recursor**: `sudo systemctl disable --now pdns-recursor` |
| API не отвечает (`curl: (7) Connection refused`) | Проверьте, что `api=yes`, `webserver=yes`, нет дублей параметров |
| **Репликация не работает** | **Проверьте `pg_hba.conf` и `postgresql.conf` на обеих машинах** |
| **pg_basebackup: could not connect to server** | **Проверьте, что PostgreSQL запущен на источнике и открыт порт 5432** |

---

## Итог: схема Master-Master кластера

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Master-Master кластер                               │
├─────────────────────────────────┬───────────────────────────────────────────┤
│           pwdns1                │              pwdns2                       │
│        192.168.97.57            │          192.168.97.67                    │
├─────────────────────────────────┼───────────────────────────────────────────┤
│ ┌─────────────────────────────┐ │ ┌─────────────────────────────────────┐   │
│ │     PostgreSQL (Master)     │ │ │        PostgreSQL (Master)          │   │
│ │         БД: pdns_db         │◄┼─┼────────►      БД: pdns_db            │   │
│ │   Пользователь: pdns        │ │ │        Пользователь: pdns            │   │
│ │   Репликация: replicator    │ │ │        Репликация: replicator        │   │
│ └─────────────────────────────┘ │ └─────────────────────────────────────┘   │
│ ┌─────────────────────────────┐ │ ┌─────────────────────────────────────┐   │
│ │       PowerDNS              │ │ │           PowerDNS                  │   │
│ │   (pdns-server)             │ │ │       (pdns-server)                 │   │
│ │   - API на 8081             │ │ │       - API на 8081                 │   │
│ │   - allow-axfr-ips: 67     │ │ │       - allow-axfr-ips: 57          │   │
│ └─────────────────────────────┘ │ └─────────────────────────────────────┘   │
└─────────────────────────────────┴───────────────────────────────────────────┘
```

**Преимущества Master-Master кластера:**
- ✅ Высокая доступность — при падении одной машины вторая продолжает работу
- ✅ Автономность — каждая машина имеет полную копию данных
- ✅ Балансировка нагрузки — DNS-запросы можно распределять между серверами
- ✅ Отказоустойчивость — нет единой точки отказа (single point of failure)



