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
```



如果無法共享在認證管理員儲存
![gh](https://raw.githubusercontent.com/jafeeye/imglib/main/obsidian/1742819159000r3q28b.png)

>[!Note] 實驗結果
>這個程式會導致macOS莫名無法儲存密碼列印，必須要每次輸入密碼才能原因不明，有可能是密碼多次儲存的關係 

## Windows 
掛載指令  
net share：顯示目前共用資料夾   
`net use Z:\\192.168.8.106\Software /user:PIN Yster86a /persistent:no`
persistent: 不會自動連線  
中斷網路磁碟機  
`net use /delete *`  
>在Windows中，Windows 檔案總管無法阻止它「自動嘗試連線」已掛載但尚未連線的 SMB 網路磁碟機(GPT)，  


出現共享文件：目前的帳戶已被鎖定無法登陸  
`cmdkey /add:ip位置 /user:用戶名 /pass:密碼`  

Win11 無法共享原因 (提高安全性，預設不能用伺服端的權限帳戶強制要設密碼)
HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation\AllowInsecureGuestAuth =1 或 - 編輯「啟用不安全的來賓登入」原則，將其設定為「已啟用」。做gpudate
發生延伸錯誤 `Set-Smb Client Configuration -RequireSecuritySignature $false`

## SMB

這是如果你電腦沒有設定密碼(空密碼)情況可以下以下  
net use z: \\IP-ADDRESS\share-folder /user:username \login
有密碼:  
net use X: \\server\share /user:user abc  
你們也可以這樣下，沒有login，他會跳出來要你打帳號密碼。沒密碼就按enter鍵如下  
net use z: \\IP-ADDRESS\share-folder  
如果要清掉或取消連線可以用 \delete 如下:  
net use z: /delete  
列出所有網路磁碟: net use  
可以不用指定drive letter，用* 當做temp如下:  
net use * "\\server\my media" /persistent:no  


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