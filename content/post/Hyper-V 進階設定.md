---
title: hyper-v 進階功能 WSLg,GPU-PV
date: 2026-03-08
toc: true
---
## 前言
一些Hyper-V 的進階功能


## WSL+WSLg

在Win10上啟用Windows 子系統Linux版、Hyper-V
WSL1：使用Linux轉譯內核，不需開WHP，可與VMware 第一層共存 (性能不減)
WSL2：使用WHP轉譯層強制開啟虛擬化型安全性，Hyper-V強制升為第一層，其他虛擬化軟體都跑WHP虛擬化引擎，性能會下降很多

>Win11 24H2 預設開啟VBS虛擬化，檢查方式： msinfo32.exe 虛擬化型安全性為執行中，關閉`bcdedit /set hypervisorlaunchtype off`


### 開啟WHP兼容
備註:要Windows Server 2022 才能開啟

![](260404-whp01.png)

![](260404-whp02.png)

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


## 二代強制用舊式vhd











## 參考資料

1. https://yulun.me/2014/vmware-shortcut-startup-fullscreen/  "快速啟動虛擬機 (建立捷徑 Windows/VMware)"
2. Windows 11 WSL2跑Linux桌面環境與圖形程式的方法，使用WSLg XWayland https://ivonblog.com/posts/run-linux-desktop-on-wsl/
3. [VMware和HyperV(wsl2)共存后性能大幅下降的解决方案 | 骏马金龙](https://www.junmajinlong.com/others/wsl_vmware_hyperv/)

