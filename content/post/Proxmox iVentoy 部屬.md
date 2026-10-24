---
title: Proxmox iVentoy 部屬
toc: true
date: 2026-10-24
tags:
  - PVE
  - PXE
---
```toc
```

## iVentoy LXC PXE 部屬
1. 敲入參數
```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/jafeeye/MyScripts/refs/heads/main/iventoy.sh)"
```
2. 參考 [YT影片](https://www.youtube.com/watch?v=TNseK41A0DQ)，使用Advanced 並且輸入`192.168.8.X/24` 自訂成以下參數
![](iventoy260228.png)

3. 重開機後發現iVentoy WEB沒拿到IP，那是因為iVentoy服務比IP啟動的速度還快，要做以下修正
```
## 編輯服務
systemctl edit iventoy.service

[Unit]
Wants=network-online.target
After=network-online.target

[Service]
ExecStartPre=/bin/bash -c 'for i in {1..30}; do ip -4 -o addr show scope global | grep -q "inet " && exit 0; sleep 1; done; exit 1'
ExecStartPre=/bin/sleep 2

##儲存後執行
systemctl daemon-reload
systemctl restart iventoy.service
systemctl status iventoy.service
```

4. 安裝後透過WEB UI 把ISO檔放進去，DHCP選擇ProxyNet 就可以啟動服務
![](iventoyscr260228.png)

5. 可以使用映射內部PVE目錄到 iVentoy LXC 的ISO資料夾，也可以搭配NFS 共享NAS ISO資料夾
```
## 檢查目前pve外部掛載裝置
cat /etc/pve/storage.cfg
pct config <vmid>

## 找掛載路徑
find / -type f -iname "*.iso" 2>/dev/null
find / -type d -iname "iso" 2>/dev/null

## 掛載本機iso區為LXC容器的iventoy 光碟 <PVE路徑><容器裡映射路徑>
pct set 100 -mp0 /var/lib/vz/template/iso,mp=/opt/iventoy/iso
pct set 100 -mp0 /mnt/pve/iso/09-OS,mp=/opt/iventoy/iso
```

> 在Synology 掛載不要重複執行 ln -sf /volume2/Software/09-OS /volume2/Software/template/iso 不然會導致層層掛載

6. 可以看到映射的掛載點
![](static/Pasted%20image%2020261024222313.png)

7. 也可以用成不同網卡做PXE
![](static/Pasted%20image%2020260710162448.png)




## netboot.xyz