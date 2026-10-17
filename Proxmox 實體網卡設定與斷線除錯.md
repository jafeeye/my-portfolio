---
title: Proxmox 實體網卡設定與斷線除錯
toc: true
date: 2026-10-17
---
當大量設備連入PVE主機出現突然主機無法連線，可能是相容性問題
1. 檢查Log檔，發現是 Detected Hardware Unit Hang
```
journalctl -ef 

## 相關log日誌
Oct 17 14:40:15 pve-server kernel: e1000e 0000:00:1f.6 en219v: Detected Hardware Unit Hang:
                                     TDH                  <40>
                                     TDT                  <79>
                                     next_to_use          <79>
                                     next_to_clean        <3f>
                                   buffer_info[next_to_clean]:
                                     time_stamp           <100f8553b>
                                     next_to_watch        <40>
                                     jiffies              <1010282c0>
```
2. 使用 `ethtool` 查詢目前網卡
```
ethtool -i en219v
ethtool -k en219v
```
3. 暫時關閉TSO，重現是否能解決問題
```
## ethtool -K <網卡名稱> tso off
ethtool -K en219v tso off
```

4. 因要下次開機也生效，在 nano`/etc/network/interfaces` 修改設定
```
iface en219v inet manual
        post-up /usr/sbin/ethtool -K en219v tso off
```

