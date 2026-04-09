---
title: 常用Linux指令
toc: true
date: 2026-04-02
---
macOS 要push之前驗證裝 `brew tap microsoft/git-credential-manager`
## 啟用zsh
```
nano ~/.zshrc        //   ~/代表家目錄
```
加入以下內容
```
# 初始化補齊系統 
autoload -Uz compinit compinit 
# 開啟選單模式，按下 Tab 兩次後進入選單 
zstyle ':completion:*' menu select
```
存檔
```
source ~/.zshrc      //   重新讀取設定檔
```
要快速顯示檔案輸入cd，tab兩次出現資料夾，再按tab做選擇

## 網路

`ifreload -a` debian 設定網路重新載入設定
`netstat -tunlp | grep 5432` 監聽Port 
`crul - i 網址` 
`nc -uv <IP> <Port> ` 

\* 發生過ping無法使用可能網段不對 例host設172.16.8.3 example.com 結果誤打成172.168.8.3 example.com
如果Ping 8.8.8.8無法成功但卻可以上網,可能防火牆擋掉ICMP Type-8
## 查Log
`tail -f /var/log/production.log
`journalctl -b -1 -r`


## 資料夾
`mkdir test1 && cd test1` 建立資料夾並進入位置

## 切換使用者
(切換使用者都建議加上-,以載入完整設定)
普通使用者輸入 `sudo -i` 切換su，在su模式輸入 exit 切回普通使用者 //sudo su 也可以
切換特定使用者 `sudo -u <使用者帳號>`
沒裝sudo
普通使用者 su - 切換su 
切換特定使用者 su - gss


## 寫入檔案
sudo su -
echo "192.168.8.58  kevin.bdx.dev" >> /etc/hosts
exit

## 服務
systemctl  
sysctl