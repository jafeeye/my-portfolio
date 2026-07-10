---
title: Scanopy
toc: true
date: 2026-07-10
---
1. 安裝完LXC後，改變IP去設定檔，把public url改掉
```
nano /opt/scanopy/.env
SCANOPY_PUBLIC_URL=http://192.168.10.9:60072
```
2. 產生dameon腳本後,貼去LXC裡面執行就會開始掃
```
root@net:/opt/scanopy# bash -c "$(curl -fsSL https://raw.githubusercontent.com/scanopy/scanopy/refs/heads/main/install.sh)" && sudo scanopy-daemon --server-url http://192.168.10.9:60072 --network-id ce737de8-80db-4957-a1b0-52cb78b94164 --daemon-api-key scp_d_VOCV3RED0wWSTLEURuBjTWvOuQPZDbCc --user-id b1f6c5
```
3. 掃完畫面
![](static/Pasted%20image%2020260710193341.png)
