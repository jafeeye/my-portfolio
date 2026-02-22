---
title: Windows 好用指令、工具
date: 2026-02-22
toc: true
---
## 前言
Windows 雖然是GUI操作介面為主，但也不乏許多相關指令可以除錯及呼叫相關功能  

1. `msiexec /i xxxx.msi /l*v install.log` 在安裝msi在執行目錄產生log檔除錯
2. `gpupdate /force /target:computer /wait:0` 套本機原則
3. `rsop.msc` 顯示本機原則結果
4. 產生原則網頁 `gpresult /h result.html && start .\\result.html`
5. 重啟進程 `taskkill /f /im explorer.exe && start explorer.exe`
6. 啟動資料夾 `start .`
7. 憑證儲存檢視 `cmdkey /list` `cmdkey /add:192.168.1.100 /user:帳號 /pass:密碼`
8. 刪除smb連線 `net use * /delete /y` `net use \\\\192.168.1.100\\share /delete` `net use \\\\192.168.1.100\\share /user:newuser newpassword`
9. 游標無法移動、桌面異常 `Win+Ctrl+Shift+B`
10. 換使用者權限 `runas /user:pin cmd` `runas /user:administrator cmd`
11. 查詢地址 `nslookup www.google.com.tw`
12. 顯示訊息小視窗 `msg * 我是訊息` `msg /server:127.0.0.1 * 訊息`
13. 換顏色 `color a`
14. 查詢port `netstat` `netstat -o`
15. 切家目錄 `cd %homepath%\\desktop` `cd %USERPROFILE%\\desktop` (給C槽之外用)
16. 秀wifi密碼 `netsh wlan show profiles`
17. 檢視檔案內容 `type 檔案路徑`
18. 檢查網址 `curl -Is <https://www.google.com.tw`>
19. 產生網址QRCode `curl [qrenco.de/https://www.google.com.tw](<http://qrenco.de/https://www.google.com.tw>)`
20. 下載檔案 `curl -o myfile.zip <https://example.com/file.zip`>
21. 出現歷史指令 `F7`
22. 暫時alias `doskey ps=powershell,再輸入ps`
23. 刪除DNS快取 `ipconfig /flushdns`
24. 路由表 `route print` `route add 192.169.0.1` (有docker很好用) `route delete`
25. 到bios介面 `shutdown /r /fw /f /t 0` `shutdown /r /o /t 0`
26. 安全移除裝置 `control hotplug.dll`
27. 開啟磁碟計數功能 `diskperf -y`


### Systernails Tools

`psexec [\\\\computer[,computer2[,...] | @file]][-u user [-p psswd]][-n s][-r servicename][-h][-l][-s|-e][-x][-i [session]][-c [-f|-v]][-w directory][-d][-<priority>][-a n,n,...][-verbose] cmd [arguments]`
**`BgInfo`**
**`shellrunas /reg [/quiet]`**
RDCMan

#### Windows RSAT

#### APP-V
### Windows Ternailms

### Windows Perforance Analyze