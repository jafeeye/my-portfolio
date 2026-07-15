---
title: Nginx Proxy Manager
toc: true
date: 2026-07-15
---
```
apt update apt install -y lsb-release ca-certificates gnupg2 curl
```

要讓NPM正常解析
hosts -> NPM -> 再轉網域名



將 **PowerDNS**、**DoH (DNS over HTTPS)**、與 **Nginx Proxy Manager (NPM)** 整合起來，其實是一個非常漂亮且標準的「高安全度內網 DNS 架構」。

只要架構理清楚，一步步來做，就不會覺得複雜。我們把整體流量拆解開來：

> **DoH 運作路徑：**
> 
> 你的設備 (發出 DoH 請求)
> 
> $\rightarrow$ **NPM (監聽 443，負責掛載 deSEC 的 SSL 憑證並解密)** > $\rightarrow$ **DNS 代理/轉發器 (如 dnsdist)** > $\rightarrow$ **PowerDNS (處理實際 DNS 解析)**

以下是為你規劃的**四步整合指南**：

## 步驟一：理解 PowerDNS 與 DoH 的關鍵橋樑：`dnsdist`

因為 PowerDNS 授權伺服器（PowerDNS Authoritative）本體**不支援**直接處理 DoH (HTTPS) 協定。PowerDNS 官方最推薦、也是業界標準的做法，是在 PowerDNS 前面擋一台 **`dnsdist`**（這是 PowerDNS 家族的超強大 DNS 負載均衡與代理器）。
- **NPM**：負責把外面的 `https://dns.yourdomain.dedyn.io/dns-query` 接收進來，處理好 SSL 憑證（安全鎖頭），然後把乾淨的 DNS 流量用 HTTP 丟給 `dnsdist`。
- **dnsdist**：接收來自 NPM 的 DoH 請求，並將它轉化為標準的 DNS 查詢（Port 53），丟給後端的 **PowerDNS**。
    

## 步驟二：設定 `dnsdist` 接收 DoH 流量

你可以把 `dnsdist` 架設在 Docker 或是獨立的 Linux（例如與 PowerDNS 同一台實體機/LXC 內）。

編輯 `dnsdist` 的設定檔（通常在 `/etc/dnsdist/dnsdist.conf`）：

```
-- 1. 監聽本地的 8080 Port 接收來自 NPM 的「未加密 DoH 流量」
-- 這裡我們把 SSL 卸載（SSL Offloading）交給 NPM 處理，所以 dnsdist 端不用設定憑證
addDOHLocal("0.0.0.0:8080", "", "", "/dns-query", { reusePort=true })

-- 2. 設定後端實際進行解析的 PowerDNS 伺服器 IP (假設是 192.168.1.254:53)
newServer({address="192.168.1.254:53", name="pdns-backend"})
```

_設定完成後，重啟 dnsdist 服務。此時，只要有 HTTP 流量打到 `http://dnsdist-IP:8080/dns-query`，它就會幫你送去 PowerDNS 解析。_

## 步驟三：在 NPM 設定反向代理與 SSL 憑證

現在，我們要讓 NPM 來當對外的門神，掛上你透過 deSEC 申請的合法憑證。
1. **登入 NPM 面板**，新增一個 **Proxy Host**：
    - **Domain Names**：填寫你的 DoH 專用網域，例如 `dns.yourdomain.dedyn.io`。
    - **Scheme**：選擇 **`http`**（因為 NPM 連到 `dnsdist` 不需要再加密）。
    - **Forward Hostname/IP**：填寫 **`dnsdist` 的內網 IP**。
    - **Forward Port**：填寫 **`8080`**（對應剛才 dnsdist 設定的 DoH Port）。
        
2. **切換到 SSL 頁籤**：
    
    - **SSL Certificate**：選取你用 Certbot + deSEC 拿到的合法憑證。
    - 勾選 **Force SSL** 與 **HTTP/2 Support**（DoH 強烈依賴 HTTP/2，這點非常重要）。
        
3. **切換到 Advanced（進階）頁籤**：
    為了確保 DoH 的標頭（Headers）與大封包能順利傳遞，請貼上以下 Nginx 優化設定：
    
    ```
    # 針對 DoH/Websocket 傳輸優化
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    
    # 調整 Buffer，避免大體積的 DNS 紀錄被 Nginx 截斷
    proxy_buffers 8 16k;
    proxy_buffer_size 32k;
    ```
    
    _點選 **Save** 儲存。_
    

