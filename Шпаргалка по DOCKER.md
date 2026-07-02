# ШПАРГАЛКА ПО DOCKER

## 📋 СОДЕРЖАНИЕ
1. [Базовые команды](#1-базовые-команды)
2. [Фильтрация](#2-фильтрация)
3. [Работа с контейнерами](#3-работа-с-контейнерами)
4. [Работа с образами](#4-работа-с-образами)
5. [Работа с БД (PostgreSQL/Redis)](#5-работа-с-бд-postgresqlredis)
6. [Очистка системы](#6-очистка-системы)
7. [Алиасы (готовый набор)](#7-алиасы-готовый-набор)
8. [Полезные скрипты](#8-полезные-скрипты)

---

## 1. БАЗОВЫЕ КОМАНДЫ

### 📦 Просмотр контейнеров

```bash
# Все запущенные контейнеры
docker ps
docker stats --no-stream

# ВСЕ контейнеры (включая остановленные)
docker ps -a

# Только ID контейнеров
docker ps -q

# Вся информация в удобном формате
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
```

**Твой пример:**
```bash
root@debian:~# docker ps
# Покажет 44 контейнера, включая:
# - cts-traefik-1 (прокси)
# - cts-postgres-1 (БД)
# - cts-redis-1 (кэш)
# - cts-messaging-1 (основной сервис)
# - microsocks-microsocks-1 (прокси SOCKS5)
```

### 🖼️ Просмотр образов

```bash
# Все образы
docker images

# Только ID
docker images -q

# С фильтром по имени
docker images --filter "reference=*traefik*"
```

**Твой пример:**
```bash
root@debian:~# docker images
# Увидишь:
# - registry.public.express/traefik:v3.6.17 (180MB) ✅ используется
# - registry.public.express/postgres:14.15 (434MB) ✅ используется
# - registry.public.express/redis:8.2.3 (19.2MB) ✅ используется
# - makeplane/* (plane-* образы) - не используются (нет U)
# - hello-world, valkey - не используются
```

---

## 2. ФИЛЬТРАЦИЯ

### 🔍 Фильтры для `docker ps`

| Фильтр | Описание | Пример |
|--------|----------|--------|
| `name=` | по имени контейнера | `docker ps --filter "name=postgres"` |
| `status=` | по статусу | `docker ps --filter "status=running"` |
| `ancestor=` | по образу | `docker ps --filter "ancestor=registry.public.express/redis:8.2.3"` |
| `label=` | по метке | `docker ps --filter "label=com.docker.compose.project=cts"` |

**Твои примеры:**

```bash
# 1. Найти контейнеры с postgres
docker ps --filter "name=postgres"
# Результат: cts-postgres-1

# 2. Найти все контейнеры с nginx
docker ps --filter "name=nginx"
# Результат: cts-nginx-1

# 3. Найти контейнеры с traefik (НЕ правильно!)
docker ps --filter "name=registry.public.express/traefik"  # ❌ пусто
docker ps --filter "name=traefik"                         # ✅ cts-traefik-1

# 4. Все healthy контейнеры
docker ps --filter "health=healthy"

# 5. Все контейнеры от одного образа (по части имени)
docker ps --filter "ancestor=registry.public.express/messaging:3.67.11"
```

### 🔍 Фильтры для `docker images`

```bash
# 1. Образы с U (используемые)
docker images --filter "dangling=false" | grep "U"

# 2. Образы без тега (dangling)
docker images --filter "dangling=true"

# 3. Только образы с traefik
docker images --filter "reference=*traefik*"

# 4. Образы старше N дней
docker images --filter "before=registry.public.express/traefik:v3.6.17"
```

---

## 3. РАБОТА С КОНТЕЙНЕРАМИ

### ▶️ Управление жизненным циклом

```bash
# Запустить контейнер
docker start cts-postgres-1

# Остановить контейнер (graceful)
docker stop cts-postgres-1

# Остановить контейнер (force)
docker kill cts-postgres-1

# Перезапустить
docker restart cts-postgres-1

# Удалить контейнер (остановленный)
docker rm cts-postgres-1

# Удалить контейнер (работающий, force)
docker rm -f cts-postgres-1
```

### 🚪 Вход в контейнер

```bash
# Войти в контейнер (bash)
docker exec -it cts-admin-1 /bin/bash

# Войти в контейнер (sh, если нет bash)
docker exec -it cts-admin-1 /bin/sh

# Выполнить команду без входа
docker exec -it cts-admin-1 ls -la /app

# Запустить команду от имени пользователя
docker exec -it --user root cts-admin-1 /bin/bash
```

**Твои контейнеры (какой shell использовать):**

| Контейнер | Тип | Shell |
|-----------|-----|-------|
| `cts-admin-1` | Elixir | `/bin/bash` или `/bin/sh` |
| `cts-postgres-1` | PostgreSQL | `/bin/bash` |
| `cts-redis-1` | Redis | `/bin/sh` |
| `cts-traefik-1` | Traefik | `/bin/sh` |
| `cts-nginx-1` | Nginx | `/bin/sh` |
| `microsocks-microsocks-1` | Alpine | `/bin/sh` |

### 📊 Логи

```bash
# Просмотр логов
docker logs cts-messaging-1

# Последние 100 строк
docker logs --tail 100 cts-messaging-1

# Логи в реальном времени (follow)
docker logs -f cts-messaging-1

# Логи с временными метками
docker logs -t cts-messaging-1

# Логи с детализацией
docker logs --details cts-messaging-1
```

---

## 4. РАБОТА С ОБРАЗАМИ

### 🖼️ Управление образами

```bash
# Удалить образ
docker rmi registry.public.express/admin:3.67.2

# Удалить образ (force)
docker rmi -f registry.public.express/admin:3.67.2

# Удалить все неиспользуемые образы
docker image prune

# Удалить все образы без тегов (dangling)
docker image prune --filter "dangling=true"
```

**Твоя ситуация:**
```bash
# Образы, которые НЕ используются (нет U):
# - makeplane/* (все)
# - hello-world
# - postgres:15.7-alpine (есть также postgres:14.15 с U)
# - rabbitmq
# - minio
# - valkey

# Удалить все makeplane образы
docker rmi makeplane/plane-admin:stable makeplane/plane-backend:stable makeplane/plane-frontend:stable makeplane/plane-live:stable makeplane/plane-proxy:stable makeplane/plane-space:stable

# Или удалить все неиспользуемые образы
docker image prune -a
```

### 📥 Скачивание образов

```bash
# Скачать образ
docker pull registry.public.express/postgres:14.15

# Скачать с указанием платформы
docker pull --platform linux/amd64 registry.public.express/postgres:14.15

# Скачать все теги
docker pull -a registry.public.express/postgres
```

### 📤 Экспорт/Импорт

```bash
# Сохранить образ в файл
docker save -o postgres-backup.tar registry.public.express/postgres:14.15

# Загрузить образ из файла
docker load -i postgres-backup.tar

# Сохранить контейнер (не образ!)
docker export -o container-backup.tar cts-postgres-1

# Импортировать контейнер
docker import container-backup.tar my-new-image:latest
```

---

## 5. РАБОТА С БД (POSTGRESQL/REDIS)

### 🗄️ PostgreSQL (на примере `cts-postgres-1`)

```bash
# === БАЗОВОЕ ПОДКЛЮЧЕНИЕ ===

# Войти в psql
docker exec -it cts-postgres-1 psql -U postgres

# Выполнить SQL-запрос
docker exec -it cts-postgres-1 psql -U postgres -c "SELECT version();"

# === УПРАВЛЕНИЕ БД ===

# Список всех БД
docker exec -it cts-postgres-1 psql -U postgres -l

# Создать БД
docker exec -it cts-postgres-1 psql -U postgres -c "CREATE DATABASE myapp_db;"

# Удалить БД
docker exec -it cts-postgres-1 psql -U postgres -c "DROP DATABASE myapp_db;"

# === РАБОТА С ТАБЛИЦАМИ ===

# Показать все таблицы в текущей БД
docker exec -it cts-postgres-1 psql -U postgres -d postgres -c "\dt"

# Показать структуру таблицы
docker exec -it cts-postgres-1 psql -U postgres -d postgres -c "\d users"

# === БЭКАП ===

# Дамп конкретной БД
docker exec -it cts-postgres-1 pg_dump -U postgres postgres > /tmp/backup.sql

# Дамп ALL БД
docker exec -it cts-postgres-1 pg_dumpall -U postgres > /tmp/backup_all.sql

# Восстановление
cat /tmp/backup.sql | docker exec -i cts-postgres-1 psql -U postgres

# === МОНИТОРИНГ ===

# Размеры БД
docker exec -it cts-postgres-1 psql -U postgres -c "
  SELECT pg_database.datname, 
         pg_size_pretty(pg_database_size(pg_database.datname)) AS size 
  FROM pg_database;
"

# Активные соединения
docker exec -it cts-postgres-1 psql -U postgres -c "SELECT * FROM pg_stat_activity;"

# === ИНТЕРАКТИВНАЯ РАБОТА ===

# Войти в psql (интерактивный режим)
docker exec -it cts-postgres-1 psql -U postgres

# Внутри psql:
# \l          - список БД
# \c mydb     - подключиться к БД
# \dt         - список таблиц
# \d table    - структура таблицы
# \x          - расширенный вывод
# \q          - выйти
```

### 🔴 Redis (на примере `cts-redis-1`)

```bash
# === БАЗОВОЕ ПОДКЛЮЧЕНИЕ ===

# Войти в redis-cli
docker exec -it cts-redis-1 redis-cli

# Выполнить команду
docker exec -it cts-redis-1 redis-cli PING

# === РАБОТА С КЛЮЧАМИ ===

# Все ключи (ОСТОРОЖНО на проде!)
docker exec -it cts-redis-1 redis-cli KEYS '*'

# Получить значение
docker exec -it cts-redis-1 redis-cli GET "user:123"

# Установить значение
docker exec -it cts-redis-1 redis-cli SET "user:123" '{"name":"John"}'

# Удалить ключ
docker exec -it cts-redis-1 redis-cli DEL "user:123"

# === СТАТИСТИКА ===

# Общая информация
docker exec -it cts-redis-1 redis-cli INFO

# Только stats
docker exec -it cts-redis-1 redis-cli INFO stats

# Память
docker exec -it cts-redis-1 redis-cli INFO memory

# Клиенты
docker exec -it cts-redis-1 redis-cli INFO clients

# === МОНИТОРИНГ ===

# Мониторинг команд в реальном времени
docker exec -it cts-redis-1 redis-cli MONITOR

# Просмотр медленных запросов
docker exec -it cts-redis-1 redis-cli SLOWLOG GET 10

# === ОЧИСТКА (ОСТОРОЖНО!) ===

# Удалить все ключи в текущей БД
docker exec -it cts-redis-1 redis-cli FLUSHDB

# Удалить все ключи во всех БД
docker exec -it cts-redis-1 redis-cli FLUSHALL
```

### 🧩 Дополнительно: ETCD (у тебя есть `cts-etcd-1`)

```bash
# Войти в etcd
docker exec -it cts-etcd-1 /bin/sh

# Внутри контейнера:
etcdctl get / --prefix --keys-only
etcdctl get /mykey
etcdctl put /mykey "myvalue"
```

---

## 6. ОЧИСТКА СИСТЕМЫ

### 🧹 Команды очистки

```bash
# === БЕЗОПАСНАЯ ОЧИСТКА ===

# Удалить остановленные контейнеры
docker container prune

# Удалить неиспользуемые образы
docker image prune

# Удалить неиспользуемые сети
docker network prune

# Удалить неиспользуемые тома
docker volume prune

# === ПОЛНАЯ ОЧИСТКА ===

# Удалить всё неиспользуемое (контейнеры, образы, сети)
docker system prune -f

# Полная очистка с томами (ОСТОРОЖНО!)
docker system prune -af --volumes

# === ОЧИСТКА ПО ВРЕМЕНИ ===

# Контейнеры старше 24 часов
docker container prune --filter "until=24h"

# Образы старше 48 часов
docker image prune --filter "until=48h"

# === ТОЧЕЧНАЯ ОЧИСТКА ===

# Удалить все остановленные контейнеры
docker rm $(docker ps -aq --filter "status=exited")

# Удалить все dangling образы
docker rmi $(docker images -q --filter "dangling=true")

# Удалить все контейнеры с ошибкой
docker rm $(docker ps -aq --filter "status=exited")

# === ДЛЯ ТВОЕЙ СИСТЕМЫ ===

# Удалить образы makeplane (если не нужны)
docker rmi makeplane/plane-admin:stable makeplane/plane-backend:stable makeplane/plane-frontend:stable makeplane/plane-live:stable makeplane/plane-proxy:stable makeplane/plane-space:stable

# Удалить неиспользуемые образы (все без U)
docker image prune -a

# Просмотр занимаемого места
docker system df
```

---

## 7. АЛИАСЫ (ГОТОВЫЙ НАБОР)

### 📝 Добавь в `~/.bashrc` или `~/.zshrc`

```bash
# ========================================
#  DOCKER ALIASES (для твоего проекта)
# ========================================

# ---- БАЗОВЫЕ ----
alias dps='docker ps'
alias dpa='docker ps -a'
alias dpaq='docker ps -aq'
alias di='docker images'
alias diq='docker images -q'
alias dinfo='docker info'
alias dversion='docker --version'

# ---- УПРАВЛЕНИЕ КОНТЕЙНЕРАМИ ----
alias drm='docker rm'
alias drmi='docker rmi'
alias dstop='docker stop'
alias dstart='docker start'
alias drestart='docker restart'
alias dlogs='docker logs'
alias dlogs-f='docker logs -f'
alias dexec='docker exec -it'

# ---- ФИЛЬТРЫ ----
alias dps-healthy='docker ps --filter "health=healthy"'
alias dps-exited='docker ps -a --filter "status=exited"'
alias dps-running='docker ps --filter "status=running"'
alias di-dangling='docker images --filter "dangling=true"'

# ---- КОМПОЗ (если используешь) ----
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
alias dce='docker compose exec'

# ---- ОЧИСТКА ----
alias dclean='docker system prune -f'
alias dclean-all='docker system prune -af --volumes'
alias dclean-old='docker container prune --filter "until=24h"'
alias drm-all='docker rm -f $(docker ps -aq)'
alias drmi-all='docker rmi -f $(docker images -q)'

# ---- БЫСТРЫЙ ВХОД В ТВОИ КОНТЕЙНЕРЫ ----
alias d-admin='docker exec -it cts-admin-1 /bin/bash'
alias d-postgres='docker exec -it cts-postgres-1 /bin/bash'
alias d-redis='docker exec -it cts-redis-1 /bin/sh'
alias d-messaging='docker exec -it cts-messaging-1 /bin/bash'
alias d-traefik='docker exec -it cts-traefik-1 /bin/sh'
alias d-nginx='docker exec -it cts-nginx-1 /bin/sh'
alias d-kafka='docker exec -it cts-kafka-1 /bin/sh'
alias d-etcd='docker exec -it cts-etcd-1 /bin/sh'
alias d-microsocks='docker exec -it microsocks-microsocks-1 /bin/sh'

# ---- БД (PostgreSQL) ----
alias pg='docker exec -it cts-postgres-1 psql -U postgres'
alias pg-list='docker exec -it cts-postgres-1 psql -U postgres -l'
alias pg-version='docker exec -it cts-postgres-1 psql -U postgres -c "SELECT version();"'
alias pg-dump='docker exec -it cts-postgres-1 pg_dump -U postgres'
alias pg-backup='docker exec -it cts-postgres-1 pg_dumpall -U postgres > backup_$(date +%Y%m%d_%H%M%S).sql'

# ---- БД (Redis) ----
alias redis='docker exec -it cts-redis-1 redis-cli'
alias redis-keys='docker exec -it cts-redis-1 redis-cli KEYS "*"'
alias redis-info='docker exec -it cts-redis-1 redis-cli INFO'
alias redis-stats='docker exec -it cts-redis-1 redis-cli INFO stats'
alias redis-monitor='docker exec -it cts-redis-1 redis-cli MONITOR'
alias redis-ping='docker exec -it cts-redis-1 redis-cli PING'

# ---- ФУНКЦИИ ----

# Выполнить SQL-запрос
pg-query() {
  docker exec -it cts-postgres-1 psql -U postgres -c "$1"
}

# Показать размер всех БД
pg-sizes() {
  docker exec -it cts-postgres-1 psql -U postgres -c "
    SELECT pg_database.datname, 
           pg_size_pretty(pg_database_size(pg_database.datname)) AS size 
    FROM pg_database ORDER BY pg_database_size(pg_database.datname) DESC;
  "
}

# Получить значение из Redis
redis-get() {
  docker exec -it cts-redis-1 redis-cli GET "$1"
}

# Установить значение в Redis
redis-set() {
  docker exec -it cts-redis-1 redis-cli SET "$1" "$2"
}

# Удалить ключ в Redis
redis-del() {
  docker exec -it cts-redis-1 redis-cli DEL "$1"
}

# Показать все контейнеры по маске имени
dps-name() {
  docker ps --filter "name=$1"
}

# Войти в контейнер по маске
denter-name() {
  CONTAINER=$(docker ps --filter "name=$1" --format "{{.Names}}" | head -1)
  if [ -z "$CONTAINER" ]; then
    echo "❌ Контейнер с именем '$1' не найден"
  else
    echo "✅ Вход в $CONTAINER"
    docker exec -it "$CONTAINER" /bin/bash || docker exec -it "$CONTAINER" /bin/sh
  fi
}

# Логи контейнера по маске
dlogs-name() {
  CONTAINER=$(docker ps --filter "name=$1" --format "{{.Names}}" | head -1)
  if [ -z "$CONTAINER" ]; then
    echo "❌ Контейнер с именем '$1' не найден"
  else
    docker logs -f "$CONTAINER"
  fi
}

# Статистика по всем контейнерам
dstats() {
  docker stats --no-stream
}

# Показать IP контейнера
dip() {
  docker inspect "$1" | grep IPAddress | tail -1 | cut -d'"' -f4
}
```

### 🔄 Применение алиасов

```bash
source ~/.bashrc
# или
source ~/.zshrc
```

---

## 8. ПОЛЕЗНЫЕ СКРИПТЫ

### 📦 Скрипт для бэкапа всех БД

Создай файл `/usr/local/bin/backup-dbs.sh`:

```bash
#!/bin/bash
# Бэкап всех PostgreSQL БД

BACKUP_DIR="/backup/postgres"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$DATE.sql"

mkdir -p "$BACKUP_DIR"

echo "📦 Создание бэкапа всех БД..."
docker exec cts-postgres-1 pg_dumpall -U postgres > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Бэкап создан: $BACKUP_FILE"
    echo "📊 Размер: $(du -h "$BACKUP_FILE" | cut -f1)"
    
    # Удалить бэкапы старше 7 дней
    find "$BACKUP_DIR" -name "*.sql" -mtime +7 -delete
    echo "🗑️  Старые бэкапы (>7 дней) удалены"
else
    echo "❌ Ошибка создания бэкапа!"
    exit 1
fi
```

Сделай исполняемым:
```bash
chmod +x /usr/local/bin/backup-dbs.sh
```

### 📊 Скрипт для мониторинга

```bash
#!/bin/bash
# docker-status.sh - Показать статус всех контейнеров

echo "=== СТАТУС DOCKER ==="
echo "Всего контейнеров: $(docker ps -a | wc -l)"
echo "Запущено: $(docker ps | wc -l)"
echo "Остановлено: $(docker ps -a --filter "status=exited" | wc -l)"
echo ""
echo "=== ИСПОЛЬЗОВАНИЕ ДИСКА ==="
docker system df
echo ""
echo "=== ЗАПУЩЕННЫЕ КОНТЕЙНЕРЫ ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
```

### 🧹 Скрипт для очистки

```bash
#!/bin/bash
# docker-cleanup.sh - Безопасная очистка

echo "🧹 Очистка Docker..."
echo ""

# 1. Остановленные контейнеры
echo "1. Удаление остановленных контейнеров..."
docker container prune -f

# 2. Dangling образы
echo "2. Удаление dangling образов..."
docker image prune -f

# 3. Неиспользуемые сети
echo "3. Удаление неиспользуемых сетей..."
docker network prune -f

echo ""
echo "✅ Очистка завершена!"
docker system df
```

---

## 📌 ВАЖНЫЕ НЮАНСЫ

### ⚠️ Безопасность

1. **Никогда не делайте на проде:**
   - `docker system prune -af --volumes`
   - `docker exec -it cts-redis-1 redis-cli FLUSHALL`
   - `docker rm -f $(docker ps -aq)`

2. **Всегда делайте бэкап перед:**
   - Удалением образов
   - Очисткой томов
   - Массовыми операциями

3. **Проверяйте перед удалением:**
   ```bash
   # Что будет удалено?
   docker system prune --dry-run
   ```

### 🐛 Особенности твоих контейнеров

1. **Elixir/Erlang контейнеры** (все `cts-*` с `/app/bin/`):
   - Используют `bash` или `sh`
   - Могут иметь свои утилиты в `/app/bin/`
   - Логи пишут в stdout

2. **Traefik** (`cts-traefik-1`):
   - Проксирует запросы
   - Порт 80 → 8080, 443 → 8443
   - Конфиг в `/etc/traefik/`

3. **PostgreSQL** (`cts-postgres-1`):
   - Пользователь: `postgres` (без пароля в локальной сети)
   - Данные в томе (не потерять при удалении)

4. **Redis** (`cts-redis-1`):
   - Без пароля (локальный доступ)
   - Данные в томе

### 🔧 Диагностика проблем

```bash
# Проверить логи проблемного контейнера
docker logs --tail 100 cts-messaging-1

# Проверить статус
docker inspect cts-messaging-1 | grep -A 5 "State"

# Проверить здоровье
docker inspect cts-messaging-1 | grep -A 10 "Health"

# Проверить сеть
docker inspect cts-messaging-1 | grep -A 10 "Networks"

# Проверить использование ресурсов
docker stats cts-messaging-1
```

---

## 🚀 БОНУС: Быстрый чит-лист

| Что сделать | Команда |
|-------------|---------|
| Посмотреть все контейнеры | `docker ps -a` |
| Зайти в admin | `docker exec -it cts-admin-1 /bin/bash` |
| Зайти в postgres | `docker exec -it cts-postgres-1 /bin/bash` |
| Зайти в psql | `docker exec -it cts-postgres-1 psql -U postgres` |
| Зайти в redis | `docker exec -it cts-redis-1 /bin/sh` |
| Зайти в redis-cli | `docker exec -it cts-redis-1 redis-cli` |
| Посмотреть логи messaging | `docker logs -f cts-messaging-1` |
| Перезапустить traefik | `docker restart cts-traefik-1` |
| Удалить все остановленные контейнеры | `docker container prune -f` |
| Очистить систему | `docker system prune -f` |
| Посмотреть размеры | `docker system df` |

---





