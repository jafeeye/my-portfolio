---
title: SMB 協定共享設定
toc: true
date: 2026-10-23
tags:
  - SMB
---
Windows 常常出現無法共用狀況，可針對以下方式去設定

```
powershell tnc 192.168.8.106 -Port 445
net use \\192.168.8.106
explorer \\192.168.8.106
```

掛載用法
persistent: 不會自動連線  
net share：顯示目前共用資料夾 
列出所有網路磁碟: net use  
不用指定drive letter，用* 當做temp如下: net use * "\\server\my media" /persistent:no  
```
net use Z:\\192.168.8.106\Software /user:PIN Yster86a /persistent:no
net use /delete *

## 資料夾權限設為everyone情形下
net use \\192.168.8.106 /user:u \login 
## 有密碼情形
net use \\192.168.8.106 /user:administrator <密碼> 

```


無法掛載
- 錯誤系統發生 1272 錯誤。您無法存取此共用資料夾，因為您組織的安全性原則已封鎖未經驗證的來賓存取。這些原則可協助保護您的電腦，以防禦網路上不安全或惡意的裝置。
`Set-SmbClientConfiguration -EnableInsecureGuestLogons $true -Force`

- 發生延伸錯誤 `Set-Smb Client Configuration -RequireSecuritySignature $false`


如果無法共享在認證管理員儲存
![gh](https://raw.githubusercontent.com/jafeeye/imglib/main/obsidian/1742819159000r3q28b.png)

>[!Note] 實驗結果
>這個程式會導致macOS莫名無法儲存密碼列印，必須要每次輸入密碼才能原因不明，有可能是密碼多次儲存的關係 

出現共享文件：目前的帳戶已被鎖定無法登陸  
`cmdkey /add:ip位置 /user:用戶名 /pass:密碼`  

Win11 無法共享原因 (提高安全性，預設不能用伺服端的權限帳戶強制要設密碼)
HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation\AllowInsecureGuestAuth =1 或 - 編輯「啟用不安全的來賓登入」原則，將其設定為「已啟用」。


## Linux 共享SMB
1. 在在本機安全性原則/網路清單管理原則，點擊修改的網路連線，改成網路類型：私人
![](Pasted%20image%2020260621115753.png)

2. `etc/samba/smb.conf`
```
[Global]
workgroup = WORKGROUP//讓Ubuntu和Win兩台區網電腦同一網域
client min protocol = SMB3
client max protocol = SMB3
```