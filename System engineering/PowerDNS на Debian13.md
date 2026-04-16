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

---------
<br/>


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
CREATE USER pdns WITH PASSWORD 'DP_Pass';
CREATE DATABASE pdns_db WITH OWNER pdns;
GRANT ALL PRIVILEGES ON DATABASE pdns_db TO pdns;
\q
EOF
```
<!-- 8X8runPwdnS -->

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

Как сгенерировать ключ
```
# Рекомендуемый способ
openssl rand -base64 32

# Или так
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
```

```ini
# Бэкенд PostgreSQL (локальная БД)
launch=gpgsql
gpgsql-host=localhost
gpgsql-user=pdns
gpgsql-password=DB_Pass
gpgsql-dbname=pdns_db

# Сетевые настройки
local-address=0.0.0.0
local-port=53

# Настройки API и веб-интерфейса
api=yes
api-key=API_KEY_LONG
webserver=yes
webserver-address=0.0.0.0
webserver-port=8081
webserver-allow-from=0.0.0.0/0

# Кластерные настройки (AXFR для второй машины)
allow-axfr-ips=192.168.97.67
```
<!-- gpgsql-password=8X8runPwdnS -->
<!-- api-key=xK8mP9nQ2rT5wY7zA1bC3dE5fG7hJ9kL -->

**Содержимое `/etc/powerdns/pdns.conf` на pwdns2:**

```ini
# Бэкенд PostgreSQL (локальная БД)
launch=gpgsql
gpgsql-host=localhost
gpgsql-user=pdns
gpgsql-password=DB_Pass  # аналогично/одинаково на первом сервере
gpgsql-dbname=pdns_db

# Сетевые настройки
local-address=0.0.0.0
local-port=53

# Настройки API и веб-интерфейса
api=yes
api-key=API_KEY_LONG  # аналогично/одинаково на первом сервере
webserver=yes
webserver-address=0.0.0.0
webserver-port=8081
webserver-allow-from=0.0.0.0/0

# Кластерные настройки (AXFR для первой машины)
allow-axfr-ips=192.168.97.57
```
<!-- gpgsql-password=8X8runPwdnS -->
<!-- api-key=xK8mP9nQ2rT5wY7zA1bC3dE5fG7hJ9kL -->


### 2.6 Настройка PowerDNS Recursor (опционально)

⚠️ **Для кластера Authoritative Server рекурсор не требуется.** Отключаем на обеих машинах:

```bash
sudo systemctl stop pdns-recursor
sudo systemctl disable pdns-recursor
```

### 2.7 Настройка прав доступа в PostgreSQL (только на pwdns1)

**Проблема:** После импорта схемы пользователь `pdns` не имеет прав на чтение таблиц, что вызывает ошибку:
```
ERROR: permission denied for table domains
```

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

---------
<br/>


## 2.8 Настройка Master-Master репликации PostgreSQL (ПОЛНЫЙ ПРОТОКОЛ)

**Для чего:** Чтобы обе машины имели свои копии базы данных и синхронизировали изменения между собой. Это обеспечивает отказоустойчивость — при падении любой машины вторая продолжает работу.

### Архитектура Master-Master кластера:

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

### Шаг 1: Настройка конфигурационных файлов PostgreSQL

#### На pwdns1 (192.168.97.57):

**Файл `/etc/postgresql/17/main/pg_hba.conf` (добавляем разрешения для pwdns2):**
```bash
sudo mcedit /etc/postgresql/17/main/pg_hba.conf
```

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
# Для pg_basebackup (подключается к БД postgres)
host    postgres        replicator      192.168.97.67/32        md5
```

**Файл `/etc/postgresql/17/main/postgresql.conf` (раскомментировать или добавить):**
```bash
sudo mcedit /etc/postgresql/17/main/postgresql.conf
```

```ini
listen_addresses = '*'
wal_level = replica
max_wal_senders = 10
wal_keep_size = 64MB
hot_standby = on
cluster_name = 'pwdns1'
```

#### На pwdns2 (192.168.97.67):

**Файл `/etc/postgresql/17/main/pg_hba.conf` (добавляем разрешения для pwdns1):**
```bash
sudo mcedit /etc/postgresql/17/main/pg_hba.conf
```

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

**Файл `/etc/postgresql/17/main/postgresql.conf`:**
```bash
sudo mcedit /etc/postgresql/17/main/postgresql.conf
```

```ini
listen_addresses = '*'
wal_level = replica
max_wal_senders = 10
wal_keep_size = 64MB
hot_standby = on
cluster_name = 'pwdns2'
```

### Шаг 2: Перезапуск PostgreSQL после изменения конфигов

```bash
# На обеих машинах:
sudo pg_ctlcluster 17 main restart
```

### Шаг 3: Создание пользователя для репликации

**На обеих машинах:**
```bash
sudo -u postgres psql <<EOF
CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'replica_pass';
GRANT ALL PRIVILEGES ON DATABASE pdns_db TO replicator;
\q
EOF
```

### Шаг 4: Диагностика и устранение проблем с паролем

**Проверка существующего пароля пользователя replicator на pwdns1:**
```bash
root@pwdns1:~# sudo -u postgres psql -c "SELECT rolname, rolpassword FROM pg_authid WHERE rolname='replicator';"
```
**Вывод:**
```
  rolname   |                                                              rolpassword                                                              
------------+---------------------------------------------------------------------------------------------------------------------------------------
 replicator | SCRAM-SHA-256$4096:OKaBFr/Nxo7E57u91Tmg1g==$iPAx0nvABPS/NsY3II53vtwkIJMeA/dEwNzjDAioZbw=:4BrNPDw0rIhNWv6B9s6I0EaYbKnzadyrGmlKjynWn68=
(1 row)
```

