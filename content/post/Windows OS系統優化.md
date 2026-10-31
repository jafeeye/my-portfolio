---
title: Windows OS系統優化部署
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


### 二、Win 大量重置
```
sysprep /generalize /oobe /shutdown
登入Shift+F10 start ms-cxh:localonly

#powershell
& "$env:windir\System32\Sysprep\Sysprep.exe" /generalize /oobe /shutdown

# 確認目前uuid
whoami /user 

下了 sysprep /generalize /oobe /shutdown，會跑到建立新帳號
如果不想用新帳號 Ctrl+Shift+F3 會在重開使用Administrator登入
```


```
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
                <NetworkLocation>Work</NetworkLocation>
                <ProtectYourPC>3</ProtectYourPC>
            </OOBE>
            <AutoLogon>
                <Enabled>true</Enabled>
                <LogonCount>999</LogonCount>
                <Username>你原本的帳號名稱</Username>
                <Password>
                    <Value>你原本的密碼</Value>
                    <PlainText>true</PlainText>
                </Password>
            </AutoLogon>
            <TimeZone>Taipei Standard Time</TimeZone>
        </component>
    </settings>
</unattend>
```


```
sysprep /generalize /oobe /reboot /unattend:C:\Windows\System32\Sysprep\unattend.xml
```





### 三、優化指令
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