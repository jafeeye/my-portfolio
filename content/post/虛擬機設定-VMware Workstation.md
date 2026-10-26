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
```
"C:\Program Files (x86)\VMware\VMware Workstation\vmware.exe" -x -B -n "C:\xxx\Workspace Ubuntu 64bit.vmx"`
"C:\Program Files (x86)\VMware\VMware Workstation\vmplayer.exe" "D:\VMWare\PC-Hyread\PC-Hyread.vmx"`
```
**開機背景啟動**
```
"C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" start "D:\VMWare\DEV\DEV.vmx" nogui
```

**VMWare-KVM 模式**
`"C:\Program Files (x86)\VMware\VMware Workstation\vmware-kvm.exe" --preferences`
`"C:\Program Files (x86)\VMware\VMware Workstation\vmware-kvm.exe" "D:\WinXP SP3\WinXP SP3.vmx"`
缺點：這個模式有一個BUG，當實體機縮小視窗時，游標會移至虛擬機
### 啟用嵌套虛擬化
在VMWare 跑Hyper-V或WSL或Windows Server 啟用Hyper-V
```
hypervisor.cpuid.v0 = "FALSE"
mce.enable = "TRUE"
vhv.enable = "TRUE"
```


|功能|最主要目的|
|---|---|
|Debugging info|收集錯誤資料給工程師排錯|
|Disable page trimming|讓 VM 記憶體更穩定（不還給主機）|
|Progress log|更詳細的 VM 啟動/執行紀錄|
|Template mode|把 VM 當模板大量複製|
|USB debug|解析 USB passthrough 問題|
|Clean up disks|自動壓縮 VMDK 節省空間|
|Disable side-channel mitigations|**讓 VMware 在 Hyper-V 開啟時比較順、不會超慢**|
|Side-channel warning|提醒效能會下降|