**Сброс пароля пользователя replicator (если неизвестен или не подходит):**
```bash
root@pwdns1:~# sudo -u postgres psql <<EOF
ALTER USER replicator WITH PASSWORD 'replica_pass';
\q
EOF
```
**Вывод:**
```
ALTER ROLE
```

### Шаг 5: Проверка подключения к БД с pwdns2

**На pwdns2 проверяем, что можем подключиться к БД postgres на pwdns1 пользователем replicator:**
```bash
root@pwdns2:~# PGPASSWORD=replica_pass psql -h 192.168.97.57 -U replicator -d postgres -c "SELECT 1"
```
**Вывод:**
```
 ?column? 
----------
        1
(1 row)
```
✅ Подключение успешно!

### Шаг 6: Первая попытка настройки pwdns2 как реплики pwdns1 (с ошибкой)

```bash
root@pwdns2:~# sudo pg_ctlcluster 17 main stop
root@pwdns2:~# sudo rm -rf /var/lib/postgresql/17/main/*
root@pwdns2:~# PGPASSWORD=replica_pass sudo -u postgres pg_basebackup -h 192.168.97.57 -D /var/lib/postgresql/17/main -U replicator -P -R
```
**Ошибка:**
```
pg_basebackup: error: connection to server at "192.168.97.57", port 5432 failed: FATAL: password authentication failed for user "replicator"
```
**Причина:** Пароль не совпадал. После сброса пароля (Шаг 4) ошибка должна исчезнуть.

### Шаг 7: Успешная настройка pwdns2 как реплики pwdns1

```bash
root@pwdns2:~# sudo pg_ctlcluster 17 main stop
root@pwdns2:~# sudo rm -rf /var/lib/postgresql/17/main/*
root@pwdns2:~# PGPASSWORD=replica_pass sudo -u postgres pg_basebackup -h 192.168.97.57 -D /var/lib/postgresql/17/main -U replicator -P -R
```
**Вывод (успешный):**
```
Password: 
31229/31229 kB (100%), 1/1 tablespace
```

```bash
root@pwdns2:~# sudo pg_ctlcluster 17 main start
```

### Шаг 8: Проверка репликации после первого направления

**На pwdns2 репликация ещё не активна (нужно время для установки соединения):**
```bash
root@pwdns2:~# sudo -u postgres psql -c "SELECT client_addr, state FROM pg_stat_replication;"
```
**Вывод:**
```
 client_addr | state 
-------------+-------
(0 rows)
```

**Через несколько секунд репликация появляется:**
```bash
root@pwdns2:~# sudo -u postgres psql -c "SELECT client_addr, state FROM pg_stat_replication;"
```
**Вывод:**
```
  client_addr  |   state   
---------------+-----------
 192.168.97.57 | streaming
(1 row)
```

### Шаг 9: Настройка pwdns1 как реплики pwdns2 (обратное направление)

```bash
root@pwdns1:~# sudo pg_ctlcluster 17 main stop
root@pwdns1:~# sudo rm -rf /var/lib/postgresql/17/main/*
root@pwdns1:~# PGPASSWORD=replica_pass sudo -u postgres pg_basebackup -h 192.168.97.67 -D /var/lib/postgresql/17/main -U replicator -P -R
```
**Вывод (успешный):**
```
Password: 
31230/31230 kB (100%), 1/1 tablespace
```

```bash
root@pwdns1:~# sudo pg_ctlcluster 17 main start
```

### Шаг 10: Финальная проверка репликации на обеих машинах

**На pwdns1:**
```bash
root@pwdns1:~# sudo -u postgres psql -c "SELECT client_addr, state FROM pg_stat_replication;"
```
**Вывод:**
```
  client_addr  |   state   
---------------+-----------
 192.168.97.67 | streaming
(1 row)
```

**На pwdns2:**
```bash
root@pwdns2:~# sudo -u postgres psql -c "SELECT client_addr, state FROM pg_stat_replication;"
```
**Вывод:**
```
  client_addr  |   state   
---------------+-----------
 192.168.97.57 | streaming
(1 row)
```

✅ **Master-Master репликация PostgreSQL полностью настроена!** Обе машины видят друг друга в состоянии `streaming`.

### Шаг 11: Перезагрузка и проверка сохранения репликации

**Перезагрузка PostgreSQL на обеих машинах:**
```bash
# На обеих машинах:
sudo systemctl restart postgresql
```

**Проверка после перезагрузки (на обеих машинах):**
```bash
sudo -u postgres psql -c "SELECT client_addr, state FROM pg_stat_replication;"
```
Ожидаемый вывод: обе машины снова видят друг друга в состоянии `streaming`.

---------
<br/>


## 2.9 Запуск и проверка статуса PowerDNS

#### Запуск PowerDNS на обеих машинах:

```bash
sudo systemctl restart pdns
sudo systemctl status pdns
```

Ожидаемый вывод: `Active: active (running)`

#### Проверка API на обеих машинах:

```bash
curl -H "X-API-Key: API_KEY_LONG" http://127.0.0.1:8081/api/v1/servers/localhost/zones
```
<!-- "X-API-Key: xK8mP9nQ2rT5wY7zA1bC3dE5fG7hJ9kL" -->

#### Проверка DNS на обеих машинах:

```bash
dig @127.0.0.1 version.bind chaos txt
```
---------
<br/>


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
| **PostgreSQL слушает только 127.0.0.1:5432** | **Раскомментируйте `listen_addresses = '*'` в postgresql.conf и перезапустите** |
| **pg_basebackup: no pg_hba.conf entry** | **Добавьте в pg_hba.conf строки для `replication` и `postgres` БД** |
| **pg_basebackup: password authentication failed** | **Сбросьте пароль: `ALTER USER replicator WITH PASSWORD 'replica_pass';`** |
| **pg_basebackup: connection to server failed** | **Проверьте, что PostgreSQL запущен: `pg_lsclusters` и порт: `ss -tulpn \| grep 5432`** |
| **Репликация не появляется сразу после настройки** | **Подождите 10-30 секунд, репликация устанавливается не мгновенно** |

