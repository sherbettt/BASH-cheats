# Установка ProxMox на Debian12

Требуется:
1. Установить Debian GNU/Linux 12 (bookworm).
2. Настроить networking параметры.
3. Установить ProxMox.

## 1. Установить Debian GNU/Linux 12 (bookworm)
Данный шаг пропустим, потому что он может быть кастомизирован от целей и задач.
> Параметры разделов и ФС спрашивайте у админов.
{.is-info}

На всякий случай озаботимся созданием снепшотов на Debian12.
Чтобы создать **снэпшот (snapshot)** операционной системы **Debian 12**, можно использовать несколько методов в зависимости от ваших целей:


### **1. Создание снэпшота с помощью `timeshift` (рекомендуется для бэкапа системы)**
**Установка**
```bash
apt-get update && sudo apt upgrade -y
apt install timeshift
```

**Запуск и создание снепшота:**
```bash
timeshift --create --comments "Before installation of ProxMox"
sudo timeshift --list
ls -alhF /timeshift/snapshots/
```
Только после первого создания снепшота, этот снепшот будет храниться временно в `/run/timeshift/4563/backup` до первой перезагрузки ОС.

Нужно создать папку для постоянного хранения снепшотов, проверив место на диске.
```bash
df -h
mkdir -p /mnt/backup/timeshift
```
Узнать UUID диска для добавления в `/etc/timeshift/timeshift.json`:
```bash
lsblk --output NAME,SERIAL,MODEL,TRAN,TYPE,SIZE,FSTYPE,MOUNTPOINT,UUID,LABEL
blkid | grep "/dev/nvme0n1p2"  # nvme0n1p2 (в нашем случае это "/" диска nvme0n1)
 # или
blkid | grep "/dev/nvme0n1p3"  # nvme0n1p3 (в нашем случае это "/home" диска nvme0n1)
```

<details>
<summary>Пример Блочных у-в</summary>

```bash
root@pmx5:~# lsblk-more 
NAME        SERIAL          MODEL                        TRAN   TYPE    SIZE FSTYPE            MOUNTPOINT UUID                                 LABEL
sda         13P0A3GHFDEH    TOSHIBA MG08ADA800E          sata   disk    7,3T                                                                   
└─sda1                                                          part    7,3T linux_raid_member            ccb5be21-2f11-f550-74a1-6b4e1ecee8a0 proxmox5:0
  └─md0                                                         raid1   7,3T ext4                         e4f25f34-cc70-4a2a-9991-1d17fb271e57 
sdb         13P0A2KNFDEH    TOSHIBA MG08ADA800E          sata   disk    7,3T                                                                   
└─sdb1                                                          part    7,3T linux_raid_member            ccb5be21-2f11-f550-74a1-6b4e1ecee8a0 proxmox5:0
  └─md0                                                         raid1   7,3T ext4                         e4f25f34-cc70-4a2a-9991-1d17fb271e57 
sdc         FC0172701E82A   ProductCode                  usb    disk   58,6G                                                                   
├─sdc1                                                          part   58,6G exfat                        4E21-0000                            Ventoy
└─sdc2                                                          part     32M vfat                         626B-4255                            VTOYEFI
nvme1n1     S4EWNS0X120280N Samsung SSD 970 EVO Plus 1TB nvme   disk  931,5G                                                                   
└─nvme1n1p1                                              nvme   part  931,5G ext4                         17a79082-d82a-496a-9d8e-dbd6d1f8b3c2 
nvme0n1     S649NL0W300499M Samsung SSD 980 1TB          nvme   disk  931,5G                                                                   
├─nvme0n1p1                                              nvme   part    487M vfat              /boot/efi  6F7B-1FDE                            
├─nvme0n1p2                                              nvme   part  279,4G ext4              /          6c0ffa47-322c-4115-9d41-3cce70b08c14 
└─nvme0n1p3                                              nvme   part  651,6G ext4              /home      cb2e1883-8456-4647-9432-a86cc17d201a 

root@pmx5:~# blkid | grep "/dev/nvme0n1p2"
/dev/nvme0n1p2: UUID="6c0ffa47-322c-4115-9d41-3cce70b08c14" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="65b1ec7b-d6a5-41b8-9854-76b29c43655b"
root@pmx5:~# blkid | grep "/dev/nvme0n1p3"
/dev/nvme0n1p3: UUID="cb2e1883-8456-4647-9432-a86cc17d201a" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="6ba29f95-1f47-4324-a7d9-8442cd9124f6"
```
</details>


