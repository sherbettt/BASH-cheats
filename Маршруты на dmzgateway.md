- **MASTER GATEWAY** : **[(dmzgateway)](https://192.168.87.20:8006/#v1:0:=lxc%2F102:4::::::11:)**
- **MASTER GATEWAY1** : **[(dmzgateway1)](https://192.168.87.20:8006/#v1:0:=lxc%2F117:4::::::11:)**
- **MASTER GATEWAY2** : **[(dmzgateway2)](https://192.168.87.20:8006/#v1:0:=lxc%2F186:4::::::11:)**
- **MASTER GATEWAY3** : **[(dmzgateway3)](https://192.168.87.20:8006/#v1:0:=lxc%2F187:4::::::11:)**
<br/>


# Полное руководство по настройке маршрутизации между сетями через шлюз

## 📋 Содержание
1. [Общая схема сети](#схема)
2. [Настройка шлюза (dmzgateway)](#шлюз)
3. [Настройка ноутбука](#ноутбук)
4. [Проверка работоспособности](#проверка)
5. [Диагностика проблем](#диагностика)
6. [Постоянное сохранение настроек](#сохранение)

---

## 🏗️ Общая схема сети {#схема}

```text
+------------------------------------------------------------------------+
|                            Ноутбук                                     |
|                    192.168.87.151/24 (wlp1s0)                         |
|                              |                                         |
|                              |                                         |
|                    +-------------------+                               |
|                    |  Основной шлюз    |                               |
|                    |  192.168.87.1     |                               |
|                    +-------------------+                               |
|                              |                                         |
|                    +-------------------+                               |
|                    |   dmzgateway      |  (Контейнер 102)              |
|                    | 192.168.87.2/24   |                               |
|                    |     (eth0)        |                               |
|                    |                   |                               |
|                    | 192.168.46.1/24   |                               |
|                    |     (eth1)        |                               |
|                    |                   |                               |
|                    | 192.168.45.1/24   |                               |
|                    |     (eth2)        |                               |
|                    +-------------------+                               |
|                              |                                         |
|              +----------------+----------------+                       |
|              |                               |                       |
|      +----------------+             +----------------+               |
|      |   Сеть dmznet  |             |   Сеть pgnet   |               |
|      | 192.168.46.0/24|             | 192.168.45.0/24|               |
|      |                |             |                |               |
|      | 192.168.46.4   |             | 192.168.45.50  |               |
|      | 192.168.46.16  |             | 192.168.45.51  |               |
|      +----------------+             +----------------+               |
+------------------------------------------------------------------------+
```

---

## ⚙️ Настройка шлюза (dmzgateway) {#шлюз}

### 1. Подключение к шлюзу
```bash
# С ноутбука подключаемся к шлюзу
ssh root@192.168.87.253

# Проверяем текущие настройки сети
ip addr show
ip route show
```

### 2. Проверка интерфейсов
**Ожидаемый вывод:**
```bash
root@dmzgateway ~ # ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether xx:xx:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff
    inet 192.168.87.2/24 brd 192.168.87.255 scope global eth0
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether xx:xx:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff
    inet 192.168.46.1/24 brd 192.168.46.255 scope global eth1
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether xx:xx:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff
    inet 192.168.45.1/24 brd 192.168.45.255 scope global eth2
       valid_lft forever preferred_lft forever
```

### 3. Включение IP forwarding
```bash
# Проверяем текущее состояние
cat /proc/sys/net/ipv4/ip_forward

# Если 0, включаем
echo 1 > /proc/sys/net/ipv4/ip_forward

# Делаем постоянным
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# Проверяем
cat /proc/sys/net/ipv4/ip_forward
# Должно быть: 1
```

### 4. Настройка iptables правил

#### Очистка старых правил (осторожно!)
```bash
# Смотрим текущие правила
iptables -t nat -L -nv
iptables -L FORWARD -nv

# Очищаем только FORWARD и NAT (безопасно)
iptables -F FORWARD
iptables -t nat -F
```

#### Настройка NAT (MASQUERADE)
```bash
# NAT для сети 45.x
iptables -t nat -A POSTROUTING -s 192.168.45.0/24 -o eth0 -j MASQUERADE

# NAT для сети 46.x  
iptables -t nat -A POSTROUTING -s 192.168.46.0/24 -o eth0 -j MASQUERADE
```

#### Настройка FORWARD правил
```bash
# Разрешаем форвардинг из внутренних сетей в интернет
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT    # из dmznet в интернет
iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT    # из pgnet в интернет

# Разрешаем ответный трафик из интернета
iptables -A FORWARD -i eth0 -o eth1 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i eth0 -o eth2 -m state --state ESTABLISHED,RELATED -j ACCEPT

# Разрешаем обмен между внутренними сетями
iptables -A FORWARD -i eth1 -o eth2 -j ACCEPT    # dmznet -> pgnet
iptables -A FORWARD -i eth2 -o eth1 -j ACCEPT    # pgnet -> dmznet

# Разрешаем доступ из внешней сети (87.x) во внутренние
iptables -A FORWARD -i eth0 -o eth1 -s 192.168.87.0/24 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth2 -s 192.168.87.0/24 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -d 192.168.87.0/24 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -d 192.168.87.0/24 -j ACCEPT
```

### 5. Проверка правил на шлюзе
```bash
# Проверяем NAT правила
iptables -t nat -L -nv
# Должно быть:
# Chain POSTROUTING (policy ACCEPT)
# target     prot opt source               destination
# MASQUERADE  all  --  192.168.45.0/24     anywhere
# MASQUERADE  all  --  192.168.46.0/24     anywhere

# Проверяем FORWARD правила
iptables -L FORWARD -nv --line-numbers
# Должны быть все добавленные правила

# Проверяем политику FORWARD
iptables -L FORWARD -n
# Policy должна быть ACCEPT
```

---

## 💻 Настройка ноутбука {#ноутбук}

### 1. Проверка текущих настроек
```bash
# Смотрим текущие маршруты
ip route show

# Проверяем интерфейсы
ip addr show wlp1s0

# Проверяем доступность шлюза
ping -c 3 192.168.87.2
```

### 2. Добавление статических маршрутов

#### Безопасный способ (без очистки всех маршрутов)
```bash
# Удаляем старые маршруты если они есть (опционально)
sudo ip route del 192.168.45.0/24 2>/dev/null || true
sudo ip route del 192.168.46.0/24 2>/dev/null || true

# Добавляем маршруты к внутренним сетям через dmzgateway
sudo ip route add 192.168.45.0/24 via 192.168.87.2 dev wlp1s0
sudo ip route add 192.168.46.0/24 via 192.168.87.2 dev wlp1s0

# Проверяем
ip route show
```

**Ожидаемый вывод:**
```
default via 192.168.87.1 dev wlp1s0 proto dhcp metric 600 
192.168.45.0/24 via 192.168.87.2 dev wlp1s0 
192.168.46.0/24 via 192.168.87.2 dev wlp1s0 
192.168.87.0/24 dev wlp1s0 proto kernel scope link src 192.168.87.151 metric 600 
```

---

## 🔍 Проверка работоспособности {#проверка}

### 1. Базовая проверка связи
```bash
# С ноутбука проверяем:
echo "=== Проверка базовой связности ==="

echo "1. Проверка шлюза dmzgateway:"
ping -c 2 192.168.87.2

echo "2. Проверка шлюза dmznet:"
ping -c 2 192.168.46.1

echo "3. Проверка шлюза pgnet:"
ping -c 2 192.168.45.1

echo "4. Проверка хостов во внутренних сетях:"
ping -c 2 192.168.46.4
ping -c 2 192.168.45.50

echo "5. Проверка интернета:"
ping -c 2 8.8.8.8
```

### 2. Проверка с шлюза
```bash
# На dmzgateway проверяем:
echo "=== Проверка с шлюза ==="

echo "1. Доступность внутренних хостов:"
ping -c 2 192.168.46.4
ping -c 2 192.168.45.50

echo "2. Проверка счетчиков iptables:"
iptables -L FORWARD -nv
iptables -t nat -L -nv

echo "3. Проверка ARP таблицы:"
ip neigh show | grep -E "192.168.(45|46)"
```

---

## 🐛 Диагностика проблем {#диагностика}

### Если пинг не проходит:

#### 1. Проверка на шлюзе
```bash
# Включаем подробное логирование
echo "=== Диагностика на шлюзе ==="

echo "1. Проверка IP forward:"
cat /proc/sys/net/ipv4/ip_forward

echo "2. Проверка интерфейсов:"
ip addr show | grep -E "(eth0|eth1|eth2)"

echo "3. tcpdump для диагностики:"
# В одном терминале:
tcpdump -i eth1 -n host 192.168.46.4
# В другом терминале с ноутбука:
ping 192.168.46.4
```

#### 2. Проверка на ноутбуке
```bash
# Проверяем маршрутизацию
ip route get 192.168.46.4

# Проверяем ARP таблицу
ip neigh show

# tcpdump для отладки
sudo tcpdump -i wlp1s0 -n host 192.168.87.2
```

#### 3. Проверка на целевом хосте
```bash
# На хосте 192.168.46.4 проверяем:
ip route show
iptables -L -n  # если есть firewall

# Проверяем что хост слушает ICMP
cat /proc/sys/net/ipv4/icmp_echo_ignore_all
# Должно быть 0
```

---

## 💾 Постоянное сохранение настроек {#сохранение}

### На шлюзе (dmzgateway):

#### Способ 1: iptables-persistent (рекомендуется)
```bash
# Устанавливаем пакет
apt-get update
apt-get install iptables-persistent

# Сохраняем текущие правила
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

# Или используем встроенную команду
netfilter-persistent save

# Проверяем что правила сохранились
cat /etc/iptables/rules.v4
```

#### Способ 2: Скрипт в /etc/network/interfaces
```bash
# Редактируем конфиг
nano /etc/network/interfaces

# Добавляем в конец:
auto eth0
iface eth0 inet static
    address 192.168.87.2/24
    gateway 192.168.87.1
    post-up iptables-restore < /etc/iptables/rules.v4
```

#### Способ 3: Systemd сервис
```bash
# Создаем сервис
cat > /etc/systemd/system/iptables-restore.service << EOF
[Unit]
Description=Restore iptables rules
After=network.target

[Service]
Type=oneshot
ExecStart=/sbin/iptables-restore /etc/iptables/rules.v4
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable iptables-restore.service
```

### На ноутбуке (Ubuntu/ALT Linux):

#### Способ 1: Netplan (Ubuntu 18.04+)
```bash
# Редактируем конфиг
sudo nano /etc/netplan/01-network-manager-all.yaml

# Добавляем маршруты:
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    wlp1s0:
      dhcp4: yes
      routes:
        - to: 192.168.45.0/24
          via: 192.168.87.2
          metric: 100
        - to: 192.168.46.0/24
          via: 192.168.87.2
          metric: 100

# Применяем
sudo netplan apply
```

#### Способ 2: NetworkManager (ALT Linux/Ubuntu)
```bash
# Находим имя подключения
nmcli connection show

# Добавляем маршруты
sudo nmcli connection modify "runtel" +ipv4.routes "192.168.45.0/24 192.168.87.2, 192.168.46.0/24 192.168.87.2"

# Перезапускаем подключение
sudo nmcli connection down "runtel" && sudo nmcli connection up "runtel"
```

#### Способ 3: Скрипт в /etc/network/interfaces (ALT Linux)
```bash
# Редактируем конфиг
sudo nano /etc/network/interfaces

# Добавляем:
auto wlp1s0
iface wlp1s0 inet dhcp
    post-up ip route add 192.168.45.0/24 via 192.168.87.2 dev wlp1s0
    post-up ip route add 192.168.46.0/24 via 192.168.87.2 dev wlp1s0
    pre-down ip route del 192.168.45.0/24 via 192.168.87.2 dev wlp1s0
    pre-down ip route del 192.168.46.0/24 via 192.168.87.2 dev wlp1s0
```

---

## 📝 Чек-лист успешной настройки

- [ ] Шлюз: IP forwarding = 1
- [ ] Шлюз: Правила iptables настроены и сохранены
- [ ] Шлюз: NAT (MASQUERADE) работает
- [ ] Ноутбук: Маршруты добавлены в таблицу маршрутизации
- [ ] Ноутбук: Маршруты сохраняются после перезагрузки
- [ ] Пинг: dmzgateway (192.168.87.2) доступен
- [ ] Пинг: Внутренние шлюзы (192.168.45.1, 192.168.46.1) доступны
- [ ] Пинг: Хосты во внутренних сетях доступны
- [ ] Пинг: Интернет доступен с внутренних сетей
- [ ] Счетчики iptables на шлюзе увеличиваются

Эта инструкция покрывает все аспекты настройки маршрутизации между сетями. Сохраните её для будущего использования!


--------

## 🔧 Дополнение 1: Мониторинг и логирование

### Настройка логирования дропнутых пакетов на шлюзе
```bash
# Добавляем правила для логирования
iptables -I FORWARD -s 192.168.87.0/24 -d 192.168.46.0/24 -j LOG --log-prefix "FW-FORWARD-87-46: "
iptables -I FORWARD -s 192.168.87.0/24 -d 192.168.45.0/24 -j LOG --log-prefix "FW-FORWARD-87-45: "

# Смотрим логи в реальном времени
tail -f /var/log/syslog | grep FW-FORWARD

# Или для journald
journalctl -f | grep FW-FORWARD
```

### Мониторинг трафика через шлюз
```bash
# Скрипт для мониторинга счетчиков iptables
#!/bin/bash
watch -n 5 'iptables -L FORWARD -nv && echo "---" && iptables -t nat -L -nv'

# Или однострочник
while true; do clear; date; iptables -L FORWARD -nv; iptables -t nat -L -nv; sleep 5; done
```

## 🔧 Дополнение 2: Безопасность

### Базовые правила безопасности на шлюзе
```bash
# Защита от spoofing
iptables -A FORWARD -s 192.168.87.0/24 -i eth1 -j DROP    # 87.x не должен приходить с eth1
iptables -A FORWARD -s 192.168.87.0/24 -i eth2 -j DROP    # 87.x не должен приходить с eth2

# Ограничение SSH доступа к шлюзу только из trusted сетей
iptables -I INPUT -p tcp --dport 22 -s 192.168.87.0/24 -j ACCEPT
iptables -I INPUT -p tcp --dport 22 -j DROP

# Защита от flood ping
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
```

## 🔧 Дополнение 3: Расширенная диагностика

### Скрипт полной диагностики сети
```bash
#!/bin/bash
# save as network-check.sh

echo "=== COMPREHENSIVE NETWORK DIAGNOSIS ==="

echo "1. Basic connectivity:"
ping -c 2 192.168.87.2 && echo "✓ dmzgateway accessible" || echo "✗ dmzgateway unreachable"
ping -c 2 192.168.46.1 && echo "✓ dmznet gateway accessible" || echo "✗ dmznet gateway unreachable" 
ping -c 2 192.168.45.1 && echo "✓ pgnet gateway accessible" || echo "✗ pgnet gateway unreachable"

echo ""
echo "2. Routing table:"
ip route show

echo ""
echo "3. ARP table:"
ip neigh show

echo ""
echo "4. Interface status:"
ip addr show | grep -E "(wlp1s0|eth0|eth1|eth2)"

echo ""
echo "5. Check specific hosts:"
for host in 192.168.46.4 192.168.45.50 192.168.45.51; do
    ping -c 1 -W 1 $host &>/dev/null && echo "✓ $host accessible" || echo "✗ $host unreachable"
done

echo ""
echo "6. Tracepath to internal networks:"
tracepath 192.168.46.4 2>/dev/null | head -5
```

### Проверка портов и сервисов
```bash
# Проверка доступности конкретных портов
nc -zv 192.168.46.4 22    # SSH
nc -zv 192.168.46.4 80    # HTTP
nc -zv 192.168.46.4 443   # HTTPS

# Скрипт проверки основных портов
for host in 192.168.46.4 192.168.45.50; do
    echo "Checking $host:"
    for port in 22 80 443 53; do
        nc -zv -w 1 $host $port 2>/dev/null && echo "  PORT $port: OPEN" || echo "  PORT $port: CLOSED"
    done
done
```

## 🔧 Дополнение 4: Резервное копирование и восстановление

### Бэкап конфигурации шлюза
```bash
#!/bin/bash
# save as backup-gateway-config.sh

BACKUP_DIR="/root/network-backup"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

echo "Backing up gateway configuration..."

# iptables rules
iptables-save > $BACKUP_DIR/iptables-rules-$DATE.v4
ip6tables-save > $BACKUP_DIR/iptables-rules-$DATE.v6

# network configuration
cp /etc/network/interfaces $BACKUP_DIR/interfaces-$DATE
cp /etc/sysctl.conf $BACKUP_DIR/sysctl.conf-$DATE

# important files
cp /etc/iptables/rules.v4 $BACKUP_DIR/ 2>/dev/null || true

# create restore script
cat > $BACKUP_DIR/restore-config-$DATE.sh << 'EOF'
#!/bin/bash
echo "Restoring gateway configuration..."
iptables-restore < iptables-rules-$DATE.v4
cp interfaces-$DATE /etc/network/interfaces
cp sysctl.conf-$DATE /etc/sysctl.conf
sysctl -p
echo "Restore complete. Reboot or restart networking."
EOF

chmod +x $BACKUP_DIR/restore-config-$DATE.sh

echo "Backup completed in: $BACKUP_DIR"
ls -la $BACKUP_DIR/*-$DATE*
```

## 🔧 Дополнение 5: Автоматизация и обслуживание

### Скрипт автоматического восстановления маршрутов
```bash
#!/bin/bash
# save as /usr/local/bin/check-routes.sh

# Check if routes exist, if not - add them
ROUTE_45=$(ip route show 192.168.45.0/24)
ROUTE_46=$(ip route show 192.168.46.0/24)

if [ -z "$ROUTE_45" ]; then
    echo "$(date): Adding missing route to 192.168.45.0/24"
    ip route add 192.168.45.0/24 via 192.168.87.2 dev wlp1s0
fi

if [ -z "$ROUTE_46" ]; then
    echo "$(date): Adding missing route to 192.168.46.0/24" 
    ip route add 192.168.46.0/24 via 192.168.87.2 dev wlp1s0
fi

# Add to crontab for automatic checking every 5 minutes
# */5 * * * * /usr/local/bin/check-routes.sh
```

### Мониторинг состояния шлюза
```bash
#!/bin/bash
# save as gateway-monitor.sh

GATEWAY="192.168.87.2"
LOG_FILE="/var/log/gateway-monitor.log"

check_gateway() {
    if ping -c 2 -W 1 $GATEWAY &> /dev/null; then
        echo "$(date): Gateway $GATEWAY is UP" >> $LOG_FILE
        return 0
    else
        echo "$(date): ALERT - Gateway $GATEWAY is DOWN" >> $LOG_FILE
        # Можно добавить отправку уведомления
        return 1
    fi
}

check_gateway
```

## 🔧 Дополнение 6: Расширенные сценарии

### Настройка QoS (качество обслуживания)
```bash
# Установка пакетов для QoS
apt-get install wondershaper

# Ограничение bandwidth для внутренних сетей
wondershaper eth1 1024 512    # dmznet: 1Mbps down, 512Kbps up
wondershaper eth2 1024 512    # pgnet: 1Mbps down, 512Kbps up

# Сброс ограничений
wondershaper clear eth1
wondershaper clear eth2
```

### Перенаправление портов (port forwarding)
```bash
# Пример: перенаправление порта 80 с шлюза на внутренний хост
iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 80 -j DNAT --to-destination 192.168.46.4:80
iptables -A FORWARD -p tcp -d 192.168.46.4 --dport 80 -j ACCEPT

# Перенаправление SSH на конкретный хост
iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 2222 -j DNAT --to-destination 192.168.46.4:22
iptables -A FORWARD -p tcp -d 192.168.46.4 --dport 22 -j ACCEPT
```

## 🔧 Дополнение 7: Полезные alias и функции

### Добавить в ~/.bashrc на шлюзе и ноутбуке
```bash
# Network aliases
alias routes='ip route show'
alias routes-add='sudo ip route add 192.168.45.0/24 via 192.168.87.2 dev wlp1s0 && sudo ip route add 192.168.46.0/24 via 192.168.87.2 dev wlp1s0'
alias routes-del='sudo ip route del 192.168.45.0/24 2>/dev/null; sudo ip route del 192.168.46.0/24 2>/dev/null; echo "Routes removed"'
alias fw-status='sudo iptables -L FORWARD -nv && echo "--- NAT ---" && sudo iptables -t nat -L -nv'

# Quick ping tests
alias ping-gw='ping 192.168.87.2'
alias ping-dmz='ping 192.168.46.1'
alias ping-pg='ping 192.168.45.1'
alias ping-internal='for h in 192.168.46.4 192.168.45.50; do ping -c 1 $h; done'

# Network info function
function netinfo() {
    echo "=== Network Information ==="
    echo "IP Addresses:" && ip addr show | grep inet
    echo ""
    echo "Routing Table:" && ip route show
    echo ""
    echo "ARP Table:" && ip neigh show
}
```

## 📋 Чек-лист дополнительных настроек

- [ ] Настроено логирование дропнутых пакетов
- [ ] Добавлены базовые правила безопасности
- [ ] Созданы скрипты диагностики
- [ ] Настроено резервное копирование конфигурации
- [ ] Добавлены автоматические проверки маршрутов
- [ ] Созданы полезные alias и функции
- [ ] При необходимости настроен QoS
- [ ] При необходимости настроен port forwarding

Эти дополнения сделают вашу сетевую инфраструктуру более надежной, безопасной и удобной в обслуживании.