---------
<br/>


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

---------
<br/>


## 2.12 Установка PowerDNS-Admin на оба сервера

### 2.12.1 Установка системных зависимостей

**На pwdns1 и pwdns2:**

```bash
# Обновление списка пакетов
sudo apt update

# Установка Python и инструментов разработки
sudo apt install -y python3-dev python3-venv python3-pip git build-essential

# Установка Node.js 20.x и Yarn
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g yarn

# Установка системных библиотек для PostgreSQL и LDAP
sudo apt install -y libpq-dev libldap2-dev libsasl2-dev libssl-dev
sudo apt install -y libxml2-dev libxslt1-dev libxmlsec1-dev libffi-dev

# Проверка версий
python3 --version
node --version
yarn --version
```

### 2.12.2 Клонирование репозитория и создание venv

**На pwdns1 и pwdns2:**

```bash
# Переход в директорию /opt
cd /opt

# Клонирование репозитория PowerDNS-Admin
sudo git clone https://github.com/PowerDNS-Admin/PowerDNS-Admin.git

# Переименование директории
sudo mv PowerDNS-Admin powerdns-admin

# Переход в директорию
cd powerdns-admin

# Создание виртуального окружения Python
sudo python3 -m venv venv

# Установка прав
sudo chown -R $USER:$USER /opt/powerdns-admin
```

### 2.12.3 Установка Python-пакетов

**На pwdns1 и pwdns2:**

```bash
# Активация виртуального окружения
source venv/bin/activate

# Обновление pip
pip install --upgrade pip

# Установка основных пакетов
pip install Flask==2.2.5
pip install Werkzeug==2.3.0
pip install Flask-Login==0.6.2
pip install Flask-SQLAlchemy==2.5.1
pip install Flask-Migrate==2.5.3
pip install Flask-Mail==0.9.1
pip install Flask-Assets==2.0
pip install Flask-SeaSurf==1.1.1
pip install Flask-Session==0.4.0
pip install Flask-SSLify==0.1.5
pip install Jinja2==3.1.3
pip install PyYAML==6.0.1
pip install SQLAlchemy==1.4.51
pip install bcrypt==4.1.2
pip install cryptography==42.0.2

# Установка пакетов для PostgreSQL
pip install psycopg2-binary==2.9.9

# Установка дополнительных модулей
pip install pyotp==2.9.0
pip install qrcode==8.2
pip install Pillow==12.2.0
pip install python-ldap==3.4.5
pip install zxcvbn==4.5.0
pip install pytimeparse==1.1.8
pip install python-dateutil
pip install email-validator
pip install bravado
pip install flask-babel
pip install flask-cors
pip install humanize
pip install gunicorn==20.1.0
pip install setuptools==65.5.0

# Проверка установленных пакетов
pip list | grep -E "Flask|psycopg|gunicorn"
```

### 2.12.4 Решение проблем с совместимостью Python 3.13

**На pwdns1 и pwdns2:**

```bash
# Проблема 1: Отсутствие модуля pkg_resources
# Создаём заглушку
cat > venv/lib/python3.13/site-packages/pkg_resources.py <<'EOF'
"""Fake pkg_resources module for compatibility."""
import sys
import os

def get_distribution(dist_name):
    class FakeDist:
        version = "0.0.0"
        project_name = dist_name
    return FakeDist()

def require(requirements):
    pass

def iter_entry_points(group, name=None):
    return []

def load_entry_point(dist, group, name):
    return None

def resource_string(package_or_requirement, resource_name):
    return b""

def resource_filename(package_or_requirement, resource_name):
    return ""

def resource_stream(package_or_requirement, resource_name):
    import io
    return io.BytesIO()

def get_provider(module_or_requirement):
    return None

def declare_namespace(package):
    pass

def fixup_namespace_packages(path_item, parent=None):
    pass

def register_finder(importer, finder):
    pass

def find_on_path(module):
    return None

def get_default_cache():
    return os.path.join(os.path.dirname(__file__), '.cache')

class Distribution:
    pass

class WorkingSet:
    def __init__(self):
        self.by_key = {}
    def add_entry(self, entry):
        pass

__all__ = [
    'get_distribution', 'require', 'iter_entry_points', 
    'load_entry_point', 'resource_string', 'resource_filename',
    'resource_stream', 'get_provider', 'declare_namespace',
    'fixup_namespace_packages', 'register_finder', 'find_on_path',
    'get_default_cache', 'Distribution', 'WorkingSet'
]
EOF

# Проблема 2: Отсутствие модуля imghdr (удалён в Python 3.13)
cat > venv/lib/python3.13/site-packages/imghdr.py <<'EOF'
"""Fake imghdr module for Python 3.13 compatibility."""
def what(file, h=None):
    return None
EOF

# Проверка
python -c "import pkg_resources; print('pkg_resources OK')"
python -c "import imghdr; print('imghdr OK')"
```

### 2.12.5 Сборка статических файлов

**На pwdns1 и pwdns2:**

```bash
# Установка зависимостей через Yarn
cd /opt/powerdns-admin
yarn install --pure-lockfile

# Сборка статических ассетов через Flask
export FLASK_APP=powerdnsadmin/__init__.py
export FLASK_CONF=/opt/powerdns-admin/configs/production.py
flask assets build

# Проверка создания файлов
ls -la powerdnsadmin/static/generated/
```

### 2.12.6 Настройка конфигурации

**На pwdns1:**

