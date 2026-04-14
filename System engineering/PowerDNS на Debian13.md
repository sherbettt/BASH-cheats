Статьи с подсказками:
- [Настройка кластера PowerDNS на Rocky Linux](https://www.dmosk.ru/instruktions.php?object=powerdns-cluster)
- [altlinux.org/PowerDNS](https://www.altlinux.org/PowerDNS)
---------
<br/>


# 1. Прописать репозитории
Переходим на оф. ресурс https://repo.powerdns.com/ и смотрим примеры установок. В нашем случае - stable установка.

 ***PowerDNS Authoritative Server - version 5.0.X (stable)***

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

### Затем установка (уже из официального репозитория)
```bash
# Установка PostgreSQL (если ещё нет)
sudo apt install postgresql postgresql-contrib

# Установка PowerDNS 5.0.x из официального репозитория
sudo apt install pdns-server pdns-backend-pgsql pdns-recursor
```

## Репозиторий для pdns-recursor
Для рекурсора также есть официальный репозиторий (версия 5.4.x stable). Опционально его тоже можно обновить:
```bash
# Добавьте в тот же /etc/apt/sources.list.d/pdns.list вторую строку
deb [signed-by=/etc/apt/keyrings/rec-54-pub.asc] http://repo.powerdns.com/debian trixie-rec-54 main

# И соответствующий файл приоритетов /etc/apt/preferences.d/rec-54
# и ключ для рекурсора (такой же ключ FD380FBB)
```


<details>
<summary>❗пример от вендора❗</summary>

## PowerDNS Authoritative Server - version 5.0.X (stable)
Create the file **'/etc/apt/sources.list.d/pdns.list'** with this content:
```
deb [signed-by=/etc/apt/keyrings/auth-50-pub.asc] http://repo.powerdns.com/debian trixie-auth-50 main
```
Put this in **'/etc/apt/preferences.d/auth-50'**:
```
Package: pdns-*
Pin: origin repo.powerdns.com
Pin-Priority: 600
```

and execute the following commands:
```
sudo install -d /etc/apt/keyrings; curl https://repo.powerdns.com/FD380FBB-pub.asc | sudo tee /etc/apt/keyrings/auth-50-pub.asc &&
sudo apt-get update &&
sudo apt-get install pdns-server
```
</details>



## 2. Установка зависимостей

```bash
# поиск зависимостей
nala search pdns-server pdns-backend-pgsql pdns-recursor
```
```bash
# 1. Установка PostgreSQL 17 (Debian 13 может иметь 16 или 17)
sudo apt update
sudo apt install postgresql postgresql-contrib

# 2. Установка PowerDNS
sudo apt install pdns-server pdns-backend-pgsql pdns-recursor

# 3. Создание БД и пользователя
sudo -u postgres psql <<EOF
CREATE USER pdns WITH PASSWORD 'ваш_пароль_БД';
CREATE DATABASE pdns_db WITH OWNER pdns;
\q
EOF

# 4. Импорт схемы
sudo -u postgres psql -d pdns_db -f /usr/share/doc/pdns-backend-pgsql/schema.pgsql.sql

# 5. Настройка /etc/powerdns/pdns.conf
sudo nano /etc/powerdns/pdns.conf
```



