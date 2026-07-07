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

負載平衡設定檔
```
global
    log /dev/log local0
    log /dev/log local1 notice
    daemon

defaults
    log     global
    mode    tcp
    timeout connect 5s
    timeout client  50s
    timeout server  50s

# ==========================================
# 1. Illumio Web Management (Port 443 -> 8443)
# ==========================================
frontend illumio_web_frontend
    bind *:443
    mode tcp
    default_backend illumio_web_backend

backend illumio_web_backend
    mode tcp
    balance leastconn

    #tcp check,if 8443 port open is up
    server pce-core-01 172.16.7.106:8443 check inter 3s fall 3 rise 2
    server pce-core-02 172.16.8.85:8443 check inter 3s fall 3 rise 2

# ==========================================
# 2. Illumio VEN Agent (Port 8444 -> 8444)
# ==========================================
frontend illumio_ven_frontend
    bind *:8444
    mode tcp
    default_backend illumio_ven_backend

backend illumio_ven_backend
    mode tcp
    balance leastconn
    
    # tcp check, if 8444 port open is up
    server pce-core-01 172.16.7.106:8444 check inter 3s fall 3 rise 2
    server pce-core-02 172.16.8.85:8444 check inter 3s fall 3 rise 2

# ==========================================
# 3. HAProxy Stats Dashboard
# ==========================================
listen stats
    bind *:9000
    mode http
    stats enable
    stats uri /
    stats refresh 5s
    stats auth admin:password   #admin:password 這邊代表帳號名跟密碼
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

設定檔2
```
#---------------------------------------------------------------------
# HAProxy 配置文件 - Illumio PCE 負載平衡 (支持標準和非標準端口)
#---------------------------------------------------------------------
global
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon
    # 啟用統計信息 socket
    stats socket /var/lib/haproxy/stats
    # 使用系統級加密政策
    ssl-default-bind-ciphers PROFILE=SYSTEM
    ssl-default-server-ciphers PROFILE=SYSTEM
defaults
    log                     global
    option                  dontlognull
    retries                 3
    timeout connect         10s
    timeout client          30m
    timeout server          30m
    timeout check           10s
    maxconn                 3000
#---------------------------------------------------------------------
# 統計信息前端 - 用於監控 HAProxy 狀態
#---------------------------------------------------------------------
frontend stats
    mode http
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 10s
    stats admin if TRUE
#    stats auth haproxy:haproxy  # 請修改為強密碼
#---------------------------------------------------------------------
# Exporter 專用 metrics endpoint (/metrics)
#---------------------------------------------------------------------
#listen metrics_exporter
#    bind *:9000
#    mode http
#    stats enable
#    stats uri /metrics
#    stats refresh 10s
#    stats auth admin:admin  # Prometheus exporter 會用這帳密連線
#---------------------------------------------------------------------
# 主前端 - 處理 HTTPS 請求 (使用 HTTP 模式)
#---------------------------------------------------------------------
frontend main
    mode                    http
    # 同時監聽標準端口和非標準端口
    bind *:443 ssl crt /etc/haproxy/certs/server.pem
    bind *:8443 ssl crt /etc/haproxy/certs/server.pem

    # 設定主機標頭
    http-request set-header Host illu2x2.gss.com.tw

    # 日誌記錄
    option                  httplog

    # 保持長連接能力
    option http-server-close
    option forwardfor
    # 預設後端
    default_backend pce_https_servers
#---------------------------------------------------------------------
# PCE 長連接前端 - 處理 8444 端口請求 (使用 TCP 模式)
#---------------------------------------------------------------------
# frontend pce_longconn
#     mode                    tcp
#     bind *:8444 ssl crt /etc/haproxy/certs/server.pem
#     default_backend pce_longconn_servers
#---------------------------------------------------------------------
# PCE HTTPS 後端 - 8443 端口服務 (使用 HTTP 模式)
#---------------------------------------------------------------------
backend pce_https_servers
    mode                    http
    balance                 roundrobin

    option httpchk
    http-check send meth GET uri /api/v2/node_available ver HTTP/1.1 hdr host illu2x2.gss.com.tw
    http-check expect status 200-499

#    cookie                  SERVERID insert indirect nocache  # 長連結
    server core0 172.16.7.137:8443 check ssl verify none inter 15000
    server core1 172.16.7.139:8443 check ssl verify none inter 15000
#---------------------------------------------------------------------
# PCE 長連接後端 - 8444 端口服務 (使用 TCP 模式)
#---------------------------------------------------------------------
# backend pce_longconn_servers
#     mode                    tcp
#     balance                 roundrobin
#     option                  tcp-check
#     server core0_event 172.16.7.137:8444 check ssl verify none
#     server core1_event 172.16.7.139:8444 check ssl verify none

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


