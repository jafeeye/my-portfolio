---
title: Windows 7 更新
date: 2026-02-22
toc: true
---
## 前言
在Windows 7 SP1 目前要啟用的功能
1. TLS 1.2 支援 (需安裝 KB3140245、KB3033929)
```powershell
> [Net.ServicePointManager]::SecurityProtocol  //檢查TLS支援狀態
> [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 //只啟用TLS 1.2連線
```
2. vxKex 內核支援
3. Windows Management Framework 5.1 (需安裝 KB3191566、.NetFramework 4.5 above)
4. Servicing Stack Update (KB4490628)
5. SHA-2 支援更新 (KB4474419)