```bash
# Копирование примера конфигурации
cd /opt/powerdns-admin
cp configs/production.py.sample configs/production.py

# Редактирование конфигурации
nano configs/production.py
```

**Содержимое `configs/production.py` на pwdns1:**

***`SECRET_KEY`*** должны быь уникальным для разных серверов.
```python
import os

# Секретный ключ (сгенерируйте свой)
SECRET_KEY = 'SECRET_KEY1'

# Используем SQLite для простоты
SQLA_DB_TYPE = 'sqlite'
SQLA_DB_NAME = '/var/lib/powerdns-admin/pdnsadmin.db'

# Подключение к PowerDNS API (локальный)
PDNS_API_URL = 'http://127.0.0.1:8081'
PDNS_API_KEY = 'xK8mP9nQ2rT5wY7zA1bC3dE5fG7hJ9kL'
PDNS_VERSION = '5.0'

# Настройки веб-сервера
BIND_ADDRESS = '0.0.0.0'
PORT = 9191
```
<!-- SECRET_KEY = 'C1vD9kraoNdZP3CL9QTc1kpiVZ8rflm4fuuhLwAi' -->

**На pwdns2 (аналогично, но с другим SECRET_KEY):**

```bash
cd /opt/powerdns-admin
cp configs/production.py.sample configs/production.py
nano configs/production.py
```

**Содержимое `configs/production.py` на pwdns2:**

```python
import os

# Секретный ключ (другой, чем на pwdns1)
SECRET_KEY = 'SECRET_KEY2'

# Используем SQLite для простоты
SQLA_DB_TYPE = 'sqlite'
SQLA_DB_NAME = '/var/lib/powerdns-admin/pdnsadmin.db'

# Подключение к PowerDNS API (локальный)
PDNS_API_URL = 'http://127.0.0.1:8081'
PDNS_API_KEY = 'xK8mP9nQ2rT5wY7zA1bC3dE5fG7hJ9kL'
PDNS_VERSION = '5.0'

# Настройки веб-сервера
BIND_ADDRESS = '0.0.0.0'
PORT = 9191
```
<!-- SECRET_KEY = 'RC1DtMvzJCSK2pLmX6lOF/Wskz/Ur/rfdLnRYOqX' -->


### 2.12.7 Создание директории для БД и инициализация

**На pwdns1 и pwdns2:**

```bash
# Создание директории для БД
sudo mkdir -p /var/lib/powerdns-admin
sudo chown -R www-data:www-data /var/lib/powerdns-admin

# Инициализация базы данных
cd /opt/powerdns-admin
source venv/bin/activate
flask db upgrade
deactivate

# Проверка создания БД
ls -la /var/lib/powerdns-admin/
```

**Ожидаемый вывод:**
```
total 16
drwxr-xr-x  2 www-data www-data 4096 Apr 15 13:26 .
drwxr-xr-x 31 root     root     4096 Apr 15 13:26 ..
-rw-r--r--  1 www-data www-data 8192 Apr 15 13:26 pdnsadmin.db
```

### 2.12.8 Создание systemd сервиса

**На pwdns1 и pwdns2:**

```bash
# Создание файла сервиса
sudo tee /etc/systemd/system/powerdns-admin.service <<'EOF'
[Unit]
Description=PowerDNS-Admin Web Interface
After=network.target pdns.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/opt/powerdns-admin
Environment="FLASK_CONF=/opt/powerdns-admin/configs/production.py"
Environment="FLASK_APP=powerdnsadmin/__init__.py"
ExecStart=/opt/powerdns-admin/venv/bin/gunicorn --bind 0.0.0.0:9191 'powerdnsadmin:create_app()'
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Перезагрузка systemd
sudo systemctl daemon-reload

# Включение автозапуска
sudo systemctl enable powerdns-admin

# Запуск сервиса
sudo systemctl start powerdns-admin

# Проверка статуса
sudo systemctl status powerdns-admin
```

### 2.12.9 Проверка работы сервиса

**На pwdns1 и pwdns2:**

```bash
# Проверка, что порт слушается
ss -tulpn | grep 9191

# Ожидаемый вывод:
# tcp   LISTEN 0      2048         0.0.0.0:9191      0.0.0.0:*    users:(("gunicorn",pid=...,fd=...))

# Проверка через curl
curl -v http://127.0.0.1:9191

# Ожидаемый вывод (редирект на /login):
# < HTTP/1.1 302 FOUND
# < Location: /login
```

### 2.12.10 Диагностика и устранение проблем

#### Проблема: Empty reply from server (пустой ответ)

**Симптомы:**
```bash
curl -v http://127.0.0.1:9191
# * Connected to 127.0.0.1 (127.0.0.1) port 9191
# * Empty reply from server
# curl: (52) Empty reply from server
```

**Логи:**
```bash
sudo journalctl -u powerdns-admin -f --since "1 minute ago"
# sqlite3.OperationalError: attempt to write a readonly database
```

**Решение:**
```bash
# Остановка сервиса
sudo systemctl stop powerdns-admin

# Удаление кэша
sudo rm -rf /opt/powerdns-admin/powerdnsadmin/static/.webassets-cache

# Исправление прав
sudo chown -R www-data:www-data /opt/powerdns-admin
sudo chown -R www-data:www-data /var/lib/powerdns-admin
sudo chmod 755 /opt/powerdns-admin
sudo chmod 755 /var/lib/powerdns-admin
sudo chmod 644 /var/lib/powerdns-admin/pdnsadmin.db
sudo chmod -R 755 /opt/powerdns-admin/powerdnsadmin/static

# Пересоздание БД
sudo rm -f /var/lib/powerdns-admin/pdnsadmin.db
cd /opt/powerdns-admin
source venv/bin/activate
flask db upgrade
deactivate

# Пересборка статики
cd /opt/powerdns-admin
source venv/bin/activate
export FLASK_APP=powerdnsadmin/__init__.py
export FLASK_CONF=/opt/powerdns-admin/configs/production.py
flask assets build
deactivate

# Запуск сервиса
sudo systemctl start powerdns-admin
sudo systemctl status powerdns-admin
```

