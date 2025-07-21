# Администрирование кластера Proxmox VE

Для управления кластером Proxmox VE, состоящим из узлов `192.168.87.20`, `192.168.87.17` и `192.168.87.6`, можно использовать как веб-интерфейс, так и командную строку.

## Основные команды для администрирования кластера

### 1. Проверка состояния кластера
```bash
pvecm status
```
Покажет статус кластера, кворум и список узлов.

### 2. Список узлов в кластере
```bash
pvecm nodes
```

### 3. Проверка кворума
```bash
pvecm expected <argument>;
pvecm expected 3
```

### 4. Проверка состояния сети кластера
```bash
pvecm ifup -a
```

### 5. Проверка состояния хранилищ
```bash
pvesm status
```

### 6. Просмотр всех виртуальных машин в кластере
```bash
qm list
```

### 7. Просмотр всех контейнеров в кластере
```bash
pct list
```

------------------

## Основные команды управления кластером

### 1. `pvecm expected <expected>`
**Назначение**: Установка ожидаемого количества узлов для кворума  
**Аргумент**:  
- `<expected>` - число (например, `3` для кластера из 3 узлов)  

**Пример**:  
```bash
pvecm expected 3
```

### 2. `pvecm nodes`
**Назначение**: Показать список узлов кластера  
**Аргументы**: Не требуются  
**Пример**:  
```bash
pvecm nodes
```

### 3. `pvecm status`
**Назначение**: Показать статус кластера  
**Аргументы**: Не требуются  
**Пример**:  
```bash
pvecm status
```

## Команды управления узлами

### 4. `pvecm addnode <node>`
**Назначение**: Добавить узел в кластер  
**Аргумент**:  
- `<node>` - имя или IP узла для добавления  

**Пример**:  
```bash
pvecm addnode 192.168.87.30
```

### 5. `pvecm delnode <node>`
**Назначение**: Удалить узел из кластера  
**Аргумент**:  
- `<node>` - имя или IP узла для удаления  

**Пример**:  
```bash
pvecm delnode 192.168.87.30
```

## Команды настройки кластера

### 6. `pvecm create <clustername>`
**Назначение**: Создать новый кластер  
**Аргумент**:  
- `<clustername>` - имя нового кластера  

**Пример**:  
```bash
pvecm create my_cluster
```

### 7. `pvecm add <hostname>`
**Назначение**: Добавить текущий узел в существующий кластер  
**Аргумент**:  
- `<hostname>` - имя или IP существующего узла кластера  

**Пример**:  
```bash
pvecm add 192.168.87.17
```

## Команды управления кворумом

### 8. `pvecm qdevice setup <address>`
**Назначение**: Настроить qdevice (устройство кворума)  
**Аргумент**:  
- `<address>` - IP или имя хоста qdevice сервера  

**Пример**:  
```bash
pvecm qdevice setup 192.168.87.100
```

### 9. `pvecm qdevice remove`
**Назначение**: Удалить qdevice из кластера  
**Аргументы**: Не требуются  
**Пример**:  
```bash
pvecm qdevice remove
```

## Дополнительные команды

### 10. `pvecm keygen <filename>`
**Назначение**: Сгенерировать ключи аутентификации  
**Аргумент**:  
- `<filename>` - путь для сохранения ключа  

**Пример**:  
```bash
pvecm keygen /etc/pve/cluster.key
```

### 11. `pvecm updatecerts`
**Назначение**: Обновить сертификаты кластера  
**Аргументы**: Не требуются (опционально `--force`)  
**Пример**:  
```bash
pvecm updatecerts
```

## Частые ошибки и решения

1. **"400 not enough arguments"**:
   - Команда `pvecm expected` требует числовой аргумент
   - Решение: Укажите количество узлов, например `pvecm expected 3`

2. **"ERROR: unknown command 'pvecm ifup'"**:
   - Такой команды не существует в текущей версии Proxmox
   - Для управления сетью используйте:
     ```bash
     ifup <interface>
     ifdown <interface>
     ```

3. **Проверка доступных команд**:
   Всегда можно посмотреть справку:
   ```bash
   pvecm help
   man pvecm
   ```
------------------



## Мониторинг и обслуживание

### Проверка использования ресурсов
```bash
df -h              # Дисковое пространство
free -h            # Оперативная память
top                # Загрузка процессора
pvesubscription get # Статус подписки
```

### Проверка состояния сети
```bash
ip a               # Сетевые интерфейсы
cat /etc/network/interfaces # Конфигурация сети
```

### Проверка журналов
```bash
journalctl -xe     # Системные логи
tail -f /var/log/syslog # Логи в реальном времени
```

## Управление миграцией ВМ