## 步驟四：在 PowerDNS 內設定「自己解析自己」

為了讓這個架構完美閉環，你在內網的 PowerDNS 裡，必須新增一筆紀錄，讓 `dns.yourdomain.dedyn.io` 解析指向 **NPM 的內網 IP**。
在 PowerDNS 內新增紀錄：
- **Zone**: `yourdomain.dedyn.io`
- **Record**: `dns` (A 紀錄) $\rightarrow$ 指向 **NPM 的內網 IP**（例如 `192.168.1.110`）。



這是一個非常好的盲點，也是許多人在初學 DNS、反向代理與 HTTPS 時最容易感到困惑的地方！

答案是：**沒錯，如果只做 PowerDNS 轉址，其他的網頁（如 NetBox）確實是「無法」直接用 HTTPS 成功連線的。**

為了讓你完全理解為什麼，我們必須把 **「DNS（PowerDNS）」**、**「反向代理（NPM）」**、與 **「網頁服務（NetBox / 其他 LinuX 服務）」** 三者的工作分工看得一清二楚。

### 1. 為什麼「只用 PowerDNS 轉址」會失敗？

DNS（包含你的 PowerDNS）的工作非常單純，它只負責**翻譯地址**。

- 當你輸入 `netbox.yourdomain.dedyn.io` 時，PowerDNS 告訴瀏覽器：「這個人在內網的 IP 是 `192.168.1.120`（NetBox LXC 的實體 IP）」。
    
- 於是，你的瀏覽器會跳過 NPM，**直接**把流量送去 NetBox LXC 的 Port 443。
    

**這時就會發生你一開始遇到的慘劇：**

1. 因為流量直接進了 NetBox LXC，沒有經過 NPM，所以 NPM 上設定的合法 deSEC 憑證**完全派不上用場**。
    
2. NetBox LXC 只能拿出自己身上那張自簽的 `localhost` 憑證。
    
3. 你的瀏覽器一看，網址是 `netbox.yourdomain.dedyn.io`，但憑證上寫著 `localhost`，兩者不符合，立刻跳出「憑證不安全」或「連線失敗」。
    

### 2. 完美的解決方案：讓所有的網址「全部集中經過 NPM」

要讓 NetBox 和其他所有內網網頁都能成功套用 deSEC 憑證，我們必須做一件事：**不論你輸入什麼網址，在 PowerDNS 裡通通都指向 NPM 的 IP！**

這就是所謂的 **「反向代理集中管理（Reverse Proxy Centrally Managed）」**：

#### 運作流程：

1. **設定 PowerDNS（通通指向 NPM）**： 在 PowerDNS 內，把你所有的服務網址（不論是 NetBox、DoH、還是其他服務），A 紀錄**全部填寫 NPM 的內網 IP**（例如 `192.168.1.110`）。
    
    - `netbox.yourdomain.dedyn.io` → 指向 `192.168.1.110` (NPM)
        
    - `dns.yourdomain.dedyn.io` → 指向 `192.168.1.110` (NPM)
        
    - `other.yourdomain.dedyn.io` → 指向 `192.168.1.110` (NPM)
        
2. **在 NPM 裡做「分流與憑證掛載」**： 因為所有的網址都送到了 NPM，NPM 就會像一個高明的交通警察。它會看瀏覽器要求的網域名稱（Domain Name）是什麼，來決定要掛哪張憑證、轉發到哪裡：
    
    - **如果收到 `netbox.yourdomain.dedyn.io`**： NPM 掛上合法 deSEC 憑證 → 將流量轉發給後端 **NetBox LXC (`192.168.1.120:443`)**（搭配我們之前寫的忽略自簽憑證進階設定）。
        
    - **如果收到 `dns.yourdomain.dedyn.io`**： NPM 掛上合法 deSEC 憑證 → 將流量轉發給後端 **dnsdist (`192.168.1.115:8080`)**。
        
    - **如果收到 `other.yourdomain.dedyn.io`**： NPM 掛上合法 deSEC 憑證 → 將流量轉發給後端 **其他服務 (`192.168.1.130:80`)**。
        

