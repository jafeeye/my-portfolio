---
title: Proxmox 叢集節點刪除
toc: true
date: 2026-10-18
tags:
  - PVE
---
## 退出節點 (適用叢集只要退一台) 
因為會有`corosync.conf` 同步問題，正確的刪除方法如下，假設有三台Node A,B,C ，要踢掉Node C 
1. 先把Node C 關機 (用意為不送出Corosync 叢集廣播)
2. 在Node A或Node B 其中一台下指令 (A,B其中一台做完設定會自動同步)
```
# 1.先切去看節點名稱並記下
ls -la /etc/pve/nodes/
# 2. 透過官方指令，將C節點的開會投票名單中移除
pvecm delnode C節點名稱 
# 3. 透過官方指令，徹底清除C節點在網頁UI殘留問號資料夾 
rm -rf /etc/pve/nodes/C節點名稱
```
3. Node C重開機，把 Node A與Node A 關機
```
# 停止 C 機器殘留的叢集通訊服務 
systemctl stop corosync.service 
# 刪除舊的通訊錄檔案 
rm -f /etc/pve/corosync.conf
```
## 退出節點 (適用拆掉所有叢集)
1. 前面那個方法適用只退其中一台，如果一次20台退群用下面方法
```
#1. 在20台一次下停止叢集服務 
systemctl stop pve-cluster.service 
systemctl stop corosync.service

#2. 在20台將系統設置為本地模式，刪除corosync
pmxcfs -l  # 強制解鎖成本地模式
rm /etc/pve/corosync.conf
rm -rf /etc/corosync/*
killall pmxcfs

#3. 重啟節點服務
systemctl start pve-cluster.service 

# 4.重啟服務後,在webui並不會刪除,所以要再刪除自己以外節點 (千萬不要刪自己)
ls -la /etc/pve/nodes
rm -rf /etc/pve/nodes/自己以外節點名稱
```

## 叢集設定
如果單純要以一個WebUI 管理把多台機器做叢集，這樣是不好的，光是一個SMB服務就會卡死
PVE HA兩個群集設定
https://youtu.be/TXFYTQKYlno?si=QSdXq5UpXMrB__he