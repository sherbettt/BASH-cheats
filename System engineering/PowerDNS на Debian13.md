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
sudo nano /etc/powerdns/pdns.conf
```

**Важно:** Убедитесь, что в файле нет дублирующихся параметров. Рекомендуемая минимальная конфигурация:

```ini
# Бэкенд PostgreSQL
launch=gpgsql
gpgsql-host=localhost          # Для Unix socket
gpgsql-user=pdns
gpgsql-password=ваш_пароль_БД
gpgsql-dbname=pdns_db

# Сетевые настройки
local-address=0.0.0.0
local-port=53

# Настройки API и веб-интерфейса
api=yes
api-key=ваш_секретный_api_ключ   # Сгенерируйте надёжный ключ!
webserver=yes
webserver-address=0.0.0.0
webserver-port=8081
webserver-allow-from=0.0.0.0/0
```

**Как сгенерировать надёжный API-ключ:**
```bash
# Рекомендуемый способ
openssl rand -base64 32

# Пример вывода: ohvN5wlMRyN2zR1XgO8qfDg7ObIARACvYJMjG4N0VAk
```

### 2.6 Настройка PowerDNS Recursor (опционально)

⚠️ **Для кластера Authoritative Server рекурсор не требуется.** Если вы всё же хотите его использовать, учтите конфликт порта 53 (см. раздел 2.8).

Для версии 5.x используется формат YAML:

```bash
sudo nano /etc/powerdns/recursor.conf
```

Пример конфигурации:

```yaml
# Секция входящих соединений
incoming:
  listen:           # Адреса для прослушивания
    - 0.0.0.0       # Все IPv4 интерфейсы
  allow_from:       # Разрешённые подсети
    - 0.0.0.0/0     # Все IPv4 (для production укажите конкретные)

# Перенаправление рекурсивных запросов
forward_zones_recurse:
  .: 1.1.1.1;8.8.8.8   # Использовать Cloudflare и Google DNS

# Настройки DNSSEC
dnssec:
  validation: process   # Включить проверку DNSSEC

# Пути и директории
recursor:
  hint_file: /usr/share/dns/root.hints   # Корневые DNS-серверы
  include_dir: /etc/powerdns/recursor.d  # Дополнительные конфиги
```

### 2.7 Настройка прав доступа в PostgreSQL

**Проблема:** После импорта схемы пользователь `pdns` не имеет прав на чтение таблиц, что вызывает ошибку:
```
ERROR: permission denied for table domains
```

**Решение:** Назначьте права пользователю `pdns` на все таблицы:

```bash
sudo -u postgres psql -d pdns_db <<EOF
-- Дать права на схему public
GRANT ALL ON SCHEMA public TO pdns;

-- Дать права на все таблицы
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pdns;

-- Дать права на последовательности
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO pdns;

-- Сделать pdns владельцем всех таблиц
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

**Проверка подключения:**
```bash
# Должно вернуть 1
PGPASSWORD=ваш_пароль_БД psql -U pdns -h 127.0.0.1 -d pdns_db -c "SELECT 1"
```

### 2.8 Запуск и проверка статуса

#### Запуск PowerDNS:

```bash
sudo systemctl restart pdns
sudo systemctl status pdns
```

Ожидаемый вывод: `Active: active (running)`

#### Проверка API:

```bash
# Должен вернуть пустой JSON массив []
curl -H "X-API-Key: ваш_секретный_api_ключ" http://127.0.0.1:8081/api/v1/servers/localhost/zones
```

#### Проверка DNS:

```bash
# Запрос версии сервера
dig @127.0.0.1 version.bind chaos txt

# Ожидаемый ответ:
# version.bind. 5 CH TXT "PowerDNS Authoritative Server 5.0.3 (...)"
```

### 2.9 Часто возникающие проблемы и их решение

| Проблема | Решение |
|----------|---------|
| `Connection failed` для security.debian.org | Игнорируйте, это не влияет на установку PowerDNS |
| `cannot access '/usr/share/doc/pdns-backend-pgsql/schema.pgsql.sql'` | Установите `pdns-backend-pgsql`: `sudo apt install pdns-backend-pgsql` |
| **`permission denied for table domains`** | **Выполните настройку прав из раздела 2.7** |
| **pdns не запускается, порт 53 занят** | **Отключите recursor или измените порт authoritative** (см. ниже) |
| API не отвечает (`curl: (7) Connection refused`) | Проверьте, что `api=yes`, `webserver=yes`, нет дублей параметров |
| pdns-recursor не запускается с ошибкой YAML | Версия из Debian (5.2.8) не поддерживает YAML-формат. Отключите recursor |

#### Конфликт порта 53 между pdns и pdns-recursor

PowerDNS Authoritative Server и Recursor **не могут одновременно использовать порт 53** на одном IP-адресе.

**Для кластера Authoritative Server рекурсор не нужен**, поэтому рекомендуется отключить его:

```bash
sudo systemctl stop pdns-recursor
sudo systemctl disable pdns-recursor
```

Если рекурсор всё же нужен, измените порт authoritative:

```ini
# В /etc/powerdns/pdns.conf
local-port=5300
```

---

## Что дальше? Настройка кластера из двух машин

После успешной установки на первой машине:

1. **Повторите все шаги 1-2 на второй машине**
2. **Настройте репликацию PostgreSQL master-master** между серверами
3. **В конфиг `pdns.conf` на обеих машинах** добавьте IP второй машины:
   ```ini
   allow-axfr-ips=IP_второго_сервера
   webserver-allow-from=127.0.0.1, IP_второго_сервера
   ```
4. **Установите PowerDNS-Admin** для веб-управления зонами


---








