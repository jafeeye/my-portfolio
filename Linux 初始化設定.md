---
title: Linux 初始化設定
toc: true
date: 2026-08-20
---
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