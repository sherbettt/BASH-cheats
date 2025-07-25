<details>
<summary>❗ sso.runtel.ru ❗</summary>

```c
### /etc/nginx/sites-enabled/sso.runtel.ru
#-------------------

upstream kc_servers {
    server 192.168.46.16:8443;
    # server 192.168.46.17:8443 backup;
}

# There are  any-other-domain.com:8443  requests
# Call-all server
server {
    listen 8443 ssl default_server;
    listen [::]:8443 ssl default_server;
    server_name _;
    
    # Really sertificates haven't beed used
    ssl_certificate /etc/nginx/runtel.pem;
    ssl_certificate_key /etc/nginx/runtel.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    return 444;       # Close session without answer

    # Отключаем все логи для этого блока
    access_log off;
    log_not_found off;
    error_log /dev/null crit;
}


# There are sso.runtel.ru  requests
server {
    listen 8443 ssl http2;  # 
    listen [::]:8443 ssl http2;
    server_name sso.runtel.ru;

    
    # SSL conf
    ssl_certificate /etc/nginx/runtel.pem;
    ssl_certificate_key /etc/nginx/runtel.pem;
    ssl_protocols  TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;
#    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_session_tickets off;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header Referrer-Policy strict-origin-when-cross-origin;
    
    # Proxy settings
    proxy_ssl_server_name on;
    proxy_ssl_verify off;
    
    location / {
        proxy_pass https://kc_servers;
        proxy_read_timeout 300s;
        proxy_connect_timeout 5s;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_403 http_404 non_idempotent;
        proxy_next_upstream_timeout 5;
        proxy_intercept_errors on;
    }
    
    location = /health {
        access_log off;
        proxy_pass https://kc_servers;
    }
    
    error_page 502 503 504 /maintenance.html;
    location = /maintenance.html {
        root /var/www/html;
        internal;
    }
```
</details>

Вот подробное построчное объяснение нашей конфигурации NGINX:

### 1. Upstream-блок
```nginx
upstream kc_servers {
    server 192.168.46.16:8443;
    # server 192.168.46.17:8443 backup;
}
```
- **`upstream kc_servers`**: Создает группу серверов для балансировки нагрузки
- **`server 192.168.46.16:8443`**: Основной сервер Keycloak
- **`# server 192.168.46.17:8443 backup;`**: Закомментированный резервный сервер (будет использоваться только при недоступности основного)

### 2. Блок server
```nginx
server {
    listen 8443 ssl http2 default_server;
    listen [::]:8443 ssl http2 default_server;
```
- **`listen 8443 ssl http2`**: Слушает порт 8443 с SSL и HTTP/2 для IPv4
- **`listen [::]:8443`**: То же самое для IPv6
- **`default_server`**: Делает этот сервер обработчиком по умолчанию для всех запросов на порт 8443; это boolean флаг, который указывает, что данный server-блок должен обрабатывать все запросы, которые:
    - Приходят на указанный порт (в нашем случае 8443)
    - Не соответствуют ни одному из других server_name в конфигурации
    - Или приходят по IP-адресу вместо доменного имени


### 3. Настройки сервера
```nginx
    server_name sso.runtel.ru;
```
- Определяет доменное имя, для которого применяется эта конфигурация

### 4. SSL-настройки
```nginx
    ssl_certificate /etc/nginx/runtel.pem;
    ssl_certificate_key /etc/nginx/runtel.pem;
```
- Пути к SSL-сертификату и приватному ключу (в одном файле PEM)

```nginx
    ssl_protocols  TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
```
- Разрешенные версии TLS (рекомендуется убрать TLSv1 и TLSv1.1)

```nginx
    ssl_ciphers         HIGH:!aNULL:!MD5;
```
- Разрешенные алгоритмы шифрования (устаревшая настройка, лучше использовать явный список)

```nginx
    ssl_prefer_server_ciphers on;
```
- Приоритет серверных настроек шифрования над клиентскими

```nginx
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_session_tickets off;
```
- Настройки кэширования SSL-сессий для улучшения производительности

### 5. Security headers
```nginx
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
```
- HSTS: Принудительное использование HTTPS на 2 года для всех поддоменов

```nginx
    add_header X-Frame-Options DENY;
```
- Запрет встраивания страницы в iframe (защита от clickjacking)

```nginx
    add_header X-Content-Type-Options nosniff;
```
- Запрет браузеру менять MIME-тип контента

```nginx
    add_header Referrer-Policy strict-origin-when-cross-origin;
```
- Контроль передачи Referer-заголовка

### 6. Настройки проксирования
```nginx
    proxy_ssl_server_name on;
    proxy_ssl_verify off;
```
- Включение SNI при проксировании
- Отключение проверки SSL сертификата бэкенда (не рекомендуется для production)

### 7. Location / (основной блок)
```nginx
    location / {
        proxy_pass https://kc_servers;
```
- Проксирует все запросы на upstream-группу kc_servers

```nginx
        proxy_read_timeout 300s;
        proxy_connect_timeout 5s;
```
- Таймауты на чтение (5 минут) и подключение (5 секунд)

```nginx
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```
- Передача оригинальных заголовков бэкенду

```nginx
        proxy_http_version 1.1;
```
- Использование HTTP/1.1 для соединения с бэкендом

```nginx
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_403 http_404 non_idempotent;
        proxy_next_upstream_timeout 5;
```
- Политика повтора запросов при ошибках
- Таймаут повтора 5 секунд

```nginx
        proxy_intercept_errors on;
```
- Перехват ошибок от бэкенда для их обработки в NGINX

### 8. Health check
```nginx
    location = /health {
        access_log off;
        proxy_pass https://kc_servers;
    }
```
- Эндпоинт для проверки здоровья (без логирования)

### 9. Обработка ошибок
```nginx
    error_page 502 503 504 /maintenance.html;
    location = /maintenance.html {
        root /var/www/html;
        internal;
    }
```
- Кастомная страница при ошибках 50x
- `internal` - доступ только через внутренние редиректы NGINX

### Критические замечания:

1. **Уязвимые протоколы**:
   ```nginx
   ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
   ```
   Должно быть:
   ```nginx
   ssl_protocols TLSv1.2 TLSv1.3;
   ```

2. **Слабые шифры**:
   ```nginx
   ssl_ciphers HIGH:!aNULL:!MD5;
   ```
   Рекомендуется:
   ```nginx
   ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
   ```

3. **Проверка SSL бэкенда**:
   ```nginx
   proxy_ssl_verify off;
   ```
   В production лучше включить проверку:
   ```nginx
   proxy_ssl_verify on;
   proxy_ssl_trusted_certificate /path/to/ca.crt;
   ```
