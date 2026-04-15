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

**Важно:** Файл схемы находится по пути символической ссылки. Убедитесь, что пакет `pdns-backend-pgsql` установлен:

```bash
# Проверка установки бэкенда
dpkg -l | grep pdns-backend-pgsql

# Файл схемы (симлинк на реальный файл)
ls -la /usr/share/doc/pdns-backend-pgsql/schema.pgsql.sql

# Импорт схемы в базу данных
sudo -u postgres psql -d pdns_db -f /usr/share/doc/pdns-backend-pgsql/schema.pgsql.sql
```

### 2.5 Настройка PowerDNS Authoritative Server

```bash
sudo mcedit /etc/powerdns/pdns.conf
```

**Важно:** Убедитесь, что в файле нет дублирующихся параметров (особенно `launch`, `local-port`, `webserver-*`). Рекомендуемая минимальная конфигурация:

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

**Как сгенерировать надёжный API-ключ:**
```bash
# Рекомендуемый способ
openssl rand -base64 32

# Или так
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
```

### 2.6 Настройка PowerDNS Recursor

Для версии 5.x используется формат YAML:

```bash
sudo mcedit /etc/powerdns/recursor.conf
```

Пример конфигурации:

```yaml
incoming:
  listen:
    - 0.0.0.0
  allow_from:
    - 0.0.0.0/0

forward_zones_recurse:
  .: 1.1.1.1;8.8.8.8

dnssec:
  validation: process

recursor:
  hint_file: /usr/share/dns/root.hints
  include_dir: /etc/powerdns/recursor.d
```

### 2.7 Запуск и проверка статуса

**Важно:** PowerDNS Authoritative Server и Recursor не могут одновременно использовать порт 53 на одном IP-адресе. Выберите один из вариантов:

**Вариант А (рекомендуется для кластера):** Используйте только Authoritative Server на порту 53, отключив Recursor:
```bash
sudo systemctl stop pdns-recursor
sudo systemctl disable pdns-recursor
```

**Вариант Б:** Authoritative на порту 5300, Recursor на 53 (измените `local-port=5300` в `pdns.conf`).

Запуск сервисов:

```bash
# Перезапуск Authoritative Server
sudo systemctl restart pdns

# Проверка статуса
sudo systemctl status pdns

# Проверка работы DNS
dig @localhost version.bind chaos txt

# Проверка API (замените ключ на ваш)
curl -H "X-API-Key: ваш_секретный_api_ключ" http://127.0.0.1:8081/api/v1/servers/localhost/zones

# Проверка рекурсора (если оставили включённым и на другом порту)
dig @localhost -p 53 google.com +short
```

### 2.8 Часто возникающие проблемы и их решение

| Проблема | Решение |
|----------|---------|
| `Connection failed` для security.debian.org | Игнорируйте, это не влияет на установку PowerDNS |
| `cannot access '/usr/share/doc/pdns-backend-pgsql/schema.pgsql.sql'` | Установите `pdns-backend-pgsql`: `sudo apt install pdns-backend-pgsql` |
| Конфликт порта 53 между pdns и pdns-recursor | Выберите вариант А или Б из раздела 2.7 |
| API не отвечает | Проверьте, что `api=yes` и `webserver=yes`, а также нет дублей параметров в `pdns.conf` |

---

## Что дальше?

После успешной установки на первой машине:

1. **Настройка репликации PostgreSQL** между серверами (master-master)
2. **Установка PowerDNS-Admin** для веб-управления зонами
3. **Настройка кластерных параметров** (`allow-axfr-ips`, `webserver-allow-from` с IP второго сервера)

---








