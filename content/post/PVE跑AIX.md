---
title: PVE跑aix
toc: true
date: 2026-05-31
---
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