#### Проблема: Ошибка "No module named 'pkg_resources'"

**Решение:**
```bash
cd /opt/powerdns-admin
source venv/bin/activate
pip install setuptools==65.5.0
deactivate
```

#### Проблема: Ошибка "No module named 'imghdr'"

**Решение:**
```bash
cat > /opt/powerdns-admin/venv/lib/python3.13/site-packages/imghdr.py <<'EOF'
def what(file, h=None):
    return None
EOF
```

### 2.12.11 Создание первого пользователя

**В браузере:**

1. Откройте `http://IP_сервера:9191`
2. Нажмите **"Create an account"**
3. Заполните поля:
   - **Username:** `admin`
   - **Email:** `admin@local.host`
   - **Password:** `YouR_Copmlex_PASS`  <!-- pEhBYZFjDGEa -->
4. Нажмите **"Register"**
5. Первый созданный пользователь автоматически получает права администратора

### 2.12.12 Проверка подключения к PowerDNS API

**В веб-интерфейсе:**

1. Войдите как `admin`
2. Перейдите в **"Admin"** → **"Settings"**
3. Проверьте, что подключение к API отображается зелёным индикатором
4. Если нет — проверьте в файле `configs/production.py`:
   - `PDNS_API_URL = 'http://127.0.0.1:8081'`
   - `PDNS_API_KEY = 'API_KEY_LONG'`

--------
<br/>


## 2.13 Миграция PowerDNS-Admin с SQLite на общий PostgreSQL

**Для чего:** Изначально PowerDNS-Admin использует SQLite на каждом сервере отдельно. Это приводит к тому, что пользователи, созданные на pwdns1, не видны на pwdns2, и наоборот. Миграция на общую PostgreSQL БД позволяет иметь единые учётные записи и настройки на обоих серверах.

### 2.13.1 Создание базы данных PostgreSQL для PowerDNS-Admin (на pwdns1)

```bash
# На pwdns1 создаём БД и пользователя для админки
sudo -u postgres psql <<EOF
CREATE USER pdns_admin WITH PASSWORD 'pEhBYZFjDGEa';
CREATE DATABASE pdns_admin_db WITH OWNER pdns_admin;
GRANT ALL PRIVILEGES ON DATABASE pdns_admin_db TO pdns_admin;
\q
EOF

# Проверяем создание
sudo -u postgres psql -d pdns_admin_db -c "\l"
```

### 2.13.2 Остановка сервисов на обеих машинах

```bash
# На pwdns1 и pwdns2:
sudo systemctl stop powerdns-admin
```

### 2.13.3 Изменение конфигурации на pwdns1

```bash
# Создаём директорию instance (если ещё не создана)
sudo mkdir -p /opt/powerdns-admin/instance

# Редактируем конфиг
sudo mcedit /opt/powerdns-admin/instance/config.py
```

**Содержимое `/opt/powerdns-admin/instance/config.py` на pwdns1:**

```python
import os

SECRET_KEY = 'C1vD9kraoNdZP3CL9QTc1kpiVZ8rflm4fuuhLwAi'

# PostgreSQL
SQLA_DB_TYPE = 'postgresql'
SQLA_DB_HOST = '127.0.0.1'
SQLA_DB_PORT = '5432'
SQLA_DB_USER = 'pdns_admin'
SQLA_DB_PASSWORD = 'pEhBYZFjDGEa'
SQLA_DB_NAME = 'pdns_admin_db'

# PowerDNS API
PDNS_API_URL = 'http://127.0.0.1:8081'
PDNS_API_KEY = 'xK8mP9nQ2rT5wY7zA1bC3dE5fG7hJ9kL'
PDNS_VERSION = '5.0'

# Веб-сервер
BIND_ADDRESS = '0.0.0.0'
PORT = 9191

# ДОБАВЬТЕ ЭТИ НАСТРОЙКИ:
# Отключаем email верификацию (для теста)
MAIL_SERVER = 'localhost'
MAIL_PORT = 25
MAIL_USE_TLS = False
MAIL_USE_SSL = False
MAIL_DEFAULT_SENDER = 'noreply@local.host'

# Настройки сессий
SESSION_TYPE = 'filesystem'
PERMANENT_SESSION_LIFETIME = 86400  # 24 часа

# Безопасность
WTF_CSRF_ENABLED = True
WTF_CSRF_TIME_LIMIT = 3600

# Регистрация
SIGNUP_ENABLED = True
EMAIL_CONFIRMATION = False  # Отключаем подтверждение email

# Отключаем CAPTCHA
CAPTCHA_ENABLE = False
LOGIN_CAPTCHA_ENABLE = False
REGISTER_CAPTCHA_ENABLE = False
SIGNUP_ENABLED = True

# для настройки NGINX
#PREFERRED_URL_SCHEME = 'https'

```

### 2.13.4 Изменение конфигурации на pwdns2

```bash
# Создаём директорию instance
sudo mkdir -p /opt/powerdns-admin/instance

# Редактируем конфиг
sudo mcedit /opt/powerdns-admin/instance/config.py
```

**Содержимое `/opt/powerdns-admin/instance/config.py` на pwdns2:**

