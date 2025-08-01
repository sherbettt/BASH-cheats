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


### **Строка `default-server` (настройки по умолчанию для всех серверов в бэкенде)**
```plaintext
default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
```
- **`inter 3s`** (interval)  
  → Интервал между проверками здоровья (health checks) — **3 секунды**.
  
- **`fall 3`**  
  → Сервер считается "нерабочим" (down), если **3 проверки подряд завершились неудачно**.  
  → Это защита от ложных срабатываний (например, из-за кратковременной сетевой проблемы).

- **`rise 2`**  
  → Сервер снова считается "рабочим" (up), если **2 проверки подряд прошли успешно**.  
  → Это предотвращает слишком быстрое возвращение в строй, если сервер ещё не стабилен.

- **`on-marked-down shutdown-sessions`**  
  → Если сервер помечен как `down`, HAProxy **немедленно разрывает все активные соединения** к нему.  
  → Это важно для PostgreSQL, чтобы клиенты не пытались писать в отключённый мастер.



### **Строки `server` (настройки для каждого конкретного сервера PostgreSQL)**
```plaintext
server pg1 192.168.45.201:5432 check port 8008 inter 5s rise 2 fall 3
```
- **`server pg1 192.168.45.201:5432`**  
  → Определяет сервер с именем `pg1`, доступный по адресу `192.168.45.201:5432` (PostgreSQL).

- **`check`**  
  → Включает **проверку здоровья** (health check) для этого сервера.

- **`port 8008`**  
  → Проверка здоровья выполняется **не на порту 5432 (PostgreSQL), а на 8008** (Patroni REST API).  
  → Patroni предоставляет `/master` и `/replica` эндпоинты для определения роли сервера.

- **`inter 5s`**  
  → Интервал проверок здоровья — **5 секунд** (переопределяет `default-server inter 3s`).  
  → Более редкие проверки, чем в `default-server`, чтобы снизить нагрузку.

- **`rise 2`**  
  → Как и в `default-server`, но явно указано для ясности.  
  → 2 успешные проверки, чтобы сервер снова стал `active`.

- **`fall 3`**  
  → 3 неудачные проверки, чтобы сервер помечался как `down`.  
  → Согласовано с `default-server`, но можно изменить для отдельных серверов.


### **Как это работает в связке с Patroni?**
1. **HAProxy проверяет Patroni API (`:8008`)**:
   - Для мастера: `GET /master` → должен вернуть `HTTP 200`.
   - Для реплики: `GET /replica` → должен вернуть `HTTP 200`.
2. **Если мастер падает**:
   - Patroni автоматически переключает роль на другую ноду.
   - HAProxy обнаруживает это через `check port 8008` и перенаправляет трафик на новый мастер.
3. **Если реплика отстаёт или недоступна**:
   - HAProxy исключает её из балансировки (`fall 3`), пока она не восстановится (`rise 2`).


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

