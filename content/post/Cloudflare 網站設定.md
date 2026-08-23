---
title: Cloudflare 網站設定
toc: true
date: 2026-04-22
---

預設 Cloureflare 託管後即有加密SSL，還可以做另外設定
Automatic HTTPS Rewrites：如果訪問的是 HTTP，會自動轉到 HTTPS。
Always use HTTPS：永遠使用 HTTPS。
Brotli：使用 Brotli 壓縮加快網站的載入速度。
 Flexible SSL 
Full (Strict) SSL 模式
Origin Rules端口 (端口轉發)

## 託管網域

![](static/Pasted%20image%2020260727170201.png)
## Cloudflare Tunnel


3. 設定https IP，這邊假設為PVE IP `https://192.168.100.1:8006`，如果直接設定會出現Bad gateway，
4. ![](static/Pasted%20image%2020260727163205.png)

![](static/Pasted%20image%2020260727163315.png)

![](static/Pasted%20image%2020260727163442.png)


5. 加上ZeroTrust
![](static/Pasted%20image%2020260727164349.png)


![](static/Pasted%20image%2020260727165817.png)



## MFA 驗證


## 實作1：透過反向代理連進illumio
```
外網
    │
    │ HTTP :8080
    ▼
cloudflared
    │
    │ HTTP :8080
    ▼
Caddy 192.168.10.9:8080
    │
    │ HTTPS :8443
    ▼
Illumio
    │
    └── 200 OK ✅
```

詳細步驟:
1. 在Clouflare CIDR routes設定`192.168.8.0/24` ，
2. Published application routes subdomain設定xxx ，domain為 pdn.example.com ，Services走HTTP，並填入Caddy IP:8080 (本實例中雖然是走10.0網段，但因為靜態路由在Cloudflared是正常可連線，因此這邊就可直接填10.0)
![](static/Pasted%20image%2020260816120810.png)
3.在Caddy 做以下設定，從8080進入的情形
```
:8080 {
    ## 反向到illumio PCE IP
    reverse_proxy https://192.168.8.122:8443 {
        transport http {
            tls_insecure_skip_verify
        }
    ## header_up Host 打上完整公網網域名
        header_up Host xxx.pdn.example.com
        header_up X-Forwarded-Host xxx.pdn.example.com
        header_up X-Forwarded-Proto https
        header_up X-Forwarded-Port 443
    }
}
```
4. 如果是Cluster 2x2，Candy寫成以下設定
```
:8080 {
    reverse_proxy https://192.168.8.12:8443 https://192.168.8.13:8443 {
        lb_policy round_robin

        health_uri /node_available
        health_interval 10s
        health_timeout 3s

        transport http {
            tls_insecure_skip_verify
        }
    ## header_up Host 打上完整公網網域名
        header_up Host xxx.pdn.example.com
        header_up X-Forwarded-Host xxx.pdn.example.com
        header_up X-Forwarded-Proto https
        header_up X-Forwarded-Port 443
    }
}
```
4. 外面用瀏覽器進去用 xxx.pdn.example.com:8443
### 參考資料
[使用 Cloudflare 幫你的網站掛上 SSL 憑證與 CDN](https://docfunc.com/posts/92/%E4%BD%BF%E7%94%A8-cloudflare-%E5%B9%AB%E4%BD%A0%E7%9A%84%E7%B6%B2%E7%AB%99%E6%8E%9B%E4%B8%8A-ssl-%E6%86%91%E8%AD%89%E8%88%87-cdn-post)
[用 Cloudflare Tunnel 打通 Synology NAS](https://sakkyoi.tech/article/cloudflare-tunnel-synology-nas/)
