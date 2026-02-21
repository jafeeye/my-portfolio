---
title: 企業VPN架設
date: 2026-02-21
toc: true
---
## VPN 相關協定
| VPN 協定            | 優點                                  | 缺點                          | 常見軟體 / 實作                                                                                                                           |
| ----------------- | ----------------------------------- | --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| **WireGuard**     | ✔ 連線速度快<br>✔ 設定簡單<br>✔ 低延遲          | ✖ 較新，少數舊設備支援不足              | • WireGuard (官方)<br>• **Tailscale**<br>• Zerotier<br>• **Mullvad VPN**<br>• **AzireVPN**<br>• **Outline VPN**                       |
| **L2TP/IPsec**    | ✔ 安全性較高（加上 IPsec）<br>✔ 泛用性高         | ✖ 易被防火牆封鎖<br>✖ 效能較純 IPsec 低 | • Windows/macOS/iOS 原生支援<br>• **Cisco VPN Client**<br>• **StrongVPN**（L2TP選項）                                                       |
| **OpenVPN**       | ✔ 安全性高<br>✔ 泛用性高<br>✔ 穿透性強（TCP/UDP） | ✖ 設定較複雜<br>✖ 非微軟限制多         | • **OpenVPN Community Edition**<br>• **OpenVPN Connect**<br>• **Tunnelblick**（macOS）<br>• **Viscosity**<br>• **Pritunl**            |
| **IPsec / IKEv2** | ✔ 安全性高<br>✔ 延遲低<br>✔ 效能高            | ✖ 設定較複雜<br>✖ 穿透性弱（NAT/防火牆）  | • **strongSwan**<br>• **LibreSwan**<br>• **Cisco AnyConnect** (IPsec/IKEv2 選項)<br>• iOS/Android 原生 IKEv2 支援<br>• **Shrew Soft VPN** |

## 實作
在下面實例將使用不同VPN技術，解決安全性及泛用性問題，假設公司分別台北及高雄分公司

|角色|WAN|LAN|
|---|---|---|
|總公司 VPN server|192.168.80.155|192.168.30.2|
|總公司 client||192.168.30.3|
|分公司 VPN server|192.168.80.156|192.168.40.2|
|分公司 client||192.168.40.3|
|remote client||192.168.80.157|
|DC（CA中心）||192.168.30.10|
