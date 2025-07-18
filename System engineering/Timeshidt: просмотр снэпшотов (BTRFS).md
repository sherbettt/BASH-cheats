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
