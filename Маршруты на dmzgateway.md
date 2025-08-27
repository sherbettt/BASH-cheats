- **MASTER GATEWAY** : **[102 (dmzgateway)](https://192.168.87.6:8006/#v1:0:=lxc%2F102:4:::::::)**
- **MASTER GATEWAY1** : **[117 (dmzgateway1)](https://192.168.87.6:8006/#v1:0:=lxc%2F117:4:::::::)**
- **MASTER GATEWAY2** : **[187 (dmzgateway2)](https://192.168.87.6:8006/#v1:0:=lxc%2F187:4:::::::)**
- **MASTER GATEWAY3** : **[186 (dmzgateway3)](https://192.168.87.6:8006/#v1:0:=lxc%2F186:4:::::::)**
<br/>


Из сети 192.168.45.0/24!
=======================




<br/>

С ноута!
=======================

```
dmzgateway
 vmbr0:        
 192.168.87.2 / Gateway 192.168.87.1
 dmznet:       
 192.168.46.1  
 pgnet:        
 192.168.45.1  
```
Чтобы удалить все текущие маршруты и заново настроить маршрутизацию на вашем ноутбуке (Ubuntu/Linux), выполните следующие шаги:

---

### **1. Удаление всех текущих маршрутов**
```bash
sudo ip route flush all  # Очистка всей таблицы маршрутизации
```

Проверьте, что таблица пуста:
```bash
ip route show
```
(Должна быть пустая таблица или только `link-local` маршруты)

---

### **2. Восстановление маршрута по умолчанию (основной шлюз)**
```bash
sudo ip route add default via 192.168.87.1 dev wlp1s0
```
(Если `192.168.87.1` — ваш основной шлюз в сети `192.168.87.0/24`)

---

### **3. Добавление маршрута в сеть 192.168.45.0/24 (pgnet)**
```bash
sudo ip route add 192.168.45.0/24 via 192.168.87.2 dev wlp1s0
```
(Здесь `192.168.87.2` — это `dmzgateway`, который знает путь до `192.168.45.0/24`)

---

### **4. Добавление маршрута в сеть 192.168.46.0/24 (dmznet)**
```bash
sudo ip route add 192.168.46.0/24 via 192.168.87.2 dev wlp1s0
```
(Аналогично, через `dmzgateway`)

---

### **5. Проверка маршрутов**
```bash
ip route show
```
Вывод должен выглядеть примерно так:
```
default via 192.168.87.1 dev wlp1s0  
192.168.45.0/24 via 192.168.87.2 dev wlp1s0  
192.168.46.0/24 via 192.168.87.2 dev wlp1s0  
192.168.87.0/24 dev wlp1s0 proto kernel scope link src 192.168.87.74  
```

---

### **6. Проверка доступности сетей**
```bash
ping 192.168.45.1   # Проверка связи с pgnet (через dmzgateway)
ping 192.168.46.1   # Проверка связи с dmznet (через dmzgateway)
ping 8.8.8.8        # Проверка интернета (через 192.168.87.1)
```

---

### **7. (Опционально) Сделать маршруты постоянными**
Чтобы маршруты не сбрасывались после перезагрузки, добавьте их в конфигурацию сети:
- **Для `netplan` (Ubuntu 18.04+)**  
  Отредактируйте `/etc/netplan/01-network-manager-all.yaml`:
  ```yaml
  network:
    version: 2
    renderer: NetworkManager
    ethernets:
      wlp1s0:
        dhcp4: yes
        routes:
          - to: 192.168.45.0/24
            via: 192.168.87.2
          - to: 192.168.46.0/24
            via: 192.168.87.2
  ```
  Примените изменения:
  ```bash
  sudo netplan apply
  ```

- **Для `networkd` (systemd-networkd)**  
  Создайте файл `/etc/systemd/network/10-static-routes.network`:
  ```
  [Route]
  Destination=192.168.45.0/24
  Gateway=192.168.87.2

  [Route]
  Destination=192.168.46.0/24
  Gateway=192.168.87.2
  ```
  Перезапустите сеть:
  ```bash
  sudo systemctl restart systemd-networkd
  sudo systemctl restart network.service
  ```

---

### **Итоговая схема маршрутизации**
- **Основной шлюз (интернет)**: `192.168.87.1`  
- **Маршрут в `pgnet` (192.168.45.0/24)**: через `192.168.87.2` (`dmzgateway`)  
- **Маршрут в `dmznet` (192.168.46.0/24)**: через `192.168.87.2` (`dmzgateway`)  

Если после этого `ping 192.168.45.1` не работает, проверьте:
1. Доступность `192.168.87.2` (`ping 192.168.87.2`).
2. Настройки маршрутизации на самом `dmzgateway` (`ip route show` на нём).
---------------
<br/>


АЛТЕРНАТИВНЫЙ ВАРИНАТ!
=======================

Отличная инструкция! Для ALT Linux, который в основе использует либо `networkmanager` (чаще в рабочих станциях) так и классический `network` (в серверных установках), процесс сохранения маршрутов будет немного отличаться.

Вот основные способы сделать маршруты постоянными на ALT Linux.

### Способ 1: Через NetworkManager (рекомендуется для ноутбуков и рабочих станций)

Это наиболее универсальный и простой способ.

1.  **Найдите имя своего подключения:**
    ```bash
    nmcli connection show
    ```
    ```
    NAME    UUID                                  TYPE      DEVICE 
    runtel  886a8694-a874-4d69-882a-7400dc1cf068  wifi      wlp1s0 
    lo      d9f3d595-5efb-4b79-be31-d1d7fb577025  loopback  lo     
    runtel  fba333dd-1dc2-4397-9a7c-54a809497128  wifi      --     
    runtel  d45f3dc8-4248-4d2d-a9dd-94e82823b406  wifi      --
    ```

    Вы увидите список. Найдите имя подключения, которое соответствует вашей беспроводной сети (например, `MyHomeWiFi`) или проводному интерфейсу (например, `Wired connection 1`).

1.  **Добавьте маршруты к существующему подключению:**
    Замените `ИМЯ_ПОДКЛЮЧЕНИЯ` на имя, полученное на предыдущем шаге.
    ```bash
    sudo nmcli connection modify "ИМЯ_ПОДКЛЮЧЕНИЯ" +ipv4.routes "192.168.45.0/24 192.168.87.2, 192.168.46.0/24 192.168.87.2"
    sudo nmcli connection modify runtel +ipv4.routes "192.168.45.0/24 192.168.87.2, 192.168.46.0/24 192.168.87.2"
    sudo nmcli connection modify 886a8694-a874-4d69-882a-7400dc1cf068 +ipv4.routes "192.168.45.0/24 192.168.87.2, 192.168.46.0/24 192.168.87.2"
    
    ```
    *Команда `+ipv4.routes` добавляет маршруты к текущим настройкам.*

2.  **Убедитесь, что основной шлюз тоже управляется NetworkManager:**
    Обычно он получается автоматически по DHCP. Проверить это можно командой:
    ```bash
    nmcli connection show "ИМЯ_ПОДКЛЮЧЕНИЯ" | grep ipv4.gateway
    nmcli connection show runtel | grep ipv4.gateway
    ```
    Если шлюз не прописан, его можно добавить явно:
    ```bash
    sudo nmcli connection modify "ИМЯ_ПОДКЛЮЧЕНИЯ" ipv4.gateway 192.168.87.1
    sudo nmcli connection modify runtel ipv4.gateway 192.168.87.1
    ```

3.  **Примените изменения:**
    ```bash
    sudo nmcli connection down "ИМЯ_ПОДКЛЮЧЕНИЯ" && sudo nmcli connection up "ИМЯ_ПОДКЛЮЧЕНИЯ"
    sudo nmcli connection down runtel && sudo nmcli connection up runtel

    sudo nmcli connection down 886a8694-a874-4d69-882a-7400dc1cf068
    sudo nmcli connection up 886a8694-a874-4d69-882a-7400dc1cf068
    ```

    Чтобы избежать путаницы в будущем, лучше переименовать подключения:
    ```bash
    # Переименовываем активное подключение
    sudo nmcli connection modify 886a8694-a874-4d69-882a-7400dc1cf068 connection.id "runtel-active"
    sudo nmcli connection modify 886a8694-a874-4d69-882a-7400dc1cf068 con.name "runtel-active"
    sudo nmcli connection modify 886a8694-a874-4d69-882a-7400dc1cf068 id "runtel-active"

    # Переименовываем остальные (опционально)
    sudo nmcli connection modify fba333dd-1dc2-4397-9a7c-54a809497128 con.name "runtel-gain1"
    sudo nmcli connection modify d45f3dc8-4248-4d2d-a9dd-94e82823b406 con.name "runtel-gain2"
    ```

5.  **Проверьте результат:**
    ```bash
    ip route show
    ```
    Маршруты должны отображаться в таблице.

**Где хранятся настройки:** NetworkManager сохраняет их в файлах в директории `/etc/NetworkManager/system-connections/`. Вручную их редактировать не нужно, для этого есть команда `nmcli`.

---

### Способ 2: Через скрипты в /etc/network/ (классический способ)

В ALT Linux, унаследовавшем традиции Debian, часто присутствует пакет `ifupdown` и структура каталога `/etc/network/`.

1.  **Откройте настройки вашего сетевого интерфейса.**
    Файл обычно находится в `/etc/network/interfaces` или в `/etc/network/interfaces.d/`. Например:
    ```bash
    sudo nano /etc/network/interfaces
    ```

2.  **Добавьте маршруты в конфигурацию вашего интерфейса.**
    Найдите секцию вашего интерфейса (например, `wlp1s0`) и добавьте строки `post-up` для добавления маршрутов после поднятия интерфейса.

    Пример конфигурации:
    ```bash
    # Основной интерфейс, получающий адрес по DHCP
    auto wlp1s0
    iface wlp1s0 inet dhcp
        # Добавляем маршруты после поднятия интерфейса
        post-up ip route add 192.168.45.0/24 via 192.168.87.2 dev wlp1s0
        post-up ip route add 192.168.46.0/24 via 192.168.87.2 dev wlp1s0
        # Удаляем маршруты перед отключением интерфейса (опционально, для чистоты)
        pre-down ip route del 192.168.45.0/24 via 192.168.87.2 dev wlp1s0
        pre-down ip route del 192.168.46.0/24 via 192.168.87.2 dev wlp1s0
    ```

3.  **Примените изменения:**
    Перезапустите сеть или конкретный интерфейс:
    ```bash
    sudo systemctl restart networking
    ```
    Или
    ```bash
    sudo ifdown wlp1s0 && sudo ifup wlp1s0
    ```

---

### Способ 3: Через systemd-networkd (менее распространен, но возможен)

Если у вас используется `systemd-networkd`, то действуйте по вашей же инструкции:

1.  **Создайте файл маршрутов** в `/etc/systemd/network/`, например, `10-static-routes.network`.
2.  **Перезапустите службу:**
    ```bash
    sudo systemctl restart systemd-networkd
    ```

### Итог и рекомендация для ALT Linux

1.  **Сначала проверьте, какой менеджер сетей у вас активен:**
    ```bash
    sudo systemctl status NetworkManager | grep active
    sudo systemctl status networking | grep active
    ```
    Это подскажет, какой способ (`nmcli` или `interfaces`) вам больше подходит.

2.  **Для большинства пользовательских систем ALT Linux рекомендуется использовать `nmcli` (Способ 1)**. Он устойчив к перезагрузкам и удобен в управлении.

3.  После применения любого из способов обязательно проверьте таблицу маршрутизации командой `ip route show` и убедитесь в доступности сетей (`ping`).