```python
import os

SECRET_KEY = 'RC1DtMvzJCSK2pLmX6lOF/Wskz/Ur/rfdLnRYOqX'  # другой ключ

# PostgreSQL (подключаемся к БД на pwdns1)
SQLA_DB_TYPE = 'postgresql'
SQLA_DB_HOST = '192.168.97.57'  # IP адрес pwdns1
SQLA_DB_PORT = '5432'
SQLA_DB_USER = 'pdns_admin'
SQLA_DB_PASSWORD = 'pEhBYZFjDGEa'
SQLA_DB_NAME = 'pdns_admin_db'

# PowerDNS API (локальный на pwdns2)
PDNS_API_URL = 'http://127.0.0.1:8081'
PDNS_API_KEY = 'xK8mP9nQ2rT5wY7zA1bC3dE5fG7hJ9kL'
PDNS_VERSION = '5.0'

# Веб-сервер
BIND_ADDRESS = '0.0.0.0'
PORT = 9191

# Настройки
MAIL_SERVER = 'localhost'
MAIL_PORT = 25
MAIL_USE_TLS = False
MAIL_USE_SSL = False
MAIL_DEFAULT_SENDER = 'noreply@local.host'

SESSION_TYPE = 'filesystem'
PERMANENT_SESSION_LIFETIME = 86400

WTF_CSRF_ENABLED = True
WTF_CSRF_TIME_LIMIT = 3600

SIGNUP_ENABLED = True
EMAIL_CONFIRMATION = False

CAPTCHA_ENABLE = False
LOGIN_CAPTCHA_ENABLE = False
REGISTER_CAPTCHA_ENABLE = False

```

### 2.13.5 Увеличение длины поля password (решение проблемы с хэшем)

**Проблема:** Хэш пароля в PostgreSQL может быть длиннее 64 символов, что вызывает ошибку `value too long for type character varying(64)`.

**Решение:** Увеличиваем длину поля password до 255 символов:

```bash
# На pwdns1 (БД ещё пустая, но увеличим для будущих пользователей)
sudo -u postgres psql -d pdns_admin_db -c "ALTER TABLE \"user\" ALTER COLUMN password TYPE VARCHAR(255);"
```

### 2.13.6 Инициализация базы данных

**На pwdns1 (создание таблиц):**

```bash
cd /opt/powerdns-admin
source venv/bin/activate
export FLASK_APP=powerdnsadmin/__init__.py
export FLASK_CONF=/opt/powerdns-admin/instance/config.py
flask db upgrade
deactivate
```

**На pwdns2 (связывание с существующей БД):**

```bash
cd /opt/powerdns-admin
source venv/bin/activate
export FLASK_APP=powerdnsadmin/__init__.py
export FLASK_CONF=/opt/powerdns-admin/instance/config.py
flask db upgrade
deactivate
```

### 2.13.7 Настройка PostgreSQL для удалённого доступа (на pwdns1)

Чтобы pwdns2 мог подключаться к БД на pwdns1:

```bash
# На pwdns1 добавляем разрешение в pg_hba.conf
sudo mcedit /etc/postgresql/17/main/pg_hba.conf
```

**Добавьте строку:**
```conf
# Разрешаем подключения для PowerDNS-Admin с pwdns2
host    pdns_admin_db     pdns_admin     192.168.97.67/32        md5
```

```bash
# Перезапускаем PostgreSQL
sudo pg_ctlcluster 17 main restart
```

### 2.13.8 Проверка подключения с pwdns2

```bash
# На pwdns2:
PGPASSWORD=pEhBYZFjDGEa psql -h 192.168.97.57 -U pdns_admin -d pdns_admin_db -c "SELECT 1"
```

**Ожидаемый вывод:**
```
 ?column? 
----------
        1
(1 row)
```

### 2.13.9 Запуск сервисов и создание пользователя

```bash
# На обеих машинах:
sudo systemctl restart powerdns-admin
sudo systemctl status powerdns-admin
```

**Создание пользователя admin (через веб-интерфейс):**

1. Откройте `http://192.168.97.57:9191`
2. Нажмите **"Create an account"**
3. Заполните поля:
   - **Username:** `admin`
   - **Email:** `admin@local.host`
   - **Password:** `pEhBYZFjDGEa`
4. Нажмите **"Register"**

**Важно:** Пользователь создаётся через веб-форму, а не через командную строку, из-за особенностей хэширования паролей в PowerDNS-Admin.

### 2.13.10 Решение возможных проблем при регистрации

| Проблема | Решение |
|----------|---------|
| `Invalid CAPTCHA answer` | Добавить в `config.py`: `CAPTCHA_ENABLE = False`, `LOGIN_CAPTCHA_ENABLE = False`, `REGISTER_CAPTCHA_ENABLE = False` |
| `Invalid salt` | Увеличить длину поля password: `ALTER TABLE "user" ALTER COLUMN password TYPE VARCHAR(255);` |
| `'NoneType' object has no attribute 'id'` | Создать пользователя через веб-форму, а не через SQL |

### 2.13.11 Финальная проверка

1. Войдите на `http://192.168.97.57:9191` с паролем `pEhBYZFjDGEa`
2. Войдите на `http://192.168.97.67:9191` с тем же паролем
3. Создайте зону на любом сервере — она должна появиться на обоих

---