### 這樣做為什麼一定會成功？

透過這種「PowerDNS 導向 NPM → NPM 再分流轉發」的架構，你可以得到以下巨大好處：

1. **憑證完美解決**：你只需要在 NPM 這一台機器上管理 deSEC 憑證。後端那堆 NetBox、Proxmox、或是其他亂七八糟的 LXC 容器，不管它們是用 HTTP 還是帶有自簽憑證的 HTTPS，**通通都不用再去改它們的憑證了**。NPM 會在最前線幫你包裝成漂亮的、瀏覽器信任的合法 HTTPS。
    
2. **不用記 Port 號**：你以後連內網任何服務，都不用在網址後面打 `:8000`、`:8443` 或 `:8080`。因為只要輸入對應的網域，NPM 就會自動幫你轉發到正確的 Port。
    
3. **安全加密的 DoH**：你的 DoH 機制也可以無縫融入這個體系，同樣享有合法的安全憑證。
    

所以，你之前的直覺是非常敏銳且正確的！光靠 PowerDNS 轉址絕對無法解決 NetBox 的憑證問題。我們**必須**把所有的網域 A 紀錄在 PowerDNS 裡都指向 NPM，並在 NPM 裡為 NetBox 新增一筆 Proxy Host 設定，這樣整個系統才會真正成功運作！



要同時完美實現 **DoH (DNS over HTTPS)**、**PowerDNS** 以及 **Nginx Proxy Manager (NPM)** 的整合，國外大神和企業最推崇的最佳實踐（Best Practice）是採用 **「前置代理與 SSL 卸載」** 的分層架構。

這個架構既能讓你用 NPM 統一管理 deSEC 的 SSL 憑證，又能保持 PowerDNS 作為內網唯一權威解析的純潔性，同時解決 DoH 所需的高效傳輸。

以下為你整理出最優雅、最不容易出錯的**四步實作指南**：

### 🌐 核心架構設計（流量走向）

Plaintext

```
【設備端】(手機/電腦) ──發送 DoH 請求 (https://dns.yourdomain.dedyn.io/dns-query)──>
      │
      ▼
【Nginx Proxy Manager】(192.168.1.110) <--- 負責外網/內網 SSL 解密 (deSEC 憑證)
      │
      ▼ (轉為純 HTTP 流量送往同主機或內網的 dnsdist)
【dnsdist (DoH 轉接器)】(192.168.1.115:8080) <--- 負責處理 DoH 協定，轉為標準 DNS
      │
      ▼ (發送標準 Port 53 查詢)
【PowerDNS Authoritative】(192.168.1.254) <--- 負責內網域名解析與 A 紀錄
```

## 第一步：PowerDNS 設定「雙向解析（Split-Horizon）」

在你的 PowerDNS（假設 IP 是 `192.168.1.254`）中，我們建立一個 Zone，並利用 **CNAME** 進行優雅的分流：

1. **建立主網域的 A 紀錄**，指向你的 **NPM IP**（假設 NPM 是 `192.168.1.110`）：
    
    - `npm.yourdomain.dedyn.io` $\rightarrow$ **A** $\rightarrow$ `192.168.1.110`
        
2. **為其他服務（包括 DoH 與 NetBox）設定 CNAME**，全部指向 `npm`：
    
    - `dns.yourdomain.dedyn.io` $\rightarrow$ **CNAME** $\rightarrow$ `npm.yourdomain.dedyn.io`
        
    - `netbox.yourdomain.dedyn.io` $\rightarrow$ **CNAME** $\rightarrow$ `npm.yourdomain.dedyn.io`
        

> 💡 **大神的思維**：
> 
> 這樣做最優雅！未來不論增加多少服務，DNS 紀錄一律 CNAME 到 `npm`。如果 NPM 更換內網 IP，你只需要修改 `npm` 的那一筆 A 紀錄，全內網的服務就自動同步過去了。

## 第二步：部署與設定 `dnsdist`（DoH 的靈魂橋樑）

因為 PowerDNS 本身**不支援**直接接收 HTTPS（DoH）請求。在業界，我們一定會在 PowerDNS 前面放一台 **`dnsdist`**（PowerDNS 官方開發的超強大 DNS 負載均衡器）來當「翻譯官」。

