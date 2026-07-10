---
title: ESXi斷線除錯
date: 2026-03-01
toc: true
---


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



