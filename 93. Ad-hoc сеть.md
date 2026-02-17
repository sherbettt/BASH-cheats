Ad-hoc команды используются для временной настройки сетевых интерфейсов Linux. Рассмотрим наиболее распространённые варианты использования `ifconfig` и современных утилит (`ip`), включая различные опции (ключи):

## ifconfig (устаревшая команда)

### Примеры с использованием `ifconfig`

1. **Просмотр текущих настроек интерфейса**
   ```bash
   sudo ifconfig eth0
   ```

2. **Назначение IP-адреса и маски подсети вручную**
   ```bash
   sudo ifconfig eth0 192.168.1.1 netmask 255.255.255.0 up
   ```

3. **Удаление IP-адреса**
   ```bash
   sudo ifconfig eth0 0.0.0.0
   ```

4. **Настройка шлюза по умолчанию**
   ```bash
   sudo route add default gw 192.168.1.254 dev eth0
   ```

5. **Задание MAC-адреса**
   ```bash
   sudo ifconfig eth0 hw ether 00:AA:BB:CC:DD:EE
   ```

6. **Разрешение маршрутизации пакетов**
   ```bash
   echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
   ```

7. **Включение широковещательной рассылки**
   ```bash
   sudo ifconfig eth0 broadcast +broadcast
   ```

8. **Отключение широковещательного режима**
   ```bash
   sudo ifconfig eth0 broadcast -broadcast
   ```

9. **Создание виртуального интерфейса**
   ```bash
   sudo ifconfig eth0:1 192.168.2.1 netmask 255.255.255.0 up
   ```

---

## ip (рекомендуемая современная команда)

### Примеры с использованием `ip`

1. **Просмотр всех интерфейсов**
   ```bash
   ip addr show
   ```

2. **Просмотр конкретного интерфейса**
   ```bash
   ip addr show eth0
   ```

3. **Назначение статического IP-адреса**
   ```bash
   sudo ip addr add 192.168.1.100/24 dev eth0
   ```

4. **Удаление IP-адреса**
   ```bash
   sudo ip addr del 192.168.1.100/24 dev eth0
   ```

5. **Запуск/остановка интерфейса**
   ```bash
   sudo ip link set eth0 up
   sudo ip link set eth0 down
   ```

6. **Установка MTU (Maximum Transmission Unit)**
   ```bash
   sudo ip link set eth0 mtu 1500
   ```

7. **Изменение MAC-адреса**
   ```bash
   sudo ip link set dev eth0 address 00:AA:BB:CC:DD:EE
   ```

8. **Задать шлюз по умолчанию**
   ```bash
   sudo ip route add default via 192.168.1.254
   ```

9. **Добавление маршрута**
   ```bash
   sudo ip route add 10.0.0.0/8 via 192.168.1.254 dev eth0
   ```

10. **Уточнить маршрут (для специфической сети)**
    ```bash
    sudo ip route change 10.0.0.0/8 via 192.168.1.254 dev eth0 metric 100
    ```

11. **Удалить маршрут**
    ```bash
    sudo ip route del 10.0.0.0/8
    ```

12. **Разрешение маршрутизации пакетов**
    ```bash
    sudo sysctl -w net.ipv4.ip_forward=1
    ```

13. **Управление ARP-записями**
    ```bash
    sudo ip neigh add 192.168.1.10 lladdr AA:BB:CC:DD:EE:FF dev eth0
    sudo ip neigh del 192.168.1.10 dev eth0
    ```

14. **Виртуальные мосты**
    ```bash
    sudo ip link add name br0 type bridge
    sudo ip link set dev eth0 master br0
    sudo ip link set dev br0 up
    ```

---


# Шпаргалка: Настройка сети в ALT Linux (etcnet/systemd-networkd)

## 1. Быстрая временная настройка сети (работает до перезагрузки)

```bash
# Очистить текущие настройки интерфейса
ip addr flush dev eth0

# Назначить статический IP адрес
ip addr add 192.168.87.100/24 dev eth0

# Включить сетевой интерфейс
ip link set eth0 up

# Добавить маршрут по умолчанию
ip route add default via 192.168.87.1

# Настроить DNS серверы
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf

# Проверить подключение
ping -c 3 192.168.87.1    # Проверка до шлюза
ping -c 3 8.8.8.8         # Проверка до интернета
```

## 2. Исправление существующего конфига systemd-networkd

### 2.1. Правим текущий конфиг (добавляем DNS)
```bash
# Редактируем существующий файл, добавляем DNS
cat > /etc/systemd/network/eth0.network << 'EOF'
[Match]
Name = eth0

[Network]
Description = Interface eth0 autoconfigured by PVE
Address = 192.168.87.100/24
Gateway = 192.168.87.1
DNS = 8.8.8.8
DNS = 1.1.1.1
DHCP = no
IPv6AcceptRA = false
EOF
```

### 2.2. Альтернатива: переименуем в правильный формат
```bash
# systemd-networkd предпочитает файлы с префиксом-цифрой
mv /etc/systemd/network/eth0.network /etc/systemd/network/10-eth0.network

# Создаем правильный конфиг
cat > /etc/systemd/network/10-eth0.network << 'EOF'
[Match]
Name = eth0

[Network]
Address = 192.168.87.100/24
Gateway = 192.168.87.1
DNS = 8.8.8.8
DNS = 1.1.1.1
EOF
```

## 3. Проверяем и включаем systemd-networkd

### 3.1. Проверяем установлен ли systemd-networkd
```bash
# Ищем пакет systemd-networkd
apt-cache search systemd-networkd

# Устанавливаем
apt-get update
apt-get install systemd-networkd
#  или
epmi systemd-networkd

# Проверяем наличие службы
systemctl status systemd-networkd
```

### 3.2. Включаем и запускаем службу
```bash
# Включаем автозагрузку
systemctl enable systemd-networkd

# Запускаем службу
systemctl start systemd-networkd

# Проверяем статус
systemctl status systemd-networkd
```

### 3.3. Применяем настройки сети
```bash
# Перезапускаем networkd для применения изменений
systemctl restart systemd-networkd

# Или принудительно применяем конфиг
networkctl reload
networkctl up eth0

# Проверяем состояние интерфейсов
networkctl list
networkctl status eth0
```

## 4. Проверка сетевых настроек

```bash
# Показать все интерфейсы
ip addr show

# Показать таблицу маршрутизации
ip route show

# Проверить DNS
cat /etc/resolv.conf

# Проверить подключение
ping -c 3 192.168.87.1
ping -c 3 8.8.8.8
nslookup google.com
```

## 5. Защита DNS настроек

```bash
# Убедимся что DNS прописан (на всякий случай)
cat > /etc/resolv.conf << 'EOF'
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

# Защищаем файл от изменений (опционально)
chattr +i /etc/resolv.conf 2>/dev/null || echo "chattr не поддерживается"
```

## 6. Диагностика если не работает

```bash
# Смотрим логи networkd
journalctl -u systemd-networkd -f

# Проверяем синтаксис конфига
networkctl status eth0

# Принудительно перезапускаем сеть
systemctl restart systemd-networkd
ip link set eth0 down && ip link set eth0 up
```

## 7. Перезагрузка и финальная проверка

```bash
# Перезагружаем контейнер
reboot

# После перезагрузки проверяем
ip addr show eth0
ping -c 2 8.8.8.8
systemctl status systemd-networkd
```


