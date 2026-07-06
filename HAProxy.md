---
title: HAProxy
toc: true
date: 2026-07-06
---
安裝HAProxy
```
apt update && apt install haproxy -y
yum install haproxy -y
```

設定HAProxy
```
nano /etc/haproxy/haproxy.cfg
```

```
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    user haproxy
    group haproxy
    daemon

defaults
    log     global
    mode    tcp          # Illumio 推薦走純 TCP 模式（L4）
    log-format "%ci:%cp [%t] %ft %b/%s %Tw/%Tc/%Tt %B %ts %ac/%fc/%bc/%sc/%rc %sq/%bq"
    timeout connect 5s
    timeout client  50s
    timeout server  50s

# ==========================================
# 1. Illumio Web Console & API (Port 8443)
# ==========================================
frontend illumio_web_frontend
    bind *:8443
    default_backend illumio_web_backend

backend illumio_web_backend
    mode tcp
    balance leastconn    # 官方強烈推薦使用最小連接數
    
    # 關鍵：利用 HTTP GET /node_available 檢查後端 Core Node 是否健康
    # 因為後端是 HTTPS，所以要帶上 check-ssl 和 verify none (忽略自我簽署憑證)
    option httpchk GET /node_available
    http-check expect status 200
    
    # 後端 Core Nodes 列表
    server pce-core-01 172.16.8.11:8443 check check-ssl verify none inter 3s fall 3 rise 2
    server pce-core-02 172.16.8.12:8443 check check-ssl verify none inter 3s fall 3 rise 2

# ==========================================
# 2. Illumio VEN Agent 通道 (Port 8444)
# ==========================================
frontend illumio_ven_frontend
    bind *:8444
    default_backend illumio_ven_backend

backend illumio_ven_backend
    mode tcp
    balance leastconn
    
    # 同樣使用 8443 的健康檢查路徑來決定 8444 是否要送流量
    option httpchk GET /node_available
    http-check expect status 200
    
    # 轉發給 Core Nodes 的 8444 埠口，但檢查依舊看 8443 的 API
    server pce-core-01 172.16.8.11:8444 check port 8443 check-ssl verify none inter 3s fall 3 rise 2
    server pce-core-02 172.16.8.12:8444 check port 8443 check-ssl verify none inter 3s fall 3 rise 2

# ==========================================
# 3. HAProxy 狀態監控後台 (選用，方便你排錯)
# ==========================================
listen stats
    bind *:9000
    mode http
    stats enable
    stats uri /
    stats refresh 5s
    stats auth admin:Password123  # 自訂你的監控後台帳密
```

啟動驗證
```
# 測試設定檔是否正常
haproxy -c -f /etc/haproxy/haproxy.cfg

# 重啟HAProxy服務
systemctl restart haproxy 
systemctl enable haproxy

# 查看運作狀態
systemctl status haproxy

```

