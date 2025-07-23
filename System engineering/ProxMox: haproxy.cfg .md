<details>
<summary>/etc/haproxy/haproxy.cfg</summary>

```cfg
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log global
    mode tcp
    option tcplog
    option dontlognull
    timeout connect 5000
    timeout client 50000
    timeout server 50000

listen stats
    bind *:7000
    mode http
    stats enable
    stats uri /
    stats refresh 10s
    stats admin if TRUE

backend postgres_master
    mode tcp
    balance roundrobin
    option httpchk GET /master
    http-check expect status 200
    default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
    server pg1 192.168.45.201:5432 check port 8008 inter 5s rise 2 fall 3
    server pg2 192.168.45.202:5432 check port 8008 inter 5s rise 2 fall 3
    server pg3 192.168.45.204:5432 check port 8008 inter 5s rise 2 fall 3

backend postgres_replica
    mode tcp
    balance roundrobin
    option httpchk GET /replica
    http-check expect status 200
    default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
    server pg1 192.168.45.201:5432 check port 8008 inter 5s rise 2 fall 3
    server pg2 192.168.45.202:5432 check port 8008 inter 5s rise 2 fall 3
    server pg3 192.168.45.204:5432 check port 8008 inter 5s rise 2 fall 3

frontend postgres_frontend
    bind *:5000
    mode tcp
    default_backend postgres_master

frontend postgres_readonly
    bind *:5001
    mode tcp
    default_backend postgres_replica

```
</details>

В конце файла должна быть пустая строка обязательно.

--------------
Это конфигурационный файл HAProxy, который используется для балансировки нагрузки и управления подключениями к кластеру PostgreSQL с Patroni.

### Глобальные настройки (global)
```cfg
log /dev/log local0          # Логирование в syslog с уровнем local0
log /dev/log local1 notice  # Доп. логирование с уровнем local1 и выше notice
chroot /var/lib/haproxy     # Изоляция процесса в chroot
stats socket /run/haproxy/admin.sock mode 660 level admin  # Сокет для управления
stats timeout 30s           # Таймаут для stats
user haproxy                # Запуск от пользователя haproxy
group haproxy               # и группы haproxy
daemon                      # Запуск в фоновом режиме
```

### Настройки по умолчанию (defaults)
```cfg
log global                   # Использовать глобальные настройки логирования
mode tcp                     # Режим работы с TCP (не HTTP)
option tcplog                # Логировать TCP-соединения
option dontlognull           # Не логировать пустые соединения
timeout connect 5000         # Таймаут подключения 5 сек
timeout client 50000         # Таймаут клиента 50 сек
timeout server 50000         # Таймаут сервера 50 сек
```

### Статистика (listen stats)
```cfg
bind *:7000                  # Слушать порт 7000 для статистики
mode http                    # Режим HTTP для статистики
stats enable                 # Включить веб-интерфейс статистики
stats uri /                  # URL для статистики - корень
stats refresh 10s            # Автообновление каждые 10 сек
stats admin if TRUE          # Разрешить администрирование через веб
```

### Бэкенд для мастера (backend postgres_master)
```cfg
mode tcp                     # TCP-режим
balance roundrobin           # Алгоритм балансировки - round-robin
option httpchk GET /master   # Проверка здоровья через HTTP GET /master
http-check expect status 200 # Ожидать HTTP 200 OK
default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
server pg1 192.168.45.201:5432 check port 8008 inter 5s rise 2 fall 3
server pg2 192.168.45.202:5432 check port 8008 inter 5s rise 2 fall 3
server pg3 192.168.45.204:5432 check port 8008 inter 5s rise 2 fall 3
```
(Проверяет Patroni API на порту 8008, чтобы определить мастер-ноду)

### Бэкенд для реплик (backend postgres_replica)
```cfg
mode tcp                     # TCP-режим
balance roundrobin           # Алгоритм балансировки - round-robin
option httpchk GET /replica  # Проверка здоровья через HTTP GET /replica
http-check expect status 200 # Ожидать HTTP 200 OK
default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
server pg1 192.168.45.201:5432 check port 8008 inter 5s rise 2 fall 3
server pg2 192.168.45.202:5432 check port 8008 inter 5s rise 2 fall 3
server pg3 192.168.45.204:5432 check port 8008 inter 5s rise 2 fall 3
```
(Проверяет Patroni API на порту 8008, чтобы определить работоспособные реплики)

### Фронтенд для записи (frontend postgres_frontend)
```cfg
bind *:5000                  # Слушать порт 5000
mode tcp                     # TCP-режим
default_backend postgres_master # По умолчанию перенаправлять на мастер-бэкенд
```

### Фронтенд для чтения (frontend postgres_readonly)
```cfg
bind *:5001                  # Слушать порт 5001
mode tcp                     # TCP-режим
default_backend postgres_replica # По умолчанию перенаправлять на реплика-бэкенд
```

Эта конфигурация обеспечивает:
1. Автоматическое определение мастера через Patroni API
2. Балансировку нагрузки на реплики для read-only запросов
3. Мониторинг состояния всех узлов
4. Веб-интерфейс статистики на порту 7000
5. Раздельные порты для записи (5000) и чтения (5001)


--------------

### Проверка файл на наличие скрытых символов:
```bash
cat -A /etc/haproxy/haproxy.cfg
```
### Проверка валидности
```bash
ls -alF /etc/haproxy/haproxy.cfg
haproxy -c -f /etc/haproxy/haproxy.cfg
```
### HAProxy в режиме отладки прямо в терминале:
```bash
haproxy -f /etc/haproxy/haproxy.cfg -d
```

