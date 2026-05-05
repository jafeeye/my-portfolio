---
title: hyper-v 進階功能 WSLg,GPU-PV
date: 2026-03-08
toc: true
---
## 前言
一些Hyper-V 的進階功能


## 二代強制使用舊式vhd


## 開啟兼容WHP
備註:要Windows Server 2022 才能開啟

![](260404-whp01.png)

![](260404-whp02.png)

### RDP
 webclient


### WSLg

安裝桌面環境 `sudo apt-get update && sudo apt-get install -y xfce4 xfce4-goodies`
wsl
```
echo "export XDG_SESSION_TYPE=x11" >> ~/.profile
echo "export GDK_PLATFORM=x11" >> ~/.profile
echo "export GDK_BACKEND=x11" >> ~/.profile
echo "export QT_QPA_PLATFORM=xcb" >> ~/.profile
echo "export WAYLAND_DISPLAY=" >> ~/.profile
source ~/.profile
```

```bash
Xephyr -br -ac -noreset -resizeable -screen 1600x900 :1 &
```

```
export DISPLAY=:1
dbus-run-session startxfce4
```

### 並存方案
當開啟WSL2後會開啟虛擬化型安全性，VMWare性能大幅下降，WSL1並不是內核也無法做顯卡直通
- NoHyperV+WSL+VMWare
- HyperV+WSL2+VMWare (性能下降)
Win11 24H2 預設開啟VBS虛擬化，檢查方式： msinfo32.exe 虛擬化型安全性為執行中，關閉`bcdedit /set hypervisorlaunchtype off`


### 參考資料

1. https://yulun.me/2014/vmware-shortcut-startup-fullscreen/  "快速啟動虛擬機 (建立捷徑 Windows/VMware)"
2. Windows 11 WSL2跑Linux桌面環境與圖形程式的方法，使用WSLg XWayland https://ivonblog.com/posts/run-linux-desktop-on-wsl/
3. [VMware和HyperV(wsl2)共存后性能大幅下降的解决方案 | 骏马金龙](https://www.junmajinlong.com/others/wsl_vmware_hyperv/)

