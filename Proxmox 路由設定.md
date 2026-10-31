---
title: Proxmox 路由設定
toc: true
date: 2026-10-30
tags:
  - PVE
---
要讓不同網段的IP互通法有2種，假設某台VM想連去VM2裝PCE不同網段主機，方法有3種
方法1. 在PCE 做靜態路由
方法2. 在最上面的路由器做靜態路由
方法3. NAT

網路架構
```
Proxmox vmbr0：172.16.7.20/24
Proxmox vmbr1：10.8.203.1/24

測試 VEN VM：10.8.203.10/24
172.16.7 網路閘道：172.16.7.1
```

### 方法1
1. PVE 原本vmbr0 為 172.16.9.14/16 (同時也是PVE登入IP) ,PCE在172.16.8.68
2. PVE 加一張vmbr1，只填10.8.203.1/24，其他都不要填包括GW
3. 開通sysctl net.ipv4.ip_forward=1
4. 輸入指令確認狀態
```
root@isbdtester02:~# ip route show  ## 使用ip route 看目前網卡路由
default via 172.16.1.11 dev vmbr0 proto kernel onlink 
10.8.203.0/24 dev vmbr1 proto kernel scope link src 10.8.203.1 
172.16.0.0/16 dev vmbr0 proto kernel scope link src 172.16.9.14 
```

   5. 在PCE加入 ip route add 10.8.203.0/24 via 172.16.9.14
   6. 在VM設定10.8.203.10 gw 10.8.203.1




### 常用指令
```
ip -br address
ip route get 172.16.8.10
```



### 方法2.路由器上靜態路由




