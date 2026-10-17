---
title: Proxmox 架設NFS Server與ESXi XenServer互通
toc: true
date: 2026-10-17
tags:
  - PVE
  - NFS
  - ESXi
  - Synology
---
 
 
 CT 安裝NFS Server
參考作法 [Github](https://gist.github.com/rwenz3l/0907385f6a6690c34eb8e36fa73d8405?permalink_comment_id=4009395)
 1. 建立Debian CT，在Wizard取消選擇非特權，完成後先不啟動選擇「巢狀」和「NFS」功能
 2. 已將要共用的資料夾掛載到容器中
 3. 安裝 nfs-kernel-server

| 方式               | LXC/VM 看到什麼      | PVE 能否存取  | 能否多人共享    | 作法                                                         | 路徑                                                              |
| ---------------- | ---------------- | --------- | --------- | ---------------------------------------------------------- | --------------------------------------------------------------- |
| PVE NVMe Host 掛載 | 共享主機目錄           | 是         | 是         |                                                            | `實體NVMe → PVE host ext4/XFS → nfs-kernel-server → vmbr1 → VM`   |
| bind mount 給 LXC | 共享主機目錄           | 可以        | 可由 NFS 分享 | 在容器使用 userspace 的 **NFS-Ganesha**，並把 NVMe 目錄 bind mount 進去 | `實體NVMe → PVE host ext4/XFS → bind mount → LXC NFS-Ganesha`<br> |
| raw block device | 一顆虛擬磁碟           | 原則上不可同時掛載 | 否         |                                                            |                                                                 |
| NFS client       | 網路共享目錄/datastore | 可以        | 可以        |                                                            |                                                                 |
| VM-> unraid      |                  |           |           |                                                            |                                                                 |
| LXC -> DSM       |                  |           |           |                                                            |                                                                 |
| VM -><br>TrueNAS |                  |           |           |                                                            |                                                                 |

## 方法2、PVE NVMe Host 掛載
1. 格式化NVME，並建立一個目錄是EXT4或NFS都可
2. 固定掛載
```
mkdir -p /srv/nfs/nvme


fdisk -l /dev/nvme2n1
wipefs -n /dev/nvme2n1
lsblk /dev/nvme2n1

## 格式化
apt update && apt install -y parted
parted -s /dev/nvme2n1 mklabel gpt
parted -s /dev/nvme2n1 mkpart primary 1MiB 100%
partprobe /dev/nvme2n1
udevadm settle

## 打上lsblk 要看到nvme2n1 底下有nvme2n1p1 才能繼續格式化
mkfs.ext4 -L nfs-nvme /dev/nvme2n1p1
blkid /dev/nvme2n1p1 ##確認nvme2n1p1底下的 uuid

##掛載組態檔
nano /etc/fstab
UUID=你的UUID /srv/nfs/nvme ext4 defaults,noatime 0 2
##掛載
mount -a
findmnt /srv/nfs/nvme
df -hT /srv/nfs/nvme
```
3. 修改 `/etc/exports`，完成後執行 `exportfs -rav`，再執行 `chmod 0777 /srv/nfs/nvme/`
```
/srv/nfs/nvme 192.168.8.0/24(rw,sync,no_subtree_check,no_root_squash)
```
4. 在XenServer加入 `192.168.8.14:/srv/nfs/nvme/`，選擇NFSv3