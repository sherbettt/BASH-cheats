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

