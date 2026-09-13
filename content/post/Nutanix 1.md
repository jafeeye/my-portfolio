---
title: Nutanix 設定
date: 2026-09-12
toc: true
---
## 一、Nutanix 基本安裝
使用單節點安裝，最低需求如下:
- 32GB memory minimum ;
    - I recommend at least 64GB as 32GB will give you no space to run virtual machines;
- 4 CPU Cores minimum;
- 64GB Boot Disk minimum;
- 200GB Hot Tier Disk minimum;
- 500GB Cold Tier Disk minimum.
架構
- Node 1:
    - AHV 10.0.0.81
    - CVM 10.0.0.82
- Netmask 255.0.0.0
- Gateway: 10.0.0.254

調整設備情形

| 類型              | 設定          |
| --------------- | ----------- |
| Processors Type | **Host**    |
| BIOS Type       | **SeaBIOS** |
| Network Type    | e1000       |
|                 | VirtIO SCSI |

1. 編輯`/etc/pve/nodes/<proxmox server name>/qemu-server/<vm id>.conf`，加入`args: -cpu host,+svm`、`serial=<somerandomserial>`
![](static/Pasted%20image%2020260912204148.png)

2. 安裝的時候使用對應方式安裝，第一顆50G當Hypervisor，兩個硬碟200G，C (CVM boot)、D(data)、H(Hypervisor boot)
![](static/Pasted%20image%2020260912204309.png)
3. 進到這個畫面代表安裝完成，按Y重新開機，到開機登入畫面,帳號`root`密碼`nutanix/4u`
![](Pasted%20image%2020260509162455.png)
4. 過10分鐘初始化後直接使用CVM IP 登入畫面,帳號nutanix密碼`nutanix/4u`，執行 `watch genesis status`，確認有看到這兩個服務在跑
![](static/Pasted%20image%2020260912204550.png)

5. 確認之後Ctrl+C 執行 `cluster -s <cvm-ip> --redundancy_factor=1 -dns_servers 1.1.1.1 create` ，如果有三個節點執行 `cluster -s <cvm-ip-node-1>,<cvm-ip-node-2>,<cvm-ip-node-3> –dns_servers 1.1.1.1 create`，出現success代表安裝成功
![](static/Pasted%20image%2020260912204753.png)

6. (可省略)設定叢集名稱及IP 
```
ncli cluster edit-params new-name=CENUC
ncli cluster set-external-ip-address external-ip-address=192.168.8.72
ncli cluster get-name-servers
ncli cluster get-ntp-servers
```

![](Pasted%20image%2020260509170959.png)

7. 登入畫面  `https://<cvm-ip>:9440` 預設帳號及密碼`admin`、 `nutanix/4u`
![](Pasted%20image%2020260509165853.png)




## 二、執行更新
在執行Update之前，必須將LCM Inventory更到最新版
1. SSH 登入任一台 CVM，用genesis status 確認是否服務都起來
2. Prism → Life Cycle Management（LCM）→ Inventory，Perform Inventory
3. 在Updates可以看到更新，可以先執行 NCC Check，結束後再按 View Upgrade Plan
(有[文章](https://www.jeroentielen.nl/upgrade-nutanix-community-edition-to-the-latest-versions/)提到消費級硬體有相容性問題，不要貿然升級)
4. 升級不能一次升，在Updates可以選AOS先升後升AHV，不然會故障，也可以到DirectUpload直接上傳更新包



## 三、相關指令

```
ecli task.list include_completed=false
genesis status # 檢查狀態
genesis restart # 重啟服務管理員

cluster status #檢查叢集
ecli task.list include_completed=false #檢查目前工作狀態
ecli task.get ce19a0c6-ee5d-4d87-4926-2ea308779e84 | grep error #查詢子工作狀態

grep -Ei \
> 'pre.?upgrade|4e508ed9|error|failed|exception|timeout|traceback' \
> /home/nutanix/data/logs/genesis.out | tail -n 200
```



## 四、參考資料
https://www.jeroentielen.nl/upgrade-nutanix-community-edition-to-the-latest-versions/
https://www.jeroentielen.nl/install-nutanix-community-edition-on-proxmox/