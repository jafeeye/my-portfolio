---
title: illumio K8S
toc: true
date: 2026-06-02
---
NodePort 會對應到 VirtualService
Extra-Scope,


Service Types：NodePort,ClusterIP,LoadBlancer

雲端走LoadBalancer 類型網路
地端走Ingress Controller使用HostNetwork

**外部本機怎麼連進去？**

1. 你的外部本機直接輸入網址（例如 `http://my-app.com`） 。
2. DNS 或是你本機的 `hosts` 檔，將該網址指向那台運行 Ingress 的 K8s 節點實體 IP 。
3. 流量直接打到節點的 `80/443` 埠 ，直接被 Ingress Controller 沒收。
4. Ingress 透過網域名稱（Domain Name）或路徑（Path）判斷，**直接將流量轉發給後端的 Pod IP** 。


## 當企業「不想採用 HostNetwork」時的安全替代方案

在前面的討論中，我們提到地端 Ingress 最常用 `hostNetwork: true` 來直接霸佔 Worker 節點的 `80/443` 。

- **正式應用（替代方案）：** 有些企業的安全架構師（Security Architect）非常保守，他們認為讓一個 Pod 擁有 `hostNetwork` 權限等同於給了它實體機的網路控制權，風險太高。
    - 此時，他們會規定 Ingress Controller **只能以普通 Pod 模式運行**，然後透過 **NodePort** 暴露一個 `30080` 和 `30443` 。
    - 最外層的硬體防火牆再將外界的 `80/443` 轉發給這組 NodePort。
        
- **為什麼正式：** 這種做法利用 NodePort 作為安全沙箱（Sandbox）的隔離緩衝，完全剝奪了 Pod 對宿主機網路的直接存取權。