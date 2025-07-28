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




Для применения изменений:
```bash
nginx -t && systemctl reload nginx
```
