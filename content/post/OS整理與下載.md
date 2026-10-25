---
title: OS整理下載
toc: true
date: 2026-05-29
---
## OS發行版
![](static/20230427194612.png)


| 系統名稱                         | 演進系統      | 描述                                  |
| ---------------------------- | --------- | ----------------------------------- |
| IBM OS/2 Warp                | ArcaOS    | 根據IBM原始碼進行修改                        |
| Amiga OS                     | AROS (開源) |                                     |
| FygoOS/FnOS                  |           | NAS系統                               |
| PrimeOS/ Phoenix OS / FydeOS |           | Android OS去修改的作業系統，現在也可以透過Waydroid跑 |
| Ghostbsd                     |           |                                     |
| IBM PC-DOS                   |           | 有推出繁體中文                             |
| MS-DOS 8.0                   |           |                                     |
| FreeDOS                      |           |                                     |
| SvarDOS：開源DR-DOS             |           |                                     |

參考資料
https://archiveos.org/

ParrotOS：另一種Kail Linux 的Debian發行版
Fedora CoreOS：預裝containerd，使用Ignition Config可預裝K8S  
Flatcar：專屬容器的linux系統
NetBSD：硬體支援週期長，從1970s-老舊機器都支援，但不支援Nvidia  
incusOS：所有指令都被禁止，只能建立LXC相關容器  
OpenVZ：  
IBM PowerVC：IBM專屬虛擬化平台，需授權  
Talos Linux/RancherOS ：針對K8s的發行版  
FreedomBox  
UmbrelOS  
Raspberry Pi OS Desktop
RetroNAS
Solaris 10、11/ OpenIndiana / SmartOS / OmniOS

## NAS 系統
ZimaOS
CasaOS
TrueNAS
UnRAID
OMV

## Windows 

Windows LTSC 是Enterprise 改過來的，Enterprise有最新版本號
Tiny 11
Nano 11
[UnCyler](https://home.gamer.com.tw/eason929623) 優化系統映像檔
UUP dump https://uupdump.net/
https://massgrave.dev/

##  優化指令
- 停用Windows Defender
- 停用 Windows Update
- 停用 Superfetch
- 開啟 RDP
- 關閉休眠
- 關閉記憶體完整性
- 關閉VBS (虛擬化安全性)
- 關閉HVCI
- 關閉遙測服務
```
# 開啟rdp
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0  
# 關閉休眠
powercfg /hibernate off
# 關閉記憶體完整性
reg add "HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d 0 /f
# Credential Guard (停用會導致hyper-v無法開啟)

```