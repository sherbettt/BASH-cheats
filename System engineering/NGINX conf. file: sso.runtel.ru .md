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




### 1. Upstream-блок (балансировка нагрузки)
```nginx
upstream kc_servers {
    server 192.168.46.16:8443;       # Основной сервер Keycloak
    # server 192.168.46.17:8443 backup; # Резервный сервер (закомментирован)
}
```
- **Назначение**: Группирует серверы для проксирования
- **Особенности**:
  - `backup` - сервер используется только при недоступности основного
  - Порт 8443 - стандартный HTTPS-порт Keycloak

### 2. Catch-all сервер (блокировка "левых" запросов)
```nginx
server {
    listen 8443 ssl default_server;      # IPv4 + default
    listen [::]:8443 ssl default_server; # IPv6 + default
    server_name _;                       # Специальное значение для "ловушки"
    
    ssl_certificate /etc/nginx/runtel.pem;      # Путь к сертификату
    ssl_certificate_key /etc/nginx/runtel.pem;  # Путь к ключу
    
    ssl_protocols TLSv1.2 TLSv1.3;       # Безопасные протоколы
    return 444;                          # Молчаливое закрытие соединения
    
    access_log off;                      # Отключение логов доступа
    log_not_found off;                   # Игнорирование логов "не найдено"
    error_log /dev/null crit;            # Перенаправление ошибок в null
}
```
- **Ключевые моменты**:
  - `default_server` перехватывает все запросы, не попавшие в другие блоки
  - **`default_server`**: Делает этот сервер обработчиком по умолчанию для всех запросов на порт 8443; это boolean флаг, который указывает, что данный server-блок должен обрабатывать все запросы, которые:
    - Приходят на указанный порт (в нашем случае 8443)
    - Не соответствуют ни одному из других server_name в конфигурации
    - Или приходят по IP-адресу вместо доменного имени
  - `return 444` - уникальная функция NGINX для разрыва соединения без ответа
  - SSL обязателен, так как порт 8443 предполагает HTTPS

### 3. Основной сервер (обработка sso.runtel.ru)
```nginx
server {
    listen 8443 ssl http2;          # IPv4 + HTTP/2
    listen [::]:8443 ssl http2;     # IPv6 + HTTP/2
    server_name sso.runtel.ru;      # Доменное имя
```
- **Особенности**:
  - `http2` - версия HTTP-протокола
  - Явное указание `server_name` для точного совпадения

### 4. SSL-конфигурация
```nginx
    ssl_certificate /etc/nginx/runtel.pem;
    ssl_certificate_key /etc/nginx/runtel.pem;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_session_tickets off;
```
- **Рекомендации**:
  - Удалите `TLSv1` и `TLSv1.1` (уязвимы)
  - Замените `HIGH:!aNULL:!MD5` на конкретные безопасные шифры
  - `ssl_session_cache` уменьшает нагрузку при повторных соединениях

### 5. Security Headers
```nginx
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header Referrer-Policy strict-origin-when-cross-origin;
```
- **Защита от**:
  - Clickjacking (`X-Frame-Options`)
  - MIME-sniffing (`X-Content-Type-Options`)
  - Утечки referrer-данных

### 6. Проксирование на Keycloak
```nginx
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
```
- **Важные параметры**:
  - `proxy_set_header` - передача оригинальных заголовков
  - `proxy_next_upstream` - политика повторных попыток
  - `proxy_intercept_errors` - обработка ошибок бэкенда

### 7. Health Check и обработка ошибок
```nginx
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
- **Особенности**:
  - `/health` - endpoint для мониторинга (без логов)
  - Кастомная страница для 5xx ошибок
  - `internal` - запрет прямого доступа к странице ошибок

### Критические улучшения:
1. Обновите SSL-настройки:
```nginx
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
```

2. Добавьте в основной сервер:
```nginx
    # Защита от атак типа Slowloris
    client_body_timeout 10s;
    client_header_timeout 10s;
    keepalive_timeout 5s 5s;
    send_timeout 10s;
```

3. Для production добавьте:
```nginx
    # Защита от DDOS
    limit_req_zone $binary_remote_addr zone=one:10m rate=10r/s;
    limit_req zone=one burst=20;
```

Для применения изменений:
```bash
nginx -t && systemctl reload nginx
```
