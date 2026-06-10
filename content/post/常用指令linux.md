---
title: 常用Linux功能指令
toc: true
date: 2026-04-02
---

macOS 要push之前驗證裝 `brew tap microsoft/git-credential-manager` 
## 網路
- Debian 設定網路重新載入設定 `ifreload -a`  
- 監聽Port `netstat -tunlp | grep 5432`  、 `ss -tunlp | grep 80`
- 檢查網址有效 `crul - i 網址`   `nc -uv <IP> <Port>`  
- 網路重新取得IP `ifdown eth0 --force && ifup eth0`  
- 查看DNS `cat /etc/resolv.conf`
>\* 發生過ping無法使用可能網段不對 例host設172.16.8.3 example.com 結果誤打成172.168.8.3 example.com
>如果Ping 8.8.8.8無法成功但卻可以上網,可能防火牆擋掉ICMP Type-8
## 查Log
- `tail -f /var/log/production.log`  
- `journalctl -b -1 -r`
## 使用者
1. 借權限(向root借權，但密碼是打目前使用者登入密碼)
- 借權限成sudo `sudo -i`，在su模式輸入 exit 
- 借權限成特定使用者 `sudo -u <使用者帳號>`   
2. 切帳號登入(要有原帳號密碼才能登入)
- 切root帳號登入，環境變數在目前使用者 `su`
- 切root帳號登入，環境變數在root使用者 `su -`    
- 切特定使用者，環境變數在特定使用者  `su - gss`  
3. 看目前登入使用者
- who ,who -H ,w,id
4. 管理帳戶
- 建立使用者跟加密碼 `useradd kevin` / `passwd kevin`
- 列出本機所有帳戶 `cat /etc/passwd`

方法1 sudo visudo
方法2 加入sudoers : sudo visudo -f /etc/sudoers.d/jack jack ALL=(ALL:ALL) ALL (sudoers.d個別設定檔)
方法3 使用者加入sudo `usermod -aG wheel <username>` (RedHat)

## 檔案資料夾
1. 檔案權限
- 決定檔案執行權限 chmod 770 <資料夾>
- 決定檔案擁有者是誰 chown -R <使用者名稱> <資料夾>
2. scp 傳輸檔案
- 上傳目錄 `scp <參數> <本地檔案位置> <使用者帳號>＠<IP位置>: <遠端檔案位置> 
sudo scp `-r` test/ `root@192.168.8.5:~`
- 下載目錄 
>-r 複製整個目錄,沒加把路徑當檔案
>複製資料夾直接複製就好不用在本地創一個相同名字資料夾
>複製檔案要記得本身創的使用者有沒有權限複製
3. 建立大空檔
dd if=/dev/zero of=testimage.raw bs=1G count=8
4. 寫入檔案
echo "192.168.8.58  kevin.bdx.dev" >> /etc/hosts
5. 列出空間
- df -h (只能看掛載點大小)
![](Pasted%20image%2020260609205205.png)
- `du -h --max-depth=1 / 2>/dev/null | sort -rh`  (列出各資料夾大小)
![](Pasted%20image%2020260609205359.png)
- `du -sh <資料夾>` (顯示目前位置資料夾大小)
![](Pasted%20image%2020260609205719.png)
- lsblk
![](Pasted%20image%2020260609210153.png)
建立資料夾並進入位置 `mkdir test1 && cd test1` 
~表示為用戶目錄 EX:/home/PIN
～/.表示用戶目錄下隱藏資料夾 EX:～/.資料夾
ls -l
-  **`cp -r ./* /var/tmp`**
    - 效果：把 `mydata` 裡面的所有內容物（不含隱藏檔），**直接散落、倒進** `/var/tmp/` 底下。
- **`cp -r . /var/tmp/`**
    - 效果：它會把 `mydata` **這整個資料夾本身** 複製過去！也就是說，它會在目的地建立一整包 `/var/tmp/mydata/`，然後把所有東西（含隱藏檔）好好地收在這個新資料夾裡。


## 路徑
```
/var/log
    /tmp
    /lock
    /liｂ        var系統變動資料
/tmp
/sbin
/lib
/home
/usr/share
	/local
	/lib ：執行檔相關so 類dll
	/man
	/bin ：執行檔
/etc
/dev
/bin ：系統執行檔
/opt : 存放第3方軟體地方
/proc
```

## 終端機
nautilus admin:/
./ 執行應用程式
history：查看打的所有指令
```
stty -a 查詢目前佔用功能鍵
backspace 無法使用 stty erase ^H ,如果是出現^? stty erase ^? 
```

```
快捷键：
Tab : 自動補齊
Ctrl+L ：清除螢幕訊息
Ctrl+S /Ctrl+Q : 畫面凍結/解除凍結(XON/XOFF)
Ctrl+C : 中斷程式
Ctrl+U : 清除貼上所有文字
Ctrl+A : 游標到行首
Ctrl+E : 游標到行尾

Ctrl D : 删除当前光标所在字符
命令行窗口中键/Shift Insert: 粘贴（相当于Windows的**Ctrl V**）
在命令行窗口选中即复制
Ctrl R，再按历史命令中出现过的字符串：按字符串寻找历史命令（重度推荐）
Ctrl PageUp : 屏幕输出向上翻页
Ctrl PageDown : 屏幕输出向下翻页
```

```
nano
Option+X (Alt+X) 隱藏選單
```


`^[](200~` 貼上夾帶模式 `bind 'set enable-bracketed-paste off'`


### Vi
顯示行數 `set nu`


cd wewe/


## 亂數
```
openssl rand -base64 16
```

## 環境變數
### 啟用zsh
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

## 服務
systemctl  
sysctl
top：表格式工作管理員
htop
free-h : 查詢記憶體用量
pkill：踢掉服務

## 補充-自行取用
### Ubuntu 常用軟體
sudo apt install nemo synaptic gdebi gparted freerdp2-x11
- Nemo：
- synaptic
- gdebi：
- gparted 
- xfreerdp：`xfreerdp /size:90% /v:192.168.170.200` //遠端到 192.168.170.200 
### Rocky linux 常用軟體
dnf install epel-release chrony net-tools bind-utils nmon htop
- epel-release
- chrony
- net-tools
- bind-utils
- nmon
- htop
### openSUSE 常用軟體


### Kail Linux 常用軟體

## RHEL
無訂閱啟用RockyLinux鏡像源
```
vi /etc/yum.repos.d/rocky.repo

##如果有Fortclient擋住,關掉ssl
[rocky-baseos]
name=Rocky Linux 9 - BaseOS
baseurl=https://dl.rockylinux.org/pub/rocky/9/BaseOS/x86_64/os/
gpgcheck=1
gpgkey=https://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-Rocky-9
enabled=1
sslverify=0

[rocky-appstream]
name=Rocky Linux 9 - AppStream
baseurl=https://dl.rockylinux.org/pub/rocky/9/AppStream/x86_64/os/
gpgcheck=1
gpgkey=https://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-Rocky-9
enabled=1
sslverify=0

#修改後記得清除暫存
dnf clean all
```

## SSL握手失敗原因
```
date
dnf upgrade ca-certificates
```
## 常用設定
```
export LANG=en_US.UTF-8 //避免安裝軟體語系不符
date -s "2026-05-05 11:00:00"  //手動校時避免dnf無法安裝
export Path=$PATH:/usr/bin  //將路徑加入程式環境變數
開啟自動登入：系統設定/登入視窗/使用者，打上使用者名稱 (預設可登入root環境)
```