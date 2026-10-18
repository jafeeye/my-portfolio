---
title: Proxmox EVPN OSPF 設定
toc: true
date: 2026-10-18
tags:
  - EVPN
---
### BOND

### OSPF

### 網路路由
![](static/default-network-setup-routed.svg)

```
种常见情况是，你有一个公共 IP（在本例中假定为 198.51.100.5），以及一个用于 VM 的额外 IP 块 （203.0.113.16/28）。对于此类情况，我们建议进行以下设置：

auto lo
iface lo inet loopback

auto eno0
iface eno0 inet static
        address  198.51.100.5/29
        gateway  198.51.100.1
        post-up echo 1 > /proc/sys/net/ipv4/ip_forward
        post-up echo 1 > /proc/sys/net/ipv4/conf/eno0/proxy_arp


auto vmbr0
iface vmbr0 inet static
        address  203.0.113.17/28
        bridge-ports none
        bridge-stp off
        bridge-fd 0

```

### OpenVSwtch

https://www.zenwen.tw/proxmox-network-config-ovs-and-sdn/
