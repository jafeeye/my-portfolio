---
title: SSL 憑證
toc: true
date: 2026-07-10
---
以現在目前大家能通過SSL憑證，不外乎以下幾種
- 買網域,有公網憑證去信任本地網址
- 使用免費Let's Crypt 
- 使用免費DuckDNS,後墜為DuckDNS
- 反向代理騙過驗證 把lan 又代理成 duckdns


![](Diagram%204.svg)


## 遠端匯憑證方法
```
# 抓下網站SSL憑證
openssl s_client -showcerts -connect IP位置:443 </dev/null 2>/dev/null | 

openssl x509 -outform PEM > /usr/local/share/ca-certificates/netbox.crt

#更新系統信任清單
update-ca-certificates
```

## 憑證簽發流程
數位憑證簽發（PKI）流程：像是戶政事務所開張，然後你跑去申請身分證
- **阿公 (根憑證 Root CA)** = 內政部總局
    - 角色：全台灣最高戶政主管機關。它自己刻了一個「天字第一號中華民國大印」（Root Key）。因為權力太大，這個大印平常鎖在中央銀行的地下保險箱，絕不輕易拿出來。它不直接幫一般民眾辦理業務。
- **老爸 (中間憑證 Intermediate CA)** = 信義區戶政事務所
    - 角色：內政部總局不可能每天派人幫全台灣民眾蓋章，所以內政部用大印簽了一張授權書，派發給「信義區戶政事務所」。戶政事務所每天開門營業，用這張授權書證明的合法地位，在現場幫民眾辦理業務。
- **孫子 (終端憑證 Leaf / Server CRT)** = **你（example.com）的身分證**
    - 角色：你跑去信義區戶政事務所申請，櫃檯人員審核你的資料後，拿出信義區的印章在你的身分證（`server.crt`）上蓋章。這張身分證證明了你是誰，但你拿到這張身分證後，**沒辦法**拿它去幫你的朋友再簽發一張身分證。

憑證鏈（Certificate Chain）![](Diagram%205.svg) 完整憑證本身要具備 root.crt (根憑證) + intermediate.crt (中繼憑證)+ server.crt (終端憑證)，有時候為了省事，會直接用 openssl 簽兩張 (根+終端)也可過信任

## OpenSSL 兩層簽法

因為我們是在實驗室環境（`.lab`），我們不花錢去跟外面大廠（如 DigiCert）買憑證，所以我們要「**自己開一家戶政事務所（俗稱自簽 CA）**」。
1. 產生 CA 的私鑰（Private Key）
```
openssl genrsa -out ca.key 4096
```
- **白話意思**：戶政事務所刻了一個「全天下只有所長知道的官方大印章（私鑰）」。這個印章絕對不能被偷走，因為未來所有發出去的身分證，都要用這個印章來蓋章。`4096` 代表這個印章的防偽複雜度極高。
2. 產生 CA 的公開憑證（Public Certificate）
```
openssl req -x509 -new -nodes -sha512 -days 3650 \
    -subj "/C=TW/ST=Taiwan/L=Taipei/O=UUU/OU=DKL/CN=docker1.training.lab" \
    -key ca.key \
    -out ca.crt
```
- **白話意思**：戶政事務所對外掛牌開張（`ca.crt`），告訴全天下（`-subj` 裡面的地區、UUU 組織等欄位）：「我是合法的戶政事務所，我的有效期限是 10 年（`3650` 天）。」
- 未來你的瀏覽器或 Docker 用戶端，必須要把這個 `ca.crt` 檔案匯入到電腦裡，點選「信任它」，這家戶政事務所說的話才算數。

**伺服器向 CA 申請身分證（憑證）**
現在戶政事務所蓋好了，你的 Docker 伺服器（`docker1.training.lab`）要來申請一張證明自己合法身份的證書。

3. 產生伺服器的私鑰（Private Key）
```
openssl genrsa -out docker1.training.lab.key 4096
```
- **白話意思**：你（伺服器）自己在家裡，秘密生成了一個「你自己的個人私章」（`docker1.training.lab.key`）。未來在進行 HTTPS 加密連線時，伺服器要用這個私章來解密資料。這個檔案一樣絕對不能外流！
4. 產生伺服器的「憑證簽發申請書（CSR）」
```
openssl req -sha512 -new \
    -subj "/C=TW/ST=Taiwan/L=Taipei/O=UUU/OU=DKL/CN=docker1.training.lab" \
    -key docker1.training.lab.key \
    -out docker1.training.lab.csr
```
- **白話意思**：你拿著自己的個人私章（`-key`），填寫了一份「身分證申請書」（`docker1.training.lab.csr`）。
- 申請書上寫明了你的基本資料（`-subj`），最重要的欄位是 **`CN=docker1.training.lab`**，這代表你跟政府宣稱：「我的網址就叫這個名字，請政府幫我驗證！」

5. 戶政事務所大印一蓋，核發身分證（CRT）
```
openssl x509 -req -sha512 -days 3650 \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in docker1.training.lab.csr \
    -out docker1.training.lab.crt
```
- **白話意思**：你把那份申請書（`-in ...csr`）送到戶政事務所。所長看了一下沒問題，拿出剛才第一步刻好的官方大印章（`-CAkey ca.key`），對照著政府公告（`-CA ca.crt`），用力在你的申請書上蓋下去！
- 產出的產物就是 **`docker1.training.lab.crt`**。這就是你的「實體身分證（數位憑證）」！它的有效期限同樣是 10 年。

