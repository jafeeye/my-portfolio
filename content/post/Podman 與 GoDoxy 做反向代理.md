---
title: Podman 與 GoDoxy 做反向代理
toc: true
date: 2026-08-09
---
本身無守護進程，可允許一般使用者執行，所以要開機啟動容器也要寫腳本
高度相容Docker，並且能使用K8s 指令，創立Pod

![[static/Diagram 13.svg]]
可以。你這台是 Debian，而且目前用 `root` 操作，完整安裝流程改成下面這套。前面 Rocky Linux 的 `dnf`、EPEL、SELinux、`firewall-cmd` 都不需要。

1. 安裝 Podman 與 Compose
```
apt update
apt install -y podman podman-compose wget openssl
```
確認：
```
podman --version
podman-compose --version
podman compose version
```

如果仍找不到，暫時指定 provider：
```
export PODMAN_COMPOSE_PROVIDER=/usr/bin/podman-compose
podman compose version
```

2.啟用 rootful Podman API
```
systemctl enable --now podman.socket
systemctl status podman.socket
```

確認 Socket：
```
ls -l /run/podman/podman.sock
```

也可以測試 API：
```
curl --unix-socket /run/podman/podman.sock \
  http://localhost/_ping
```

正常會回覆：
```
OK
```

`/var/run` 在 Debian 通常指向 `/run`，因此以下兩條其實通常是同一個 Socket：
```
/run/podman/podman.sock
/var/run/podman/podman.sock
```

3. 建立 GoDoxy 目錄
```
mkdir -p /opt/godoxy/config
mkdir -p /opt/godoxy/logs
mkdir -p /opt/godoxy/error_pages
mkdir -p /opt/godoxy/data
mkdir -p /opt/godoxy/certs

cd /opt/godoxy
```

4. 下載官方設定檔
```
wget \
  https://raw.githubusercontent.com/yusing/godoxy/main/config.example.yml \
  -O config/config.yml

wget \
  https://raw.githubusercontent.com/yusing/godoxy/main/.env.example \
  -O .env

wget \
  https://raw.githubusercontent.com/yusing/godoxy/main/compose.example.yml \
  -O compose.yml
```

5. 修改 `.env`

先產生 JWT 密鑰：
```
openssl rand -base64 32
```
複製輸出結果，然後編輯：
```
nano /opt/godoxy/.env
```
至少調整成：
```
TAG=latest
TZ=Asia/Taipei

GODOXY_UID=1000
GODOXY_GID=1000

GODOXY_API_JWT_SECURE=true
GODOXY_API_JWT_SECRET=貼上剛才產生的隨機字串

GODOXY_API_USER=admin
GODOXY_API_PASSWORD=設定一組強密碼

GODOXY_HTTP_ADDR=:80
GODOXY_HTTPS_ADDR=:443
GODOXY_SNI_ROUTING_FOR_TCP_ROUTES=true
GODOXY_HTTP3_ENABLED=true

GODOXY_API_ADDR=127.0.0.1:8888

DOCKER_SOCKET=/run/podman/podman.sock
LISTEN_ADDR=127.0.0.1:2375

GODOXY_DEBUG=false
USE_SONIC_JSON=true
```

