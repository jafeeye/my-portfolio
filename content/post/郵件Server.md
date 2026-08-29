---
title: 郵件Server 架設
toc: true
date: 2026-06-29
---

## mailhog

1. 先安裝docker，跑mailhog服務
docker run -d -p 1025:1025 -p 8025:8025 --name local_mailhog mailhog/mailhog
2. 在 `/etc/illumio-pce/runtime_env.yml` 中把smtp的 IP:Port 從預設127.0.0.1:587改成
```
## 改變前
smtp_relay_address: 127.0.0.1:587
## 改變後
smtp_relay_address: 192.168.8.30:1025
```
3. 在docker主機用瀏覽器打開 127.0.0.1:8025 去收信測試


腳本改法
把`smtp.sendmail(from_, recipients, msg.as_bytes())` 改成 `smtp.sendmail(from_, recipients, msg.as_string())`



## mailpit
```
services:
  mailpit:
    image: axllent/mailpit:latest
    container_name: mailpit
    restart: unless-stopped

    ports:
      - "587:1025"
      - "8025:8025"

    environment:
      MP_SMTP_TLS_CERT: /certs/fullchain.cer
      MP_SMTP_TLS_KEY: /certs/wildcard.bd1.dev.key
      MP_SMTP_REQUIRE_STARTTLS: "true"

      MP_SMTP_AUTH: "testuser:testpass123"

    volumes:
      - ./certs:/certs:ro
```




## mailcow

架設前設定

A/AAAA 和 MX Records
- **A:** mail.yourdomain.com → 您的 IPv4
- **AAAA：** mail.yourdomain.com → 您的 IPv6 （可選但推薦）
- **MX：** yourdomain.com → mail.yourdomain.com（優先級 10）

PTR（反向） DNS
	**由您的房東設定：** IPv4 PTR 記錄必須對應到 mail.yourdomain.com，而且該網域必須解析回同一個 IP 位址。缺少 PTR 記錄會導致郵件無法送達。

SPF、DKIM、DMARC
- **SPF（RFC 7208）：** `v=spf1 a mx ip4:YOUR.IP all` （收緊至 `all` 驗證後）
- **DKIM（RFC 6376）：** 產生 2048 位元金鑰；發布選擇器 TXT 檔案；對外寄郵件進行簽名
- **DMARC（RFC 7489）：** 開始 `v=DMARC1; p=none; rua=mailto:dmarc@yourdomain.com; ruf=mailto:dmarc@yourdomain.com; sp=none; adkim=s; aspf=s`。 搬去 `quarantine` or `reject` 監測後

MTA STS 與 TLS RPT（現代交付能力）
- **MTA** **STS（RFC 8461）：** 在…主持一項政策 `mta-sts.yourdomain.com` 並發布 `_mta-sts` TXT。強制 SMTP 使用 TLS 加密。
- **SMTP TLS 報告（RFC 8460）：** 發布 `_smtp._tls` 請將報告傳送到您的郵箱，以便了解 TLS 問題。


```
# Prereqs sudo apt update && sudo apt -y install curl docker.io docker-compose-plugin sudo systemctl enable --now docker 

# Mailcow 
git clone https://github.com/mailcow/mailcow-dockerized 
cd mailcow-dockerized 
./generate_config.sh 
# Enter mail.yourdomain.com echo "ACME_CONTACT=admin@yourdomain.com" | sudo tee -a mailcow.conf 
sudo docker compose pull 
sudo docker compose up -d
```




## iRedmail



## Zimbra


## 除錯
name I or service not know：SMTP Host 無法被解析
```
getent hosts smtp-mail.bd1.dev
nslookup smtp-mail.bd1.dev

```


```
swaks \
  --server smtp-server.company.com \
  --port 25 \
  --from testuser@company.com \
  --to receiver@company.com
```
