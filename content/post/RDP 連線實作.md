---
title: RDP 連線實作
toc: true
date: 2026-05-29
---

## 桌面環境選擇
| **排名** | **桌面環境 **        | **RAM 佔用**            | **資源** | **適合的 xrdp 應用場景**                |
| ------ | ---------------- | --------------------- | ------ | -------------------------------- |
| **1**  | **LXQt**         | **約 200 MB**          | 🪶 極輕量 | 老舊伺服器、極度壓榨硬體的極限環境。               |
| **2**  | **XFCE**         | **約 250 MB**          | 🪶 輕量  | **多人 xrdp 首選！** 反應極快，功能完整。       |
| **3**  | **MATE**         | **約 350 MB**          | 🥈 次輕量 | **多人 xrdp 次選。** Windows 用戶無縫接軌。  |
| **4**  | **KDE Plasma**   | **約 400 MB ~ 600 MB** | ⚖️ 中量  | 適合**單人**遠端高自訂化桌面（不適合太多人連線）。      |
| **5**  | **Cinnamon**     | **約 600 MB**          | ⚖️ 中量  | Linux Mint 的預設桌面，動畫較多，xrdp 體感較重。 |
| **6**  | **Budgie**       | **約 650 MB**          | ⚖️ 中量  | 介面精美現代，但在遠端環境效率普通。               |
| **7**  | **Deepin (DDE)** | **約 950 MB**          | ❌ 笨重   | 特效極其華麗，嚴重依賴 GPU，千萬別用於 xrdp。      |
| **8**  | **GNOME**        | **約 1.0 GB ~ 1.2 GB** | ❌ 笨重   | 多數發行版預設，但對 xrdp 多人連線是資源災難。       |

## FreeRDP
官網連結：https://www.freerdp.com/
## XRDP
教學示範在Rocky Linux 9實作
### 前置安裝
```
## Rocky Linux 9, add the EPEL repository:
sudo dnf config-manager --set-enabled crb
sudo dnf install epel-release
## 安裝xrdp
sudo dnf -y install xrdp
## 啟動服務
sudo systemctl enable --now xrdp
## 服務通過防火牆
sudo firewall-cmd --zone=public --add-port=3389/tcp --permanent
sudo firewall-cmd --reload
```

## Ubunut LXC on XRDP
```
## 安裝xfce
apt update && apt install xfce4 xfce4-goodies -y 
# 3. 安裝 xrdp 
apt install xrdp -y 
# 4. 將 xrdp 加入 ssl-cert 群組，解決憑證讀取權限問題 
adduser xrdp ssl-cert


## 允許root登入
apt update && apt install openssh-server -y
nano /etc/ssh/sshd_config
PermitRootLogin yes
systemctl enable ssh && systemctl restart ssh


## 進去 startwm.sh 修改

# 把原本這兩行註解掉（前面加#），不讓它跑預設的 Xsession 
# test -x /etc/X11/Xsession && exec /etc/X11/Xsession 
# exec /bin/sh /etc/X11/Xsession 
# 強制指定啟動 XFCE 桌面 
startxfce4


# 1. 下載 Google 官方最新 Chrome 穩定版（純 .deb，不含 Snap） 
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb 
# 2. 用 apt 直接灌進去 
apt install ./google-chrome-stable_current_amd64.deb -y 
# 3. 砍掉暫存包 
rm google-chrome-stable_current_amd64.deb


## chromium只能用snap，偏偏lxc不支援snap安全機制
google-chrome --no-sandbox --disable-gpu
```

### 安裝中文語言
sudo apt-get install language-pack-zh*sudo apt-get install -y chinese*
### 補裝中文常用font
sudo apt-get install fonts-arphic-ukai fonts-arphic-uming fonts-ipafont-mincho fonts-ipafont-gothic fonts-unfonts-core


