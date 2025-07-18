Для начала выясним разделы на Ximper Linux.

<details>
<summary>lsblk, blkid, parted</summary>

```bash
┌─ kirill ~ 
└─ $ sudo lsblk-more 
MOUNTPOIN NAME        TRAN   UUID                                 TYPE   SIZE FSTYPE MODE       PTTYPE PARTTYPE                             LABEL
          nvme0n1     nvme                                        disk 476,9G        brw-rw---- gpt                                         
/boot/efi ├─nvme0n1p1 nvme   6845-5F34                            part   511M vfat   brw-rw---- gpt    c12a7328-f81f-11d2-ba4b-00a0c93ec93b 
[SWAP]    ├─nvme0n1p2 nvme   8f70fab1-86fe-41b3-80cd-a071b5f7fe3b part   8,4G swap   brw-rw---- gpt    0fc63daf-8483-4772-8e79-3d69d8477de4 
/home     └─nvme0n1p3 nvme   d52de598-b702-4de5-ad46-a8b99b6be1a5 part   468G btrfs  brw-rw---- gpt    0fc63daf-8483-4772-8e79-3d69d8477de4 

┌─ kirill ~ 
└─ $ sudo blkid -o list
device                                           fs_type         label            mount point                                          UUID
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/dev/nvme0n1p3                                   btrfs                            (in use)                                             d52de598-b702-4de5-ad46-a8b99b6be1a5
/dev/nvme0n1p1                                   vfat                             /boot/efi                                            6845-5F34
/dev/nvme0n1p2                                   swap                             [SWAP]                                               8f70fab1-86fe-41b3-80cd-a071b5f7fe3b

┌─ kirill ~ 
└─ $ sudo parted -l
Model: KBG50ZNV512G KIOXIA (nvme)
Disk /dev/nvme0n1: 512GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system     Name  Flags
 1      1049kB  537MB   536MB   fat32                 boot, esp
 2      537MB   9556MB  9019MB  linux-swap(v1)
 3      9556MB  512GB   503GB   btrfs

```
</details>


Чтобы посмотреть, где физически хранятся ваши снапшоты Timeshift на разделе Btrfs, выполните следующие шаги:

1. Снапшоты Timeshift в Btrfs хранятся как подтома (subvolumes) в корневом томе. Сначала определим, где смонтирован ваш корневой раздел Btrfs:

```bash
sudo btrfs subvolume list /
```

2. Если корневой раздел не смонтирован напрямую, а смонтирован только `/home` (как видно из вашего вывода `lsblk`), то смотрим подтома в `/home`:

```bash
sudo btrfs subvolume list /home
```

3. Снапшоты Timeshift обычно находятся в папке `timeshift-btrfs/snapshots`. Вы можете проверить её содержимое:

```bash
sudo ls -l /home/timeshift-btrfs/snapshots
```

4. Если вы не видите эту папку, возможно, она скрыта. Попробуйте:

```bash
sudo ls -la /home/.timeshift
```

5. Также вы можете временно смонтировать корневой подтом Btrfs и проверить его содержимое:

```bash
sudo mkdir -p /mnt/btrfs
sudo mount /dev/nvme0n1p3 /mnt/btrfs
sudo ls -l /mnt/btrfs/timeshift-btrfs/snapshots
```

После проверки не забудьте размонтировать:

```bash
sudo umount /mnt/btrfs
```

Из вывода Timeshift видно, что у имеется один снапшот с меткой "Manual1". Он физически хранится в подтоме Btrfs на разделе `/dev/nvme0n1p3`, который смонтирован как `/home`.


<details>
<summary>Timeshift info</summary>
          
