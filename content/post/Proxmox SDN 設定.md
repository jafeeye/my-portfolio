---
title: Proxmox SDN 設定
toc: true
date: 2026-10-24
tags:
  - PVE
  - SDN
---
查看Zone 區 `cat /etc/pve/sdn/vnets.cfg`
```
root@pve:~# cat /etc/pve/sdn/vnets.cfg
vnet: vnet
        zone simpzone
```

2. 先查詢這個目錄下有哪些cfg設定等於vnet10
```
grep -Rns 'bridge=vnet10' /etc/pve/lxc /etc/pve/qemu-server

#內容	  用法
grep	搜尋文字
-R	遞迴搜尋指定目錄中的檔案
-n	顯示符合內容位於第幾行
-s	隱藏無法讀取或檔案不存在等錯誤
'bridge=vnet10'	要搜尋的文字
/etc/pve/lxc	LXC 容器設定檔目錄
/etc/pve/qemu-server	QEMU/KVM 虛擬機設定檔目錄
```

3. 批次取代
```bash
grep -rl 'bridge=vnet10' /etc/pve/lxc /etc/pve/qemu-server |
while IFS= read -r file; do
    echo "修改：$file"
    sed -i 's/bridge=vnet10\([,[:space:]]\)/bridge=vent\1/g' "$file"
done
```
