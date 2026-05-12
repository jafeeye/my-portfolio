---
title: 常用Linux功能指令
toc: true
date: 2026-04-02
---
## 常用設定
```
export LANG=en_US.UTF-8 //避免安裝軟體語系不符
date -s "2026-05-05 11:00:00"  //手動校時避免dnf無法安裝
```


macOS 要push之前驗證裝 `brew tap microsoft/git-credential-manager` 
## 啟用zsh
 1. 編輯組態檔
```
nano ~/.zshrc        //   ~/代表家目錄
```
2. 加入以下內容
```
# 初始化補齊系統 
autoload -Uz compinit compinit 
# 開啟選單模式，按下 Tab 兩次後進入選單 
zstyle ':completion:*' menu select
```
3. 存檔
```
source ~/.zshrc      //   重新讀取設定檔
```
4. 要快速顯示檔案輸入cd，tab兩次出現資料夾，再按tab做選擇

## Vi
顯示行數 `set nu`



## 網路

debian 設定網路重新載入設定 `ifreload -a`  
監聽Port `netstat -tunlp | grep 5432`  、 ss -tunlp | grep 80
檢查網址有效 `crul - i 網址`  
`nc -uv <IP> <Port> `  

\* 發生過ping無法使用可能網段不對 例host設172.16.8.3 example.com 結果誤打成172.168.8.3 example.com
如果Ping 8.8.8.8無法成功但卻可以上網,可能防火牆擋掉ICMP Type-8

## 查Log
`tail -f /var/log/production.log`  
`journalctl -b -1 -r`


## 資料夾
建立資料夾並進入位置 `mkdir test1 && cd test1` 
查看資料夾大小 `du -sh <illumio-pce>`

## 切換使用者
1. 有安裝sudo套件
(切換使用者都建議加上-,以載入完整設定)  
普通使用者輸入 `sudo -i` 切換su，在su模式輸入 exit 切回普通使用者 //sudo su 也可以
切換特定使用者 `sudo -u <使用者帳號>`   

2. 沒裝sudo套件
切換root   `su`
普通使用者切換su  `su -`    
切換特定使用者 `su - gss`  


權限設定
使用者加入sudo `usermod -aG wheel <username>`




## 安裝套件
yum RHEL7之前,dnf RHEL8之後
dnf 要跳過gpg檢查 dnf -no gpgcheck

因有時候內建repo會把gpgcheck取消,以下為確保在無連網環境能透過dnf+gpgkey 安裝

```
1.vi illumio.key 後貼上begin跟end後存檔

2.匯入gpg key
sudo rpm --import /home/gss/illumio.key

3.用rpm -K 可檢查是否成功匯入key,正確會顯示digests signatures OK
rpm -K illumio-pce-25.2.40-141.el9.x86_64.rpm

4.強制做gpg檢查安裝,是否能安裝成功
dnf install illumio-pce-25.2.40-141.el9.x86_64.rpm --setopt=localpkg_gpgcheck=1
```





## 寫入檔案
sudo su -
echo "192.168.8.58  kevin.bdx.dev" >> /etc/hosts
exit

## 服務
systemctl  
sysctl
top：表格式工作管理員
htop
free-h : 查詢記憶體用量



## 位置
opt : 存放第3方軟體地方



## AIX
ipfstat -io


## Ubuntu 常用軟體
- Nemo：sudo apt-get install nemo
- synaptic：sudo apt-get install synaptic
- gdebi：sudo apt install gdebi
- gparted 


## Rocky linux 常用軟體
- dnf install epel-release
-  dnf install chrony
- dnf install net-tools
- dnf bind-utils
- nmon
- htop
## openSUSE


## Kail Linux 