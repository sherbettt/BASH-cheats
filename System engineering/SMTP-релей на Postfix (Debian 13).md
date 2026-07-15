# Полная инструкция по настройке SMTP-релея на Postfix (Debian 13)

## Оглавление
1. [Введение и требования](#введение-и-требования)
2. [Установка Postfix](#установка-postfix)
3. [Настройка аутентификации](#настройка-аутентификации)
4. [Настройка релея через Яндекс](#настройка-релея-через-яндекс)
5. [Проблемы с Яндексом и переход на Рамблер](#проблемы-с-яндексом-и-переход-на-рамблер)
6. [Настройка релея через Рамблер](#настройка-релея-через-рамблер)
7. [Решение проблем с портами и адресами](#решение-проблем-с-портами-и-адресами)
8. [Итоговая конфигурация](#итоговая-конфигурация)
9. [Тестирование и проверка](#тестирование-и-проверка)
10. [Дальнейшие шаги](#дальнейшие-шаги)

---

## Введение и требования

### Что такое SMTP-релей?
SMTP-релей (или *smart host*) — это почтовый сервер, который не хранит письма локально, а сразу передает их через внешний SMTP-сервис. Это позволяет централизовать отправку почты от всех приложений на сервере и использовать надежные внешние сервисы для доставки.

### Требования
- Сервер на **Debian 13 (Trixie)**
- Доступ к интернету
- Учетная запись на SMTP-сервисе (в нашем случае — Рамблер Почта)
- Права root или sudo

---

## Установка Postfix

### Шаг 1. Установка пакетов

```bash
apt update
apt install -y postfix
```

Во время установки выберите тип конфигурации **`Internet Site`** и укажите ваше доменное имя (например, `runtel.ru`).

### Шаг 2. Проверка установки

```bash
dpkg -l postfix
postfix --version
```

Установился **Postfix 3.10.12** — стабильная версия для Debian 13.

---

## Настройка аутентификации

### Шаг 1. Установка SASL-модуля

```bash
apt install -y libsasl2-modules
```

### Шаг 2. Создание файла с паролями

```bash
nano /etc/postfix/sasl_passwd
```

Формат файла:
```
[smtp.сервер.com]:порт логин:пароль
```

Пример для Рамблера:
```
[smtp.rambler.ru]:465 kkorablin@ro.ru:ВашПароль
```

### Шаг 3. Создание базы данных паролей

```bash
postmap /etc/postfix/sasl_passwd
```

Теперь есть два файла:
- `/etc/postfix/sasl_passwd` — текстовый (можно удалить)
- `/etc/postfix/sasl_passwd.db` — бинарный (используется Postfix)

### Шаг 4. Установка прав доступа

```bash
chown root:root /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
chmod 0600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
```

---

## Настройка релея через Яндекс

### Первая попытка

Изначально мы пытались использовать Яндекс 360 с доменом `runtel.ru`.

**Конфигурация `/etc/postfix/main.cf`:**
```conf
myorigin = runtel.ru
mydestination = 
relayhost = [smtp.yandex.ru]:587

smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd

smtp_tls_security_level = encrypt
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt

inet_protocols = ipv4
```

**Файл `/etc/postfix/sasl_passwd`:**
```
[smtp.yandex.ru]:587 k@runtel.ru:пароль
```

### Ошибка 1: Проблемы с аутентификацией

**Ошибка в логах:**
```
SASL authentication failed; server smtp.yandex.ru said: 
535 5.7.8 Error: authentication failed: Invalid user or password!
```

**Причина:** Для корпоративных ящиков Яндекс 360 нужен **пароль приложения**, а не обычный пароль. Создать его может только администратор домена.

### Ошибка 2: Попытка использовать личный аккаунт

Попробовали использовать личный аккаунт `kkorablin@yandex.ru`.

**Ошибка:**
```
SASL authentication failed; server smtp.yandex.ru said: 
535 5.7.8 Error: authentication failed: This user does not have access rights to this service
```

**Причина:** Яндекс блокирует SMTP-доступ для личных аккаунтов, если нет специального разрешения или пароля приложения.

### Ошибка 3: Порт 465 требует специальной настройки

При попытке использовать порт 465:
```
SMTPS wrappermode (TCP port 465) requires setting "smtp_tls_wrappermode = yes"
```

**Решение:** Добавить в `main.cf`:
```conf
smtp_tls_wrappermode = yes
```

---

## Проблемы с Яндексом и переход на Рамблер

### Почему Яндекс не подошел?

1. **Яндекс 360** (`@runtel.ru`) — требует прав администратора для создания пароля приложения.
2. **Личный аккаунт** (`@yandex.ru`) — блокирует SMTP-доступ для почтовых клиентов.
3. **Создать новый аккаунт без телефона** — невозможно, Яндекс требует телефон.

### Решение: Рамблер Почта

Рамблер позволяет создавать почтовые ящики без номера телефона.

#### Регистрация на Рамблере

1. Перейдите на `mail.rambler.ru`
2. Нажмите **«Завести почту @rambler.ru»**
3. Заполните форму:
   - Имя и фамилия
   - Логин (выбрали `kkorablin@ro.ru`)
   - Пароль (задали `ohP3phei`)
   - Контрольный вопрос (запишите ответ!)
4. Нажмите **«Зарегистрироваться»**

#### Включение доступа для почтовых клиентов

1. Войдите в почту `mail.rambler.ru`
2. Нажмите на шестеренку (⚙️) → «Настройки»
3. Перейдите в раздел **«Безопасность»**
4. Включите опцию **«Доступ к почтовому ящику с помощью почтовых клиентов»**

---

## Настройка релея через Рамблер

### Параметры SMTP-сервера Рамблера

| Протокол | Сервер | Порт | Шифрование |
|----------|--------|------|------------|
| SMTP | `smtp.rambler.ru` | 465 | SSL/TLS (wrappermode) |
| SMTP | `smtp.rambler.ru` | 587 | STARTTLS |

Мы использовали порт 465 с SSL/TLS.

### Итоговая конфигурация `/etc/postfix/main.cf`

```conf
# Основной домен
myorigin = runtel.ru

# Указываем, что сервер НЕ принимает почту локально
mydestination = 

# Внешний SMTP-сервер для отправки
relayhost = [smtp.rambler.ru]:465

# Аутентификация
smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd

# TLS для безопасного соединения
smtp_tls_security_level = encrypt
smtp_tls_wrappermode = yes
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt

# Преобразование адреса отправителя
smtp_generic_maps = hash:/etc/postfix/generic

# Отключаем IPv6 (если нет доступа)
inet_protocols = ipv4

# Безопасные протоколы и шифры
smtp_tls_mandatory_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
smtp_tls_mandatory_ciphers = high
```

### Файл `/etc/postfix/sasl_passwd`

```
[smtp.rambler.ru]:465 kkorablin@ro.ru:ohP3phei
```

---

## Решение проблем с портами и адресами

### Ошибка 4: Несовпадение адреса отправителя

**Ошибка в логах:**
```
530 5.1.8 <root@postfix.localdomain>: Sender address rejected: 
Envelope from do not match auth data; check your settings
```

**Причина:** Рамблер проверяет, что адрес отправителя (`MAIL FROM`) совпадает с логином аутентификации. По умолчанию Postfix отправляет письма от `root@postfix.localdomain`.

**Решение:** Использовать `smtp_generic_maps` для замены адреса.

#### Создание файла `/etc/postfix/generic`

```bash
nano /etc/postfix/generic
```

Содержимое:
```
root@postfix.localdomain    kkorablin@ro.ru
```

Создание базы данных:
```bash
postmap /etc/postfix/generic
chmod 0600 /etc/postfix/generic /etc/postfix/generic.db
```

### Ошибка 5: SASL authentication failed для bounce-писем

**Ошибка:**
```
SASL authentication failed; server smtp.rambler.ru said: 535 5.7.0 Invalid login or password
```

**Решение:** После исправления адреса отправителя эта ошибка исчезла автоматически, так как bounce-письма тоже стали использовать правильный адрес.

---

## Итоговая конфигурация

### Файлы и их содержимое

**`/etc/postfix/main.cf`**:
```conf
myorigin = runtel.ru
mydestination = 
relayhost = [smtp.rambler.ru]:465

smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd

smtp_tls_security_level = encrypt
smtp_tls_wrappermode = yes
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt

smtp_generic_maps = hash:/etc/postfix/generic

inet_protocols = ipv4

smtp_tls_mandatory_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
smtp_tls_mandatory_ciphers = high
```

**`/etc/postfix/sasl_passwd`**:
```
[smtp.rambler.ru]:465 kkorablin@ro.ru:ohP3phei
```

**`/etc/postfix/generic`**:
```
root@postfix.localdomain    kkorablin@ro.ru
```

### Применение изменений

```bash
postmap /etc/postfix/sasl_passwd
postmap /etc/postfix/generic
chmod 0600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
chmod 0600 /etc/postfix/generic /etc/postfix/generic.db
systemctl restart postfix
systemctl status postfix
```

---

## Тестирование и проверка

### Отправка тестового письма

```bash
echo "Тест через Рамблер" | mail -s "Test Rambler" kkorablin@yandex.ru
```

### Проверка логов

```bash
tail -f /var/log/mail.log | ccze -A
```

### Успешный результат

В логах должно быть:
```
status=sent (250 2.0.0 Ok: queued as XXXXXXX)
```

---

## Дальнейшие шаги

### 1. Настройка DNS для улучшения доставляемости

Для предотвращения попадания писем в спам:

| Запись | Тип | Значение |
|--------|-----|----------|
| **SPF** | TXT | `v=spf1 mx ip4:ВАШ_IP_АДРЕС -all` |
| **DKIM** | TXT | Инструкцию даст Рамблер в настройках домена |
| **DMARC** | TXT | `v=DMARC1; p=none; rua=mailto:admin@runtel.ru` |
| **PTR** | У провайдера | `ВАШ_IP` → `mail.runtel.ru` |

### 2. Использование релея приложениями

Теперь любые приложения могут отправлять почту через:
- SMTP-сервер: `localhost` (или `127.0.0.1`)
- Порт: `25` (стандартный)
- Без аутентификации (Postfix сам отправит через Рамблер)

### 3. Мониторинг

```bash
# Просмотр очереди
mailq

# Принудительная отправка отложенных писем
postqueue -f
```

---

## Резюме ошибок и решений

| № | Ошибка | Причина | Решение |
|---|--------|---------|---------|
| 1 | `535 Invalid user or password` | Неверный пароль или нужен пароль приложения | Создать пароль приложения (Яндекс) или использовать другой сервис |
| 2 | `This user does not have access rights` | Яндекс блокирует SMTP для личных аккаунтов | Использовать другой SMTP-сервис |
| 3 | `SMTPS wrappermode requires smtp_tls_wrappermode` | Порт 465 требует специальной настройки | Добавить `smtp_tls_wrappermode = yes` |
| 4 | `Sender address rejected: Envelope from do not match auth data` | Адрес отправителя не совпадает с логином | Настроить `smtp_generic_maps` |
| 5 | `SASL authentication failed` для bounce | Bounce-письма используют неправильный адрес | Исправляется вместе с ошибкой №4 |

---

## Заключение

Ваш SMTP-релей полностью настроен и готов к работе. Письма теперь будут отправляться через Рамблер Почту с адреса `kkorablin@ro.ru`. Это решение:
- ✅ Работает в РФ без VPN
- ✅ Не требует номера телефона для регистрации
- ✅ Обеспечивает надежную доставку писем
- ✅ Централизует отправку почты от всех приложений

Для корпоративного использования рекомендуется настроить DNS-записи и использовать выделенный домен для отправки.

