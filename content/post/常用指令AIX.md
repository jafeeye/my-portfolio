---
title: 常用指令-AIX
toc: true
date: 2026-05-26
---
cd -
ls -l
ipfstat -io

顯示目前任務(迴圈)
方法1：while true; do tput clear; ps auxw | head -n 1 ; ps auxw | grep ven ; sleep 2; done
方法2：nmon -C <程式名稱>，進入畫面再按t
## 快速鍵
set -o emacs 模式

| **動作**       | **現代鍵盤按鍵**  | **Emacs 模式標準按鍵 (完全不會噴亂碼)** | **記憶口訣**          |
| ------------ | ----------- | -------------------------- | ----------------- |
| **往回刪除一格**   | `Backspace` | **`Ctrl + H`**             | 取代傳統退格鍵           |
| **游標往左移一格**  | `←` (左方向鍵)  | **`Ctrl + B`**             | **B**ackward (後退) |
| **游標往右移一格**  | `→` (右方向鍵)  | **`Ctrl + F`**             | **F**orward (前進)  |
| **移到指令最前面**  | `Home`      | **`Ctrl + A`**             | **A**head (最前)    |
| **移到指令最後面**  | `End`       | **`Ctrl + E`**             | **E**nd (最後)      |
| **清除游標後整行**  | _無_         | **`Ctrl + K`**             | **K**ill (殺掉後半段)  |
| **往後刪除一整個字** | _無_         | **`Esc` 放開再按 `Backspace`** | 批次刪除              |
在 AIX 的 Emacs 模式下，想找上一條敲過的指令，按「上方向鍵 `↑`」一定會噴亂碼（通常會噴 `^[OA` 這種怪字）。請改用這個極致優雅的盲操按法：
- **找上一條指令（Up）：** 按 **`Ctrl + P`**（**P**revious，上一條）
- **找下一條指令（Down）：** 按 **`Ctrl + N`**（**N**ext，下一條）
- **關鍵字搜尋歷史（Reverse Search）：** 按 **`Ctrl + R`**，然後直接輸入你記得的指令關鍵字（例如輸入 `ifconfig`）

`stty eof ^D` 一直跳出系統日誌
歷史指令搜尋（取代上、下方向鍵）

## 設定

選單快速鍵

| 動作       | 快速鍵    |
| -------- | ------ |
| 切換yes或no | F4或tab |
| 多選       | esc+7  |
|          | esc+4  |

nmon 等待時間很長,輸入oslevel -s
stty erase 或使用set -o vi

## 安裝軟體
安裝OpenSSH (預設無安裝)，驗證 ssh IP位置
smit install 進入安裝畫面
![](Pasted%20image%2020260621111926.png)

`lslpp -l|grep open` 檢查目前安裝套件有無open開頭

### 設定網路

![[static/Diagram 2.svg]]
smit mktcpip //引導網路設定 (設定IP、Gateway、mask)，設定完ping區網是否會通
![](Pasted%20image%2020260616230051.png)
查看目前IP `ifconfig -a`
![](Pasted%20image%2020260616230441.png)


lsdev -Cc adapter
lsdev -Cc if
smit tcpip
netstat -rn


快速設定網路方法
lsdev  -Cc if
ifconfig en0 192.168.8.75 up
ifconfig -a 查看網卡IP
netstat -rn 看路由表

關機
shutdown -F
errpt //log檔是用errlog
lspv

其他
prtconf
## 檔案資料夾
| **特性**     | **df (Disk Free)**                  | **du (Disk Usage)**       |
| ---------- | ----------------------------------- | ------------------------- |
| **核心目的**   | 查看**整個檔案系統（掛載點）**的剩餘與已用空間。          | 查看**特定目錄或檔案**佔用了多少空間。     |
| **獲取數據來源** | 直接讀取磁碟的 **超級區塊 (Superblock)** 或元數據。 | 逐一掃描目錄，把裡面的**檔案大小累加**起來。  |
| **執行速度**   | **極快**（一瞬間完成），不論硬碟多大。               | **較慢**，檔案越多、目錄越深，掃描時間就越長。 |
| **主要功能**   | 「我的 `/tmp` 爆了沒？」、「還剩幾 GB 可用？」       | 「是哪個王八蛋檔案把我的硬碟吃光了？」       |

看根目錄/資料夾大小 `df -g <資料夾>`
![](Pasted%20image%2020260531134742.png)
看目錄分配多少空間 du -g <資料夾>

填充空檔 
```
# 解除連線使用者最大建立1gb檔案
ulimit -f unlimited
dd if=/dev/urandom of=/tmp/test.raw bs=1M count=2048
```

列出資料夾下面檔案：在打路徑打到一半時，接著按`Esc`+`=` 
![](Pasted%20image%2020260531135413.png)
## LVM
```
#查看vg大小，從FreePPs可以知道LVM剩多少空間
lsvg rootvg

#幫/tmp 加上2GB空間
chfs -a size=+2G /tmp
```
![](Pasted%20image%2020260531135722.png)
## 安裝軟體
出現db4 error：rpm --rebuilddb
AIX Toolbox for Linux Applications
- 舊版 AIX（如 AIX 7.1 / 7.2 早期）支援 **`yum`**。
- 新版 AIX（如 AIX 7.2 晚期、AIX 7.3）全面改用 **`dnf`**（背後跑的是 Python 3 體系）。


## 參考資料
- [bilibili-Window下安装运行AIX系统详解完整版|Muonsol](https://www.bilibili.com/video/BV1AZqvYrEar/)
- [IBM-Run your AIX VM on x86 using KVM and QEMU](https://community.ibm.com/community/user/blogs/hugo-b/2024/01/17/aix-virtualization-x86-kvm-qemu#ItemCommentPanel)