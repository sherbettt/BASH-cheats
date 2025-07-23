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
    server pg1 192.168.45.201:5432 check port 8008
    server pg2 192.168.45.202:5432 check port 8008
    server pg3 192.168.45.204:5432 check port 8008

backend postgres_replica
    mode tcp
    balance roundrobin
    option httpchk GET /replica
    http-check expect status 200
    default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
    server pg1 192.168.45.201:5432 check port 8008
    server pg2 192.168.45.202:5432 check port 8008
    server pg3 192.168.45.204:5432 check port 8008

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
Вот подробное объяснение конфигурационного файла HAProxy (`/etc/haproxy/haproxy.cfg`) для вашего PostgreSQL-кластера с Patroni:


### **Секция `global`**
```haproxy
global
    log /dev/log local0           # Логирование в /dev/log с уровнем local0
    log /dev/log local1 notice    # Доп. логирование с уровнем local1 и приоритетом notice
    chroot /var/lib/haproxy       # Изоляция HAProxy в chroot-окружении
    stats socket /run/haproxy/admin.sock mode 660 level admin  # Unix-сокет для управления
    stats timeout 30s             # Таймаут для статистики
    user haproxy                 # Запуск от пользователя haproxy
    group haproxy                # Запуск от группы haproxy
    daemon                       # Режим демона (фоновая работа)
```
**Назначение**: Общие настройки HAProxy (логирование, безопасность, управление).



### **Секция `defaults`**
```haproxy
defaults
    log global                    # Использовать настройки логирования из global
    mode tcp                      # Режим работы с TCP (не HTTP)
    option tcplog                 # Логировать TCP-соединения
    option dontlognull            # Не логировать пустые соединения
    timeout connect 5000          # Таймаут подключения к серверу (5 сек)
    timeout client 50000          # Таймаут клиента (50 сек)
    timeout server 50000          # Таймаут сервера (50 сек)
```
**Назначение**: Базовые настройки для всех остальных секций (если не переопределены).



### **Секция `listen stats` (веб-интерфейс статистики)**
```haproxy
listen stats
    bind *:7000                   # Слушать порт 7000 на всех интерфейсах
    mode http                     # Режим HTTP (для веб-интерфейса)
    stats enable                  # Включить статистику
    stats uri /                   # URL для статистики (http://<IP>:7000/)
    stats refresh 10s             # Автообновление страницы каждые 10 сек
    stats admin if TRUE           # Разрешить админ-функции (например, управление серверами)
```
**Назначение**: Веб-интерфейс для мониторинга состояния HAProxy.



### **Бэкенд `postgres_master` (только мастер)**
```haproxy
backend postgres_master
    mode tcp                      # Режим TCP (для PostgreSQL)
    balance roundrobin            # Балансировка Round Robin
    option httpchk GET /master    # Проверка здоровья через HTTP GET /master
    http-check expect status 200  # Ожидать HTTP 200 (Patroni возвращает 200 только для мастера)
    default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions  # Настройки проверок
    server pg1 192.168.45.201:5432 check port 8008  # Сервер 1 (Patroni API на 8008)
    server pg2 192.168.45.202:5432 check port 8008  # Сервер 2
    server pg3 192.168.45.204:5432 check port 8008  # Сервер 3
```
**Назначение**:  
– Направлять запросы **только на текущий мастер-узел PostgreSQL**.  
– Patroni API (`/master`) возвращает `HTTP 200` только для лидера.  
– Если мастер падает, HAProxy исключает его из балансировки.



### **Бэкенд `postgres_replica` (только реплики)**
```haproxy
backend postgres_replica
    mode tcp                      # Режим TCP
    balance roundrobin            # Балансировка Round Robin
    option httpchk GET /replica   # Проверка через HTTP GET /replica
    http-check expect status 200  # Ожидать HTTP 200 (Patroni возвращает 200 для реплик)
    default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions  # Настройки проверок
    server pg1 192.168.45.201:5432 check port 8008  # Сервер 1
    server pg2 192.168.45.202:5432 check port 8008  # Сервер 2
    server pg3 192.168.45.204:5432 check port 8008  # Сервер 3
```
**Назначение**:  
– Направлять запросы **только на реплики PostgreSQL**.  
– Patroni API (`/replica`) возвращает `HTTP 200` для узлов в режиме реплики.  
– Если реплика отстаёт или недоступна, HAProxy исключает её из балансировки.



### **Фронтенд `postgres_frontend` (запись)**
```haproxy
frontend postgres_frontend
    bind *:5000                   # Слушать порт 5000 для запросов на запись
    mode tcp                      # Режим TCP
    default_backend postgres_master  # По умолчанию использовать бэкенд мастера
```
**Назначение**:  
– Принимает подключения на порту `5000` и перенаправляет их **только на мастер**.  
– Используется для операций `INSERT/UPDATE/DELETE`.



### **Фронтенд `postgres_readonly` (чтение)**
```haproxy
frontend postgres_readonly
    bind *:5001                   # Слушать порт 5001 для запросов на чтение
    mode tcp                      # Режим TCP
    default_backend postgres_replica  # По умолчанию использовать бэкенд реплик
```
**Назначение**:  
– Принимает подключения на порту `5001` и перенаправляет их **на реплики**.  
– Используется для операций `SELECT` (чтение).



### **Как это работает?**
1. **Для записи (`:5000`)**:
   - Клиент подключается к `192.168.45.X:5000`.
   - HAProxy проверяет через Patroni API (`:8008/master`), какой узел является мастером.
   - Трафик направляется **только на текущий мастер**.

2. **Для чтения (`:5001`)**:
   - Клиент подключается к `192.168.45.X:5001`.
   - HAProxy проверяет через Patroni API (`:8008/replica`), какие узлы являются репликами.
   - Трафик балансируется между всеми репликами.

3. **Автоматическое переключение при смене мастера**:
   - Если мастер (`pg2`) падает, Patroni назначает нового мастера (например, `pg1`).
   - HAProxy обнаруживает это через проверку `/master` и перенаправляет трафик на новый мастер.

4. **Мониторинг**:
   - Статистика доступна на `http://<IP>:7000/`.


### **Что можно улучшить?**
1. **Добавить резервный порт для мастера** (например, `5002`), если `postgres_master` пуст (в случае аварии).
2. **Настроить ACL** для разделения трафика по IP или другим правилам.
3. **SSL/TLS** для безопасного подключения к HAProxy.


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

