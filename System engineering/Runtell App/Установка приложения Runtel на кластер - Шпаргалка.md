
# Установка приложения Runtel на кластер - Полная шпаргалка

<!-- **[Применение installer_pbxv2_cluster](https://gitlab.runtel.org/runtel/installer_pbxv2_cluster)** -->

## Содержание
1. [Начальная настройка Ansible](#1-начальная-настройка-ansible)
2. [SSH настройки для кластера](#2-ssh-настройки-для-кластера)
3. [Управление плейбуками и тегами](#3-управление-плейбуками-и-тегами)
4. [Работа с базой данных PostgreSQL](#4-работа-с-базой-данных-postgresql)
5. [Проверка состояния системы и сервисов](#5-проверка-состояния-системы-и-сервисов)
6. [Управление службами Runtel](#6-управление-службами-runtel)
7. [Patroni и репликация](#7-patroni-и-репликация)
8. [Устранение неполадок](#8-устранение-неполадок)
9. [FreeSWITCH и HAProxy](#9-freeswitch-и-haproxy)

---

## 1. Начальная настройка Ansible

### Создать симлинку в системной директории ролей
```bash
sudo ln -s /home/kiko0625/projects/git/installer_pbxv2_cluster /etc/ansible/roles/installer_pbxv2_cluster
```

### Создать инвенторку
```ini
## /home/<user_name>/projects/git/installer_pbxv2_cluster/inventory.ini

#==============
# Runtel Platform Test Cluster
[cluster-test]
192.168.87.38
192.168.87.127
192.168.87.148
192.168.87.66

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

## 2. SSH настройки для кластера

### SSH редактирование
Добавить в `/etc/ssh/ssh_config`:
```ini
Host *
    HostkeyAlgorithms +ssh-rsa,ecdsa-sha2-nistp256,ssh-ed25519
    KexAlgorithms +diffie-hellman-group14-sha256
    PubkeyAcceptedAlgorithms +ssh-rsa,ecdsa-sha2-nistp256,ssh-ed25519
    SendEnv LANG LC_*
    HashKnownHosts yes
    GSSAPIAuthentication yes
```

Добавить в `/etc/ssh/sshd_config`:
```ini
# КРИТИЧЕСКИ ВАЖНО - алгоритмы для совместимости между узлами кластера
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group14-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
HostkeyAlgorithms ssh-rsa,rsa-sha2-256,rsa-sha2-512,ecdsa-sha2-nistp256,ssh-ed25519
PubkeyAcceptedAlgorithms ssh-rsa,rsa-sha2-256,rsa-sha2-512,ecdsa-sha2-nistp256,ssh-ed25519
Ciphers chacha20-poly1305@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com
```

Раскомментировать в `/etc/ssh/sshd_config`:
```ini
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
```

---

## 3. Управление плейбуками и тегами

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

---

## 4. Работа с базой данных PostgreSQL

### Настройка .pgpass
Создать файл для пользователя (postgres:postgres) с правами 600 `/var/lib/postgresql/.pgpass`, 
<br/> а для (root:root) с правами 600 `/root/.pgpass`:
```conf
# Прямое подключение к PostgreSQL (5433)
192.168.87.38:5433:*:postgres:AdminDBPassComplex
192.168.87.127:5433:*:postgres:AdminDBPassComplex
192.168.87.148:5433:*:postgres:AdminDBPassComplex

# Подключение через HAProxy (5432)
192.168.87.38:5432:*:postgres:AdminDBPassComplex
192.168.87.127:5432:*:postgres:AdminDBPassComplex
192.168.87.148:5432:*:postgres:AdminDBPassComplex

# локальные адреса
localhost:5433:*:postgres:AdminDBPassComplex
127.0.0.1:5433:*:postgres:AdminDBPassComplex

# Пользователь rt_pbx - все базы данных
192.168.87.38:5432:*:rt_pbx:VeryComplexPass123
192.168.87.127:5432:*:rt_pbx:VeryComplexPass123
192.168.87.148:5432:*:rt_pbx:VeryComplexPass123
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
# Через HAProxy к БД на порту 5432
su - postgres
psql -h localhost -p 5432

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

### Удаление таблиц БД
```bash
# Если требуется удалить таблицы БД
sudo -u postgres psql -c "DROP DATABASE IF EXISTS rt_pbx_v2;"
sudo -u postgres psql -c "DROP DATABASE IF EXISTS rt_pbx_v2_stat;"
sudo -u postgres psql -c "DROP DATABASE IF EXISTS rt_pbx_v2_media;"
sudo -u postgres psql -c "DROP DATABASE IF EXISTS rt_pbx_v2_logging;"

# или командой ansible
# на одном из хостов
ansible app-clust3 -m shell -a "systemctl stop runtel-cdr-v2.service runtel-core-v2.service runtel-event-hunter-v2.service runtel-event-sender-v2.service runtel-iface-v2.service --no-pager" -b

# На всех хостах кластера
ansible -i inventory.ini app-clust1,app-clust2,app-clust3 -m shell -a "systemctl stop runtel-cdr-v2.service runtel-core-v2.service runtel-event-hunter-v2.service runtel-event-sender-v2.service runtel-iface-v2.service --no-pager" -b

# Проверить оставшиеся подключения к базе rt_pbx_v2 (на лидере)
ansible -i inventory.ini app-clust3 -m shell -a "psql -h 192.168.87.148 -p 5432 -U postgres -c 'SELECT datname, usename, application_name, client_addr FROM pg_stat_activity WHERE datname = \"rt_pbx_v2\";'" -b

# Завершить ВСЕ подключения к базе rt_pbx_v2 (на лидере)
ansible -i inventory.ini app-clust3 -m shell -a "psql -h 192.168.87.148 -p 5432 -U postgres -c 'SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = \"rt_pbx_v2\" AND pid <> pg_backend_pid();'" -b

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
ansible app-clust3 -m shell -a "rm -rf /etc/runtel/ /opt/runtel/web-v2/" -b
```

---

## 5. Проверка состояния системы и сервисов

### После установки проверьте
```bash
ansible -i inventory.ini app-clust3 -m shell -a "psql -h 192.168.87.148 -p 5432 -U postgres -d rt_pbx_v2 -c '\du'" -b
ansible 192.168.87.178 -m shell -a "sudo -u postgres psql -d rt_pbx_v2 -c 'SELECT email, username FROM users;'" -b
ansible 192.168.87.178 -m shell -a "systemctl status runtel-core-v2 runtel-iface-v2" -b
ansible 192.168.87.178 -m shell -a "ss -tulnp | grep runtel" -b
ansible 192.168.87.178 -m shell -a "grep -A10 'location /api' /etc/nginx/templates/root" -b
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

## 6. Управление службами Runtel

### Проверка служб
```bash
ansible 192.168.87.178 -m shell -a "systemctl status runtel-core-v2 runtel-iface-v2" -b
ansible 192.168.87.178 -m shell -a "ss -tulnp | grep runtel" -b
```

### Проверка Redis
```bash
redis-cli -h 127.0.0.1 -p 6380 -a "VeryComplexPass" ping
redis-cli -h 127.0.0.1 -p 6380 AUTH "VeryComplexPass"
```

### Просмотр логов
```bash
journalctl -xeu runtel-iface-v2.service --no-pager --lines=12 | ccze -A
```

---

## 7. Patroni и репликация

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
psql -h 192.168.87.127 -p 5432 -U postgres -c "SELECT * FROM test_cluster;"
psql -h 192.168.87.148 -p 5432 -U postgres -c "SELECT * FROM test_cluster;"

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

### Настроить переменные окружения для удобства
```bash
# Добавить в ~/.bashrc пользователя postgres
echo "export PGHOST=/var/lib/postgresql/patroni" >> ~/.bashrc
echo "export PGPORT=5433" >> ~/.bashrc
source ~/.bashrc

# Теперь можно просто
psql -U postgres
```

---

## 8. Устранение неполадок

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

## 9. FreeSWITCH и HAProxy

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

# Или посмотреть в задачах:
grep -r "freeswitch" tasks/ --include="*.yml"
grep -r "haproxy" tasks/ --include="*.yml"

# Посмотреть mediahost_install.yml (там обычно freeswitch)
grep -A5 -B5 "freeswitch" tasks/mediahost_install.yml

# Посмотреть haproxy_install.yml
grep -A5 -B5 "haproxy" tasks/haproxy_install.yml

# Быстрая проверка тегов:
ansible-playbook -i inventory.ini playbook-clust-test.yml --tags="haproxy" --list-tasks
ansible-playbook -i inventory.ini playbook-clust-test.yml --tags="fs" --list-tasks
```

#### Установка после определения тегов:
```bash
# Установить FreeSWITCH
ansible-playbook -i inventory.ini playbook-clust-test.yml --tags="freeswitch" --limit 192.168.87.66

# Установить HAProxy
ansible-playbook -i inventory.ini playbook-clust-test.yml --tags="haproxy" --limit 192.168.87.66

# Или одной командой
ansible-playbook -i inventory.ini playbook-clust-test.yml --tags="freeswitch,haproxy" --limit 192.168.87.66
```

#### Проверка установки:
```bash
# Проверить FreeSWITCH
ansible -i inventory.ini 192.168.87.66 -m shell -a "dpkg -l | grep freeswitch" -b
ansible -i inventory.ini 192.168.87.66 -m shell -a "systemctl status freeswitch" -b

# Проверить HAProxy
ansible -i inventory.ini 192.168.87.66 -m shell -a "dpkg -l | grep haproxy" -b
ansible -i inventory.ini 192.168.87.66 -m shell -a "ls -la /etc/haproxy/haproxy.cfg" -b
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

