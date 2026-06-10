---
title: Windows 常用指令工具
date: 2026-02-22
toc: true
---
## 前言
Windows 雖然是GUI操作介面為主，但也不乏許多相關指令可以除錯及呼叫相關功能  

1. `msiexec /i xxxx.msi /l*v install.log` 在安裝msi在執行目錄產生log檔除錯
2. `gpupdate /force /target:computer /wait:0` 套本機原則
3. `rsop.msc` 顯示本機原則結果
4. 產生原則網頁 `gpresult /h result.html && start .\\result.html`
5. 憑證儲存檢視 `cmdkey /list` `cmdkey /add:192.168.1.100 /user:帳號 /pass:密碼`
6. 顯示訊息小視窗 `msg * 我是訊息` `msg /server:127.0.0.1 * 訊息`
7. 換顏色 `color a`
8. 產生網址QRCode `curl [qrenco.de/https://www.google.com.tw](<http://qrenco.de/https://www.google.com.tw>)`
9. 出現歷史指令 `F7`
10. 暫時alias `doskey ps=powershell,再輸入ps`
11. 開啟磁碟計數功能 `diskperf -y`

## 系統元件
- 安全移除裝置 `control hotplug.dll`

## 網路
- 查開的Port `netstat -nao`
- 路由表 `route print` `route add 192.169.0.1` (有docker很好用) `route delete`
- 刪除DNS快取 `ipconfig /flushdns`
- 查詢地址 `nslookup www.google.com.tw`
- 刪除smb連線 `net use * /delete /y`、`net use \\\\192.168.1.100\\share /delete` 、`net use \\\\192.168.1.100\\share /user:newuser newpassword`
- 秀wifi密碼 `netsh wlan show profiles`
- telnet
- 檢查網址 `curl -Is <https://www.google.com.tw`>
- 下載檔案 `curl -o myfile.zip <https://example.com/file.zip`>

## 安裝
- winget install <套件名稱>
- winget install <套件名稱> --scope machine
- winget search <套件名稱>
- winget install Microsoft.Coreutils
- choco
- 換使用者權限 `runas /user:pin cmd` `runas /user:administrator cmd`
## WS相關
- sconfig
- `Add-WindowsCapability -Online -Name "ServerCore.AppCompatibility~~~~0.0.1.0"`

## 檔案資料夾
- 改檔名：ren <檔案路徑+檔名><新檔名>
- 建立檔案：touch <檔案名>
- 看檔案/建立空檔 type <檔案位置>、 type nul > config.txt
- 寫入檔案：echo erwer > config.txt
- 建立1gb空檔 fsutil file createnew test_1gb.txt 1073741824
- 切家目錄 `cd %homepath%\\desktop` `cd %USERPROFILE%\\desktop` (給C槽之外用)
## 開關機
- 到bios介面 `shutdown /r /fw /f /t 0` `shutdown /r /o /t 0`
## 終端機
- `Start .` 、 `Start xxx.exe` 、`Start .\`(ps)  開啟應用程式
- `taskkill /f /im explorer.exe && start explorer.exe` 重啟進程
## 第三方
- iperf3
- tshark
- ncat -zv 192.168.1.AIX_IP 22
- tcpvcon
- accesschk
- du
- psexec
### Systernails Tools
- `psexec [\\\\computer[,computer2[,...] | @file]][-u user [-p psswd]][-n s][-r servicename][-h][-l][-s|-e][-x][-i [session]][-c [-f|-v]][-w directory][-d][-<priority>][-a n,n,...][-verbose] cmd [arguments]`
- `BgInfo`
- `shellrunas /reg [/quiet]`
- SDelete

RDCMan
![](260328-rdcman.png)
`Tools\Options\Experiences` 可以調整連線穩定度，可調成boradband 比較穩定

### Windows RSAT

### APP-V
### Windows Terminal

### Windows Perforance Analyze

### Microsoft Network Monitor


## 快速鍵
Win+Shift+S 快速存成圖片檔
Ctrl+Shift+Esc 工作管理員
Ctrl+Win+Shift+B 軟重啟