### Живая миграция ВМ между узлами
```bash
qm migrate <VMID> <target-node> --online
```

### Миграция контейнеров
```bash
pct migrate <CTID> <target-node>
```

## Рекомендации по администрированию

1. **Регулярно проверяйте состояние кластера** с помощью `pvecm status`
2. **Контролируйте кворум** - для работы кластера необходимо большинство узлов (2 из 3 в вашем случае)
3. **Резервное копирование** - настройте регулярное резервное копирование ВМ и контейнеров
4. **Обновления** - регулярно обновляйте систему:
   ```bash
   apt update && apt dist-upgrade
   ```
5. **Мониторинг** - настройте мониторинг (например, через Zabbix или Prometheus)
6. **Хранилища** - убедитесь, что все узлы имеют доступ к общим хранилищам

Для более детального управления конкретными аспектами кластера можно использовать веб-интерфейс, который предоставляет удобный графический интерфейс для всех этих операций.




## Текущее состояние кластера

1. **Состав кластера**:
   - Узел 1: `192.168.87.17` (NodeID: 0x00000001)
   - Узел 2: `192.168.87.6` (NodeID: 0x00000002)
   - Узел 3: `192.168.87.20` (NodeID: 0x00000003, текущий узел "pmx5")

2. **Кворум**: 
   - Кворум установлен (Quorate: Yes)
   - Минимальное требование: 2 из 3 узлов

3. **Сеть**:
   - Основной интерфейс: `vmbr0` с IP 192.168.87.20/24
   - Дополнительные сети: 
     - `dmznet` (vxlan, MTU 1450)
     - `pgnet` (vxlan, MTU 1450)

## Критические проверки и команды

### 1. Проверка сети кластера
```bash
corosync-cmapctl | grep members
pvecm status
cat /etc/pve/corosync.conf
```

### 2. Проверка хранилищ
```bash
pvesm status
df -h
lsblk
```

### 3. Проверка работы VXLAN
```bash
ip -d link show vxlan_dmznet
ip -d link show vxlan_pgnet
bridge fdb show dev vxlan_dmznet
bridge fdb show dev vxlan_pgnet
```

### 4. Проверка состояния сервисов
```bash
systemctl status pve-cluster corosync pmxcfs
pvecm nodes
```

### 5. Мониторинг производительности
```bash
pvesh get /cluster/resources --type node
pvesh get /cluster/resources --type vm
pvesh get /cluster/resources --type storage
```

## Рекомендации по администрированию

1. **Резервное копирование конфигурации**:
   ```bash
   tar czf /stg/8tb/dump/pve-config-backup-$(date +%Y%m%d).tar.gz /etc/pve
   ```

2. **Обновление системы**:
   ```bash
   apt update
   apt list --upgradable
   apt dist-upgrade
   ```

3. **Мониторинг сети кластера**:
   - Проверьте, что все узлы используют одинаковый MTU (1450 для VXLAN)
   - Убедитесь, что multicast работает (для VXLAN):

   ```bash
   tcpdump -ni vmbr0 igmp
   ```

4. **Проверка миграции**:
   Протестируйте live-миграцию между узлами:
   ```bash
   qm migrate <VMID> <target-node> --online
   ```

5. **Настройка мониторинга**:
   - Включите мониторинг в веб-интерфейсе: Datacenter → Monitor
   - Или настройте внешний мониторинг (Zabbix, Prometheus)

## Потенциальные проблемы

1. **Разный MTU**: 
   - Основной интерфейс использует MTU 1500, а VXLAN - 1450
   - Убедитесь, что физическая сеть поддерживает такой MTU

2. **Беспроводной интерфейс**:
   - Интерфейс `wlp3s0` находится в состоянии DOWN
   - Не рекомендуется использовать Wi-Fi для кластерной коммуникации

3. **Хранилище**:
   - Проверьте состояние хранилища `/stg/8tb/dump`
   - Убедитесь, что оно доступно на всех узлах кластера
<br/>


Инфо №1
<details>
<summary>systemctl status pve-cluster corosync pmxcfs</summary>

