---
title: Linux 網路設定
date: 2026-07-13
toc: true
---
Debian 固定DNS




## Ubuntu
Ubuntu LXC，預設用systemd-resolved ，會把PVE WebUI上的DNS套到LXC容器上

預設會是用 Netplan。你可以在 YAML 設定檔中，明確指定不使用 DHCP 帶來的 DNS（`dhcp4-overrides`）。
1. **打開 Netplan 設定檔：**
```
nano /etc/netplan/50-cloud-init.yaml
```
    _(檔名可能依環境不同，請至 `/etc/netplan/` 查看)_
2. **修改內容加入 overrides：**
```
network:
  version: 2
  ethernets:
	eth0:
	  dhcp4: true
	  dhcp4-overrides:
		use-dns: false  # 關鍵：忽略 DHCP 派發的 DNS
	  nameservers:
		addresses: [8.8.8.8, 1.1.1.1] # 填入你自訂的 DNS
```
3. **套用設定：**
```
netplan apply
```

## Rocky Linux
```
nmcli connection modify enp6s18 ipv4.dns "8.8.8.8 8.8.4.4" 
nmcli connection modify enp6s18 ipv4.ignore-auto-dns yes 
nmcli connection up enp6s18
nmcli connection show enp6s18 | grep dns
cat /etc/resolv.conf
```

