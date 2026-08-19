## 📘 Инструкция по обновлению wildcard-сертификата для `*.chat.runtel.org`

### 1. Запросить новый сертификат

```bash
certbot certonly --manual --preferred-challenges dns -d *.chat.runtel.org -d chat.runtel.org --force-renewal
```

> **Важно:** Certbot запросит добавить **TXT-запись** в DNS.  
> Добавьте её в DNS-панели и **подождите 1–2 минуты** перед нажатием `Enter`.

---

### 2. После успешного получения — проверить, что ключи совпадают

```bash
openssl x509 -noout -modulus -in /etc/letsencrypt/live/chat.runtel.org/fullchain.pem | openssl md5
openssl rsa -noout -modulus -in /etc/letsencrypt/live/chat.runtel.org/privkey.pem | openssl md5
```

Хеши **должны совпасть**. Если нет — сертификат и ключ не подходят друг к другу.

---

### 3. Обновить конфиг Nginx

Отредактируйте файл:

```bash
nano /etc/nginx/sites-enabled/ext/wc_chat.runtel.org
```

Убедитесь, что используются **актуальные пути**:

```nginx
ssl_certificate /etc/letsencrypt/live/chat.runtel.org/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/chat.runtel.org/privkey.pem;
```

> 💡 Если раньше использовался `runtelorg.pem` — закомментируйте или удалите эти строки.

---

### 4. Проверить конфиг и перезапустить Nginx

```bash
nginx -t
nginx -s reload
```

---

### 5. Проверить, что сертификат работает

```bash
openssl s_client -connect pbx5.chat.runtel.org:443 -servername pbx5.chat.runtel.org 2>/dev/null | openssl x509 -noout -subject -dates
```

Ожидаемый вывод:

```
subject=CN = *.chat.runtel.org
notBefore=... (сегодня)
notAfter=... (через 3 месяца)
```

---

### 6. Проверить через curl

```bash
curl -vI https://pbx5.chat.runtel.org/
```

В выводе должна быть строка:

```
SSL certificate verify ok.
```

---

### 7. Проверить в браузере (особенно в инкогнито)

Откройте:

```
https://pbx5.chat.runtel.org/
```

Должен быть **зелёный замок**. Если в обычном режиме ошибка — **очистите кеш браузера**.

---

## ✅ Добавлю важное

### 🔐 Проверка цепочки сертификатов

```bash
openssl s_client -connect pbx5.chat.runtel.org:443 -showcerts </dev/null
```

В конце должно быть:

```
Verify return code: 0 (ok)
```

Если код не `0` — есть проблема с цепочкой.

---

### 🔄 Настройка автоматического обновления

Добавьте в cron:

```bash
crontab -e
```

Строка:

```
0 3 * * * /usr/bin/certbot renew --quiet
```

---

## ❗ Что ещё стоит запомнить

- `fullchain.pem` — **сертификат + цепочка** (публичная часть)
- `privkey.pem` — **приватный ключ** (секретная часть, никогда не покидает сервер)
- Для wildcard (`*.chat.runtel.org`) **обязательно** используется DNS-вызов (`--manual --preferred-challenges dns`)
- Браузер может кешировать старый сертификат — проверяйте в **инкогнито-режиме**

---

## 📎 Итоговый чек-лист

- [ ] Сертификат получен через `certbot`
- [ ] Хеши `fullchain.pem` и `privkey.pem` совпадают
- [ ] Конфиг Nginx обновлён
- [ ] `nginx -t` успешен
- [ ] `nginx -s reload` выполнен
- [ ] `curl` показывает `SSL certificate verify ok`
- [ ] Браузер в инкогнито показывает зелёный замок
- [ ] В cron добавлена задача `certbot renew`

---
<br/>


### Кратко
обновление сертификатов для *.chat.runtel.org  и  chat.runtel.org

```bash
letsencrypt -d *.chat.runtel.org --manual --preferred-challenges dns certonly

# или
certbot certonly --manual --preferred-challenges dns -d *.chat.runtel.org -d chat.runtel.org --force-renewal
Проверка
nginx -t
nginx -s reload
```
Проверить
```bash
host -t TXT _acme-challenge.chat.runtel.org

openssl s_client -connect pbx5.chat.runtel.org:443 -servername pbx5.chat.runtel.org 2>/dev/null | openssl x509 -noout -subject -dates

curl -vI https://pbx5.chat.runtel.org/

# проверить NGINX
/etc/nginx/sites-enabled/ext/wc_chat.runtel.org
```
