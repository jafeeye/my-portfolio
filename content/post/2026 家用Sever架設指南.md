---
title: 2026 家用Sever架設指南
date: 2026-02-28
toc: true
---
## 前言
最近這一年學習上課加上學了許多開源技術，而現在已進入5G時代，可以在家用架許多好用服務供家裡使用，於是就有了以下紀錄


![](homelab-diagram.svg)


三層式架構：Data Plane、Control Plane  
列印VM：PaperMF、AirPrint、Windows 區網印表機  
備份VM：WS2022-Recuse  
VDI: VMware Horizon、Citirx、SPICE、Kasm Workskapce  
Mointor VM：

![](lab.svg)



## 命名問題
有些程式路徑不能包含空格，Windows除了`\/：*？''｜` 都是支持，不能用空格是因為一些軟體的功能都是調用命令行執行，命令行程序傳輸參數就是用空白格來分割 ，要解決這問題就是路徑及代稱路徑參數一定要前後加單引號

常見命名規則
軟體：Firefox_V10_Alpha_CHT_20220202.7z
文件名：文件名稱

範例1:專案存放
![](Pasted%20image%2020241123113459.png)
範例2:檔案命名
![](Pasted%20image%2020241123113507.png)
範例3:
![](Pasted%20image%2020241123114616.png)


## 系統選擇
對於系統新舊而言，用最好的配置就是最好的系統

| 系統平台     | RAM   |
| -------- | ----- |
| Win7 x86 | 512MB |


## 影音資料庫

### 方案1: emby+infuse+playlist

缺：影片播放清單自己加 搜尋不直覺


### 方案2:PeerTube




設定不同資料夾顯示方式；設定/emby/首頁螢幕/，顯示預設畫面為哪種

### 音樂TAG編輯
整理音樂軟體
MediaGO 使用Gracenote抓取
先使用MP3Tag將檔名寫入標籤，再丟進軟體去擷取資訊
iTunes 抓取資訊
解決亂碼問題：可使用mp3tag將標籤以UTF-8全部寫入一遍
mp3 tag 信息里的album artist和artist 这两个tag 有什么区别？为什么没有词作者这一项？[https://www.zhihu.com/question/19736378](https://www.zhihu.com/question/19736378)
打造自己的 iTunes Server，一同分享最愛的 MP3 音樂
http://blog.itist.tw/2014/11/centos-itunes-server.html?zx=5522c0214f92462b

超級無損：支援7.1
DSD DSF DFF
無損：
DTS FLAC M4A WAV APE ASF AIFC 

### CrazyKTV
![gh|400](https://raw.githubusercontent.com/jafeeye/imglib/main/obsidian/1759737079000pcpta2.png)

因為大部分歌曲是原聲原影 (所以也不要去設,不然重複檔會一直加)
整理歌遇到原聲原影類別就砍掉
刪掉演唱會類別
有時候判斷也不準 有時並未重複
語系設定
程式不能偵測臺語加入
佛教
節慶

*unicode值不對無法判斷合唱:＆
將－替代為-
將＆替代為&
將^替代為&

翻唱就直接(其他 佚名)(佚名不知道誰唱_不要設定翻唱)
佚名設定：其他/佚名 (女聲)(優必勝)
佚名女
佚名男
佚名合唱

取代
取代所有英文文字[a-zA-Z ]
刪除空行 ^\s*\n 
只匹配一個數字加字元(^\d\.\S+)  例:1.好棒>01.好棒
(\S+)_(\S+)
愿 願、后 後、舍 捨、么 麽、干 乾、云 雲、傑<>杰 

大陸方言
福州語、潮州語
雷語
牛馬丁 潮語
小蜻蜓 你到底愛誰

CrazyKTV設定
一定要調成左右聲音
隨機播放使用立體聲




低配置方案
Firefox 裝上 h264ify-ehanced 可以硬解H.264

[1] Android TV 雖然稱為 SmartTV，但它笨重、反應遲鈍、速度慢、無法多應用切換，
Youtube TV：可使用Chrome 外掛加上 Kiosk Mode

## 機型
Dell Wyse
HP Prodesk
## 設備
Logitech K400 Plus 鍵盤 (非必要)
手把收納架
## 軟體
JRiver Media Center
PowerDVD
## 模擬器
DockStation
Redream
Pegasus gameos
Heimdall

## 作法
PowerDVD 播放YouTube 
Jriver 播放歌曲
遠端桌面用ipad控制htpc
Pegasus 當萬用前端 啟用crazyktv與es

## 關閉設定
關閉、停用 Win10自動傳送錯誤報告 Disable Error Reporting in Windows
刪除自動排程器的關閉程式錯誤報告


https://superuser.com/questions/1343290/disable-chrome-session-restore-popup


[1]: https://www.ctrl.blog/entry/why-htpc-benefits.html "Why you need a HTPC"
[2]: https://meta.appinn.net/t/topic/21972 "如何无边框地浏览网页？"







## 參考資料
1. 2026年-家庭/工作室/小企业免费的云桌面VDI方案--VDI for PVE8/9，https://yangwenqing.com/archives/2473/。超有價值文章，裡面所展示技術令人折服
2. [歷經30年，為啥這個文件夾越來越沒存在感](https://youtu.be/QtHFbskDCtg?si=YtUSAHONgQbf2Lik)
3. The Best Way to Organize Your Computer Files， [https://www.youtube.com/watch?v=bKjRKZxr-KY](https://www.youtube.com/watch?v=bKjRKZxr-KY)。
4. Linux 快速列出(製作)樹狀目錄結構清單(tree)
5. [https://www.spreadsheet.com/template/equipment-sign-out-system](https://www.spreadsheet.com/template/equipment-sign-out-system)
6. 制定檔案整理的規範，https://medium.com/deerlight/file-efc8c86e37d9。
