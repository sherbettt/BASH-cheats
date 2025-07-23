<details>
<summary>/etc/haproxy/haproxy.cfg</summary>

```cfg
root@pg1 /etc/haproxy # cat haproxy.cfg
global
	log /dev/log	local0
	log /dev/log	local1 notice
	chroot /var/lib/haproxy
	stats socket /run/haproxy/admin.sock mode 660 level admin
	stats timeout 30s
	user haproxy
	group haproxy
	daemon

	# Default SSL material locations
	ca-base /etc/ssl/certs
	crt-base /etc/ssl/private

	# See: https://ssl-config.mozilla.org/#server=haproxy&server-version=2.0.3&config=intermediate
        ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
        ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
        ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

defaults
	log	global
	mode	http
	option	httplog
	option	dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
	errorfile 400 /etc/haproxy/errors/400.http
	errorfile 403 /etc/haproxy/errors/403.http
	errorfile 408 /etc/haproxy/errors/408.http
	errorfile 500 /etc/haproxy/errors/500.http
	errorfile 502 /etc/haproxy/errors/502.http
	errorfile 503 /etc/haproxy/errors/503.http
	errorfile 504 /etc/haproxy/errors/504.http

# Include Haproxy statistic (for web-interface)
listen stats
    bind *:7000
    mode http
    stats enable
    stats uri /
    stats refresh 10s
    stats admin if TRUE

# Backend for master node PostgreSQL
backend postgres_master
    mode tcp
    balance roundrobin
    option httpchk GET /master
    http-check expect status 200
    default-server inter 3s fall 3 rise 2
    server pg1 192.168.45.201:5432 check port=8008
    server pg2 192.168.45.202:5432 check port=8008
    server pg3 192.168.45.204:5432 check port=8008

# Backend for replica nodes PostgreSQL (read-only)
backend postgres_replica
    mode tcp
    balance roundrobin
    option httpchk GET /replica
    http-check expect status 200
    default-server inter 3s fall 3 rise 2
    server pg1 192.168.45.201:5432 check port=8008
    server pg2 192.168.45.202:5432 check port=8008
    server pg3 192.168.45.204:5432 check port=8008

# Frontend for SQL request
frontend postgres_frontend
    bind *:5000
    mode tcp
    default_backend postgres_master

# Read-only Frontend
frontend postgres_readonly
    bind *:5001
    mode tcp
```

</details>





