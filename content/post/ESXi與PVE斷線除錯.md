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
# 關閉卸載功能，這能避免 
Hardware Unit Hang ethtool -K eno1 tso off gso off 
# 重新啟動網卡服務 
systemctl restart networking
```

Proxmox 重啟後 `ethtool` 的設定會消失，請編輯網路設定檔：
1. `nano /etc/network/interfaces`
2. 在 `iface eno1 inet manual` 下方增加一行： `post-up /usr/sbin/ethtool -K eno1 tso off gso off`

## ESXi 
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

