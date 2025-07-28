<details>
<summary>❗ sso.runtel.ru ❗</summary>

```c
### /etc/nginx/sites-enabled/sso.runtel.ru
#-------------------

upstream kc_servers {
    server 192.168.46.16:8443;
    server 192.168.46.17:8443 backup;
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
}


# There are sso.runtel.ru  requests
server {
    listen 8443 ssl http2;  # 
    listen [::]:8443 ssl http2;
    server_name sso.runtel.ru;

    
    # SSL conf
    ssl_certificate /etc/nginx/runtel.pem;
    ssl_certificate_key /etc/nginx/runtel.pem;
    ssl_protocols  TLSv1.2 TLSv1.3;
#    ssl_ciphers         HIGH:!aNULL:!MD5;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
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
#    proxy_ssl_server_name on;
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
    
#    error_page 502 503 504 /maintenance.html;
#    location = /maintenance.html {
#        root /var/www/html;
#        internal;
    }
```
</details>
<br/>



### **Upstream-блок (определение группы серверов)**
```nginx
upstream kc_servers {
    server 192.168.46.16:8443;
    server 192.168.46.17:8443 backup;
}
```
- **`upstream kc_servers`** — создает группу серверов с именем `kc_servers` для балансировки нагрузки.
- **`server 192.168.46.16:8443`** — основной сервер, на который будут перенаправляться запросы.
- **`server 192.168.46.17:8443 backup`** — резервный сервер, который будет использоваться только при недоступности основного.



### **Серверный блок для всех остальных доменов (default_server)**
```nginx
server {
    listen 8443 ssl default_server;
    listen [::]:8443 ssl default_server;
    server_name _;
```
- **`listen 8443 ssl default_server`** — сервер слушает порт 8443 с SSL для любого домена (так как указан `default_server`).
- **`listen [::]:8443 ssl default_server`** — аналогично, но для IPv6.
- **`server_name _`** — обрабатывает все запросы, не подходящие под другие `server_name`.

```nginx
    ssl_certificate /etc/nginx/runtel.pem;
    ssl_certificate_key /etc/nginx/runtel.pem;
```
- Указывает SSL-сертификат и ключ (в данном случае один файл для обоих).

```nginx
    ssl_protocols TLSv1.2 TLSv1.3;
```
- Разрешает только TLS версий 1.2 и 1.3 (без устаревших SSL).

```nginx
    return 444;       # Close session without answer
}
```
- **`return 444`** — соединение закрывается без ответа (Nginx-специфичный код для "молчаливого" разрыва).



### **Серверный блок для sso.runtel.ru**
```nginx
server {
    listen 8443 ssl http2;
    listen [::]:8443 ssl http2;
    server_name sso.runtel.ru;
```
- **`listen 8443 ssl http2`** — слушает порт 8443 с SSL и HTTP/2.
- **`server_name sso.runtel.ru`** — обрабатывает только запросы к этому домену.

#### **SSL-настройки**
```nginx
    ssl_certificate /etc/nginx/runtel.pem;
    ssl_certificate_key /etc/nginx/runtel.pem;
```
- Пути к SSL-сертификату и ключу.

```nginx
    ssl_protocols  TLSv1.2 TLSv1.3;
```
- Разрешенные протоколы (без TLS 1.0 и 1.1).

```nginx
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
```
- Разрешенные шифры (только безопасные современные алгоритмы).

```nginx
    ssl_prefer_server_ciphers on;
```
- Приоритет серверных шифров над клиентскими.

```nginx
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_session_tickets off;
```
- **`ssl_session_cache`** — кеш SSL-сессий для ускорения handshake.
- **`ssl_session_timeout`** — время жизни сессии (10 минут).
- **`ssl_session_tickets off`** — отключает TLS-билеты (улучшает безопасность).



#### **Security Headers (заголовки безопасности)**
```nginx
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
```
- **HSTS** — принудительное использование HTTPS на 2 года (`max-age=63072000`), включая поддомены.

```nginx
    add_header X-Frame-Options DENY;
```
- Запрещает встраивание страницы в `<iframe>` (защита от clickjacking).

```nginx
    add_header X-Content-Type-Options nosniff;
```
- Запрещает браузеру "угадывать" MIME-тип (защита от XSS).

```nginx
    add_header Referrer-Policy strict-origin-when-cross-origin;
```
- Контролирует передачу Referer-заголовка (ограничивает утечку данных).



#### **Proxy-настройки (перенаправление на Keycloak)**
```nginx
    proxy_ssl_verify off;
```
- Отключает проверку SSL-сертификата upstream-сервера (не рекомендуется в продакшене).

```nginx
    location / {
        proxy_pass https://kc_servers;
```
- Все запросы перенаправляются на серверы из `upstream kc_servers`.

```nginx
        proxy_read_timeout 300s;
        proxy_connect_timeout 5s;
```
- **`proxy_read_timeout`** — максимальное время ожидания ответа (5 минут).
- **`proxy_connect_timeout`** — время на установку соединения (5 секунд).

```nginx
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```
- Передает заголовки:
  - **`Host`** — исходный домен.
  - **`X-Real-IP`** — реальный IP клиента.
  - **`X-Forwarded-For`** — цепочка прокси.

```nginx
        proxy_http_version 1.1;
```
- Использует HTTP/1.1 для связи с бэкендом.

```nginx
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_403 http_404 non_idempotent;
        proxy_next_upstream_timeout 5;
```
- **`proxy_next_upstream`** — условия переключения на резервный сервер (ошибки, таймауты и т. д.).
- **`proxy_next_upstream_timeout`** — время ожидания перед переключением (5 секунд).

```nginx
        proxy_intercept_errors on;
```
- Позволяет Nginx обрабатывать ошибки от бэкенда (например, показывать свою страницу 502).



#### **Health Check**
```nginx
    location = /health {
        access_log off;
        proxy_pass https://kc_servers;
    }
```
- **`/health`** — эндпоинт для проверки здоровья (логирование отключено).



#### **Заглушка для ошибок (закомментирована)**
```nginx
#    error_page 502 503 504 /maintenance.html;
#    location = /maintenance.html {
#        root /var/www/html;
#        internal;
```
- Если раскомментировать, при ошибках 502/503/504 будет показываться статичная страница `maintenance.html`.


Для применения изменений:
```bash
nginx -t && systemctl reload nginx
```


### **Итог**
Конфигурация:
1. Перенаправляет запросы к `sso.runtel.ru` на кластер Keycloak (`192.168.46.16` и `192.168.46.17`).
2. Блокирует все остальные домены (код 444).
3. Настроена безопасность (TLS, заголовки, шифры).
4. Поддержка HTTP/2 для ускорения загрузки.
5. Есть health-check и резервирование (backup-сервер). 

**Рекомендации:**
- Включить `proxy_ssl_verify` и добавить корневой сертификат для проверки бэкенда.
- Настроить отдельные файлы для сертификата и ключа (не `.pem`).





