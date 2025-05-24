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
