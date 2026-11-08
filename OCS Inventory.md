---
title: OCS Inventory
date: 2026-11-08
tags:
---
# OCS Inventory 安裝記錄 Debian

  本篇將以 Debian 系列進行設架服務。

#### **運行環境**

---

本工作室環境都是在 「Proxmox VE 」 虛擬系統上架設，都是以 「 LXC 」模式為主，除非有特殊狀況會告知使用 「 VM 」 模式

- 系統環境： Debian 11、12
- Web 服務： Apache 2.4.61
- PHP 服務： PHP 8.3
- 資料庫服務： MariaDB 10.11

由於 `OCS Inventory` 只能在 `Apache` 服務上運行不能在 `Nginx` ，由於有些服務在 `Nginx` 上是無法運行只能在 `Apache` 上才能運行。

#### **安裝過程**

---
##### **安裝 web 服務**
  
- 安裝 `Apache` 服務
sudo apt -y install apache2
- 安裝完之後啟用 `Apache` 服務
sudo systemctl enable --now apache2

##### **安裝資料庫**