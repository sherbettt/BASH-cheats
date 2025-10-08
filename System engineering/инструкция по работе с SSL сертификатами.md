# Подробная инструкция по работе с SSL сертификатами

## 1. Проверка SSL сертификата сайта

### Проверить удаленный сервер:
```bash
# Базовая проверка
openssl s_client -connect domain.com:443 -servername domain.com

# С проверкой цепочки сертификатов
openssl s_client -connect domain.com:443 -servername domain.com -verify_return_error -showcerts

# Только проверка без деталей
echo | openssl s_client -connect domain.com:443 -servername domain.com 2>/dev/null | openssl x509 -noout -dates
```

### Проверить локальный сервер:
```bash
# Через localhost
openssl s_client -connect localhost:443 -servername domain.com

# Через внутренний IP
openssl s_client -connect 192.168.1.100:443 -servername domain.com
```

## 2. Анализ SSL сертификатов

### Просмотр информации о сертификате:
```bash
# Основная информация
openssl x509 -in certificate.pem -text -noout

# Только даты действия
openssl x509 -in certificate.pem -noout -dates

# Только субъект (для кого выдан)
openssl x509 -in certificate.pem -noout -subject

# Только издатель
openssl x509 -in certificate.pem -noout -issuer

# Альтернативные имена (SAN)
openssl x509 -in certificate.pem -noout -ext subjectAltName
```

### Проверить приватный ключ:
```bash
# Проверить соответствие ключа и сертификата
openssl x509 -noout -modulus -in certificate.pem | openssl md5
openssl rsa -noout -modulus -in private.key | openssl md5
# Хэши должны совпадать

# Проверить валидность ключа
openssl rsa -in private.key -check
```

## 3. Работа с файлами сертификатов

### Анализ структуры PEM файла:
```bash
# Посмотреть что внутри файла
cat certificate.pem

# Проверить структуру
grep -E "(BEGIN|END) (CERTIFICATE|PRIVATE KEY|RSA PRIVATE KEY)" certificate.pem

# Подсчитать количество сертификатов в цепочке
grep -c "BEGIN CERTIFICATE" certificate.pem
```

### Разделение комбинированного PEM файла:
```bash
# Извлечь приватный ключ
sed -n '/-----BEGIN RSA PRIVATE KEY-----/,/-----END RSA PRIVATE KEY-----/p' combined.pem > private.key

# Извлечь первый сертификат (доменный)
awk '/-----BEGIN CERTIFICATE-----/{flag=1} flag; /-----END CERTIFICATE-----/{flag=0; exit}' combined.pem > domain.crt

# Извлечь все сертификаты
csplit -f cert- combined.pem '/-----BEGIN CERTIFICATE-----/' '{*}'
```

## 4. Проверка конфигурации Nginx

### Проверить синтаксис конфига:
```bash
nginx -t
```

### Проверить какие порты слушает nginx:
```bash
# Вариант 1
netstat -tulpn | grep nginx

# Вариант 2 (современный)
ss -tulpn | grep nginx

# Вариант 3
lsof -i -P | grep nginx
```

### Просмотр конфигурации сайтов:
```bash
# Список включенных сайтов
ls -la /etc/nginx/sites-enabled/

# Просмотр конфига конкретного сайта
cat /etc/nginx/sites-enabled/domain.com
```

## 5. Диагностика сетевых проблем

### Проверить DNS разрешение:
```bash
nslookup domain.com
dig domain.com
host domain.com
```

### Проверить доступность портов:
```bash
# Проверить открыт ли порт
telnet domain.com 443
nc -zv domain.com 443

# Проверить изнутри сервера
curl -k -I https://localhost/
curl -k -I https://127.0.0.1/
```

### Проверить firewall:
```bash
# iptables
iptables -L -n -v

# ufw
ufw status

# firewalld
firewall-cmd --list-all
```

## 6. Работа с iptables

### Открыть порты для веб-сервера:
```bash
# Разрешить HTTP
iptables -I INPUT -p tcp --dport 80 -j ACCEPT

# Разрешить HTTPS
iptables -I INPUT -p tcp --dport 443 -j ACCEPT

# Сохранить правила
iptables-save > /etc/iptables/rules.v4

# Или использовать iptables-persistent
apt-get install iptables-persistent
netfilter-persistent save
```

## 7. Проверка цепочки сертификатов

### Валидация цепочки:
```bash
# Проверить всю цепочку
openssl verify -untrusted intermediate.crt domain.crt

# Или если все в одном файле
openssl verify -CAfile ca-bundle.crt domain.crt
```

### Скачать цепочку сертификатов:
```bash
# Получить всю цепочку с сервера
openssl s_client -connect domain.com:443 -showcerts </dev/null > chain.pem
```

## 8. Полезные команды для мониторинга

### Проверить истечение срока действия:
```bash
# Дата истечения
openssl x509 -in certificate.pem -noout -enddate

# Сколько дней осталось
openssl x509 -in certificate.pem -noout -enddate | cut -d= -f2 | xargs -I {} date -d {} +%s | xargs -I {} echo $(( ({} - $(date +%s)) / 86400 )) days
```

### Автоматическая проверка:
```bash
#!/bin/bash
DOMAIN="lk-fuji.cprt.su"
echo "Проверка SSL для $DOMAIN"

# Проверка подключения
if openssl s_client -connect $DOMAIN:443 -servername $DOMAIN -verify_return_error < /dev/null 2>/dev/null; then
    echo "✅ SSL подключение работает"
    
    # Информация о сертификате
    echo "📅 Срок действия:"
    openssl s_client -connect $DOMAIN:443 -servername $DOMAIN < /dev/null 2>/dev/null | openssl x509 -noout -dates
    
    echo "👤 Владелец:"
    openssl s_client -connect $DOMAIN:443 -servername $DOMAIN < /dev/null 2>/dev/null | openssl x509 -noout -subject
    
else
    echo "❌ Ошибка SSL подключения"
fi
```

## 9. Частые проблемы и решения

### "Connection refused":
- Nginx не слушает порт
- Firewall блокирует
- Неправильная привязка в конфиге

### "Certificate name mismatch":
- Сертификат выдан для другого домена
- Проверить Subject и SAN

### "bad end line" в PEM файле:
- Файл обрезан или поврежден
- Пересоздать правильный PEM

### "SSL handshake failed":
- Несоответствие ключа и сертификата
- Неправильная цепочка сертификатов
