---
title: DNS 遞迴解析
toc: true
date: 2026-07-05
---
Unbound：遞迴解析器（Recursor），不透過8.8.8.8查，通常會搭配Pi-hole
CoreDNS
dnsmasq：兼具DHCP功能
MosDNS
BindDNS
OxiDNS
Technitium
AdGuard Home
Stork：WebUI 介面Monitoring KeaDHCP+Bind9 套件 (也可以監控PowerDNS)
KeaDHCP
## PowerDNS 簡介
PowerDNS主要架構元件為以下三個
- Authoritative Server (權威伺服器)
- Recursor (遞迴解析伺服器)
- dnsdist (DNS 負載均衡與路由器)
![](Diagram%203.svg)

### LXC 安裝
```
# 1. 一口氣安裝 PowerDNS(SQLite3)、Apache 與 PHP 套件
apt update
apt install pdns-server pdns-backend-sqlite3 sqlite3 apache2 php php-sqlite3 php-mbstring php-intl php8.4-gettext php8.4-xml php8.4-intl -y

# 2. 建立存放目錄並注入官方 SQLite Schema 結構
mkdir -p /var/lib/powerdns
sqlite3 /var/lib/powerdns/pdns.sqlite3 < /usr/share/doc/pdns-backend-sqlite3/schema.sqlite3.sql

# 3. 關鍵：把這個檔案與目錄的權限，同時交給 pdns 與網頁 (www-data) 共同存取
chown -R pdns:www-data /var/lib/powerdns
chmod 775 /var/lib/powerdns
chmod 664 /var/lib/powerdns/pdns.sqlite3

# 4.編輯設定檔
nano /etc/powerdns/pdns.conf

launch=gsqlite3 
gsqlite3-database=/var/lib/powerdns/pdns.sqlite3 
local-address=0.0.0.0

systemctl restart pdns 
systemctl enable pdns

# 5.下載poweradmin
# 下載 Poweradmin 4.2.1 穩定版（目前 4.2 系列的最新發行版） 
cd /tmp
wget https://github.com/poweradmin/poweradmin/archive/refs/tags/v4.2.1.tar.gz 
# 解壓並移動到 Apache 網頁目錄 
tar -zxvf v4.2.1.tar.gz 
mv poweradmin-4.2.1 /var/www/html/poweradmin 
# 修正目錄權限，讓 Apache (www-data) 能夠正常存取
chown -R www-data:www-data /var/www/html/poweradmin

# 6. 瀏覽器輸入http://<你的LXC_IP>/poweradmin/install/

# 1. 啟用 Apache 的 rewrite 模組 
a2enmod rewrite 
# 2. 修改 Apache 設定檔，允許網頁目錄使用 .htaccess 進行路由覆寫 
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# 7.

sudo chown -R pdns:www-data /var/lib/powerdns 
# 2. 強制給予資料夾 775 權限（允許 www-data 群組在裡面建立暫存檔） 
sudo chmod 775 /var/lib/powerdns 
# 3. 強制給予資料庫檔案本身 664 權限（允許 www-data 讀寫） 
sudo chmod 664 /var/lib/powerdns/pdns.sqlite3

# 8. web DNS設置
主機管理員:admin.bd1.dev
主域名服務器:ns1.bd1.dev
輔助域名服務器 :ns2.bd1.dev

# 9 確認PowerDNS 設定檔路徑有被創立
touch /var/www/html/poweradmin/config/setting.php 並貼上網頁的內容
chown www-data:www-data /var/www/html/poweradmin/config/settings.php 
chmod 664 /var/www/html/poweradmin/config/settings.php

#刪除poweradmin install 資料夾才能正常運行
rm -rf /var/www/html/poweradmin/install/

```

設定檔備份
```
cp /opt/poweradmin_settings.php.bak /opt/poweradmin/config/settings.php 
cp /opt/poweradmin_powerdns.db.bak /opt/poweradmin/powerdns.db
```


## PowerDNS 與 AD DNS共存

在 Linux 伺服器上配置兩套 PowerDNS 元件，在PVE Script 下的PowerDNS預設沒有安裝PowerDNS Recursor，先補裝此套件，此原理是透過 PowerDNS Recursor 遞迴解析，把不同網域交給不同的DNS查詢，首先給AD查詢，然後再給PowerDNS Authoritative，最後再派給外網DNS

### 配置 PowerDNS Authoritative (授權伺服器)

負責管理 AD 以外的其他內網自訂紀錄（例如：Nginx、Harbor、GitLab 等伺服器的 `*.internal` 紀錄）。
- **修改設定檔：** `/etc/powerdns/pdns.conf`
- **關鍵修改：** 因為預設用 PowerDNS Authoritative 的 Port 53，這邊交給給 Recursor，改成`5300` 埠。
```Ini, TOML
    local-port=5300
    local-address=127.0.0.1
```
- **重啟服務：** `sudo systemctl restart pdns`

