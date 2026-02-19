---
title: ESXi 安裝設定
date: 2026-02-19
toc: true
tags:
  - vmware
---
### 取消ESXi 虛擬內存
開機後按`Shift+o` 在cdromBoot runweasel 後面加入`autoPartitionOSDataSize = 4096`  

### 內顯直通
UHD 630 直通方法
1. 主機/管理/系統/高級設定，在`VMkernel.Boot.disableACSCheck` 修改為 True，作用為IOMMU強制獨立分組
2. 主機->管理->硬體，UHD Graphics 630 切換為直通
3. 使用SSH連進ESXi，並輸入`esxcli system settings kernel set -s vga -v FALSE`
4. 在虛擬機選項/高級/編輯設置，添加參數 `hypervisor.cpuid.v0` 為 `FALSE` ，欺騙作業系統不在虛擬機執行
5. 在VM中的PCIE設備添加UHD Graphics 630

### 直通SATA控制器
