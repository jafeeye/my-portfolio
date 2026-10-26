---
title: 共享區域網路SMB設定
toc: true
date: 2026-10-03
tags:
  - Windows
  - SMB
---
在Windows 與不同平台共享SMB容易出現無法出現檔案，可由下面方式處理

1. 先檢查Port是否開啟，並使用CMD 掛載連線
```
powershell tnc 192.168.8.104 -Port 445
net user \\192.168.8.104\檔案 /user:smbreader *
explorer "\\192.168.8.106\App"
```

2. 出現錯誤訊息
系統發生錯誤1272，因為您的組織安全性原則已封鎖未經驗證的來賓存取
`Set-SmbClientConfiguration -EnableInsecureGuestLogons $true -Force`
Win11 會強制未經驗證來賓做簽章