### 配置 PowerDNS Recursor 5.x (遞迴伺服器)

站在內網第一線，負責接收所有設備的 DNS 請求（Port 53），並落實條件式轉發（Forward Zones）。
1. **修改YAML （適用 5.x 新版)設定檔：** `/etc/powerdns/recursor.conf`
```YAML
    dnssec:
      trustanchorfile: /usr/share/dns/root.key
    
    recursor:
      hint_file: /usr/share/dns/root.hints
      include_dir: /etc/powerdns/recursor.d
      security_poll_suffix: ''
    
      # 💡 5.x 新版條件式轉發 (將 AD 紀錄與內網紀錄精準分流)
      forward_zones:
        # 只要查 AD 網域，就丟給 Windows DC (假設 DC IP 是 192.168.1.10)
        - zone: ad.internal
          forwarders: [ 192.168.1.10 ]
        - zone: _msdcs.ad.internal
          forwarders: [ 192.168.1.10 ]
    
        # 其他內部自訂域名，丟給剛剛改聽 5300 埠的 PowerDNS Authoritative
        - zone: internal
          forwarders: [ 127.0.0.1:5300 ]
    
    # 💡 5.x 正確的監聽入口設定：監聽全內網的標準 Port 53
    incoming:
      listen:
        - 0.0.0.0:53
```
2.  **驗證 YAML 語法並重啟：**
```Bash
# 檢查設定檔是否正確（必須無 Fatal 錯誤）
sudo pdns_recursor --check-config
# 重啟服務
sudo systemctl restart pdns-recursor
```


## PowerDNS + Adguard 

第一次進入ADguard是IP:3000,設定完後為IP:80進入

![](Pasted%20image%2020260705144248.png)
### 🌐 混用後的流量封包走向

內網所有設備（PC、手機、伺服器、舊設備）的 DNS，統一指向 **AdGuard Home**（Port 53）。
當設備發出 DNS 查詢時，封包會經歷以下完美的旅程：

1. **第一關：AdGuard Home（前線盾牌 🛡️）**
    - 收到查詢後，先比對廣告、追蹤器與惡意網站黑名單。
    - **如果是廣告**（例如 `ads.doubleclick.net`）：直接在第一關**攔截並丟棄**。
    - **如果是正常查詢**（不管是外網 `google.com` 還是內網 `ad.internal`）：AdGuard 自己不做解析，**全部轉發給後方的 PowerDNS Recursor**。
        
2. **第二關：PowerDNS Recursor（核心分流 🚦）**
    - 收到 AdGuard 送過來的乾淨請求。
    - 執行你先前設定好的 YAML 條件式轉發（Forward Zones）邏輯：
        - 查 AD 網域（`ad.internal`） ➡️ 轉發給 **Windows AD DNS**（確保 LDAPS 正常）。
        - 查內部域名（`internal`） ➡️ 轉發給 **PowerDNS Authoritative (Port 5300)**。
        - 查外網（`google.com`） ➡️ 直接向公網遞迴解析。

### 🛠️ 簡單兩步驟：無痛混用設定

因為 AdGuard Home 預設必須搶佔標準的 **Port 53**，我們只需要把 PowerDNS Recursor 往後挪一個 Port 讓位即可。

#### 步驟 1：修改 PowerDNS Recursor 的 Port

打開你那份漂亮的 `/etc/powerdns/recursor.conf` YAML 設定檔，將監聽連接埠從 `53` 改為 **`5353`**
```YAML
# 找到最下方的 incoming 區塊
incoming:
  listen:
    - 0.0.0.0:5353  # 改聽 5353，把 Port 53 讓給 AdGuard
```

```Bash
sudo systemctl restart pdns-recursor
```

#### 步驟 2：設定 AdGuard Home 的上游 DNS

1. 登入 AdGuard Home 的網頁後台。
2. 點選 **設定 (Settings)** ➡️ **DNS 設定 (DNS settings)**。
3. 在 **上游 DNS 伺服器 (Upstream DNS servers)** 欄位中，清空原本預設的外網 DNS，**唯獨填入你 PowerDNS Recursor 的 IP 與新 Port**：
    - 語法：`192.168.1.X:5353` （請換成你跑 PowerDNS 那台 Linux 的內網 IP）。
4. 點選最下方的**儲存**，大功告成！


## Windows DNS Zonetransfer PowerDNS
1. 讓PowerDNS 支援Secondary功能
```
nano /etc/powerdns/pdns.conf
secondary=yes
systemctl restart pdns
```

2. Windows DNS 開啟 ZoneTransfer
![](Pasted%20image%2020260708112538.png)

3. PowerDNS 加入從屬區域
![](Pasted%20image%2020260708112816.png)
4.開啟同步
```
#測試是否有收到IP
dig axfr bd1.dev @IP
#同步PowerDNS
pdns_control retrieve bd1.dev
```


