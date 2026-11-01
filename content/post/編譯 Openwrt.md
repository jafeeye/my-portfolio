---
title: 編譯 Openwrt
tags:
date: 2026-11-01
tag: PVE
---
# [一看就会的在pve创建ubuntu虚拟机编译属于自己的openwrt固件](https://www.geekxw.top/1301/)

# [一看就会的PVE LXC 部署OPENWRT旁路由和简单设置,运行内存只用100MB不到](https://www.geekxw.top/1346/)

[

[小陈折腾日记](https://www.geekxw.top/author/1/)

2年前发布

253180

apt install squashfs-tools

**/var/lib/vz/template/cache/**

unsquashfs openwrt-x86-64-generic-squashfs-rootfs-by-Xiaochenzhetengriji.img

cd /var/lib/vz/template/cache/squashfs-root

tar zcf /var/lib/vz/template/cache/OpenWRT-x86-64-generic-rootfs.tar.gz ./*

pct create 200 local:vztmpl/OpenWRT-x86-64-generic-rootfs.tar.gz --rootfs local-lvm:1 --ostype unmanaged --hostname openwrt --arch amd64 --cores 4 --memory 256 --swap 0 -net0 bridge=vmbr0,name=eth0

/etc/pve/lxc

features: keyctl=1,mknod=1,nesting=1  
lxc.apparmor.profile: unconfined  
lxc.include: /usr/share/lxc/config/openwrt.common.conf  
lxc.cgroup2.devices.allow: a  
lxc.cap.drop:  
lxc.mount.auto: proc:mixed sys:ro cgroup:mixed  
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file

vi /etc/config/network

vi /etc/config/uhttpd