關鍵是：
```
DOCKER_SOCKET=/run/podman/podman.sock
```
GoDoxy 官方 `.env.example` 已直接標示 Podman 可以使用 `/var/run/podman/podman.sock`。[官方 `.env.example`](https://raw.githubusercontent.com/yusing/godoxy/main/.env.example)
如果你目前沒有 HTTPS 憑證，只想先透過 HTTP 測試 Web UI，可以暫時改成：
```
GODOXY_API_JWT_SECURE=false
```
正式使用 HTTPS 後再改回 `true`。

6. 修正目錄權限
因為 GoDoxy 容器預設以 UID/GID `1000:1000` 執行：
```
chown -R 1000:1000 \
  /opt/godoxy/config \
  /opt/godoxy/logs \
  /opt/godoxy/error_pages \
  /opt/godoxy/data \
  /opt/godoxy/certs
```
如果 `.env` 裡改用其他 UID/GID，這裡也要跟著改。

7. 設定 GoDoxy Web UI 網址
```
nano /opt/godoxy/config/config.yml
```

找到：
```
webui:
  aliases:
    - godoxy
```

改成你的實際網域，例如：
```
webui:
  aliases:
    - godoxy.lab.example.com
```

接著讓 DNS 指向這台 Podman VM：
```
godoxy.lab.example.com → Podman VM IP
```

如果要自動代理其他子網域，可以再建立：
```
*.lab.example.com → Podman VM IP
```

8. 檢查 80／443 是否被占用
```
ss -lntup | grep -E ':(80|443|2375|8888)\b'
```
如果 80 或 443 已被 Nginx、Apache、Traefik 等服務占用，要先停掉或改 Port。

9. 驗證並啟動
```
cd /opt/godoxy
podman compose config
```

若設定正常：
```
podman compose pull
podman compose up -d
```

檢查容器：
```
podman ps
```
預期會看到：
```
socket-proxy
godoxy-proxy
```

查看日誌：
```
podman logs socket-proxy
podman logs godoxy-proxy
```

持續查看 GoDoxy 日誌：
```
podman logs -f godoxy-proxy
```

10. 防火牆

Debian 預設不一定有啟用 UFW。先檢查：
```
ufw status
```

如果顯示啟用，再開放：
```
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 443/udp
```
其中 `443/udp` 是 HTTP/3。若不使用 HTTP/3，可以在 `.env` 設定：
```
GODOXY_HTTP3_ENABLED=false
```
就不必開放 UDP 443。
不要對外開放這兩個 Port：
```
2375
8888
```
目前它們都只監聽 `127.0.0.1`，保持這樣即可。

11. 測試 Podman 容器探索

先啟動測試容器：
```
podman run -d \
  --name whoami \
  --label proxy.aliases=whoami.lab.example.com \
  -p 8080:80 \
  docker.io/traefik/whoami:latest
```

確認容器：
```
podman ps
```

再查看 GoDoxy 是否偵測到：
```
podman logs --since 2m godoxy-proxy
```

DNS 還要有：
```
whoami.lab.example.com → Podman VM IP
```

然後測試：
```
curl -I http://whoami.lab.example.com
```

你現在最先需要做的其實就是：
```
apt update
apt install -y podman-compose
podman compose version
```

確認 Compose 已正常後，再從 `/opt/godoxy` 的安裝步驟繼續。

重建容器：
```
podman compose up -d --force-recreate
```

然後檢查：
```
podman ps
podman logs --since 2m godoxy-proxy
```

### 5. 如果目前沒有 HTTPS 憑證

編輯：
```
nano /opt/godoxy/.env
```

暫時設定：
```
GODOXY_API_JWT_SECURE=false
```

然後重建：
```
cd /opt/godoxy
podman compose up -d --force-recreate
```

再開：
```
http://godoxy.lab.example.com
```

`GODOXY_API_JWT_SECURE=true` 時，登入 Cookie 要求 HTTPS；沒有可用憑證時，先用 `false` 測試比較合理。GoDoxy 官方也要求透過 `webui.aliases` 中的 hostname 開啟內嵌 Web UI，而不是直接連管理 API Port。[GoDoxy Web UI 設定](https://docs.godoxy.dev/docs/godoxy/getting-started/Configuring-GoDoxy)

## 再修 Podman 容器探索

這段是另一個問題：
```
502 Bad Gateway
/v1.51/containers/json
```

Podman 的 Docker 相容 API 版本比 GoDoxy 嘗試使用的 `v1.51` 低。先測試 `v1.40`：
```
curl -i http://127.0.0.1:2375/_ping
curl -i http://127.0.0.1:2375/version
curl -i 'http://127.0.0.1:2375/v1.40/containers/json?all=1'
```

如果第三條能回傳容器 JSON，編輯：
```
nano /opt/godoxy/compose.yml
```

在 `godoxy-proxy` 的 `environment` 加入：
```
environment:
  - DOCKER_HOST=tcp://127.0.0.1:2375
  - DOCKER_API_VERSION=1.40
```

然後重建：
```
cd /opt/godoxy
podman compose up -d --force-recreate
podman logs --since 2m godoxy-proxy
```

正常應該從：
```
docker@local   0 routes
```

變成至少偵測到你的 `whoami` 容器。Podman 官方說明其 REST 服務提供 Docker 相容 API，而 rootful socket 位於 `/run/podman/podman.sock`。[Podman API 官方文件](https://docs.podman.io/en/latest/markdown/podman-system-service.1.html)
所以你現在第一步只要做：
```
hosts 加入 192.168.8.32 godoxy.test
→ 開啟 http://godoxy.test
```

我現在進去網頁了 那帳號密碼又是甚麼
帳號密碼就是你在 `/opt/godoxy/.env` 裡設定的：

```
GODOXY_API_USER=admin
GODOXY_API_PASSWORD=你當時設定的密碼
```
直接查看：
```
grep -E '^GODOXY_API_(USER|PASSWORD)=' /opt/godoxy/.env
```

如果還沒設定或忘記了，就編輯：
```
nano /opt/godoxy/.env
```

填入新的帳密：
```
GODOXY_API_USER=admin
GODOXY_API_PASSWORD=你的新密碼
```

然後必須重建容器，才能載入新環境變數：
```
cd /opt/godoxy
podman compose up -d --force-recreate
```

再用：
```
帳號：admin
密碼：你在 GODOXY_API_PASSWORD 設定的內容
```

如果 HTTP 登入後又跳回登入頁，確認：
```
GODOXY_API_JWT_SECURE=false
```

因為你目前是用 `http://godoxy.test`，不能設成 `true`。


## godoxy要串接caddy 的acme server 拿憑證來用


可以。你目前使用 `godoxy.test`，最適合的做法是：
```
GoDoxy
  └─ DNS-01 驗證 → PowerDNS API
  └─ ACME 申請 → Caddy ACME Server
  └─ 最終憑證 → Caddy 內部 CA 簽發
```

GoDoxy 只支援 DNS-01，因此即使 CA 改成 Caddy，仍需要 PowerDNS API 幫它建立 `_acme-challenge` TXT 紀錄。

以下假設：

```
Caddy ACME 主機名：caddy-ca.test
GoDoxy 網域：*.test
PowerDNS DNS IP：192.168.8.10
PowerDNS API：http://192.168.8.10:8081
GoDoxy IP：192.168.8.32
```

請把 IP 換成你的實際環境。

## 1. 建立 DNS 紀錄

PowerDNS 加入：
```
caddy-ca.test → Caddy 伺服器 IP
*.test        → 192.168.8.32
```

從 GoDoxy 主機確認：
```
getent hosts caddy-ca.test
getent hosts godoxy.test
```

## 2. 在 Caddy 啟用 ACME Server

編輯 Caddyfile：
```
{
	pki {
		ca homelab {
			name "HomeLab CA"
			intermediate_lifetime 730d
		}
	}
}

caddy-ca.test {
	tls {
		issuer internal {
			ca homelab
		}
	}

	acme_server {
		ca homelab
		lifetime 90d

		challenges dns-01
		allow_wildcard_names

		resolvers 192.168.8.10:53

		allow {
			domains "*.test"
		}
	}
}
```

這裡有兩個重要設定：

```
allow_wildcard_names
lifetime 90d
```

Caddy ACME Server 預設憑證只有 `12h`，但 GoDoxy 會在到期前 30 天更新，因此一定要提高有效期；同時也要提高 Intermediate CA 的有效期。[Caddy ACME Server 文件](https://caddyserver.com/docs/caddyfile/directives/acme_server)

驗證並重新載入：

```
caddy validate --config /etc/caddy/Caddyfile
systemctl reload caddy
journalctl -u caddy -n 100 --no-pager
```

測試 ACME Directory：

```
curl -k https://caddy-ca.test/acme/homelab/directory
```

正常會看到包含 `newAccount`、`newOrder` 等網址的 JSON。

## 3. 把 Caddy Root CA 複製到 GoDoxy

如果 Caddy 是用 Debian/RHEL systemd 安裝，Root CA 通常在：

```
/var/lib/caddy/.local/share/caddy/pki/authorities/homelab/root.crt
```

從 Caddy 主機複製到 GoDoxy：

```
scp \
  /var/lib/caddy/.local/share/caddy/pki/authorities/homelab/root.crt \
  root@192.168.8.32:/opt/godoxy/certs/caddy-homelab-root.crt
```

如果 Caddy 是容器，容器內通常位於：

```
/data/caddy/pki/authorities/homelab/root.crt
```

回到 GoDoxy 主機確認：

```
ls -l /opt/godoxy/certs/caddy-homelab-root.crt
```

測試 GoDoxy 能否信任 ACME Server：

```
curl \
  --cacert /opt/godoxy/certs/caddy-homelab-root.crt \
  https://caddy-ca.test/acme/homelab/directory
```

這條不能出現：

```
certificate signed by unknown authority
```

## 4. 設定 PowerDNS API 帳密

編輯：

```
nano /opt/godoxy/.env
```

加入：

```
PDNS_API_URL=http://192.168.8.10:8081/
PDNS_API_KEY=你的PowerDNS_API_Key
```

PowerDNS API 不建議暴露至外網，只讓 GoDoxy 所在內網存取即可。PowerDNS 在 lego 裡面的 provider 名稱是 `pdns`。[lego PowerDNS 文件](https://go-acme.github.io/lego/dns/pdns/)

## 5. 修改 GoDoxy autocert

編輯：

```
nano /opt/godoxy/config/config.yml
```

加入或修改：

```
autocert:
  provider: pdns
  email: your-email@example.com

  domains:
    - "*.test"

  ca_dir_url: https://caddy-ca.test/acme/homelab/directory

  ca_certs:
    - /app/certs/caddy-homelab-root.crt

  cert_path: /app/certs/cert.crt
  key_path: /app/certs/priv.key
```

這裡不要寫：

```
provider: custom
```

因為你申請的是 wildcard 憑證，GoDoxy仍然需要 `pdns` provider 建立 DNS-01 TXT 紀錄；`ca_dir_url` 才是用來把簽發端改成 Caddy。

GoDoxy 官方支援使用 `ca_dir_url` 與 `ca_certs` 串接自訂內部 CA。[GoDoxy 憑證文件](https://docs.godoxy.dev/docs/godoxy/advanced-topics/Certificates)

## 6. 確認 Root CA 有掛入容器

檢查 Compose：

```
grep -A15 'volumes:' /opt/godoxy/compose.yml
```

GoDoxy 服務需要有：

```
volumes:
  - ./certs:/app/certs
```

確認容器看得到憑證：

```
podman exec godoxy-proxy \
  ls -l /app/certs/caddy-homelab-root.crt
```

## 7. 重建 GoDoxy

```
cd /opt/godoxy
podman compose up -d --force-recreate
```

持續查看日誌：

```
podman logs -f godoxy-proxy
```

正常流程應該會看到：

```
registering ACME account
presenting DNS challenge
obtaining certificate
certificate obtained
server started addr=:443
```

另外觀察 Caddy：

```
journalctl -u caddy -f
```

## 8. 確認憑證

```
openssl s_client \
  -connect 127.0.0.1:443 \
  -servername godoxy.test \
  -showcerts </dev/null
```

或者：

```
curl \
  --cacert /opt/godoxy/certs/caddy-homelab-root.crt \
  https://godoxy.test
```

## 9. Windows 信任 Caddy Root CA

即使 GoDoxy 成功取得憑證，Windows 沒信任 Caddy Root CA，瀏覽器還是會顯示不安全。

把：

```
caddy-homelab-root.crt
```

複製到 Windows，使用系統管理員 PowerShell 執行：

```
certutil -addstore -f Root .\caddy-homelab-root.crt
```

關閉並重新開啟瀏覽器後，進入：

```
https://godoxy.test
```

如果申請失敗，最有用的是貼這三段輸出：

```
podman logs --tail 150 godoxy-proxy
curl --cacert /opt/godoxy/certs/caddy-homelab-root.crt https://caddy-ca.test/acme/homelab/directory
dig @192.168.8.10 TXT _acme-challenge.test
```