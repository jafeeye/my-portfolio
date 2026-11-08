---
title: MOSDNS 設定
toc: true
tags:
  - DNS
---
1. 下載編譯原檔安裝
```
wget https://github.com/IrineSistiana/mosdns/releases/download/v5.3.4/mosdns-linux-amd64.zip
unzip mosdns.zip
install -m 0755 mosdns /usr/local/bin/mosdns
mkdir -p /etc/mosdns
mosdns version
```

2. 下載別人寫好[前端](https://blog.curlc.com/posts/mosdns-lan-webui/) 
```
curl -fsSL https://raw.githubusercontent.com/luoye663/mosdns-controller/main/deploy/binary/install-release.sh | bash
## 禁用systemd-resolved，會占用端口
systemctl stop systemd-resolved
systemctl disable systemd-resolved

```

3. 進入網頁IP:8080建立一組本地上游DNS
![](static/Pasted%20image%2020261108125148.png)
4. 寫一組自訂義規則就好
![](static/Pasted%20image%2020261108125444.png)