6. 最終在 Docker / Harbor 上怎麼使用這些檔案？
 當這 5 個指令跑完後，你會得到一堆檔案，最常拿去配置在 Nginx、Harbor 或 Docker 上的有這三個：
- **`docker1.training.lab.key`（伺服器私鑰）**：放在伺服器後台（例如 Nginx 的 `ssl_certificate_key`），用來解密流量，死都不能給別人。
 - **`docker1.training.lab.crt`（伺服器憑證）**：放在伺服器前台，任何人連進你的網頁時，伺服器會大方地把這張「身分證」亮給瀏覽器看。
-  **`ca.crt`（根憑證）**：你要把這個檔案派發給你的 GitLab Runner、你的 PVE 主機或是你的個人電腦，讓它們信任這家「自建戶政事務所」。


## OpenSSL 三層簽法

1. 阿公開張（建立 Root CA）
首先，建立最高權力的根憑證，這張是自己簽給自己的（Self-Signed）。

```
# 1. 產生阿公的私鑰 (Root Key)
openssl genrsa -out root.key 4096

# 2. 產生阿公的憑證 (Root CRT)
openssl req -x509 -new -nodes -sha512 -days 3650 \
    -subj "/C=TW/ST=Taiwan/L=Taipei/O=Lab/CN=My-Root-CA" \
    -key root.key \
    -out root.crt
```

2. 老爸出世（建立中間 Intermediate CA）
這是關鍵！我們要產生一個中間 CA，並且用**阿公的私鑰**幫它蓋章。
為了讓老爸具有「簽發別人的權力」，我們必須先寫一個超簡單的設定檔，檔名取叫 `x509_ext.cnf`：

```
# 先用 cat 建立一個暫時的設定檔
cat <<EOF > x509_ext.cnf
[ v3_intermediate_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
EOF
```

> 💡 **這段設定的黑魔法：** `CA:true` 代表這是一張 CA 憑證（可以簽別人）；`pathlen:0` 代表它只能再往下簽一層（就是孫子輩），孫子不能再簽曾孫。
接著開始產出老爸：

```
# 3. 產生老爸的私鑰 (Intermediate Key)
openssl genrsa -out intermediate.key 4096

# 4. 產生老爸的申請書 (Intermediate CSR)
openssl req -sha512 -new \
    -subj "/C=TW/ST=Taiwan/L=Taipei/O=Lab/CN=My-Intermediate-CA" \
    -key intermediate.key \
    -out intermediate.csr

# 5. 重頭戲：用「阿公的 Key 和 CRT」去簽老爸，並套用剛剛的 CA 特效設定檔
openssl x509 -req -sha512 -days 1825 \
    -CA root.crt -CAkey root.key -CAcreateserial \
    -in intermediate.csr \
    -out intermediate.crt \
    -extfile x509_ext.cnf -extensions v3_intermediate_ca
```

3. 孫子出生（建立終端憑證 Leaf）
現在阿公可以回保險箱休息了。我們接下來要用**老爸的私鑰**，去簽發你 Docker 伺服器要用的終端憑證。

```
# 6. 產生孫子的私鑰 (Server Key)
openssl genrsa -out docker1.training.lab.key 4096

# 7. 產生孫子的申請書 (Server CSR)
openssl req -sha512 -new \
    -subj "/C=TW/ST=Taiwan/L=Taipei/O=Lab/CN=docker1.training.lab" \
    -key docker1.training.lab.key \
    -out docker1.training.lab.csr

# 8. 最終簽發：用「老爸的 Key 和 CRT」來簽發孫子憑證！
openssl x509 -req -sha512 -days 365 \
    -CA intermediate.crt -CAkey intermediate.key -CAcreateserial \
    -in docker1.training.lab.csr \
    -out docker1.training.lab.crt
```

4. 終點關鍵：如何綁定成「憑證鏈」給 Nginx / Harbor 使用？
當你走完上面三層，瀏覽器在連線時，它需要同時看到「孫子」和「老爸」。所以業界的標準作法是把**孫子憑證和老爸憑證黏在一起**，做成一個「完整憑證鏈檔案（Full Chain）」：

```
# 把孫子放前面，老爸放後面，合併成一個檔案
cat docker1.training.lab.crt intermediate.crt > fullchain.crt
```
最後部署時：
- Nginx / Harbor 的網頁憑證欄位：填這個合併後的 `fullchain.crt`。
- Nginx / Harbor 的私鑰欄位：填孫子的 `docker1.training.lab.key`。
- 你的電腦 / PVE 信任清單：只需要匯入最頂層的阿公 `root.crt`。

## EJBCA Community
## Step CA


## Windows ADCS


## Caddy - 本地Root憑證做到可以瀏覽.local 加密



## 結論 - 使用情境

| **情境**                   | **憑證層級選擇**            | **為什麼？**               |
| ------------------------ | --------------------- | ---------------------- |
| **個人 HomeLab / 期末專案測試**  | **兩層 (手動 OpenSSL)**   | 快速、省事、好除錯。             |
| **企業正式 Production 生產環境** | **三層 (step-ca / 大廠)** | 核心安全考量，避免 Root Key 曝光。 |
| **自動化短命憑證 (ACME) 環境**    | **三層 (必須)**           | 線上自動更新必須依賴中間 CA 來擋刀。   |
| **封閉式硬體設備維運網頁**          | **兩層 (Self-signed)**  | 權限不外擴，不需要多此一舉。         |