```bash
┌─ kirill ~ 
└─ $ sudo timeshift --list-devices
Mounted '/dev/nvme0n1p3' at '/run/timeshift/48762/backup'
btrfs: Quotas are not enabled

Devices with Linux file systems:

Num     Device              Size   Type  Label  
------------------------------------------------------------------------------
0    >  /dev/nvme0n1p3  502.5 GB  btrfs         

┌─ kirill ~ 
└─ $ sudo btrfs subvolume list /home
ID 256 gen 35696 top level 5 path @
ID 257 gen 35696 top level 5 path @home
ID 258 gen 16802 top level 256 path @/var/lib/machines
ID 329 gen 35672 top level 5 path timeshift-btrfs/snapshots/2025-07-18_10-49-53/@
ID 330 gen 35673 top level 5 path timeshift-btrfs/snapshots/2025-07-18_10-49-53/@home

┌─ kirill ~ 
└─ $ sudo cat /etc/timeshift/timeshift.json
{
  "backup_device_uuid" : "d52de598-b702-4de5-ad46-a8b99b6be1a5",
  "parent_device_uuid" : "",
  "do_first_run" : "false",
  "btrfs_mode" : "true",
  "include_btrfs_home_for_backup" : "true",
  "include_btrfs_home_for_restore" : "false",
  "stop_cron_emails" : "true",
  "schedule_monthly" : "false",
  "schedule_weekly" : "true",
  "schedule_daily" : "false",
  "schedule_hourly" : "false",
  "schedule_boot" : "false",
  "count_monthly" : "1",
  "count_weekly" : "2",
  "count_daily" : "1",
  "count_hourly" : "1",
  "count_boot" : "1",
  "snapshot_size" : "0",
  "snapshot_count" : "0",
  "date_format" : "%Y-%m-%d %H:%M:%S",
  "exclude" : [],
  "exclude-apps" : []
}
```
</details>



### **Где физически находятся снапшоты?**  
Из вывода `btrfs subvolume list /home` видно, что снапшоты Timeshift хранятся в **подтомах Btrfs** по пути:  
```
timeshift-btrfs/snapshots/2025-07-18_10-49-53/@  
timeshift-btrfs/snapshots/2025-07-18_10-49-53/@home  
```
Но они **не отображаются в `/home` как обычные папки**, потому что Btrfs использует **подтома (subvolumes)**, которые монтируются отдельно.  

---

### **Как посмотреть содержимое снапшота?**  
Чтобы получить доступ к файлам внутри снапшота, нужно **смонтировать подтом вручную**.  

#### **1. Смонтируем корень Btrfs раздела (`/dev/nvme0n1p3`) временно**  
```bash
sudo mkdir -p /mnt/btrfs-root
sudo mount /dev/nvme0n1p3 /mnt/btrfs-root
```

#### **2. Посмотрим содержимое папки `timeshift-btrfs/snapshots`**  
```bash
sudo ls -l /mnt/btrfs-root/timeshift-btrfs/snapshots
```
Вы должны увидеть папку `2025-07-18_10-49-53`, которая содержит подтома `@` (корневая система) и `@home` (ваши домашние файлы).  

#### **3. Можно смонтировать конкретный снапшот для просмотра**  
Например, смонтируем корневой снапшот (`@`):  
```bash
sudo mkdir -p /mnt/snapshot-root
sudo mount -o subvol=timeshift-btrfs/snapshots/2025-07-18_10-49-53/@ /dev/nvme0n1p3 /mnt/snapshot-root
```
Теперь вы можете просмотреть файлы снапшота:  
```bash
ls /mnt/snapshot-root
```

#### **4. После просмотра размонтируем**  
```bash
sudo umount /mnt/snapshot-root
sudo umount /mnt/btrfs-root
```

---

### **Почему снапшоты не видны в `/home`?**  
- Timeshift хранит их как **отдельные подтома Btrfs**, а не как обычные папки.  
- Они не занимают место в `/home`, пока не смонтированы.  

---

### **Как управлять снапшотами через Timeshift?**  
- **Удалить старые снапшоты**:  
  ```bash
  sudo timeshift --delete --snapshot '2025-07-18_10-49-53'
  ```
- **Создать новый вручную**:  
  ```bash
  sudo timeshift --create --comments "Новый снапшот"
  ```
- **Открыть графический интерфейс**:  
  ```bash
  sudo timeshift-gtk
  ```

---

### **Вывод**  
Ваши снапшоты находятся в **подтомах Btrfs** на разделе `/dev/nvme0n1p3`, но чтобы увидеть их содержимое, нужно смонтировать их вручную. Если нужно просто восстановить систему, используйте Timeshift в графическом режиме или через CLI (`--restore`).
