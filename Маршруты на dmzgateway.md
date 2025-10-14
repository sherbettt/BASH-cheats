- **MASTER GATEWAY** : **[102 (dmzgateway)](https://192.168.87.6:8006/#v1:0:=lxc%2F102:4:::::::)**
- **MASTER GATEWAY1** : **[117 (dmzgateway1)](https://192.168.87.6:8006/#v1:0:=lxc%2F117:4:::::::)**
- **MASTER GATEWAY2** : **[187 (dmzgateway2)](https://192.168.87.6:8006/#v1:0:=lxc%2F187:4:::::::)**
- **MASTER GATEWAY3** : **[186 (dmzgateway3)](https://192.168.87.6:8006/#v1:0:=lxc%2F186:4:::::::)**
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
