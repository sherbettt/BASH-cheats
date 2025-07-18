Читай [cheat.sh/timeshift](https://cheat.sh/timeshift)


# Копирование снепшотов с Debian12 (ProxMox)


## Для начала выясним разделы на Debian12 (ProxMox)

<details>
<summary>lsblk, blkid, parted</summary>
  
```bash
root@pmx5:~# uname -a
Linux pmx5 6.8.12-11-pve #1 SMP PREEMPT_DYNAMIC PMX 6.8.12-11 (2025-05-22T09:39Z) x86_64 GNU/Linux
root@pmx5:~# 
root@pmx5:~# sudo parted -l
Model: ATA TOSHIBA MG08ADA8 (scsi)
Disk /dev/sda: 8002GB
Sector size (logical/physical): 512B/4096B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name     Flags
 1      1049kB  7990GB  7990GB               primary


Model: ATA TOSHIBA MG08ADA8 (scsi)
Disk /dev/sdb: 8002GB
Sector size (logical/physical): 512B/4096B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name     Flags
 1      1049kB  7990GB  7990GB               primary


Model: Samsung SSD 980 1TB (nvme)
Disk /dev/nvme0n1: 1000GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size   File system  Name  Flags
 1      1049kB  512MB   511MB  fat32              boot, esp
 2      512MB   301GB   300GB  ext4
 3      301GB   1000GB  700GB  ext4


Model: Linux Software RAID Array (md)
Disk /dev/md0: 7990GB
Sector size (logical/physical): 512B/4096B
Partition Table: loop
Disk Flags: 

Number  Start  End     Size    File system  Flags
 1      0,00B  7990GB  7990GB  ext4


Model: Samsung SSD 970 EVO Plus 1TB (nvme)
Disk /dev/nvme1n1: 1000GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name  Flags
 1      1049kB  1000GB  1000GB  ext4


root@pmx5:~# sudo blkid -o list
device                                          fs_type         label            mount point                                         UUID
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/dev/nvme0n1p3                                  ext4                             /home                                               cb2e1883-8456-4647-9432-a86cc17d201a
/dev/nvme0n1p1                                  vfat                             /boot/efi                                           6F7B-1FDE
/dev/nvme0n1p2                                  ext4                             /                                                   6c0ffa47-322c-4115-9d41-3cce70b08c14
/dev/sdb1                                       linux_raid_member proxmox5:0     (in use)                                            ccb5be21-2f11-f550-74a1-6b4e1ecee8a0
/dev/md0                                        ext4                             /stg/8tb                                            e4f25f34-cc70-4a2a-9991-1d17fb271e57
/dev/loop0                                      ext4                             (in use)                                            3a46effc-b443-4ddd-9703-28db13ba4f4e
/dev/nvme1n1p1                                  ext4                             (not mounted)                                       17a79082-d82a-496a-9d8e-dbd6d1f8b3c2
/dev/sda1                                       linux_raid_member proxmox5:0     (in use)                                            ccb5be21-2f11-f550-74a1-6b4e1ecee8a0
/dev/loop1                                      ext4                             (in use)                                            e0f0744f-6ad0-4c07-981f-72c8cbf7dbec
/dev/loop6                                      ext4                             (in use)                                            0871c3f0-efb0-4c53-92b6-132a0e1dc18d
/dev/loop4                                      ext4                             (in use)                                            b0cbdb1c-07fe-46f5-bb06-2c2a8afb5ef0
/dev/loop2                                      ext4                             (in use)                                            282efc1a-55cf-4efb-b773-fd9d5c142b5e
/dev/loop7                                      ext4                             (in use)                                            ad205f41-cf66-41d8-b10d-406ba3f7a619
/dev/loop5                                      ext4                             (in use)                                            6f1182c9-8475-45f8-b02b-eee88dd97cad
/dev/loop3                                      ext4                             (in use)                                            1f7dff87-25ed-452f-95c6-dc40b0423190

root@pmx5:~# lsblk-more 
TRAN   TYPE  PATH           NAME        MOUNTPOINT UUID                                   SIZE FSTYPE     MODE       PTTYPE PARTTYPE                             LABEL
       loop  /dev/loop0     loop0                  3a46effc-b443-4ddd-9703-28db13ba4f4e    10G ext4       brw-rw----                                             
       loop  /dev/loop1     loop1                  e0f0744f-6ad0-4c07-981f-72c8cbf7dbec    20G ext4       brw-rw----                                             
       loop  /dev/loop2     loop2                  282efc1a-55cf-4efb-b773-fd9d5c142b5e    10G ext4       brw-rw----                                             
       loop  /dev/loop3     loop3                  1f7dff87-25ed-452f-95c6-dc40b0423190    20G ext4       brw-rw----                                             
       loop  /dev/loop4     loop4                  b0cbdb1c-07fe-46f5-bb06-2c2a8afb5ef0    20G ext4       brw-rw----                                             
       loop  /dev/loop5     loop5                  6f1182c9-8475-45f8-b02b-eee88dd97cad   420G ext4       brw-rw----                                             
       loop  /dev/loop6     loop6                  0871c3f0-efb0-4c53-92b6-132a0e1dc18d    20G ext4       brw-rw----                                             
       loop  /dev/loop7     loop7                  ad205f41-cf66-41d8-b10d-406ba3f7a619    50G ext4       brw-rw----                                             
sata   disk  /dev/sda       sda                                                           7,3T            brw-rw---- gpt                                         
       part  /dev/sda1      └─sda1                 ccb5be21-2f11-f550-74a1-6b4e1ecee8a0   7,3T linux_raid brw-rw---- gpt    0fc63daf-8483-4772-8e79-3d69d8477de4 proxmox5:0
       raid1 /dev/md0         └─md0     /stg/8tb   e4f25f34-cc70-4a2a-9991-1d17fb271e57   7,3T ext4       brw-rw----                                             
sata   disk  /dev/sdb       sdb                                                           7,3T            brw-rw---- gpt                                         
       part  /dev/sdb1      └─sdb1                 ccb5be21-2f11-f550-74a1-6b4e1ecee8a0   7,3T linux_raid brw-rw---- gpt    0fc63daf-8483-4772-8e79-3d69d8477de4 proxmox5:0
       raid1 /dev/md0         └─md0     /stg/8tb   e4f25f34-cc70-4a2a-9991-1d17fb271e57   7,3T ext4       brw-rw----                                             
nvme   disk  /dev/nvme1n1   nvme1n1                                                     931,5G            brw-rw---- gpt                                         
nvme   part  /dev/nvme1n1p1 └─nvme1n1p1            17a79082-d82a-496a-9d8e-dbd6d1f8b3c2 931,5G ext4       brw-rw---- gpt    0fc63daf-8483-4772-8e79-3d69d8477de4 
nvme   disk  /dev/nvme0n1   nvme0n1                                                     931,5G            brw-rw---- gpt                                         
nvme   part  /dev/nvme0n1p1 ├─nvme0n1p1 /boot/efi  6F7B-1FDE                              487M vfat       brw-rw---- gpt    c12a7328-f81f-11d2-ba4b-00a0c93ec93b 
nvme   part  /dev/nvme0n1p2 ├─nvme0n1p2 /          6c0ffa47-322c-4115-9d41-3cce70b08c14 279,4G ext4       brw-rw---- gpt    0fc63daf-8483-4772-8e79-3d69d8477de4 
nvme   part  /dev/nvme0n1p3 └─nvme0n1p3 /home      cb2e1883-8456-4647-9432-a86cc17d201a 651,6G ext4       brw-rw---- gpt    0fc63daf-8483-4772-8e79-3d69d8477de4
```
  
</details>




Для просмотра и копирования снепшотов Timeshift в вашей системе на базе Debian 12 с Proxmox, следуйте этим шагам:

### 1. Просмотр снепшотов Timeshift
Вы уже выполнили команду `timeshift --list`, которая показала доступные снепшоты:
```
Num     Name                 Tags  Description                 
------------------------------------------------------------------------------
0    >  2025-07-17_17-42-21  O     After ProxMox Installation  
```

Снепшоты хранятся в `/run/timeshift/480618/backup` (это временная точка монтирования).  
Фактическое расположение снепшотов — на `/dev/md0`, который смонтирован в `/stg/8tb` (как видно из `lsblk-more`).

Чтобы найти точный путь к снепшотам:
```bash
sudo ls -l /stg/8tb/timeshift/snapshots
```

### 2. Проверка целостности RAID
Перед копированием убедитесь, что RAID `/dev/md0` в норме:
```bash
cat /proc/mdstat
sudo mdadm --detail /dev/md0
```
Если статус `clean` и оба диска (`sda1`, `sdb1`) активны, проблем нет.


### 3. Копирование снепшотов на удалённую машину
Используйте `rsync` для безопасного копирования. Так как `/dev/md0` уже смонтирован в `/stg/8tb`, копирование не повлияет на его работу.

#### Пример команды:
```bash
sudo rsync -avz --progress /stg/8tb/timeshift/snapshots/2025-07-17_17-42-21/ kirill@192.168.87.136:/home/kirill/timeshift_backup/pmx5/
```
#### Пояснение:
- `-avz`: архивирование, сохранение атрибутов и сжатие.
- `--progress`: отображение хода копирования.
- Убедитесь, что у пользователя `kirill` есть права на запись в `/home/kirill/timeshift_backup/pmx5/` на целевой машине.


### 4. Дополнительные советы
- **Скорость копирования**: Если сеть медленная, используйте флаг `--bwlimit=50000` в `rsync` (ограничение до 50 МБ/с).
- **Исключение файлов**: Добавьте `--exclude='*/cache/*'`, чтобы пропускать кэш.
- **Проверка после копирования**: На целевой машине выполните:
  ```bash
  ls -l /home/kirill/timeshift_backup/pmx5/
  ```

#### Альтернатива с `scp` (если `rsync` недоступен):
```bash
sudo scp -r /stg/8tb/timeshift/snapshots/2025-07-17_17-42-21/ kirill@192.168.87.136:/home/kirill/timeshift_backup/pmx5/
```


### Важно!
- Не размонтируйте `/dev/md0` во время копирования.
- Если снепшоты занимают много места, убедитесь, что на целевой машине достаточно свободного места (`df -h`).

Таким образом, вы безопасно скопируете снепшоты, не затрагивая работу RAID.














