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