### 啟動腳本
無法打中文是因為使用者無法去執行ibus權限，指派成root就可以或是在一般使用者載入ibus環境，去`/etc/xrdp/sesman.ini` 去找UserWindowManager、DefaultWindowManager，看這設定檔放在哪，代表設定檔是放在startwm.sh
```
UserWindowManager=startwm.sh
DefaultWindowManager=startwm-bash.sh
```

全域腳本
因為也不知道startwm.sh放在哪，先用find指令尋找檔案位置，最後在startwm.sh修改並加入環境變數中文輸入法即可
```
## 找設定檔放在哪
sudo find / -name "*startwm*" 2>/dev/null
## 編輯xrp初始腳本，在裡面加入執行輸入法權限
nano /usr/libexec/xrdp/startwm.sh
## 放入以下內容

#注入中文輸入法 
export LANG=zh_TW.UTF-8 
export LC_ALL=zh_TW.UTF-8 
export GTK_IM_MODULE=ibus 
export QT_IM_MODULE=ibus 
export XMODIFIERS=@im=ibus
# 檢查如果目前使用者還沒啟動 ibus，就幫他啟動一個獨立的背景進程 
pgrep -u $USER ibus-daemon > /dev/null || /usr/bin/ibus-daemon -rxd

```
> 2>/dev/null 在linux有三種數據流，`0` (STDIN / 標準輸入)：接收你的鍵盤輸入、`1` (STDOUT / 標準輸出)、`2` (STDERR / 標準錯誤)，意思是把權限不足的輸入都濾掉

個人使用者腳本
啟用桌面預設使用mate
```
echo "mate-session" > ~/.Xclients 
chmod +x ~/.Xclients
sudo systemctl restart xrdp
```

### 無法擷取鍵盤
在Rocky Linux用Win+Space或Ctrl+Space無法切換輸入法，代表快速鍵沒有被攔截進去rdp，需要遠端桌面更改設定。
開啟mstsc，本機資源/鍵盤/套用Windows按鍵組合，選擇`在遠端電腦上` 

## Gnome鎖定畫面卡住輸入密碼
```
sudo nano /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla
[Allow Colord all Users] 
Identity=unix-user:* 
Action=org.freedesktop.color-manager.*;org.freedesktop.packagekit.*;org.freedesktop.policykit.*;org.gnome.gcontrol.* 
ResultAny=yes 
ResultInactive=yes 
ResultActive=yes
```




## 結語
原本Rocky Linux 9之後預設都只裝Wayland環境，但為什麼裝了xrdp可以用是因為他把x.org桌面安裝後隱藏了，所以登入就不會出現X.org桌面環境可選，至於GNOME最新版有整合wayland 的rdp版本，但因為他的技術原理是用螢幕鏡像原理，不能支援多使用者登入，要穩定性還是選用Xrdp吧。

比較表：

| **比較項目**             | **xrdp**               | **GNOME 內建 RDP**   | FreeRDP |
| -------------------- | ---------------------- | ------------------ | ------- |
| **流暢度 / 體驗**         | 普通（堪用、微頓）              | **極好**（非常順滑）       | 待測試     |
| **輸入法相容性**           | 需要額外改設定檔（如 startwm.sh） | **免設定**，直接完美支援中文   | 待測試     |
| **多人同時登入**           | **支援**（每個人獨立分身，互不干涉）   | 不支援（會變成搶同一個畫面的主導權） | 待測試     |
| **無螢幕開機 (Headless)** | **極穩定**，後台自己開虛擬畫面      | 較麻煩，有時會卡在登入鎖定畫面進不去 | 待測試     |

## 參考資料
- [Rocky linux Documentation,Desktop Sharing via RDP]( https://docs.rockylinux.org/10/desktop/gnome/rdp-server/)
- [WSL 2安装ubuntu-24.04踩坑日记（xrdp远程桌面、中文输入法、WSLg）](https://www.cnblogs.com/coolfan/articles/19085490 "发布于 2025-09-11 12:29") 
