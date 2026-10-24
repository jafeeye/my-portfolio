---
title: RollBack RX 還原卡軟體
toc: true
date: 2026-10-23
tags:
  - RollbackRx
---
```mermaid
flowchart TD
    G["管理電腦<br/>Endpoint Manager GUI"]
    S["另一台電腦<br/>Endpoint Manager Server Services"]
    R["Windows Server<br/>RollBack Rx Server"]
    P["一般 Windows 電腦<br/>RollBack Rx Pro"]

    G -->|"管理操作"| S
    S -->|"發現與管理"| R
    S -->|"發現與管理"| P
```

RollBack RX Pro Endpoint Manager 與 RollBack RX Server Endpoint Manager 本身無法兼容，一個能搜Endpoint 設備一個能搜Server設備，

1. 在安裝好的地方設定發現GUI
![](static/Pasted%20image%2020261024174523.png)

安裝 RollBack RX Pro Endpoint Manager，要修改端口要到 `C:\Program Files\RollBack Rx Server\EndPoint Manager`，修改 `Settings.ini`，把Port 給改了

