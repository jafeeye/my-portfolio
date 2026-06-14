---
title: AIX  安裝
toc: true
date: 2026-05-31
---
## Windows 環境
安裝AIX
因為純軟體模擬，安裝需有耐心，除非卡很久畫面都沒變化不然就是在安裝
AIX 7.1 qemu Power7-10  
AIX 7.2 qemu Power7,Power8  
AIX 7.3  
```
## windows 增加環境變數
qemu-img.exe create -f qcow2 D:\vm\aix71\hdisk0.qcow2 20G
qemu-img.exe create -f qcow2 D:\vm\aix71\hdisk1.qcow2 20G

## qemu 安裝
qemu-system-ppc64.exe `
-cpu POWER7 `
-machine pseries `
-smp 2 `
-m 3g `
-serial mon:stdio `
-nographic `
-drive file=D:\vm\aix71\hdisk0.qcow2,if=none,id=drive-virtio-disk0 `
-device scsi-hd,drive=drive-virtio-disk0 `
-drive file=D:\vm\aix71\hdisk1.qcow2,if=none,id=drive-virtio-disk1 `
-device scsi-hd,drive=drive-virtio-disk1 `
-cdrom D:\aix_7200-04-02-2027_1of2_072020.iso `
-prom-env "boot-command=boot cdrom:" `
-prom-env "input-device=/vdevice/vty@71000000" `
-prom-env "output-device=/vdevice/vty@71000000"

```
安裝完後，要移除iso檔案從硬碟啟動
```powershell
qemu-system-ppc64.exe `
-cpu POWER7 `
-machine pseries `
-smp 2 `
-m 3g `
-serial mon:stdio `
-nographic `
-drive file=D:\vm\aix71\hdisk0.qcow2,if=none,id=drive-virtio-disk0 `
-device scsi-hd,drive=drive-virtio-disk0 `
-drive file=D:\vm\aix71\hdisk1.qcow2,if=none,id=drive-virtio-disk1 `
-device scsi-hd,drive=drive-virtio-disk1 `
-cdrom D:\aix_7200-04-02-2027_1of2_072020.iso `
-prom-env "boot-command=boot disk:" `
-prom-env "input-device=/vdevice/vty@71000000" `
-prom-env "output-device=/vdevice/vty@71000000"
```

打通虛擬機跟主機連線，先在Windows安裝OpenVPN執行檔選項的tap網卡，並把tap網卡改成tap0，啟動腳本下面加上這串
```
-nic tap,ifname=tap0
```

## PVE Debian LXC 環境

先建立一個LXC的非特權容器開啟Nesting，安裝powerppc模擬器
```
apt update
apt install qemu-system-ppc qemu-utils -y
```
nano /etc/pve/lxc/容器ID.conf
```
mp0: /mnt/pve/iso,mp=/mnt/iso
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
```
補充語法：也可以用指令的方式
```
pct set <VMID> <-mp0> 
pct set 182 -mp0 /mnt/pve/iso,mp=/mnt/iso
```

執行腳本前先安裝
```
apt update && apt install screen -y
```
要放到腳本上執行不然會斷線，建立nano start_aix.sh
```bash
#!/bin/bash

# Define the Screen session name for this VM
SESSION_NAME="aix72_vm"
# Define the path for the boot log file with a timestamp
LOG_FILE="/tmp/aix_boot_$(date +%Y%m%d_%H%M%S).log"

echo "=================================================="
echo "🚀 Starting IBM AIX 7.2 Emulation Environment..."
echo "📂 All boot console logs will be saved to: $LOG_FILE"
echo "💡 TIP: Press 'Ctrl+A' then 'D' to detach from session."
echo "   The VM will continue running in the background."
echo "=================================================="
sleep 2

# Start QEMU inside a detached Screen session and log output using tee
screen -dmS "$SESSION_NAME" bash -c "qemu-system-ppc64 \
  -cpu POWER7 \
  -machine pseries \
  -smp 2 \
  -m 3g \
  -serial mon:stdio \
  -nographic \
  -drive file=/hdisk0.qcow2,if=none,id=drive-virtio-disk0 \
  -device scsi-hd,drive=drive-virtio-disk0 \
  -cdrom /mnt/iso/template/iso/aix_7200-04-02-2027_1of2_072020.iso \
  -prom-env 'boot-command=boot cdrom:' \
  -prom-env 'input-device=/vdevice/vty@71000000' \
  -prom-env 'output-device=/vdevice/vty@71000000' \
  -nic tap,script=no,downscript=no,mac=52:54:00:12:34:10,ifname=tap0 02>&1 | tee $LOG_FILE"

# Automatically attach to the created screen session
screen -r "$SESSION_NAME"
```
完成後給權限 `chmod +x start_aix.sh`

建立網卡連結
```
# 1. 建立名為 br0 的虛擬網橋 
brctl addbr br0 
# 把這個網橋介面「升起來」（啟動） 
ip link set br0 up

# 2. 建立你在 QEMU 寫的那個 tap0 網卡 
ip tuntap add dev tap0 mode tap 
ip link set tap0 up

# 3. 把 tap0 和容器原本的網卡 eth0 全部扔進網橋裡 
brctl addif br0 tap0 
brctl addif br0 eth0
```

改寫後腳本 (從硬碟啟動、刪除光碟機)
```
#!/bin/bash

# 定義這台虛擬機的 Screen 後台名稱
SESSION_NAME="aix72_vm"
# 定義開機 Log 紀錄檔的路徑
LOG_FILE="/tmp/aix_boot_$(date +%Y%m%d_%H%M%S).log"
# 掛載iso
ISO=""

echo "=================================================="
echo "🚀 正在啟動 IBM AIX 7.2 模擬環境..."
echo "📂 本次開機的所有文字紀錄將自動存入: $LOG_FILE"
echo "💡 提示：隨時可以按 Ctrl+A 放開後再按 D 退出後台，虛擬機不會中斷"
echo "=================================================="
sleep 2

# 使用 Screen 在後台開闢獨立空間，並執行 QEMU，同時利用 tee 雙向輸出 Log
screen -dmS "$SESSION_NAME" bash -c "qemu-system-ppc64 \
  -cpu POWER7 \
  -machine pseries \
  -smp 2 \
  -m 3g \
  -serial mon:stdio \
  -nographic \
  -drive file=/hdisk0.qcow2,if=none,id=drive-virtio-disk0 \
  -device scsi-hd,drive=drive-virtio-disk0 \
  -drive file=${ISO},if=none,id=drive-virtio-disk1,media=cdrom \
  -prom-env 'boot-command=boot disk:' \
  -prom-env 'input-device=/vdevice/vty@71000000' \
  -prom-env 'output-device=/vdevice/vty@71000000' 2>&1 | tee $LOG_FILE"

# 啟動後，自動幫你接入（Attach）畫面
screen -r "$SESSION_NAME"

```