Настроить Timeshift на сохранение в `/mnt/backup/timeshift`:
```bash
vim /etc/timeshift/timeshift.json  # Shift+ZZ или Shift+ZQ
```
```json
{
  "backup_device_uuid" : "UUID_вашего_диска",
  "backup_device" : "/mnt/backup/timeshift",
  "schedule_monthly" : "true",  ## опционально,но лучше false
  "schedule_weekly" : "true",
  "schedule_daily" : "true"
}
```
По умолчанию были выбраны:
```json
└─sda1                                                          part    7,3T linux_raid_member            ccb5be21-2f11-f550-74a1-6b4e1ecee8a0 proxmox5:0
  └─md0                                                         raid1   7,3T ext4                         e4f25f34-cc70-4a2a-9991-1d17fb271e57
```

### **2. Создание снапшота вручную (через `tar` или `rsync`)**
Если нужно просто заархивировать систему для переноса или бэкапа:

 **Создание архива системы (`tar`)**
```bash
tar -cvpzf /backup/debian12_snapshot_$(date +%Y-%m-%d).tar.gz --exclude=/backup --exclude=/proc --exclude=/tmp --exclude=/mnt --exclude=/dev --exclude=/sys --exclude=/run --exclude=/media /
```
- `--exclude` — исключает временные и виртуальные файловые системы.
- Архив сохраняется в `/backup/`.

#### **Копирование системы через `rsync`**
```bash
rsync -aAXv --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} / /mnt/backup/
```
- Копирует всю систему в `/mnt/backup/`.
<br/>


## 2. Настроить networking параметры.

Поменять имя машины:
```markdown
hostname -b pmx5.runtel.ru
```

Отредактировать **`/etc/hosts`**, добавив:
```markdown
127.0.0.1 pmx5.runtel.ru
192.168.87.20 pmx5.runtel.ru pmx5
```

-  Для начала установим пакет `bridge-utils` и др. утилиты;
	```bash
  	apt-get update && sudo apt upgrade -y
  	apt-get install -y bridge-utils;
    apt install -y curl wget gnupg
  	```
- Проверить имя интерфейса командой `ip -c a s`, и в наше случае - это **`enp4s0`**;
- Отредактировать файл `/etc/network/interfaces`, где вместо **<ИНТЕРФЕЙС>** ставим **enp4s0**:
	```markdown
	auto vmbr0
	iface vmbr0 inet static
  	address 192.168.87.20/24
  	gateway 192.168.87.1
  	bridge-ports <ИНТЕРФЕЙС>
  	bridge-stp off
  	bridge-fd 0
	```


- запускаем `ifup vmbr0`;
- перегружаем службу `systemctl restart networking.service`;
- опционально перезагрузить сервер;
- проверяем маршруты:
	```bash
  root@pmx5:~# ip route
	default via 192.168.87.1 dev vmbr0 onlink 
	192.168.87.0/24 dev vmbr0 proto kernel scope link src 192.168.87.20 
	192.168.87.0/24 dev enp4s0 proto kernel scope link src 192.168.87.185 
  ```
- проверка моста:
	```bash
	root@pmx5:~# brctl show
	bridge name	bridge id		STP enabled	interfaces
	vmbr0		8000.5601207190d8	no		enp4s0
  ```

- снова проверить `ip -c a s`, где в результате увидим наш текущий статический адрес уже на интерфейсе **`vmbr0`**:

<details>
<summary>ip -c a s</summary>

```c
root@pmx5:~# ipc
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: enp4s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master vmbr0 state UP group default qlen 1000
    link/ether 74:56:3c:40:a6:3f brd ff:ff:ff:ff:ff:ff
    inet 192.168.87.185/24 brd 192.168.87.255 scope global dynamic enp4s0
       valid_lft 86257sec preferred_lft 86257sec
3: vmbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 56:01:20:71:90:d8 brd ff:ff:ff:ff:ff:ff
    inet 192.168.87.20/24 brd 192.168.87.255 scope global vmbr0
       valid_lft forever preferred_lft forever
    inet6 fe80::5401:20ff:fe71:90d8/64 scope link 
       valid_lft forever preferred_lft forever
4: wlp3s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether f0:a6:54:c5:22:47 brd ff:ff:ff:ff:ff:ff
```
</details>

  
По-хорошему после перезагрузки интерфейс enp4s0 не нужен, он будет конфликтовать с vmbr0, посему нужно закомментировать строки в файле /etc/network/interfaces:
  #allow-hotplug enp4s0
	#iface enp4s0 inet dhcp


## 3. Установить ProxMox.

