---
title: Traefik
toc: true
date: 2026-08-08
---
## 反向代理

這邊使用
![[static/Diagram 12.svg]]

1. Adguard Home 分流給 Windows AD DNS、PowerDNS、mDNS Bridge
2. Adguard Home 做為 DoH Server
3. Caddy 跟 Traefik 都要設定DNS Server為PowerDNS
4. Caddy 在這邊做為反代跟本地Acme Server：負責一般的https
5. Traefik 透過acme.json 跟Caddy拿臨時憑證：負責容器之間的https
6. Certmate 向 Acme Server取得憑證後寫入 PowerDNS


EntraID

## Traefik Manager

## dnsweaver
如果覺得PowerDNS子網域設定太麻煩，可直接用Wild 對應Traefik主機IP，雖然省事但還是不太好