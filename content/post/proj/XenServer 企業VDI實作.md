---
title: XenServer 企業實作
toc: true
date: 2026-09-25
---
1. 先基本安裝Hypervisor，在這邊使用PVE模擬 (RAM32G/HDD200G/SeaBIOS)
![](static/Pasted%20image%2020260925210139.png)

2. 升級過程 (從8.2.0升級到8.2.1，步驟基本上都一樣，差在按鈕變成Upgrade)
![](static/Pasted%20image%2020260926141201.png)

3. 安裝XenCenter 
4. `File → Import` 匯入 Citrix_License_Server_Virtual_Appliance.xva，安裝 Citrix License Server
![](static/Pasted%20image%2020260926155759.png)

5. 開機會先設定密碼，因為hostname 要跟 License 的hostname一致，使用 `hostnamectl set-hostname --static 電腦名稱`，因為還會有transit hostname所以再重開機一次，要重置授權可以輸入 resetsettings.sh
Web:https://192.168.8.81:8082/ 授權Port 27000
![](static/Pasted%20image%2020260926202359.png)
6. 指派授權，舊版的License Server VPX 已經淘汰，Tools/License Manager

7. 設定Citirx Studio
![](static/Pasted%20image%2020260927001158.png)


8. XCP-NG 安裝
![](static/Pasted%20image%2020260927123210.png)

相關套件一覽表

| 元件                              | 功能                              | 需要程度       |
| ------------------------------- | ------------------------------- | ---------- |
| **AD DS＋DNS**                   | 提供網域帳號、電腦加入網域與名稱解析              | 傳統網域架構的基礎  |
| **Delivery Controller**         | 管理桌面、應用程式，分配使用者連線               | 核心         |
| **SQL Server**                  | 儲存 Citrix Site 設定與工作階段資訊        | 核心         |
| **Citrix License Server**       | 管理 Citrix 授權                    | 核心         |
| **Studio／Web Studio**           | 建立機器目錄、交付群組與發布應用程式              | 管理介面，依版本使用 |
| **StoreFront**                  | 提供使用者登入及選擇桌面／程式的入口              | 一般地端環境使用   |
| **VDA（Virtual Delivery Agent）** | 裝在提供桌面或應用程式的 Windows VM，接受使用者連線 | 必要         |
| **Citrix Workspace app**        | 裝在使用者電腦，用來開啟遠端桌面／程式             | 一般用戶端使用    |
| **Director**                    | 監控連線、效能及協助排錯                    | 建議         |
| **Citrix Gateway**              | 提供外網安全存取                        | 純內網實驗可先省略  |

```
XenServer（XenCenter 管理）
│
├─ VM 1：Windows Server
│   └─ AD DS + DNS
│
├─ VM 2：Windows Server
│   ├─ Delivery Controller
│   ├─ Studio／Web Studio
│   ├─ SQL Server（支援的 Express 版本可用於小型實驗）
│   ├─ Citrix License Server
│   └─ StoreFront
│
└─ VM 3：支援版本的 Windows 桌面或 Windows Server
    ├─ VDA
    └─ 要提供給使用者的應用程式
```

4. 安裝 CXVD
![](static/Pasted%20image%2020260926003723.png)

golden image
![](static/Pasted%20image%2020260927123658.png)

Citrix Studio 派發
![](static/Pasted%20image%2020260927151704.png)


5. 發布步驟
```
Citrix Studio / Delivery Controller
        ↓
建立 Machine Catalog
        ↓
MCS 呼叫 Hypervisor
        ↓
XenServer 真正建立並執行 VM
        ↓
VDI01 / VDI02 / VDI03 ...
```

