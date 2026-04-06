---
title: VMware Workstation 進階功能
toc: true
date: 2026-04-06
---
### VMWare 命令列
**在視窗右鍵選擇隱藏控件**
`%APPDATA%\Roaming\VMware\preferences.ini`寫入`pref.allowHideControls = "TRUE"`
**捷徑內容**
-n 開啟新視窗、-x 執行啟動虛擬機、 -X 啟動虛擬機完成後進入全螢幕、-f 執行全螢幕 -q 關閉虛擬機直接關閉視窗 -B 套用vmx預設設定
`"C:\Program Files (x86)\VMware\VMware Workstation\vmware.exe" -x -B -n "C:\xxx\Workspace Ubuntu 64bit.vmx"`
`"C:\Program Files (x86)\VMware\VMware Workstation\vmplayer.exe" "D:\VMWare\PC-Hyread\PC-Hyread.vmx"`
**開機啟動**
`"C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" start "D:\VMWare\DEV\DEV.vmx" nogui`
**VMWare-KVM 模式**
`"C:\Program Files (x86)\VMware\VMware Workstation\vmware-kvm.exe" --preferences`
缺點：視窗縮小滑鼠會跳回去
### 啟用嵌套虛擬化
在VMWare 跑Hyper-V或WSL或Windows Server 啟用Hyper-V
```
hypervisor.cpuid.v0 = "FALSE"
mce.enable = "TRUE"
vhv.enable = "TRUE"
```