## PowerDNS 外網解析
1. 把原本 Authoritative Server 的Port 53改成別的
```
nano /etc/powerdns/pdns.conf
local-port=5353
local-address=0.0.0.0
systemctl restart pdns
```

2. 安裝 PowerDNS Recursor
```
apt update && apt install pdns-recursor -y
```

3. 修改Recursor設定檔,現在新版是用yaml排版要注意寫法
```
nano /etc/powerdns/recursor.conf
```
新增以下內容
```
dnssec:
  trustanchorfile: /usr/share/dns/root.key

recursor:
  hint_file: /usr/share/dns/root.hints
  include_dir: /etc/powerdns/recursor.d
  security_poll_suffix: ''

  forward_zones_recurse:
    - zone: .
      forwarders:
        - 192.168.50.1

  forward_zones:
    - zone: bd1.dev
      forwarders:
        - 127.0.0.1:5353

incoming:
  listen:
    - 0.0.0.0
    - '::'
  allow_from:
    - 172.16.0.0/16
    - 127.0.0.0/8

```
重啟服務
```
systemctl restart pdns-recursor
```

4. 用dig查詢是否正常
```
# dig <網域> @<DNS位置> -p <Port>
dig bd1.dev @127.0.0.1 -p 5353
```

![](Pasted%20image%2020260709092627.png)

5. (進階設定)使用lua腳本，不用在自己新增遞迴Zone

建立一個`nano /etc/powerdns/recursor-fallback.lua`
```
function preresolve(dq)
    -- 1. 先把使用者的問題，悄悄丟給後台 5353 的 SQLite 權威版
    local res = resolveUDP("127.0.0.1", 5353, dq.qname, dq.qtype)

    -- 2. 如果後台有答案，而且不是錯誤（代表是內網網域）
    if res and res.rcode == pdns.RCODE_NOERROR and #res.records > 0 then
        dq:addRecords(res.records)
        dq.rcode = pdns.RCODE_NOERROR
        return true -- 內網攔截成功，直接回傳給用戶
    end

    -- 3. 如果後台找不到，就回傳 false，PowerDNS 會自動往下走 recursor.conf 裡設定的 Windows DNS 查外網
    return false
end
```

把 `/etc/powerdns/recursor.conf`
```
dnssec:
  validation: off

recursor:
  hint_file: /usr/share/dns/root.hints
  include_dir: /etc/powerdns/recursor.d
  security_poll_suffix: ''

  lua_config_file: /etc/powerdns/recursor-fallback.lua

  # 預設外網流量全部交給有權限出海的 Windows DNS
  forward_zones_recurse:
    - zone: .
      forwarders:
        - 172.16.4.35

incoming:
  listen:
    - 0.0.0.0
    - '::'
  allow_from:
    - 172.16.0.0/16
    - 127.0.0.0/8
```


## dnsmasq
透過LXC 安裝
```
apt update && apt upgrade -y
apt install dnsmasq -y
# 確認port 53正常
ss -tunlp
```
編寫 **dnsmasq.conf**
```
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.bak 
nano /etc/dnsmasq.conf
```
設定內容
```
# --- 基礎設定 ---
# 監聽的介面，也可以寫 interface=eth0
listen-address=127.0.0.1, 192.168.1.53  # 192.168.1.53 是這台 LXC 的固定 IP
port=53
domain-needed       # 限制唯有完整網域才能往外查（不轉發純主機名）
bogus-priv          # 防止私有 IP 逆向解析請求流到外網

# --- 上游 DNS 伺服器 (當 dnsmasq 找不到答案時向外問) ---
server=1.1.1.1
server=8.8.8.8

# --- 內網本地 DNS 解析 ---
local=/lab.home/     # 定義你的本地專屬網域
expand-hosts
domain=lab.home

# --- DHCP 伺服器設定 (選用，如果家裡有路由器發 IP 則不要開) ---
# 發放的 IP 範圍，以及租期 12 小時
dhcp-range=192.168.1.100,192.168.1.200,255.255.255.0,12h
# 預設閘道 (通常是你家路由器的 IP)
dhcp-option=3,192.168.1.1
# 分配給用戶端的 DNS 伺服器 (指向這台 LXC 自己)
dhcp-option=6,192.168.1.53

# --- 靜態 IP 綁定 (Static DHCP) ---
# 適合把你家 PVE 主機、NAS、其他重要 VM 的 MAC 鎖定固定 IP
dhcp-host=AA:BB:CC:DD:EE:FF,pve-host,192.168.1.10,infinite
dhcp-host=11:22:33:44:55:66,my-nas,192.168.1.20,infinite
```

設定 PXE Proxy
```
interface = eth0
bind-interfaces
dhcp-range=192.168.0.0, proxy
pxe-service=7, "ipxe net boot", Boot\x64\wdsmgfw.efi, 192.168.181.188
```

啟用
```
systemctl enable dnsmasq 
systemctl start dnsmasq
systemctl status dnsmasq
```