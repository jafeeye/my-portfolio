---
title: VIrtualBox 建置與設定
toc: true
date: 2026-10-12
tags:
  - 虛擬化
---
附加性套件有以下
- phpVirtualBox
- RemoteBox 
- VBoxVM

早期VirtualBox 6.1版本之前有純軟體模擬功能，但現在拔掉了，基本上如果vt-x 被Hyper-v 接管就無法使用，即使在半虛擬化調整成無或KVM也無效，需開啟WHP兼容層才能正常運作
```
Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -All -NoRestart
Restart-Computer

Disable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -NoRestart
```


若要使用VirtualBox Server功能需執行下面腳本 密碼為Windows登入帳密
```
cd /d "C:\Program Files\Oracle\VirtualBox"
vboxwebsrv.exe -t 0 -H 192.168.8.20
```

使用RemoteBox 或 RemoteBox Appliance 登入

