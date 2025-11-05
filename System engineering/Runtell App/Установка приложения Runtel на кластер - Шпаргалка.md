
# Установка приложения Runtel на кластер - шпаргалка

<!-- **[Применение installer_pbxv2_cluster](https://gitlab.runtel.org/runtel/installer_pbxv2_cluster)** -->

## Содержание
1. [Начальная настройка Ansible](#1-начальная-настройка-ansible)
2. [Управление плейбуками и тегами](#2-управление-плейбуками-и-тегами)
3. [Работа с базой данных PostgreSQL](#3-работа-с-базой-данных-postgresql)
4. [Проверка состояния системы и сервисов](#4-проверка-состояния-системы-и-сервисов)
5. [Управление службами Runtel](#5-управление-службами-runtel)
6. [Patroni и репликация](#6-patroni-и-репликация)
7. [Устранение неполадок](#7-устранение-неполадок)
8. [FreeSWITCH и HAProxy](#8-freeswitch-и-haproxy)
9. [Установка приложения Runtel](#9-установка-приложения-runtel)
---


## 1. Начальная настройка Ansible

### Создать симлинку в системной директории ролей
```bash
sudo ln -s /home/<user_name>/projects/git/installer_pbxv2_cluster /etc/ansible/roles/installer_pbxv2_cluster
```

### Создать инвенторку
```ini
## /home/<user_name>/projects/git/installer_pbxv2_cluster/inventory.ini

#==============
# Runtel Platform Test Cluster
[cluster-test]
192.168.87.38		# app-clust1
192.168.87.127	# app-clust2
192.168.87.148	# app-clust3
192.168.87.66		# app-clust4

[cluster-test:vars]
ansible_user=root
debug_enabled=True
ansible_ssh_private_key_file=~/.ssh/id_ed25519
#ansible_env_LANG=en_US.UTF-8
#ansible_env_LC_ALL=en_US.UTF-8
```

### Проверка хостов ansible
```bash
ansible -i inventory.ini --list-hosts all
```

---

## 2.1. Управление плейбуками и тегами

### Посмотреть доступные теги:
```bash
ansible-playbook -i inventory.ini playbook-clust-test.yml --list-tags
```

### Запуск по тегам
```bash
# Отдельные теги
ansible-playbook -i inventory.ini playbook-clust-test.yml --tags="patroni"
ansible-playbook -i inventory.ini playbook-clust-test.yml --tags="haproxy,redis"
```

### Пропуск тегов
```bash
ansible-playbook -i inventory.ini playbook-clust-test.yml --skip-tags freeswitch
ansible-playbook -i inventory.ini playbook-clust-test.yml --skip-tags="patroni,haproxy,redis"
```


## 2.2. Добавление ключа вручную
Отлично! Вот как вручную применить ключ на серверах:

## Способ 1: Добавить ключ в apt-key (рекомендуемый)

```bash
# На каждом сервере выполни:
apt-key add /etc/nginx/runtel.gpg
```

## Способ 2: Скопировать ключ в директорию trusted.gpg.d

```bash
# На каждом сервере:
cp /etc/nginx/runtel.gpg /etc/apt/trusted.gpg.d/runtel.gpg
chmod 644 /etc/apt/trusted.gpg.d/runtel.gpg
```

## Способ 3: Добавить репозиторий с указанием ключа

```bash
# На каждом сервере:
echo "deb [signed-by=/etc/nginx/runtel.gpg] http://repo.runtel.ru/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/runtel.list
apt update
```

## Проверить, что ключ добавлен:

```bash
# Проверить список ключей
apt-key list

# Или посмотреть конкретно runtel ключ
apt-key list | grep -A5 -B5 runtel
```

## Быстрая команда для всех серверов через Ansible:

```bash
# Добавить ключ на все ноды
ansible -i inventory.ini all -m shell -a "apt-key add /etc/nginx/runtel.gpg" -b

# Проверить
ansible -i inventory.ini all -m shell -a "apt-key list | grep -i runtel" -b
```


---

## 3. Работа с базой данных PostgreSQL

### Настройка `.pgpass`
Создать файл для пользователя (postgres:postgres) с правами 600 `/var/lib/postgresql/.pgpass`, 
<br/> а для root (root:root) с правами 600 `/root/.pgpass`:
```conf
# Прямое подключение к PostgreSQL (5433)
192.168.87.38:5433:*:postgres:AdminDBPassComplex
192.168.87.66:5433:*:postgres:AdminDBPassComplex
192.168.87.195:5433:*:postgres:AdminDBPassComplex

# Подключение через HAProxy (5432)
192.168.87.38:5432:*:postgres:AdminDBPassComplex
192.168.87.66:5432:*:postgres:AdminDBPassComplex
192.168.87.195:5432:*:postgres:AdminDBPassComplex

# Локальные адреса
localhost:5433:*:postgres:AdminDBPassComplex
127.0.0.1:5433:*:postgres:AdminDBPassComplex

# Пользователь rt_pbx - все базы данных (прямое подключение 5433)
192.168.87.38:5433:*:rt_pbx:VeryComplexPass123
192.168.87.66:5433:*:rt_pbx:VeryComplexPass123
192.168.87.195:5433:*:rt_pbx:VeryComplexPass123

# Пользователь rt_pbx - все базы данных (через HAProxy 5432)
192.168.87.38:5432:*:rt_pbx:VeryComplexPass123
192.168.87.66:5432:*:rt_pbx:VeryComplexPass123
192.168.87.195:5432:*:rt_pbx:VeryComplexPass123
```

### (опционально) Настроить переменные окружения для удобства
```bash
# Добавить в ~/.bashrc пользователя postgres
echo "export PGHOST=/var/lib/postgresql/patroni" >> ~/.bashrc
echo "export PGPORT=5433" >> ~/.bashrc
source ~/.bashrc

# Теперь можно просто
psql -U postgres
```

### Структура директорий PostgreSQL
- **`/var/lib/postgresql/15/main/`** - **Данные**
  - **Назначение**: Хранит все файлы БД (таблицы, индексы, WAL-файлы)
  - **Аналог**: "Диск C:" для Windows или `/home` для пользователей
  - **Содержимое**: Бинарные файлы баз данных, транзакционные логи
  - **Важно**: Это самое ценное - ваши данные!

- **`/etc/postgresql/15/main/`** - **Конфигурация**
  - **Назначение**: Файлы настроек
  - **Аналог**: Registry в Windows или `.config` директории
  - **Содержимое**: `postgresql.conf`, `pg_hba.conf`, `pg_ident.conf`
  - **Важно**: Здесь настраивается поведение PostgreSQL

- **`/var/run/postgresql/`** - **Runtime (временные файлы)**
  - **Назначение**: Сокеты и PID-файлы для коммуникации
  - **Аналог**: `/dev` для устройств
  - **Содержимое**: Сокеты для подключения, lock-файлы
  - **Важно**: Создается при старте, удаляется при остановке

### Подключение к БД
```bash
# Зайти под соответствующим пользователем
su - postgres

# Через HAProxy (должно работать всегда, если он запущен)
psql -h 192.168.87.38 -p 5432 -U postgres
psql -h 192.168.87.38 -p 5432 -U postgres -c "SELECT version();"

# Подключимся как пользователь приложения (rt_pbx)
psql -h 192.168.87.38 -p 5432 -U rt_pbx -d rt_pbx_v2 -c "SELECT current_user, current_database();"

# Подключение через полный путь к сокету
psql -h /var/lib/postgresql/patroni -p 5433 -U postgres
```

### Проверка Баз Данных
```bash
# Основные команды проверки
psql -h 192.168.87.38 -p 5432 -U postgres -c "\l"

# Основная база приложения
psql -h 192.168.87.38 -p 5432 -U rt_pbx -d rt_pbx_v2 -c "\dt"

# База для логирования
psql -h 192.168.87.38 -p 5432 -U rt_pbx -d rt_pbx_v2_logging -c "\dt"

# База для медиа (записи разговоров и т.д.)
psql -h 192.168.87.38 -p 5432 -U rt_pbx -d rt_pbx_v2_media -c "\dt"

# База для статистики
psql -h 192.168.87.38 -p 5432 -U rt_pbx -d rt_pbx_v2_stat -c "\dt"

# Или одной командой посмотреть все таблицы во всех базах
for db in rt_pbx_v2 rt_pbx_v2_logging rt_pbx_v2_media rt_pbx_v2_stat; do
    echo "=== База данных: $db ==="
    psql -h 192.168.87.38 -p 5432 -U postgres -d $db -c "\dt" | head -20
done
```

### Расширенные запросы к БД
```bash
# Посмотреть размеры баз данных
psql -h 192.168.87.38 -p 5432 -U postgres -c "
SELECT 
    datname as database,
    pg_size_pretty(pg_database_size(datname)) as size
FROM pg_database 
WHERE datname LIKE 'rt_pbx%'
ORDER BY pg_database_size(datname) DESC;"

# Показать всех пользователей/ролей
psql -h 192.168.87.38 -p 5432 -U postgres -c "\du"

# Подробный список пользователей
psql -h 192.168.87.38 -p 5432 -U postgres -c "
SELECT 
    rolname as username,
    rolsuper as is_superuser,
    rolcreatedb as can_create_db,
    rolcreaterole as can_create_roles,
    rolcanlogin as can_login,
    rolvaliduntil as password_expires
FROM pg_roles 
WHERE rolname NOT LIKE 'pg_%';"

# Размеры таблиц
psql -h 192.168.87.38 -p 5432 -U postgres -d rt_pbx_v2 -c "
SELECT 
    schemaname as schema,
    tablename as table,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) as table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) as index_size
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 20;"

# Проверить настройки лицензии
psql -h 192.168.87.38 -p 5432 -U rt_pbx -d rt_pbx_v2 -c "SELECT * FROM license LIMIT 5;"

# Проверим таблицу user
psql -h 192.168.87.38 -p 5432 -U rt_pbx -d rt_pbx_v2 -c "SELECT * FROM \"user\" LIMIT 5;"
```

### Удаление Баз Данных
> **ВАЖНО!** 
>	**Предварительно остановить службы.**
> **В противном случае, если сервисы запущены, будет выполняться переподключение.**
{.is-warning}

> Для выполнения запроса, пользователь, от которого он будет выполняться, должен иметь права суперпользователя в PostgreSQL.
{.is-info}


```bash
# Остановить службы
systemctl stop runtel-cdr-v2.service runtel-core-v2.service runtel-event-hunter-v2.service runtel-event-sender-v2.service runtel-iface-v2.service --no-pager

# Удалить БД
sudo -u postgres psql -c "DROP DATABASE IF EXISTS rt_pbx_v2;"
sudo -u postgres psql -c "DROP DATABASE IF EXISTS rt_pbx_v2_stat;"
sudo -u postgres psql -c "DROP DATABASE IF EXISTS rt_pbx_v2_media;"
sudo -u postgres psql -c "DROP DATABASE IF EXISTS rt_pbx_v2_logging;"

# или Ad-Hoc командой ansible
# на одном из хостов
ansible 192.168.87.148 -m shell -a "systemctl stop runtel-cdr-v2.service runtel-core-v2.service runtel-event-hunter-v2.service runtel-event-sender-v2.service runtel-iface-v2.service --no-pager" -b

# На всех хостах кластера
ansible -i inventory.ini 192.168.87.38,192.168.87.127,192.168.87.148 -m shell -a "systemctl stop runtel-cdr-v2.service runtel-core-v2.service runtel-event-hunter-v2.service runtel-event-sender-v2.service runtel-iface-v2.service --no-pager" -b

# Проверить оставшиеся подключения к базе rt_pbx_v2 (на лидере)
ansible -i inventory.ini 192.168.87.148 -m shell -a "psql -h 192.168.87.148 -p 5432 -U postgres -c 'SELECT datname, usename, application_name, client_addr FROM pg_stat_activity WHERE datname = \"rt_pbx_v2\";'" -b

# Завершить ВСЕ подключения к базе rt_pbx_v2 (на лидере)
ansible -i inventory.ini 192.168.87.148 -m shell -a "psql -h 192.168.87.148 -p 5432 -U postgres -c \"SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname like '%rt_pbx_v2%' AND pid <> pg_backend_pid();\"" -b --extra-vars "ansible_ssh_common_args='-o StrictHostKeyChecking=no'"

 #или руками
 psql -h 192.168.87.148 -p 5432 -U postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname like  '%rt_pbx_v2%' AND pid <> pg_backend_pid();"

# Удалить все базы
ansible -i inventory.ini app-clust3 -m shell -a "psql -h 192.168.87.148 -p 5432 -U postgres -c 'DROP DATABASE IF EXISTS rt_pbx_v2;'" -b
ansible -i inventory.ini app-clust3 -m shell -a "psql -h 192.168.87.148 -p 5432 -U postgres -c 'DROP DATABASE IF EXISTS rt_pbx_v2_logging;'" -b
ansible -i inventory.ini app-clust3 -m shell -a "psql -h 192.168.87.148 -p 5432 -U postgres -c 'DROP DATABASE IF EXISTS rt_pbx_v2_media;'" -b
ansible -i inventory.ini app-clust3 -m shell -a "psql -h 192.168.87.148 -p 5432 -U postgres -c 'DROP DATABASE IF EXISTS rt_pbx_v2_stat;'" -b

# удаление через цикл
ansible -i inventory.ini app-clust3 -m shell -a \ 
"for db in rt_pbx_v2 rt_pbx_v2_logging rt_pbx_v2_media rt_pbx_v2_stat; \ 
do psql -h 192.168.87.148 -p 5432 -U postgres -c \"DROP DATABASE IF EXISTS \\\"\$db\\\"\"; done" -b

# Очистка конфигурации
ansible app-clust3 -m shell -a "rm -rf /etc/runtel/" -b
```

---

## 4. Проверка состояния системы и сервисов

### После установки проверьте
```bash
ansible -i inventory.ini 192.168.87.148 -m shell -a "psql -h 192.168.87.148 -p 5432 -U postgres -d rt_pbx_v2 -c '\du'" -b
ansible -i inventory.ini 192.168.87.148 -m shell -a "sudo -u postgres psql -d rt_pbx_v2 -c 'SELECT email, username FROM users;'" -b
ansible -i inventory.ini 192.168.87.148 -m shell -a "systemctl status runtel-core-v2 runtel-iface-v2" -b
ansible -i inventory.ini 192.168.87.148 -m shell -a "ss -tulnp | grep runtel" -b
ansible -i inventory.ini 192.168.87.148 -m shell -a "grep -A10 'location /api' /etc/nginx/templates/root" -b
```

### Проверка основных портов
```bash
ss -tulpn | grep -E "(5432|5433|8008|2379|2380|6379|4810)"
```

### Поиск сокета БД
```bash
ls -alF /var/run/postgresql/

# Поищем сокеты в системе (скоре всего в /var/lib/postgresql/patroni/.s.PGSQL.5433)
find / -name ".s.PGSQL.5433" 2>/dev/null
find /var/run -name ".s.PGSQL.*" 2>/dev/null
find /var/lib/postgresql /tmp /var/tmp -name ".s.PGSQL.5433" 2>/dev/null

# Посмотрим в какой директории запущен Patroni (рабочая директория)
ps aux | grep patroni | grep -v grep

# Какая текущая директория у процесса Patroni
pwdx $(pgrep -f "patroni /etc/patroni/config.yml")
```

---

## 5. Управление службами Runtel

### Проверка служб
```bash
ansible -i inventory.ini cluster-test -m shell -a "systemctl list-units runtel*" -b
ansible -i inventory.ini 192.168.87.148 -m shell -a "systemctl status runtel-cdr-v2.service runtel-core-v2.service runtel-event-hunter-v2.service runtel-event-sender-v2.service runtel-iface-v2.service" -b
ansible -i inventory.ini 192.168.87.148 -m shell -a "ss -tulnp | grep runtel" -b
```

### Проверка Redis
```bash
redis-cli -h 127.0.0.1 -p 6380 -a "VeryComplexPass" ping
redis-cli -h 127.0.0.1 -p 6380 AUTH "VeryComplexPass"
```

### Просмотр логов
```bash
journalctl -xeu runtel-iface-v2.service --no-pager --lines=12
```

### Управление службами приложения Runtel по тэгу
```bash
# Перезагружает systemd и перезапускает все службы Runtel
ansible-playbook -i inventory.ini playbook-clust-test.yml --limit 192.168.87.66 --tags="runtel"

# Принудительный перезапуск
ansible-playbook -i inventory.ini playbook-clust-test.yml --limit 192.168.87.66 --tags="force-restart"

# Только перезагрузка systemd
ansible-playbook -i inventory.ini playbook-clust-test.yml --limit 192.168.87.66 --tags="reload"

# Проверка состояния служб
ansible-playbook -i inventory.ini playbook-clust-test.yml --limit 192.168.87.66 --tags="check"

# Включение автозапуска
ansible-playbook -i inventory.ini playbook-clust-test.yml --limit 192.168.87.66 --tags="autostart"
```

---

## 6. Patroni и репликация

### Проверка HAProxy вместе с БД
```bash
# Проверим, что HAProxy балансирует нагрузку
psql -h 192.168.87.38 -p 5432 -U postgres -c "SELECT inet_server_addr(), inet_server_port();"
psql -h 192.168.87.127 -p 5432 -U postgres -c "SELECT inet_server_addr(), inet_server_port();"
psql -h 192.168.87.148 -p 5432 -U postgres -c "SELECT inet_server_addr(), inet_server_port();"

# Показать активные подключения
psql -h 192.168.87.38 -p 5432 -U postgres -c "SELECT datname, usename, state, query FROM pg_stat_activity WHERE state = 'active';"
```

### Проверить репликацию
```bash
# На лидере создадим тестовую таблицу
psql -h 192.168.87.38 -p 5432 -U postgres -c "CREATE TABLE IF NOT EXISTS test_cluster (id serial, ts timestamptz DEFAULT now());"

# Проверим на репликах
psql -h 192.168.87.38 -p 5433 -U postgres -c "SELECT * FROM test_cluster;"
psql -h 192.168.87.127 -p 5433 -U postgres -c "SELECT * FROM test_cluster;"
psql -h 192.168.87.148 -p 5433 -U postgres -c "SELECT * FROM test_cluster;"

# На лидере - информация о репликации
psql -h 192.168.87.38 -p 5432 -U postgres -c "
SELECT 
    application_name,
    client_addr,
    state,
    sync_state,
    write_lag,
    flush_lag,
    replay_lag
FROM pg_stat_replication;"

# На репликах - статус репликации
psql -h 192.168.87.127 -p 5432 -U postgres -c "SELECT pg_is_in_recovery(), pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn();"
psql -h 192.168.87.148 -p 5432 -U postgres -c "SELECT pg_is_in_recovery(), pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn();"
```

---

## 7. Устранение неполадок

### Проблемы с Patroni
```bash
# Проверка валидности конф. patroni
patronictl -c /etc/patroni/config.yml list
patronictl -c /etc/patroni/config.yml show-config
patronictl -c /etc/patroni/config.yml history

# Если реплики не могут запуститься из-за конфликта файлов блокировки
# Остановить Patroni на проблемных нодах
systemctl stop patroni.service

# Очистить файлы блокировки
rm -f /var/lib/postgresql/patroni/.s.PGSQL.5433*
rm -f /var/lib/postgresql/patroni/.s.PGSQL.5433.lock
rm -f /var/lib/postgresql/patroni/postmaster.pid

# Убедиться, что нет висящих процессов
ps aux | grep postgres | grep -v grep
pkill -f postgres  # если есть висящие процессы

systemctl start patroni
patronictl -c /etc/patroni/config.yml list

# Если не поможет - переинициализировать реплики
# На лидере (app-clust1)
patronictl -c /etc/patroni/config.yml reinit postgres app-clust2
patronictl -c /etc/patroni/config.yml reinit postgres app-clust3

# Принудительный failover (если лидер не отвечает)
patronictl -c /etc/patroni/config.yml failover --master app-clust1 --candidate app-clust2
```

---

## 8. FreeSWITCH и HAProxy
> Данные действия нужны в том случае, если основной деплой завершился с ошибкой и требуется переустановка отдельных модулей.
{.is-info}

#### Проверить необходимый хост
Проверить в плейбук список неоходимых IP адресов в переменной **`fs_hosts`** (в нашем случае 192.168.87.66)
```yml
***
    # список хостов приложений
    app_hosts: ["192.168.87.38", "192.168.87.127", "192.168.87.148"]
    # список медиахостов
    fs_hosts: ["192.168.87.38", "192.168.87.127", "192.168.87.148", "192.168.87.66"]
***
```

### Управление FreeSWITCH и HAProxy на app-clust4

#### Удаление FreeSWITCH и конфигурации HAProxy:
```bash
# Остановить FreeSWITCH службу
ansible -i inventory.ini 192.168.87.66 -m service -a "name=freeswitch state=stopped" -b

# Принудительно завершить процесс если служба не останавливается
ansible -i inventory.ini 192.168.87.66 -m shell -a "pkill -9 freeswitch" -b

# Удалить FreeSWITCH пакеты
ansible -i inventory.ini app-clust4 -m apt -a "name=freeswitch state=absent purge=yes" -b
ansible -i inventory.ini 192.168.87.66 -m apt -a "name=freeswitch state=absent purge=yes" -b

# Удалить конфигурацию HAProxy
ansible -i inventory.ini app-clust4 -m file -a "path=/etc/haproxy/haproxy.cfg state=absent" -b
ansible -i inventory.ini 192.168.87.66 -m file -a "path=/etc/haproxy/haproxy.cfg state=absent" -b

# Или удалить весь HAProxy
ansible -i inventory.ini app-clust4 -m apt -a "name=haproxy state=absent purge=yes" -b
ansible -i inventory.ini 192.168.87.66 -m apt -a "name=haproxy state=absent purge=yes" -b
```

#### Поиск тегов для установки:
```bash
# Посмотреть все доступные теги в плейбуке:
ansible-playbook -i inventory.ini playbook-clust-test.yml --list-tags

 ## Получим
 [autostart, check, db, disable, etcd, force-restart, fs, haproxy, patroni, postgresql, redis, reload, runtel, ssh, stop]

# Или посмотреть в задачах:
grep -r "freeswitch" tasks/ --include="*.yml"
grep -r "haproxy" tasks/ --include="*.yml"

# Посмотреть mediahost_install.yml (там обычно freeswitch)
grep -A5 -B5 "freeswitch" tasks/mediahost_install.yml
grep -A5 -B5 "freeswitch" . -r

# Посмотреть haproxy_install.yml
grep -A5 -B5 "haproxy" tasks/haproxy_install.yml
grep -A5 -B5 "haproxy" . -r
```

#### Быстрая проверка тегов:
```bash
# Посмотреть задачи с тегом haproxy
ansible-playbook -i inventory.ini playbook-clust-test.yml --tags="haproxy" --list-tasks

# Посмотреть задачи с тегом fs (вероятно freeswitch)
ansible-playbook -i inventory.ini playbook-clust-test.yml --tags="fs" --list-tasks

# Или посмотреть все задачи чтобы найти правильные теги
ansible-playbook -i inventory.ini playbook-clust-test.yml --list-tasks | grep -E "(freeswitch|haproxy)"
```

#### Найденные теги:

**Для FreeSWITCH:**
- `freeswitch` - основной тег для установки FreeSWITCH
- `freeswitch, sysctl` - для настройки sysctl

**Для HAProxy:**
- `haproxy` - основной тег (включает задачи из `haproxy_install.yml` и `haproxy_media_install.yml`)
- `install, haproxy` - дополнительные теги


#### Установка после определения тегов:
```bash
# Установить FreeSWITCH
ansible-playbook -i inventory.ini playbook-clust-test.yml --limit 192.168.87.66 --tags="freeswitch"

# Установить HAProxy
ansible-playbook -i inventory.ini playbook-clust-test.yml --limit 192.168.87.66 --tags="haproxy"

# Или одной командой
ansible-playbook -i inventory.ini playbook-clust-test.yml --limit 192.168.87.66 --tags="freeswitch,haproxy"
```

#### Проверка установки:
```bash
# Проверить FreeSWITCH
ansible -i inventory.ini 192.168.87.66 -m shell -a "dpkg -l | grep freeswitch" -b
ansible -i inventory.ini 192.168.87.66 -m shell -a "systemctl status freeswitch" -b

# Проверить HAProxy
ansible -i inventory.ini 192.168.87.66 -m shell -a "dpkg -l | grep haproxy" -b
ansible -i inventory.ini 192.168.87.66 -m shell -a "ls -alF /etc/haproxy/haproxy.cfg" -b
ansible -i inventory.ini 192.168.87.66 -m shell -a "systemctl status haproxy" -b
```

### Проблема с FreeSWITCH
Для FreeSWITCH на отдельном сервере возможно потребуется написать `override.conf` для systemd юнита.
Это проблема с LCX контейнером, на обычной ВМ проблем быть не должно.

```ini
## /etc/systemd/system/freeswitch.service.d/override.conf
## Права: 644

[Service]
# Отключаем проблемные CPU scheduling параметры
# Пустые значения сбрасывают к defaults
CPUSchedulingPolicy=
#CPUSchedulingPriority=  # закомментировать вместо пустого значения
IOSchedulingClass=
#IOSchedulingPriority=   # закомментировать вместо пустого значения

# Отключаем SETSCHEDULER для ExecStartPre
NoNewPrivileges=false
PermissionsStartOnly=false
```

#### Применение фикса для FreeSWITCH:
```bash
# Создать директорию
ansible -i inventory.ini 192.168.87.66 -m file -a "path=/etc/systemd/system/freeswitch.service.d state=directory owner=root group=root mode=0755" -b

# Создать override.conf с правами 644
ansible -i inventory.ini 192.168.87.66 -m copy -a "dest=/etc/systemd/system/freeswitch.service.d/override.conf content='[Service]
# Отключаем проблемные CPU scheduling параметры
# Пустые значения сбрасывают к defaults
CPUSchedulingPolicy=
#CPUSchedulingPriority=  # закомментировать вместо пустого значения
IOSchedulingClass=
#IOSchedulingPriority=   # закомментировать вместо пустого значения

# Отключаем SETSCHEDULER для ExecStartPre
NoNewPrivileges=false
PermissionsStartOnly=false' mode=0644" -b

# Перезагрузить systemd и запустить FreeSWITCH
ansible -i inventory.ini 192.168.87.66 -m shell -a "systemctl daemon-reload && systemctl reset-failed freeswitch && systemctl restart freeswitch" -b
ansible -i inventory.ini 192.168.87.66 -m shell -a "systemctl status freeswitch.service -l --no-pager"
```

---


## 9. Установка приложения Runtel 
> Данные действия нужны в том случае, если требуется на один из хостов с каким-либо модулем поставить приложение.
{.is-info}


#### Добавить необходимый хост

Добавить в плейбук неоходимый IP к переменной **`app_hosts`** (в нашем случае 192.168.87.66 [app-clust4] ), т.к. ранее на него уже был установлен медиахост.
```yml
***
    # список хостов приложений
    app_hosts: ["192.168.87.38", "192.168.87.127", "192.168.87.148", "192.168.87.66"]
    # список медиахостов
    fs_hosts: ["192.168.87.38", "192.168.87.127", "192.168.87.148", "192.168.87.66"]
***
```

#### Поиск тегов для установки:
```bash
# Посмотреть все доступные теги в плейбуке:
ansible-playbook -i inventory.ini playbook-clust-test.yml --list-tags

 ## Получим
 [autostart, check, db, disable, etcd, force-restart, fs, haproxy, patroni, postgresql, redis, reload, runtel, ssh, stop]

# Посмотрим какие задачи есть в плейбуке на установку
ansible-playbook -i inventory.ini playbook-clust-test.yml --list-tasks | grep -i install

# Посмотреть задачи с тегом haproxy
ansible-playbook -i inventory.ini playbook-clust-test.yml --tags="runtel" --list-tasks
```

#### Проверка перед установкой приложения Runtel на узел app-clust4
```bash
ansible-playbook -i inventory.ini playbook-clust-test.yml --limit 192.168.87.66 --check --diff
```

#### Установка приложения Runtel на узел app-clust4
```bash
# Режим проверки (без реальных изменений)
ansible-playbook -i inventory.ini playbook-clust-test.yml --limit 192.168.87.66 --check --diff

# Запустим плейбук БЕЗ тегов - это установит все необходимое
ansible-playbook -i inventory.ini playbook-clust-test.yml --limit 192.168.87.66
```

#### Проверим состояние после установки
```bash
# Что уже установлено на app-clust4
ansible -i inventory.ini 192.168.87.66 -m shell -a "dpkg -l | grep -iE runtel" -b
ansible -i inventory.ini 192.168.87.66 -m shell -a "dpkg -l | grep -iE '(runtel|nginx)'" -b
ansible -i inventory.ini 192.168.87.66 -m shell -a "systemctl list-units runtel*" -b

# Проверим порты
ansible -i inventory.ini 192.168.87.66 -m shell -a "ss -tulpn | grep -E '(4810|6379|8021)'" -b
ansible -i inventory.ini 192.168.87.66 -m shell -a "ls -alF /etc/runtel/" -b
ansible -i inventory.ini 192.168.87.66 -m shell -a "cat /etc/runtel/base.yaml | grep -i port" -b

# Проверка на хосте
# Проверим конфигурацию приложения - там указаны порты
cat /etc/runtel/base.yaml | grep -i port
cat /etc/runtel/env | grep -i port

# Или посмотрим конфиги служб
grep -r "port" /etc/runtel/

# Все listening порты
lsof -i -P -n | grep LISTEN

# Только LISTEN порты iface
lsof -iTCP -sTCP:LISTEN | grep iface
```

#### Принудительно создать таблицы
```bash
# Перезапустить iface службу на лидере - она должна создать таблицы
ansible -i inventory.ini 192.168.87.148 -m shell -a "systemctl restart runtel-iface-v2" -b

# Проверить создание таблиц
ansible -i inventory.ini 192.168.87.148 -m shell -a "psql -h 192.168.87.38 -p 5432 -U postgres -d rt_pbx_v2 -c '\dt'" -b
```
