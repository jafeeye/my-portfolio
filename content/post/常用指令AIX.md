---
title: 常用指令-AIX
toc: true
date: 2026-05-26
---
Ctrl+H 往後刪除文字

AIX Toolbox for Linux Applications
cd -
ls -l
ipfstat -io

- 舊版 AIX（如 AIX 7.1 / 7.2 早期）支援 **`yum`**。
- 新版 AIX（如 AIX 7.2 晚期、AIX 7.3）全面改用 **`dnf`**（背後跑的是 Python 3 體系）。

AIX Toolbox for Linux Applications


顯示目前任務(迴圈)
while true; do tput clear; ps auxw | head -n 1 ; ps auxw | grep ven ; sleep 2; done
方法2：nmon -C <程式名稱>，進入畫面再按t


快速鍵
Ctrl+H 對應到Backspace
Ctrl+B/F 游標往前 / 往後
`Ctrl` + `A` ：游標直接**到最前面（開頭）**。
`Ctrl` + `E` ：游標直接到最後面（結尾）**。
`Ctrl` + `K`


prtconf

## 安裝AIX

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


0c50 qemu磁碟大小也不會變化

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

## 設定
nmon 等待時間很長,輸入oslevel -s
stty erase 或使用set -o vi

安裝軟體
安裝OpenSSH (預設無安裝)
lslpp -l|grep open
smit install 



驗證
ssh 127.0.0.1

設定網路
lsdev -Cc adapter
lsdev -Cc if
smit tcpip
smit mtcpip

快速方法
lsdev  -Cc if
ifconfig en0 192.168.8.65 up
netstat -rn 看路由表


關機
shutdown -F
errpt //log檔是用errlog
lspv