## Итоговая схема после миграции

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PowerDNS Master-Master кластер                       │
├─────────────────────────────────┬───────────────────────────────────────────┤
│           pwdns1                │              pwdns2                       │
│        192.168.97.57            │          192.168.97.67                    │
├─────────────────────────────────┼───────────────────────────────────────────┤
│ ┌─────────────────────────────┐ │ ┌─────────────────────────────────────┐   │
│ │     PostgreSQL 17 (master)  │ │ │     PostgreSQL 17 (master)          │   │
│ │         БД: pdns_db         │◄┼─┼────────►      БД: pdns_db            │   │
│ │   Репликация: replicator    │ │ │   Репликация: replicator            │   │
│ └─────────────────────────────┘ │ └─────────────────────────────────────┘   │
│ ┌─────────────────────────────┐ │ ┌─────────────────────────────────────┐   │
│ │   PowerDNS Authoritative    │ │ │   PowerDNS Authoritative            │   │
│ │   (порт 53, UDP/TCP)        │ │ │   (порт 53, UDP/TCP)                │   │
│ │   API (порт 8081)           │ │ │   API (порт 8081)                   │   │
│ └─────────────────────────────┘ │ └─────────────────────────────────────┘   │
│ ┌─────────────────────────────┐ │ ┌─────────────────────────────────────┐   │
│ │     PowerDNS-Admin          │ │ │     PowerDNS-Admin                  │   │
│ │     (порт 9191)             │ │ │     (порт 9191)                     │   │
│ │   PostgreSQL: pdns_admin_db │◄┼─┼─────── общая БД на pwdns1           │   │
│ └─────────────────────────────┘ │ └─────────────────────────────────────┘   │
└─────────────────────────────────┴───────────────────────────────────────────┘
```

**Преимущества миграции на общую PostgreSQL БД:**
- ✅ Единые учётные записи на обоих серверах
- ✅ Общие настройки PowerDNS-Admin
- ✅ Централизованное управление пользователями
- ✅ Готовность к интеграции с Keycloak SSO


----------------------------------------------------------------
<br/>














----------------------------------------------------------------
<br/>
<br/>



# К каким базам данных подключены все три сервиса.

## 1. PowerDNS Authoritative Server (pdns)

```bash
# На pwdns1:
grep -E "gpgsql-host|gpgsql-dbname" /etc/powerdns/pdns.conf

# На pwdns2:
grep -E "gpgsql-host|gpgsql-dbname" /etc/powerdns/pdns.conf
```

**Ожидаемый вывод:** Оба должны указывать на `localhost` и `pdns_db` (каждый свою локальную БД).

## 2. PowerDNS-Admin (веб-интерфейс)

```bash
# На pwdns1:
grep -E "SQLA_DB_HOST|SQLA_DB_NAME|SQLA_DB_TYPE" /opt/powerdns-admin/instance/config.py

# На pwdns2:
grep -E "SQLA_DB_HOST|SQLA_DB_NAME|SQLA_DB_TYPE" /opt/powerdns-admin/instance/config.py
```

**Ожидаемый вывод:**
- **pwdns1:** `SQLA_DB_HOST = '127.0.0.1'` (своя локальная БД для админки)
- **pwdns2:** `SQLA_DB_HOST = '192.168.97.57'` (общая БД на pwdns1)

## 3. PostgreSQL (база данных)

```bash
# На pwdns1 проверяем, какие БД существуют
sudo -u postgres psql -c "\l"

# На pwdns1 проверяем, какие таблицы в БД pdns_admin_db
sudo -u postgres psql -d pdns_admin_db -c "\dt"

# На pwdns1 проверяем, какие пользователи в БД админки
sudo -u postgres psql -d pdns_admin_db -c "SELECT id, username, email FROM \"user\";"

# На pwdns2 проверяем подключение к БД на pwdns1
PGPASSWORD=pEhBYZFjDGEa psql -h 192.168.97.57 -U pdns_admin -d pdns_admin_db -c "SELECT id, username, email FROM \"user\";"
```

## 4. Проверка репликации PostgreSQL (для DNS-зон)

```bash
# На pwdns1:
sudo -u postgres psql -c "SELECT client_addr, state, sync_state FROM pg_stat_replication;"

# На pwdns2:
sudo -u postgres psql -c "SELECT pg_is_in_recovery();"
# Должно вернуть 't' (true) — значит сервер в режиме реплики
```

## 5. Проверка, что PowerDNS-Admin видит одинаковых пользователей

```bash
# На pwdns1 через curl (API)
curl -s -H "X-API-Key: xK8mP9nQ2rT5wY7zA1bC3dE5fG7hJ9kL" http://127.0.0.1:8081/api/v1/servers/localhost/zones

# На pwdns2 через curl (API)
curl -s -H "X-API-Key: xK8mP9nQ2rT5wY7zA1bC3dE5fG7hJ9kL" http://127.0.0.1:8081/api/v1/servers/localhost/zones
```

## Схема подключений:

```
pwdns1 (192.168.97.57)
├── PostgreSQL (pdns_db) ──────────► локальная БД для DNS-зон
├── PostgreSQL (pdns_admin_db) ─────► локальная БД для админки
├── PowerDNS (порт 53, 8081) ───────► использует локальную pdns_db
└── PowerDNS-Admin (порт 9191) ─────► использует локальную pdns_admin_db

pwdns2 (192.168.97.67)
├── PostgreSQL (pdns_db) ──────────► локальная БД для DNS-зон (реплика с pwdns1)
├── PowerDNS (порт 53, 8081) ───────► использует локальную pdns_db
└── PowerDNS-Admin (порт 9191) ─────► использует БД на pwdns1 (192.168.97.57)
```

----------------------------------------------------------------
<br/>
<br/>


Вы правы! Исправляю. Вот полная инструкция по добавлению пользователя в администраторы напрямую через SQL.

---

## Добавление пользователя через SQL с генерацией bcrypt хэша

### Что такое bcrypt хэш?

PowerDNS-Admin не хранит пароли в открытом виде. Вместо этого он хранит **хэш** — результат работы алгоритма bcrypt, который превращает пароль в уникальную строку фиксированной длины. Хэш невозможно превратить обратно в пароль, но при каждой попытке входа система может проверить, соответствует ли введённый пароль сохранённому хэшу.

**Пример хэша для пароля `pEhBYZFjDGEa`:**
```
$2b$12$8X8runPwdnS8X8runPwdnSOYKjYk6fB6fYk6fB6fYk6fB6fYk6fB6f
```

| Часть | Значение |
|-------|----------|
| `$2b$` | Версия bcrypt |
| `12` | Стоимость (2^12 = 4096 итераций) |
| `8X8runPwdnS8X8runPwdnS` | Соль (случайные данные) |
| `OYKjYk6f...` | Хэш пароля |

---

### Шаг 1: Сгенерировать bcrypt хэш для нужного пароля

```bash
cd /opt/powerdns-admin
source venv/bin/activate

