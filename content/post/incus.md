---
title: incus
toc: true
date: 2026-05-28
---
|**比較項目**|**LXD (Canonical)**|**Incus (Linux Containers 社群)**|**MicroCloud (Canonical)**|
|---|---|---|---|
|**定位與角色**|單機或叢集的**系統容器/VM 管理器**|核心技術同 LXD，但屬於**純開源、社群驅動**的管理器|基於 LXD 的**微型超融合私有雲 (HCI) 部署方案**|
|**底層技術**|LXC (容器) + QEMU (VM)|LXC (容器) + QEMU (VM)|**LXD** + **Ceph** (儲存) + **OVN** (網路)|
|**授權條款**|商業友善但受制於 Canonical CLA|完全開源 (Apache 2.0 / MPL)|開源，但高度綁定 Ubuntu 生態系 (Snap)|
|**多機叢集能力**|支援內建的 MicroCluster (採用 dqlite)|支援內建叢集 (採用 dqlite)|**原生強大**，至少 3 台節點即可自動達成高可用性 (HA)|
|**目標使用情境**|喜歡 Ubuntu 生態系、需要兼顧 Container 與 VM 的開發或維運環境|追求純粹開源、不受商業公司綁架，或使用 Debian/Fedora/Arch 等非 Ubuntu 系統的環境|邊緣運算 (Edge)、小型辦公室、希望 10 分鐘內用幾台小主機組出 **Micro-OpenStack / 輕量 Proxmox Ceph 叢集** 的場景|

## Incus Server Install
這裡使用rl10示範，
```

## 確認安裝狀態
incus list 
```

## Incus Server GUI Install
Incus  
CGManager  
distrobuilder  
LXCFS  


## 參考資料
1. https://linuxcontainers.cn/