```bash
root@pmx5:~# systemctl status pve-cluster corosync pmxcfs --no-pager
● pve-cluster.service - The Proxmox VE cluster filesystem
     Loaded: loaded (/lib/systemd/system/pve-cluster.service; enabled; preset: enabled)
     Active: active (running) since Thu 2025-07-17 18:12:08 MSK; 3 days ago
    Process: 1225 ExecStart=/usr/bin/pmxcfs (code=exited, status=0/SUCCESS)
   Main PID: 1231 (pmxcfs)
      Tasks: 7 (limit: 154203)
     Memory: 66.5M
        CPU: 4min 46.422s
     CGroup: /system.slice/pve-cluster.service
             └─1231 /usr/bin/pmxcfs

июл 21 04:48:10 pmx5 pmxcfs[1231]: [status] notice: received log
июл 21 04:48:11 pmx5 pmxcfs[1231]: [status] notice: received log
июл 21 05:33:51 pmx5 pmxcfs[1231]: [dcdb] notice: data verification successful
июл 21 06:33:51 pmx5 pmxcfs[1231]: [dcdb] notice: data verification successful
июл 21 06:44:35 pmx5 pmxcfs[1231]: [status] notice: received log
июл 21 07:33:51 pmx5 pmxcfs[1231]: [dcdb] notice: data verification successful
июл 21 08:33:51 pmx5 pmxcfs[1231]: [dcdb] notice: data verification successful
июл 21 08:56:35 pmx5 pmxcfs[1231]: [status] notice: received log
июл 21 09:33:51 pmx5 pmxcfs[1231]: [dcdb] notice: data verification successful
июл 21 09:48:39 pmx5 pmxcfs[1231]: [status] notice: received log

● corosync.service - Corosync Cluster Engine
     Loaded: loaded (/lib/systemd/system/corosync.service; enabled; preset: enabled)
     Active: active (running) since Thu 2025-07-17 18:12:09 MSK; 3 days ago
       Docs: man:corosync
             man:corosync.conf
             man:corosync_overview
   Main PID: 1528 (corosync)
      Tasks: 9 (limit: 154203)
     Memory: 135.8M
        CPU: 35min 1.212s
     CGroup: /system.slice/corosync.service
             └─1528 /usr/sbin/corosync -f

июл 17 18:12:19 pmx5 corosync[1528]:   [KNET  ] pmtud: Global data MTU changed to: 1397
июл 17 18:12:21 pmx5 corosync[1528]:   [KNET  ] link: Resetting MTU for link 0 because host 2 joined
июл 17 18:12:21 pmx5 corosync[1528]:   [KNET  ] host: host: 2 (passive) best link: 0 (pri: 1)
июл 17 18:12:21 pmx5 corosync[1528]:   [QUORUM] Sync members[3]: 1 2 3
июл 17 18:12:21 pmx5 corosync[1528]:   [QUORUM] Sync joined[2]: 1 2
июл 17 18:12:21 pmx5 corosync[1528]:   [TOTEM ] A new membership (1.1060a78) was formed. Members joined: 1 2
июл 17 18:12:21 pmx5 corosync[1528]:   [QUORUM] Members[3]: 1 2 3
июл 17 18:12:21 pmx5 corosync[1528]:   [MAIN  ] Completed service synchronization, ready to provide service.
июл 17 18:12:21 pmx5 corosync[1528]:   [KNET  ] pmtud: PMTUD link change for host: 2 link: 0 from 469 to 1397
июл 17 18:12:21 pmx5 corosync[1528]:   [KNET  ] pmtud: Global data MTU changed to: 1397
Unit pmxcfs.service could not be found.

```

</details> 
<br/>


Инфо №2
<details>
<summary>PVE info</summary>

```bash
root@pmx5:~# pvecm status
Cluster information
-------------------
Name:             dc
Config Version:   13
Transport:        knet
Secure auth:      on

Quorum information
------------------
Date:             Mon Jul 21 10:00:03 2025
Quorum provider:  corosync_votequorum
Nodes:            3
Node ID:          0x00000003
Ring ID:          1.1060a78
Quorate:          Yes

Votequorum information
----------------------
Expected votes:   3
Highest expected: 3
Total votes:      3
Quorum:           2  
Flags:            2Node Quorate WaitForAll 

Membership information
----------------------
    Nodeid      Votes Name
0x00000001          1 192.168.87.17
0x00000002          1 192.168.87.6
0x00000003          1 192.168.87.20 (local)
root@pmx5:~# 
root@pmx5:~# pvecm nodes

Membership information
----------------------
    Nodeid      Votes Name
         1          1 prox4
         2          1 pmx6
         3          1 pmx5 (local)

root@pmx5:~# pct list
VMID       Status     Lock         Name                
105        running                 dm-gitlab           
107        running                 minio               
112        running                 sonar               
117        stopped                 test-lan            
118        stopped                 ubuntu-bpm          
119        running                 minio3              
121        running                 dev70               
122        stopped                 fttpv               
151        running                 new-villabadjo      
153        running                 records             
155        running                 fileserver2         
156        running                 hoppscotch2         
157        running                 app                 
158        running                 lk-learn1           
root@pmx5:~# qm list
      VMID NAME                 STATUS     MEM(MB)    BOOTDISK(GB) PID       
       138 docker               running    8192              32.00 1876

```

</details> 