python3 <<'EOF'
import bcrypt

# ЗАДАЙТЕ ЗДЕСЬ ВАШ ПАРОЛЬ
password = 'pEhBYZFjDGEa'

# Генерируем хэш
hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
print(f"Пароль: {password}")
print(f"Хэш для вставки в БД:\n{hashed.decode('utf-8')}")
EOF

deactivate
```

**Пример вывода:**
```
Пароль: pEhBYZFjDGEa
Хэш для вставки в БД:
$2b$12$8X8runPwdnS8X8runPwdnSOYKjYk6fB6fYk6fB6fYk6fB6fYk6fB6f
```

> ⚠️ **Важно:** У вас сгенерируется **свой уникальный хэш** (соль каждый раз разная). Используйте ТОТ хэш, который вывела команда, не копируйте из примера.

---

### Шаг 2: Узнать ID роли

В PowerDNS-Admin есть три роли:

| Роль | ID | Описание |
|------|----|----------|
| **Administrator** | 1 | Полный доступ |
| **Operator** | 2 | Управление зонами |
| **User** | 3 | Только свои зоны |

```bash
sudo -u postgres psql -d pdns_admin_db -c "SELECT id, name FROM role;"
```

---

### Шаг 3: Добавить пользователя с ролью Administrator (ПРЯМОЙ SQL)

```bash
sudo -u postgres psql -d pdns_admin_db <<EOF
INSERT INTO "user" (
    username,
    password,
    email,
    confirmed,
    role_id
) VALUES (
    'newadmin',                                    -- имя пользователя
    '\$2b\$12\$8X8runPwdnS8X8runPwdnSOYKjYk6fB6fYk6fB6fYk6fB6fYk6fB6f',  -- сгенерированный хэш
    'newadmin@local.host',                         -- email
    1,                                             -- confirmed (1 = да, 0 = нет)
    1                                              -- role_id = 1 (Administrator!)
);
EOF
```

> ⚠️ **Важно:** В SQL-запросе знак `$` нужно экранировать как `\$`. То есть хэш `$2b$12$abc...` записывается как `\$2b\$12\$abc...`

---

### Шаг 4: Проверить, что пользователь создан

```bash
sudo -u postgres psql -d pdns_admin_db -c "SELECT id, username, email, role_id, confirmed FROM \"user\";"
```

**Ожидаемый вывод:**
```
 id | username |      email       | role_id | confirmed 
----+----------+------------------+---------+-----------
  5 | admin    | admin@local.host |       1 |         1
  6 | ipetrov  | i@runtel.ru      |       1 |         1
  7 | newadmin | newadmin@local.host |     1 |         1
```

---

### Пример: полный скрипт для создания администратора (одной командой)
```bash
# 1. Генерируем хэш для пароля
cd /opt/powerdns-admin
source venv/bin/activate
HASH=$(python3 -c "import bcrypt; print(bcrypt.hashpw(b'pEhBYZFjDGEa', bcrypt.gensalt()).decode('utf-8'))")
echo "Хэш: $HASH"
deactivate

# 2. Экранируем $ для SQL
HASH_ESCAPED=$(echo "$HASH" | sed 's/\$/\\$/g')

# 3. Добавляем пользователя с ролью Administrator
sudo -u postgres psql -d pdns_admin_db <<EOF
INSERT INTO "user" (username, password, email, confirmed, role_id)
VALUES ('admin_new', '$HASH_ESCAPED', 'admin_new@local.host', 1, 1);
EOF

# 4. Проверяем
sudo -u postgres psql -d pdns_admin_db -c "SELECT id, username, email, role_id FROM \"user\";"
```

### Пример: полный скрипт для создания администратора с заданным паролем
```bash
cd /opt/powerdns-admin
source venv/bin/activate

# Задаём параметры
USERNAME="kkorablin"
PASSWORD="PASS123"
EMAIL="k@runtel.ru"
ROLE_ID=1  # 1=Administrator, 2=Operator, 3=User

# Генерируем хэш
HASH=$(python3 -c "import bcrypt; print(bcrypt.hashpw(b'$PASSWORD', bcrypt.gensalt()).decode('utf-8'))")
HASH_ESCAPED=$(echo "$HASH" | sed 's/\$/\\$/g')

# Добавляем пользователя
sudo -u postgres psql -d pdns_admin_db <<EOF
INSERT INTO "user" (username, password, email, confirmed, role_id)
VALUES ('$USERNAME', '$HASH_ESCAPED', '$EMAIL', 1, $ROLE_ID);
EOF

deactivate

# Проверяем
sudo -u postgres psql -d pdns_admin_db -c "SELECT id, username, email, role_id FROM \"user\";"
```


---

### Важное замечание

В PowerDNS-Admin пароли хэшируются с помощью **bcrypt**, НЕ через `werkzeug.generate_password_hash`!

| Метод | Результат | Совместимость с PDNS-Admin |
|-------|-----------|---------------------------|
| `bcrypt.hashpw()` | `$2b$12$...` (60 символов) | ✅ **Да** |
| `werkzeug.generate_password_hash()` | `pbkdf2:sha256:600000$...` (102 символа) | ❌ **Нет** |

Поэтому при добавлении пользователя через SQL **обязательно** используйте bcrypt хэш, сгенерированный как показано выше.


