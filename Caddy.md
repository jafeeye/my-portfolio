---
title: Caddy
toc: true
date: 2026-08-16
---

DNS Chanllage 提供 `http-01 / dns-01 / tls-alpn-01`
Caddyfile **已經有一個 `{}` global block** 而是要合併
```
那不能再新增第二個，而是要合併
{
    ## email xxx@example.com
    local_certs
    pki {
        ca local {
            name "Caddy Local Authority"
            intermediate_lifetime 730d
        }
    }
}
# 下面才放其他所有網站

acme-ca.test:9000 {
    acme_server {
        ca local
        lifetime 365d
    }
}
```

### 1. 確認 Caddy ACME CA 正常
```
sudo caddy validate --config /etc/caddy/Caddyfile
sudo systemctl restart caddy
systemctl status caddy --no-pager
```
然後測 ACME directory：
```
curl -vk https://acme-ca.test:9000/acme/local/directory
```
正常應該會回 JSON，裡面有類似：
```
{
  "newAccount": "...",
  "newNonce": "...",
  "newOrder": "...",
  "revokeCert": "..."
}
```
這代表：
```
Caddy local Root CA
        │
        └── ACME Server :9000
                ✅ 可以使用
```

## 2. 調整輪替有效期後再刪掉
```
{
    pki {
        ca local {
            name "Caddy Local Authority"
            intermediate_lifetime 730d
            renewal_window_ratio 0.9
        }
    }
}
```
重啟
```
sudo caddy validate --config /etc/caddy/Caddyfile
sudo systemctl restart caddy
```
等一下再查：
```
sudo openssl x509 \
  -in /var/lib/caddy/.local/share/caddy/pki/authorities/local/intermediate.crt \
  -noout -subject -issuer -dates -serial
```

## 3.簽一張CA
```

acme.sh
   │
   │ ACME
   ▼
Caddy :9000
local CA
   │
   └── 簽 illumio-kevin.bd1.dev
                │
                ├─ key
                ├─ leaf cert
                └─ full chain
                      ↓
                 Illumio PCE

```


安裝 acme.sh，因為單純拿 certificate 很方便。在管理 Linux/Caddy 主機安裝：
```
## 切換到root
curl https://get.acme.sh | sh
## 重新載入 shell：
source ~/.bashrc
```
確認caddy acme directory
```
curl -vk https://acme-ca.test:9000/acme/local/directory
```

向
```
export ACME_TLS_INSECURE=1
```
簽發 `--insecure`可跳過驗證
```
~/.acme.sh/acme.sh --issue \
  --server https://acme-ca.test:9000/acme/local/directory \
  --insecure \
  --standalone \
  -d colortokens.bd1.dev
```


## 實例1:簽一張Colortokens憑證並安裝
架構圖
```
Caddy ACME CA
      ↓ TLS-ALPN-01
colortokens.bd1.dev:443
      ↓
192.168.8.30:443
      ↓
acme.sh + socat
      ↓
challenge 驗證成功
```


```
產 RSA private key
↓
產 CSR
SAN:
  colortokens.bd1.dev
  *.colortokens.bd1.dev
↓
用 Caddy local Intermediate 簽
↓
tls.crt
tls.key
```


```
sudo apt update && apt install -y socat
```

要使用root權限簽發，這邊比較麻煩要求憑證要有RSA，萬用憑證 Wildcard SAN ，ACME 驗證要能簽發成功，要進行DNS-01 Challenge
```
~/.acme.sh/acme.sh --issue \
  --server https://acme-ca.test:9000/acme/local/directory \
  --insecure \
  --dns \
  --yes-I-know-dns-manual-mode-enough-go-ahead-please \
  --keylength 2048 \
  -d colortokens.bd1.dev \
  -d '*.colortokens.bd1.dev'
```

```
dig @192.168.10.2 TXT _acme-challenge.colortokens.bd1.dev
dig @192.168.10.3 TXT _acme-challenge.colortokens.bd1.dev
```

新增完紀錄後執行
```
~/.acme.sh/acme.sh --renew \
  --server https://acme-ca.test:9000/acme/local/directory \
  --insecure \
  -d colortokens.bd1.dev \
  --force \
  --yes-I-know-dns-manual-mode-enough-go-ahead-please
```
把憑證簽在一起，要做的是把 Caddy Root CA 接在 fullchain 後面
```
scp root@192.168.10.9:/var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt \
  /home/ctuser/caddy-root.crt
```
重組憑證
```
cat \
  /root/.acme.sh/colortokens.bd1.dev/fullchain.cer \
  /home/ctuser/caddy-root.crt \
  > /home/ctuser/tls.crt
```
檢查憑證
```
awk '
/BEGIN CERTIFICATE/{n++}
{print > ("/tmp/cert" n ".pem")}
' /home/ctuser/tls.crt

for f in /tmp/cert*.pem; do
  openssl x509 -in "$f" -noout -subject -issuer
done

## 確認憑證是不是3層
grep -c "BEGIN CERTIFICATE" /home/ctuser/tls.crt

## 驗證
openssl verify \
  -CAfile /home/ctuser/caddy-root.crt \
  -untrusted /root/.acme.sh/colortokens.bd1.dev/ca.cer \
  /root/.acme.sh/colortokens.bd1.dev/colortokens.bd1.dev.cer
```
複製憑證到安裝目錄
```




sudo cp \
  /root/.acme.sh/colortokens.bd1.dev/colortokens.bd1.dev.key \
  /home/ctuser/tls.key

sudo chown ctuser:ctuser \
  /home/ctuser/tls.crt \
  /home/ctuser/tls.key

sudo chmod 644 /home/ctuser/tls.crt
sudo chmod 600 /home/ctuser/tls.key
```
### 安裝
```
cd $HOME/onprem-infrastructure/single-node
./deploy.sh --domain
輸入網域名稱:bd1.dev
HTTPS
憑證位置:/home/ctuser/
yes
./deploy.sh --poc
```
確認全綠燈
![](static/Pasted%20image%2020260816201228.png)



./deploy.sh --poc 不能重新佈署 可能有其他方法
