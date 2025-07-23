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

