Для создания трех нод в сети `pgnet` с установкой Debian 12, etcd и Patroni, выполните следующие шаги:

### 1. Создаем три LXC контейнера (по одному на каждую ноду)

**Нода 1:**
```bash
pct create 201 local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst \
  --hostname pg-node1 \
  --cores 2 \
  --memory 2048 \
  --swap 1024 \
  --storage local \
  --net0 name=eth0,bridge=pgnet,ip=10.10.10.1/24,gw=10.10.10.1 \
  --unprivileged 1 \
  --start
```

**Нода 2:**
```bash
pct create 202 local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst \
  --hostname pg-node2 \
  --cores 2 \
  --memory 2048 \
  --swap 1024 \
  --storage local \
  --net0 name=eth0,bridge=pgnet,ip=10.10.10.2/24,gw=10.10.10.1 \
  --unprivileged 1 \
  --start
```

**Нода 3:**
```bash
pct create 203 local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst \
  --hostname pg-node3 \
  --cores 2 \
  --memory 2048 \
  --swap 1024 \
  --storage local \
  --net0 name=eth0,bridge=pgnet,ip=10.10.10.3/24,gw=10.10.10.1 \
  --unprivileged 1 \
  --start
```


### 1. [ALT] Создание виртуальных машин (LXC контейнеров)
Создадим три LXC контейнера с Debian 12 в сети `pgnet`:

```bash
for i in {1..3}; do
  pct create $((200+i)) \
    local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst \
    --hostname pg-node${i} \
    --cores 2 \
    --memory 2048 \
    --swap 1024 \
    --storage local \
    --net0 name=eth0,bridge=pgnet,ip=10.10.10.${i}/24,gw=10.10.10.1 \
    --unprivileged 1 \
    --start
done
```

### 2. Настройка каждой ноды
Зайдите в каждую ноду (`pct enter 201`, `pct enter 202`, `pct enter 203`) и выполните:

#### Обновление системы:
```bash
apt update && apt upgrade -y
```

#### Установка зависимостей:
```bash
apt install -y sudo curl wget gnupg2 software-properties-common
```

### 3. Установка etcd
На каждой ноде выполните:

```bash
ETCD_VER=v3.5.0
wget https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xvf etcd-${ETCD_VER}-linux-amd64.tar.gz
cd etcd-${ETCD_VER}-linux-amd64
sudo mv etcd etcdctl /usr/local/bin/
```

#### Настройка etcd (пример для pg-node1):
```bash
cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd service
Documentation=https://github.com/etcd-io/etcd

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name pg-node1 \\
  --data-dir /var/lib/etcd \\
  --initial-advertise-peer-urls http://10.10.10.1:2380 \\
  --listen-peer-urls http://0.0.0.0:2380 \\
  --listen-client-urls http://0.0.0.0:2379 \\
  --advertise-client-urls http://10.10.10.1:2379 \\
  --initial-cluster-token etcd-cluster \\
  --initial-cluster pg-node1=http://10.10.10.1:2380,pg-node2=http://10.10.10.2:2380,pg-node3=http://10.10.10.3:2380 \\
  --initial-cluster-state new \\
  --heartbeat-interval 1000 \\
  --election-timeout 5000
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

Аналогично настройте для pg-node2 и pg-node3, изменив IP-адреса и имена.

#### Запуск etcd:
```bash
systemctl daemon-reload
systemctl enable --now etcd
```

### 4. Установка PostgreSQL и Patroni
На каждой ноде:

#### Добавление репозитория PostgreSQL:
```bash
echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
apt update
```

#### Установка PostgreSQL и Patroni:
```bash
apt install -y postgresql-15 patroni python3-python-etcd
```

#### Настройка Patroni (пример для pg-node1):
```bash
cat <<EOF | sudo tee /etc/patroni.yml
scope: pg-cluster
namespace: /service/
name: pg-node1

restapi:
  listen: 10.10.10.1:8008
  connect_address: 10.10.10.1:8008

etcd:
  hosts: 10.10.10.1:2379,10.10.10.2:2379,10.10.10.3:2379

bootstrap:
  dcs:
    ttl: 30
    loop_wait: 10
    retry_timeout: 10
    maximum_lag_on_failover: 1048576
    postgresql:
      use_pg_rewind: true
      parameters:
        max_connections: 100
        shared_buffers: 128MB
        dynamic_shared_memory_type: posix

  initdb:
  - encoding: UTF8
  - data-checksums

  pg_hba:
  - host replication replicator 10.10.10.1/32 md5
  - host replication replicator 10.10.10.2/32 md5
  - host replication replicator 10.10.10.3/32 md5
  - host all all 10.10.10.0/24 md5

postgresql:
  listen: 10.10.10.1:5432
  connect_address: 10.10.10.1:5432
  data_dir: /var/lib/postgresql/15/main
  bin_dir: /usr/lib/postgresql/15/bin
  pgpass: /tmp/pgpass
  authentication:
    replication:
      username: replicator
      password: secretpassword
    superuser:
      username: postgres
      password: secretpassword

tags:
  nofailover: false
  noloadbalance: false
  clonefrom: false
EOF
```

Аналогично настройте для других нод, изменив `name`, `listen` и `connect_address`.

#### Запуск Patroni:
```bash
systemctl enable --now patroni
```

### 5. Проверка кластера
После запуска всех компонентов проверьте статус:

```bash
# Проверка etcd кластера
etcdctl member list

# Проверка Patroni кластера
patronictl -c /etc/patroni.yml list
```




