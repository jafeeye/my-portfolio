---
title: Proxmox LXC 安裝GDM
toc: true
date: 2026-11-01
---
1. 先創建一個特權容器

```
sudo apt update sudo apt install -y ubuntu-desktop
```

```
sudo nano /etc/X11/Xwrapper.config
allowed_users=anybody
```

將使用者加入硬體群組
```
sudo usermod -aG video,render,audio,input root
```


3. 修改容器組態檔
```
nano /etc/pve/lxc/100.conf
#100改成自己lxc容器id

lxc.mount.entry: tmpfs run tmpfs rw,nosuid,nodev,mode=0755,size=256M,create=dir
lxc.mount.entry: tmpfs run/lock tmpfs rw,nosuid,nodev,noexec,mode=0755,size=16M,create=dir
lxc.mount.entry: tmpfs tmp tmpfs rw,nosuid,nodev,mode=1777,size=2G,create=dir
lxc.mount.entry: /run/udev run/udev none bind,ro,optional,create=dir
lxc.cgroup2.devices.allow: c 226:* rwm
lxc.cgroup2.devices.allow: c 13:* rwm
lxc.cgroup2.devices.allow: c 116:* rwm
lxc.cgroup2.devices.allow: c 4:* rwm
lxc.cgroup2.devices.allow: c 10:223 rwm
lxc.cgroup2.devices.allow: c 189:* rwm
lxc.mount.entry: /dev/dri/card1 dev/dri/card1 none bind,optional,create=file
lxc.mount.entry: /dev/dri/renderD128 dev/dri/renderD128 none bind,optional,create=file
lxc.mount.entry: /dev/input dev/input none bind,optional,create=dir
lxc.mount.entry: /dev/snd dev/snd none bind,optional,create=dir
lxc.mount.entry: /dev/uinput dev/uinput none bind,optional,create=file
lxc.mount.entry: /dev/bus/usb dev/bus/usb none bind,optional,create=dir
lxc.mount.entry: /dev/tty0 dev/tty0 none bind,optional,create=file
lxc.mount.entry: /dev/tty1 dev/tty1 none bind,optional,create=file
lxc.mount.entry: /dev/tty2 dev/tty2 none bind,optional,create=file
lxc.mount.entry: /dev/tty3 dev/tty3 none bind,optional,create=file
lxc.mount.entry: /dev/tty4 dev/tty4 none bind,optional,create=file
lxc.mount.entry: /dev/tty5 dev/tty5 none bind,optional,create=file
lxc.mount.entry: /dev/tty6 dev/tty6 none bind,optional,create=file
```


4. 更改容器設定值
![](static/Pasted%20image%2020261101190415.png)



5. 修復其他功能
語系導致Terminal打不開
```
apt-get install -y locales
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

```
設定卡住停用ModernManager
```
sudo systemctl stop ModemManager
sudo systemctl disable ModemManager
sudo systemctl mask ModemManager

```


Ctrl+Alt+F1-F5 可以一次直通多個Linux 輸出畫面