你可以在 Docker 或單獨的 LXC 中安裝 `dnsdist`（假設 IP 為 `192.168.1.115`），並編輯其設定檔 `/etc/dnsdist/dnsdist.conf`：

Lua

```
-- 1. 監聽本地的 8080 埠口，接收來自 NPM 解密後的「純 HTTP DoH 流量」
-- (路徑設為標準的 /dns-query)
addDOHLocal("0.0.0.0:8080", "", "", "/dns-query", { reusePort=true })

-- 2. 設定後端實際進行解析的 PowerDNS 伺服器
newServer({address="192.168.1.254:53", name="powerdns-backend"})
```

_設定完後啟動 `dnsdist`。此時，如果有 HTTP 請求打到 `http://192.168.1.115:8080/dns-query`，它就會自動轉成標準 DNS 向 PowerDNS 查詢。_

## 第三步：在 NPM 中配置「DoH 反向代理」

現在，我們要讓 NPM 來當最前端的防線，掛上你申請好的 deSEC 合法憑證：

1. **新增 Proxy Host**：
    
    - **Domain Names**：`dns.yourdomain.dedyn.io`
        
    - **Scheme**：選擇 **`http`**
        
    - **Forward Hostname/IP**：填入 `dnsdist` 的 IP（`192.168.1.115`）
        
    - **Forward Port**：填入 `8080`
        
2. **SSL 頁籤設定**：
    
    - 選擇你的 **deSEC SSL 憑證**。
        
    - 務必勾選 **Force SSL**（強制 HTTPS）。
        
    - 務必勾選 **HTTP/2 Support**（**極重要！** DoH 協定強制要求必須在 HTTP/2 或更高版本上運行）。
        
3. **Advanced（進階設定）頁籤**：
    
    貼上以下優化 Nginx 緩衝與標頭的參數，避免大型 DNS 解析封包被 Nginx 阻擋：
    
    Nginx
    
    ```
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    
    # 針對 DoH 大流量優化快取緩衝區
    proxy_buffers 8 16k;
    proxy_buffer_size 32k;
    ```
    

## 第四步：在 NPM 中配置「NetBox 反向代理」

既然 DNS 已經把 `netbox.yourdomain.dedyn.io` CNAME 到 NPM 了，我們順便把 NetBox 也一起收進來：

1. **新增 Proxy Host**：
    
    - **Domain Names**：`netbox.yourdomain.dedyn.io`
        
    - **Scheme**：選擇 **`https`**（因為你的 NetBox LXC 預設強制自簽 HTTPS）
        
    - **Forward Hostname/IP**：NetBox LXC 的實際 IP（`192.168.1.120`）
        
    - **Forward Port**：`443`
        
2. **SSL 頁籤設定**：
    
    - 選擇你的 **deSEC SSL 憑證**，勾選 **Force SSL**。
        
3. **Advanced（進階設定）頁籤**：
    
    貼上我們之前研究出、能完美忽略後端自簽憑證報錯的設定：
    
    Nginx
    
    ```
    proxy_ssl_verify off;
    proxy_ssl_server_name on;
    proxy_ssl_name $host;
    proxy_ssl_protocols TLSv1.2 TLSv1.3;
    
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    ```
    

### 🎯 最終達成的完美效果

完成這四個步驟後，你就建立起了一套極其標準、安全的「HomeLab 邊緣閘道架構」：

- **連線 NetBox**：
    
    你在網址列打 `https://netbox.yourdomain.dedyn.io` $\rightarrow$ 流量走到 NPM $\rightarrow$ NPM 掛載合法憑證（瀏覽器顯示安全鎖頭） $\rightarrow$ NPM 安全地中繼給 NetBox LXC。**完全不會再出現 502 或是 localhost 憑證錯誤！**
    
- **連線 DoH**：
    
    你在手機或瀏覽器設定 DoH 伺服器為 `https://dns.yourdomain.dedyn.io/dns-query` $\rightarrow$ 手機發起加密 DNS 請求 $\rightarrow$ NPM 解密後丟給 dnsdist $\rightarrow$ PowerDNS 執行解析。**全家設備都能享有安全、無警告、完全不洩漏隱私的自建加密 DNS 服務！**

![[static/Diagram 6.svg]]