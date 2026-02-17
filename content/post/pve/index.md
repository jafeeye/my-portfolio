---
title: PVE 安裝CML
date: 2026-02-17
toc: true
---
### 簡介
新版CML採用Ubuntu 24.10發行版製作，原理是開機先將`cml_2.9.1xx.iso`進行掛載，此時會自動進行安裝程式把cml跟GRUB安裝好，在第二次開機會出現GRUB的CML選單，接續才進行帳號及IP位置初始化設定。  

BIOS：OVMF (UEFI)  
硬碟：EFI Disk (預設大小)、Hard Disk (scsi0)並設定Async IO為native  
CD/DVD (ide0)：cml_2.9.1xx.iso (第一次自動安裝完可以移除)  
CD/DVD (ide1)：refplat-20250616-fcs.iso  

![CML畫面圖](cml0217.png)