1. Скачайте и установите ключ репозитория Proxmox:
```bash
wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg
 # или
wget -qO- https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg | sudo tee /etc/apt/trusted.gpg.d/proxmox.asc
```
Если это не сработает, попробуйте альтернативный вариант - добавить ключ вручную:
```bash
wget -qO- https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg
```
Проверка ключа: `apt-key list | grep -A1 "Proxmox"`


2. Отредактировать файл `/etc/apt/sources.list`, добавив:
	```markdown
	deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
	```
   ```bash
   echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" | sudo tee /etc/apt/sources.list.d/pve.list
    cat /etc/apt/sources.list | grep -i proxmox
   ```
   
	Проверка отпечатка ключа:
	```bash
   wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg
	 gpg --show-keys proxmox-release-bookworm.gpg  # Проверить отпечаток
	sudo mv proxmox-release-bookworm.gpg /etc/apt/trusted.gpg.d/
   ```
Ожидаемый отпечаток (fingerprint) ключа: `F0B4 D1F2 7FE3 2F74 89D5 D05E 7D20 D794 7A93 0E21`
<br/>

3. После этого обновите список пакетов и ОС:
	```bash
	sudo apt update && sudo apt upgrade -y
	```  

	#### Опционально
4. Проверить и удалить файл `/etc/apt/sources.list.d/pve-enterprise.list`, если вдруг использовали платный репозиторий по каким-то причинам.
	Почистить кеш.
	```bash
   rm -rf /etc/apt/sources.list.d/pve-enterprise.list
   apt clean
   rm -rf /var/lib/apt/lists/*
   sudo apt update && sudo apt upgrade -y
	```
<br/>


5. Установить пакет `ifupdown2`:
```bash
apt install -y ifupdown2;
dpkg --status ifupdown2;
dpkg --status ifupdown;
```
6. Установить пакет `proxmox-ve open-iscsi`:
```bash
apt install -y proxmox-ve open-iscsi;
  apt install -y postfix  #опционально
```
7. Установить ZFS:
```bash
apt install -y zfsutils-linux;
```
8. Удалить стандартное ядро Debian (**опционально!**):
```bash
apt purge -y linux-image-amd64 'linux-image-6.1.*'
```
9. Перезагрузить систему и проверить ядро:
```bash
systemctl reboot;
uname -a
```
```bash
root@pmx5:~# uname -a
 Linux pmx5 6.1.0-37-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.140-1 (2025-05-22) x86_64 GNU/Linux
# --после ребута--
root@pmx5:~# uname -a
 Linux pmx5 6.8.12-11-pve #1 SMP PREEMPT_DYNAMIC PMX 6.8.12-11 (2025-05-22T09:39Z) x86_64 GNU/Linux
```

10. Проверить службы/сервисы:
  ```bash
  systemctl status pveproxy pvedaemon pve-cluster --no-pager
  ```

11. Откройте следующую ссылку: **https://pmx5.runtel.ru:8006** в вашем веб-браузере, чтобы проверить, была ли установка успешной.  Если DNS имя не разрешено или не записано нигде, требуется зайти по сыслке **https://192.168.87.20:8006**  (https://192.168.87.20:8006/#v1:0:18:4:::::::).
<br/>
  
### 1. Проблема с кластером Proxmox.
Ошибка .vmlist часто возникает при проблемах с кластером или когда узел не может синхронизировать конфигурацию.

Проверьте доступность **`/etc/pve`**, существует ли там файл **`.vmlist`** ?
Каталог /etc/pve является виртуальной файловой системой (pve-cluster), и если служба pve-cluster не работает, файлы могут быть недоступны.

Проверьте:
```bash
pvecm status
pmxcfs -l
systemctl status pve-cluster
journalctl -u pve-cluster -n 50 --no-pager
journalctl -u proxmox-firewall -n 50 --no-pager
```
Если есть ошибки, возможно, потребуется перезапустить кластерные службы:
```bash
systemctl restart corosync pvedaemon pveproxy
```

Если проблема не решена, попробуйте вручную создать пустой файл .vmlist (временное решение):
```bash
echo '{}' > /etc/pve/.vmlist
echo '{"ids":{}}' > /etc/pve/.vmlist
chown root:www-data /etc/pve/.vmlist
chmod 0640 /etc/pve/.vmlist
```


также см.: [Как установить Proxmox Virtual Environment на Debian 12](https://byzoni.org/posts/how-to-install-proxmox-virtual-environment-on-debian-12/)
Затем перезапустите фаервол:
```bash
systemctl restart proxmox-firewall
```
