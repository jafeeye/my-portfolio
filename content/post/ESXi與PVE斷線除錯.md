---
title: ESXi與PVE斷線除錯
date: 2026-03-01
toc: true
---
## 前言

通常再過一段時間網站PVE入口連不上或ESXi插拔網線後連不上，通常是驅動問題導致
除錯顯示log指令
```
journalctl --until "2026-02-27 11:00:00" -n 100 -r
```
在指令發現這條
`Feb 27 15:25:25 pve-server kernel: e1000e 0000:00:1f.6 eno1: NIC Link is Up 1000 Mbps Full Duplex, Flow`
懷疑是驅動出現 `Detected Hardware Unit Hang` 關閉電源休眠可解決問題


```
# 關閉卸載功能Hardware Unit Hang，這能避免
ethtool -K enx00e01c680083 tso off gso off 
ethtool -K eno1 tso off gso off 
# 重新啟動網卡服務 
systemctl restart networking
```

Proxmox 重啟後 `ethtool` 的設定會消失，請編輯網路設定檔：
1. 在 `iface eno1 inet manual` 下方增加一行： `post-up /usr/sbin/ethtool -K eno1 tso off gso off`

## USB 網卡優化設定

想在不插網卡下加增加速度，方式是bridge 一張USB網卡，因為USB網卡也會有斷線問題，解決方式為一樣關閉休眠功能

```
auto lo
iface lo inet loopback

iface nic0 inet manual

auto vmbr0
iface vmbr0 inet static
        address 192.168.8.90/24
        gateway 192.168.8.1
        bridge-ports nic0 enx00e01c680083
        bridge-stp off
        bridge-fd 0
        post-up /usr/sbin/ethtool -K enx00e01c680083 tso off gso off

iface nic1 inet manual
source /etc/network/interfaces.d/*
```

- bridge-ports nic0 enx00e01c680083 //bridge到enx00e01c680083這張USB網卡
- post-up /usr/sbin/ethtool -K enx00e01c680083 tso off gso off  //關閉休眠功能


## ESXi 

實際案例遇到i219v當拔除超過5分鐘後就無法再連線，根據排除因為i219v是消費級晶片,第一思路關閉自動協商調整成1000Mbps失效，第二關閉EEE省電模組寫死在驅動，雖然ESXi 可以使用但是社群版驅動`ne1000` ，BIOS也找不到可以關閉EEE選項，只好直接放棄ESXi

```
esxcli network nic tso set -n vmnic0 -e 0
```
持久化設定
/etc/rc.local.d/local.sh 在exit0 之前加入下面這條
```
esxcli network nic tso set -n vmnic0 -e 0
```
重開機生效
```
/sbin/auto-backup.sh
```


ESXI 7升8
![[Pasted image 20260321174801.png]]
