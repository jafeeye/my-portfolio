---
title: Linux 系統優化部署
toc: true
date: 2026-08-20
tags:
  - Linux
---
```toc
```

1. IME 在設定值/Keyboard/輸入來源新增臺灣語(如果是英文版在輸入來源要選Other才會出現台灣)
![](static/Pasted%20image%2020260821001151.png)
2. 新增qemu-agent guest
```
dnf install -y qemu-guest-agent
systemctl enable --now qemu-guest-agent
```
3. 新增 VMtools
```
## server
dnf install -y open-vm-tools
systemctl enable --now vmtoolsd
## desktop
dnf install -y open-vm-tools-desktop
```
4. xtrem.js
```
qm set <VMID> --serial0 socket

## rockylinux
systemctl enable --now serial-getty@ttyS0.service
systemctl status serial-getty@ttyS0.service
grubby --update-kernel=ALL --args="console=tty0 console=ttyS0,115200n8"


```


## Linux 大量重置
```
## 列出目前machine-id
cat /etc/machine-id

## 方法1重產machine-id
echo uninitialized > /etc/machine-id # 完整firstboot作法
sync
reboot

## 方法2重新開機產生machine-id 給模板使用
truncate -s 0 /etc/machine-id
sync
poweroff

## 方法3cloud-init 做法
cloud-init clean --logs --machine-id
sync
poweroff

## 錯誤做法，絕對不要直接rm -rf 這個檔案，有軟連結會導致不能開機
## rm -f /etc/machine-id ;
## rm -f /var/lib/dbus/machine-id ;

```