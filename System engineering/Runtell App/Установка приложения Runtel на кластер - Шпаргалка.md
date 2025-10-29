# Установка приложения Runtel на кластер - Шпаргалка

## Содержание
1. [Настройка Ansible](#настройка-ansible)
2. [Управление плейбуками](#управление-плейбуками)
3. [База данных PostgreSQL](#база-данных-postgresql)
4. [Проверка состояния системы](#проверка-состояния-системы)
5. [Управление службами Runtel](#управление-службами-runtel)
6. [Устранение неполадок](#устранение-неполадок)
7. [FreeSWITCH и HAProxy](#freeswitch-и-haproxy)

---

## Настройка Ansible

### Создание симлинки для роли
```bash
sudo ln -s /home/kiko0625/projects/git/installer_pbxv2_cluster /etc/ansible/roles/installer_pbxv2_cluster
```

### Проверка инвентаря
```bash
ansible -i inventory.ini --list-hosts all
```

---

## Управление плейбуками

### Просмотр тегов
```bash
ansible-playbook -i inventory.ini playbook-clust-test.yml --list-tags
```

### Запуск по тегам
```bash
# Отдельные теги
ansible-playbook -i inventory.ini playbook-clust-test.yml --tags="patroni"
ansible-playbook -i inventory.ini playbook-clust-test.yml --tags="haproxy,redis"

# Пропуск тегов
ansible-playbook -i inventory.ini playbook-clust-test.yml --skip-tags freeswitch
ansible-playbook -i inventory.ini playbook-clust-test.yml --skip-tags="patroni,haproxy,redis"
```

---

## База данных PostgreSQL

### Настройка .pgpass
Создать файл `/var/lib/postgresql/.pgpass` или `/root/.pgpass` (права 600):
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

# Пользователь rt_pbx
192.168.87.38:5432:*:rt_pbx:VeryComplexPass123
192.168.87.127:5432:*:rt_pbx:VeryComplexPass123
192.168.87.148:5432:*:rt_pbx:VeryComplexPass123
```

### Директории PostgreSQL
- **`/var/lib/postgresql/15/main/`** - Данные (таблицы, индексы, WAL)
- **`/etc/postgresql/15/main/`** - Конфигурация
- **`/var/run/postgresql/`** - Runtime файлы (сокеты, PID)

### Подключение к БД
```bash
# Через HAProxy
psql -h 192.168.87.38 -p 5432 -U postgres
psql -h 192.168.87.38 -p 5432 -U rt_pbx -d rt_pbx_v2

# Прямое подключение
psql -h /var/lib/postgresql/patroni -p 5433 -U postgres
```

### Проверка БД
```bash
# Список баз данных
psql -h 192.168.87.38 -p 5432 -U postgres -c "\l"

# Размеры баз данных
psql -h 192.168.87.38 -p 5432 -U postgres -c "
SELECT 
    datname as database,
    pg_size_pretty(pg_database_size(datname)) as size
FROM pg_database 
WHERE datname LIKE 'rt_pbx%'
ORDER BY pg_database_size(datname) DESC;"

# Пользователи/роли
psql -h 192.168.87.38 -p 5432 -U postgres -c "\du"

# Таблицы в основной базе
psql -h 192.168.87.38 -p 5432 -U postgres -d rt_pbx_v2 -c "\dt"
```

### Удаление баз данных
```bash
# Остановка служб
ansible -i inventory.ini cluster-test -m shell -a "systemctl stop runtel-cdr-v2.service runtel-core-v2.service runtel-event-hunter-v2.service runtel-event-sender-v2.service runtel-iface-v2.service" -b

# Завершение подключений к БД
ansible -i inventory.ini app-clust3 -m shell -a "psql -h 192.168.87.148 -p 5432 -U postgres -c 'SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = \"rt_pbx_v2\" AND pid <> pg_backend_pid();'" -b

# Удаление баз
ansible -i inventory.ini app-clust3 -m shell -a "psql -h 192.168.87.148 -p 5432 -U postgres -c 'DROP DATABASE IF EXISTS rt_pbx_v2;'" -b
ansible -i inventory.ini app-clust3 -m shell -a "psql -h 192.168.87.148 -p 5432 -U postgres -c 'DROP DATABASE IF EXISTS rt_pbx_v2_logging;'" -b
ansible -i inventory.ini app-clust3 -m shell -a "psql -h 192.168.87.148 -p 5432 -U postgres -c 'DROP DATABASE IF EXISTS rt_pbx_v2_media;'" -b
ansible -i inventory.ini app-clust3 -m shell -a "psql -h 192.168.87.148 -p 5432 -U postgres -c 'DROP DATABASE IF EXISTS rt_pbx_v2_stat;'" -b
```

---

## Проверка состояния системы

### Основные порты
```bash
ss -tulpn | grep -E "(5432|5433|8008|2379|2380|6379|4810)"
```

### Поиск сокета БД
```bash
find / -name ".s.PGSQL.5433" 2>/dev/null
find /var/run -name ".s.PGSQL.*" 2>/dev/null
ps aux | grep patroni | grep -v grep
```

### Проверка репликации
```bash
# Статус репликации на лидере
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

# Статус на репликах
psql -h 192.168.87.127 -p 5432 -U postgres -c "SELECT pg_is_in_recovery(), pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn();"
```

---

## Управление службами Runtel

### Проверка служб
```bash
ansible 192.168.87.178 -m shell -a "systemctl status runtel-core-v2 runtel-iface-v2" -b
ansible 192.168.87.178 -m shell -a "ss -tulnp | grep runtel" -b
```

### Проверка Redis
```bash
redis-cli -h 127.0.0.1 -p 6380 -a "VeryComplexPass" ping
```

### Просмотр логов
```bash
journalctl -xeu runtel-iface-v2.service --no-pager --lines=12 | ccze -A
```

---

## Устранение неполадок

### Проблемы с Patroni
```bash
# Проверка состояния
patronictl -c /etc/patroni/config.yml list
patronictl -c /etc/patroni/config.yml show-config

# Очистка файлов блокировки
systemctl stop patroni.service
rm -f /var/lib/postgresql/patroni/.s.PGSQL.5433*
rm -f /var/lib/postgresql/patroni/postmaster.pid
systemctl start patroni

# Переинициализация реплик
patronictl -c /etc/patroni/config.yml reinit postgres app-clust2
```

### Настройка SSH для кластера
В `/etc/ssh/sshd_config`:
```ini
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group14-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
HostkeyAlgorithms ssh-rsa,rsa-sha2-256,rsa-sha2-512,ecdsa-sha2-nistp256,ssh-ed25519
PubkeyAcceptedAlgorithms ssh-rsa,rsa-sha2-256,rsa-sha2-512,ecdsa-sha2-nistp256,ssh-ed25519
```

---

## FreeSWITCH и HAProxy

### Управление FreeSWITCH
```bash
# Удаление
ansible -i inventory.ini app-clust4 -m apt -a "name=freeswitch state=absent purge=yes" -b

# Установка
ansible-playbook -i inventory.ini playbook-clust-test.yml --tags="freeswitch" --limit 192.168.87.66

# Systemd override для FreeSWITCH
# /etc/systemd/system/freeswitch.service.d/override.conf:
[Service]
CPUSchedulingPolicy=
IOSchedulingClass=
NoNewPrivileges=false
PermissionsStartOnly=false
```

### Управление HAProxy
```bash
# Удаление
ansible -i inventory.ini app-clust4 -m apt -a "name=haproxy state=absent purge=yes" -b
ansible -i inventory.ini app-clust4 -m file -a "path=/etc/haproxy/haproxy.cfg state=absent" -b

# Установка
ansible-playbook -i inventory.ini playbook-clust-test.yml --tags="haproxy" --limit 192.168.87.66
```

### Поиск тегов для установки
```bash
# Просмотр всех тегов
ansible-playbook -i inventory.ini playbook-clust-test.yml --list-tags

# Поиск в задачах
grep -r "freeswitch" tasks/ --include="*.yml"
grep -r "haproxy" tasks/ --include="*.yml"

# Просмотр задач по тегам
ansible-playbook -i inventory.ini playbook-clust-test.yml --tags="haproxy" --list-tasks
ansible-playbook -i inventory.ini playbook-clust-test.yml --tags="fs" --list-tasks
```

### Проверка установки
```bash
# FreeSWITCH
ansible -i inventory.ini 192.168.87.66 -m shell -a "dpkg -l | grep freeswitch" -b
ansible -i inventory.ini 192.168.87.66 -m shell -a "systemctl status freeswitch" -b

# HAProxy
ansible -i inventory.ini 192.168.87.66 -m shell -a "dpkg -l | grep haproxy" -b
ansible -i inventory.ini 192.168.87.66 -m shell -a "systemctl status haproxy" -b
```
