---
title: CA檢測方法
toc: true
date: 2026-08-09
---
顯示網站憑證資訊
```
openssl s_client \
  -connect acme-ca.test:443 \
  -servername acme-ca.test \
  -showcerts </dev/null
```
不匯入CA憑證檢查ACME Directory JSON
```
curl -v \
  --cacert /opt/godoxy/certs/caddy-homelab-root.crt \
  https://acme-ca.test:9000/acme/local/directory
```
