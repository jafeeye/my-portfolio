---
title: Windows OS系統優化
toc: true
date: 2026-10-26
tags:
  - Windows
---
```toc
```
### 一、Windows 版本選擇

Windows LTSC 是Enterprise 改過來的，Enterprise有最新版本號，LTSC透過更新包也可以升到2026
Tiny 11
Nano 11
[UnCyler](https://home.gamer.com.tw/eason929623) 優化系統映像檔
UUP dump https://uupdump.net/
https://massgrave.dev/
Windows10Debloater

### 二、優化指令
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


優化後效果，主要觀察這三個值有沒有下降
![509](static/Pasted%20image%2020261026104842.png)

深度優化可達這樣

![517](static/Pasted%20image%2020261026114924.png)

Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control" -Name SvcHostSplitThresholdInKB -Type DWord -Value 33554432

```
Get-Process | Sort-Object ProcessName | Select-Object ProcessName,Id,@{Name="RAM_MB";Expression={[math]::Round($_.WorkingSet64/1MB,1)}},Path


Get-Process | Sort-Object ProcessName | Select-Object ProcessName,Id,@{Name="RAM_MB";Expression={[math]::Round($_.WorkingSet64/1MB,1)}},Path
```