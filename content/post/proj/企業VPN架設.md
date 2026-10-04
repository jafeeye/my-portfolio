

**前言**

隨著概位公司業務成長與組織擴編，企業除原有總公司（TPE）外，陸續設立分公司（TNN）與遠端辦公據點，各據點所處的網路環境與設備條件不同，但皆需存取企業內部系統與共享資料。為確保跨據點連線的安全性、穩定性與管理一致性，公司極需一套可延伸內部網路的安全連線機制。

**解決方案**

經評估專線建置成本與資安風險等相關問題後，概位公司最終選擇以 VPN 作為企業網路延伸的解決方案，透過 VPN 技術，可在既有的公共網際網路上建立加密通道，使總公司與分公司之間如同位於同一內部網路中，達成安全、低成本且具擴充性的跨據點連線架構。

**技術說明**

本架構採用 IPsec 建立總公司與分公司間的 Site-to-Site VPN ，提供穩定且長時間的網段互通，同時部署 OpenVPN 作為 Client-to-Site VPN ，供遠端或行動人員安全連線內部系統。所有資料皆透過加密通道傳輸，有效防止竊聽與未授權存取，確保企業資訊安全。

**VPN優缺點比較**

| VPN | WireGuard      | L2TP/IPsec           | **OpenVPN**     | **IPsec/IKEv2** |
| --- | -------------- | -------------------- | --------------- | --------------- |
| 優點  | 連線速度快 設定簡單 低延遲 | 安全性高 泛用性高            | 安全性高 泛用性高  穿透性強 | 安全性高 延遲低 效能高    |
| 缺點  | 較新，少數舊 設備支援不足  | 易被防火牆封鎖、效能較純 IPsec 低 | 設定較複雜 非微軟限制多    | 設定較複雜 穿透性弱      |

**IPsec**
公司總部與分公司皆為固定網路環境，需長期且穩定地進行網段互通，因此選擇 IPsec 作為 Site-to-Site VPN 解決方案。IPsec 具備高安全性與低延遲特性，並可部署於既有防火牆設備上，適合企業據點之間的全天候連線需求，確保內部系統資料傳輸的安全與穩定。

**OpenVPN**
針對遠端辦公與行動員工，概位公司採用 OpenVPN 作為 Client-to-Site VPN 解決方案。OpenVPN 支援多種作業系統，並具備良好的防火牆穿透能力，適合員工於不同網路環境下使用。其憑證與帳號驗證機制可有效提升身分識別安全性，滿足彈性與資安需求。

**架構說明**
**概位總公司：台北**
**概位分公司：台南**
**網段規劃**

| User          | WAN            | LAN            |
| ------------- | -------------- | -------------- |
| 總公司VPN server | 192.168.80.155 | 192.168.30.2   |
| 總公司 client    |                | 192.168.30.3   |
| 分公司VPN server | 192.168.80.156 | 192.168.40.2   |
| 分公司 client    |                | 192.168.40.3   |
| remote client |                | 192.168.80.157 |
| DC（CA中心）      |                | 192.168.30.10  |

**![](data:image/png;base64...)**

**實作建置**

**使用 IPSec /IKEv2 建立 site to site VPN**

**一、初始化 PKI**

在 DC 中建立 CA 中心，安裝 AD 憑證服務

勾選憑證授權單位、憑證授權單位網頁註冊>企業級 CA >根 CA

![](data:image/png;base64...)

![](data:image/png;base64...)

![](data:image/png;base64...)

選擇 RSA#Microsoft Software Key Storage Provider ，金鑰長度為 2048

雜湊演算法選 SHA256 ，並設定名稱與有效時間，到此 PKI 信任根已初始化完成

![](data:image/png;base64...)![](data:image/png;base64...)

![](data:image/png;base64...)

**二、設定自動註冊憑證範本**

點開憑證授權單位，右鍵點選憑證範本>管理>右鍵點選電腦>複製範本>

右鍵點選電腦的範本>內容>點選標籤安全性>選擇 Domain Computers >

將讀取、註冊、自動註冊 3 個選項全數打勾>

點選標籤處理要求>勾選允許匯出私密金鑰>

![](data:image/png;base64...)點選標籤延伸>編輯>勾選用戶端驗證、伺服器驗證，並命名為 VPN-User-Auto

![](data:image/png;base64...)

![](data:image/png;base64...)![](data:image/png;base64...)

回到憑證授權單位，右鍵點選憑證範本>新增>要發出的憑證範本>

選取 VPN-User-Auto

![](data:image/png;base64...)

![](data:image/png;base64...)

**三、設定群組原則**

打開群組原則管理，右鍵點選網域>建立 GPO 並連結
編輯 GPO ，依照路徑至電腦設定>原則> Windows 設定>安全性設定>
公開金鑰原則>憑證服務用戶端-自動註冊，啟動功能，並勾選下方 2 個選項
再右鍵點選自動憑證要求設定值，選擇電腦（選擇 IPSec 多為手動需求）

![](data:image/png;base64...)![](data:image/png;base64...)

**四、檢驗憑證**

於總公司 VPN server 打開 cmd ，輸入 gpupdate /force

