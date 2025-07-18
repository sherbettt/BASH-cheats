Для создания swap-файла на вашей системе Proxmox, выполните следующие шаги:

<details>
<summary>lsblk, blkid</summary>
  
```bash
root@pmx5:~# lsblk-more 
TRAN   TYPE  NAME        MOUNTPOINT UUID                                   SIZE FSTYPE            MODE       PTTYPE PARTTYPE                             LABEL
       loop  loop0                  3a46effc-b443-4ddd-9703-28db13ba4f4e    10G ext4              brw-rw----                                             
sata   disk  sda                                                           7,3T                   brw-rw---- gpt                                         
       part  └─sda1                 ccb5be21-2f11-f550-74a1-6b4e1ecee8a0   7,3T linux_raid_member brw-rw---- gpt    0fc63daf-8483-4772-8e79-3d69d8477de4 proxmox5:0
       raid1   └─md0     /stg/8tb   e4f25f34-cc70-4a2a-9991-1d17fb271e57   7,3T ext4              brw-rw----                                             
sata   disk  sdb                                                           7,3T                   brw-rw---- gpt                                         
       part  └─sdb1                 ccb5be21-2f11-f550-74a1-6b4e1ecee8a0   7,3T linux_raid_member brw-rw---- gpt    0fc63daf-8483-4772-8e79-3d69d8477de4 proxmox5:0
       raid1   └─md0     /stg/8tb   e4f25f34-cc70-4a2a-9991-1d17fb271e57   7,3T ext4              brw-rw----                                             
nvme   disk  nvme1n1                                                     931,5G                   brw-rw---- gpt                                         
nvme   part  └─nvme1n1p1            17a79082-d82a-496a-9d8e-dbd6d1f8b3c2 931,5G ext4              brw-rw---- gpt    0fc63daf-8483-4772-8e79-3d69d8477de4 
nvme   disk  nvme0n1                                                     931,5G                   brw-rw---- gpt                                         
nvme   part  ├─nvme0n1p1 /boot/efi  6F7B-1FDE                              487M vfat              brw-rw---- gpt    c12a7328-f81f-11d2-ba4b-00a0c93ec93b 
nvme   part  ├─nvme0n1p2 /          6c0ffa47-322c-4115-9d41-3cce70b08c14 279,4G ext4              brw-rw---- gpt    0fc63daf-8483-4772-8e79-3d69d8477de4 
nvme   part  └─nvme0n1p3 /home      cb2e1883-8456-4647-9432-a86cc17d201a 651,6G ext4              brw-rw---- gpt    0fc63daf-8483-4772-8e79-3d69d8477de4 
  
root@pmx5:~# blkid 
/dev/nvme0n1p3: UUID="cb2e1883-8456-4647-9432-a86cc17d201a" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="6ba29f95-1f47-4324-a7d9-8442cd9124f6"
/dev/nvme0n1p1: UUID="6F7B-1FDE" BLOCK_SIZE="512" TYPE="vfat" PARTUUID="04632b87-27dc-4118-bad7-e99e3e037ecb"
/dev/nvme0n1p2: UUID="6c0ffa47-322c-4115-9d41-3cce70b08c14" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="65b1ec7b-d6a5-41b8-9854-76b29c43655b"
/dev/sdb1: UUID="ccb5be21-2f11-f550-74a1-6b4e1ecee8a0" UUID_SUB="4ccf9a89-b03b-b245-0cb3-2067d7e1b2fc" LABEL="proxmox5:0" TYPE="linux_raid_member" PARTLABEL="primary" PARTUUID="2f5bb289-3278-45ff-8485-ad6b8376ff49"
/dev/md0: UUID="e4f25f34-cc70-4a2a-9991-1d17fb271e57" BLOCK_SIZE="4096" TYPE="ext4"
/dev/loop0: UUID="3a46effc-b443-4ddd-9703-28db13ba4f4e" BLOCK_SIZE="4096" TYPE="ext4"
/dev/nvme1n1p1: UUID="17a79082-d82a-496a-9d8e-dbd6d1f8b3c2" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="5bd77df5-ef18-c442-899f-b8807b86c0fd"
/dev/sda1: UUID="ccb5be21-2f11-f550-74a1-6b4e1ecee8a0" UUID_SUB="9c9ebcfc-2b53-692b-693b-a6f4422b8b2b" LABEL="proxmox5:0" TYPE="linux_raid_member" PARTLABEL="primary" PARTUUID="60e8112f-d3c0-4725-8ad2-32110cc1ea4e"
```
</details>


### 1. Выберите место для swap-файла
Из нашего вывода видно, что есть несколько разделов:
- `/` (279.4 GB на nvme0n1p2)
- `/home` (651.6 GB на nvme0n1p3)
- `/stg/8tb` (7.3 TB на md0)

Рекомендуется размещать swap на быстром хранилище (NVMe), например в корневом разделе (`/`) или в `/home`.

### 2. Создание swap-файла (пример для корневого раздела)
```bash
# Создаем файл размером 8GB (можно изменить по необходимости)
sudo fallocate -l 8G /swapfile

# Альтернатива, если fallocate не работает:
# sudo dd if=/dev/zero of=/swapfile bs=1M count=8192

# Устанавливаем правильные права
sudo chmod 600 /swapfile

# Форматируем как swap
sudo mkswap /swapfile

# Активируем swap
sudo swapon /swapfile
```

### 3. Добавление в /etc/fstab для автоматического подключения при загрузке
```bash
swapfile 	none 	swap 	sw 	0 	0
```

### 4. Проверка
```bash
# Проверяем, что swap активен
sudo swapon --show
free -h
```