確認成功後，輸入 gpresult /r 檢視狀態

![](data:image/png;base64...)

![](data:image/png;base64...)

打開主控台>在新增/移除嵌入式管理單元選擇憑證>電腦帳戶

在個人憑證的部分確認新增的憑證是否存在

![](data:image/png;base64...)

**五、設定 IPSec 通道（TPE 與 TNN 都要）**

打開防火牆設定>點選進階設定>連線安全性規則>在右方點選新增規則>選擇通道>

勾選自訂設定、否。請通過通道傳送所有符合此連線安全性規則的網路流量>

需要對輸入及輸出連線執行驗證>按照圖中設定填入 IP 位址

>再點選瀏覽自動填入 CA 名稱>選擇公用>設定此規則名稱為 IPsec-TPE-to-TNN

![](data:image/png;base64...)![](data:image/png;base64...)

![](data:image/png;base64...)

![](data:image/png;base64...)

註：TNN 將兩電腦、通道端點位置互換

**六、驗證結果**

總公司（TPE）可 Ping 通分公司（TNN）

![](data:image/png;base64...)

![](data:image/png;base64...)

**使用OpenVPN建立 Client-to-Site VPN**

**一、獲取憑證**

依照先前方式產生憑證，再於總公司 VPN server 開啟憑證工具

主控台>在新增/移除嵌入式管理單元選擇憑證>使用者帳戶>

右鍵點選個人>所有工作>要求新憑證

![](data:image/png;base64...)![](data:image/png;base64...)![](data:image/png;base64...)

![](data:image/png;base64...)

**二、拆分憑證（總公司 VPN server 與 remote client 都要）**

安裝 OpenVPN 2.6.16
勾選 OpenVPN Service 與 EasyRSA 3 Certificate Management Scripts

![](data:image/png;base64...)

過程中會安裝 OpenSSL ，可於 cmd 拆分所需憑證
先於 C:\Program Files\OpenVPN\ 先建立 cert 資料夾
再將匯出之憑證放入該資料夾

![](data:image/png;base64...)

打開 cmd ，切到 C:\Program Files\OpenVPN\bin ，再分別輸入：

openssl pkcs12 -in " C:\Program Files\OpenVPN\certs\OpenVPN-Server.pfx" -nocerts -nodes -out "C:\Program Files\OpenVPN\certs\server.key （取出 Server 私鑰）

openssl pkcs12 -in " C:\Program Files\OpenVPN\certs\OpenVPN-Server.pfx" -clcerts -nokeys -out "C:\Program Files\OpenVPN\certs\server.crt （取出 Server 憑證）

每次均需要輸入先前設定的密碼

![](data:image/png;base64...)

拆分結果

![](data:image/png;base64...)

**三、獲取根憑證**

於 CA 中心開啟憑證授權單位>右鍵點選 CA >內容>選取標籤一般>

點擊檢視憑證>選取標籤詳細資料>點擊複製到檔案>

匯出格式為 Base-64 編碼 X.509（.CER），並將檔名更改為 ca

![](data:image/png;base64...)![](data:image/png;base64...)

![](data:image/png;base64...)

![](data:image/png;base64...)![](data:image/png;base64...)

確認總共需要有 3 個憑證

![](data:image/png;base64...)

**四、編輯 OpenVPN 設定檔**

先至總公司 VPN server ，建立名為 server.ovpn 的檔案，放入：

```
port 1194
proto udp
dev tun
ca ca.cer
cert server.crt
key server.key
server 10.8.0.0 255.255.255.0
push "route 192.168.30.0 255.255.255.0"
push "route 192.168.40.0 255.255.255.0"
keepalive 10 120
persist-key
persist-tun
verb 3
```

後至 remote client ，建立名為 client.ovpn 的檔案，放入：

```
client
dev tun
proto udp
remote 192.168.80.10 1194
ca ca.crt
cert client.crt
key client.key
persist-key
persist-tun
verb 3
```

**五、防火牆設定**

允許 OpenVPN 連線：

於總公司 VPN server ，打開防火牆設定>點選進階設定>輸入規則>在右方點選新增規則>選擇連接埠> UDP1194 >允許連線>將網域、私人打勾

![](data:image/png;base64...)![](data:image/png;base64...)

![](data:image/png;base64...)

![](data:image/png;base64...)

允許 VPN 虛擬網段進入內部：

一樣於總公司 VPN server ，打開防火牆設定>點選進階設定>輸入規則>在右方點選新增規則>選擇自訂>所有程式>通訊協定類型選擇任一>
遠端 IP 位址新增 10.8.0.0/24 （本機選擇任何）>允許連線>將網域、私人打勾

![](data:image/png;base64...)![](data:image/png;base64...)

![](data:image/png;base64...)

![](data:image/png;base64...)

![](data:image/png;base64...)![](data:image/png;base64...)

啟用上述 2 條規則

![](data:image/png;base64...)

**五、驗證結果**

當未啟用 OpenVPN ，無法 Ping 回公司網路

![](data:image/png;base64...)

當啟用 OpenVPN ，可以 Ping 回公司網路

![](data:image/png;base64...)