---
title: PVE 企業進階設定
date: 2026-02-28
toc: true
---
## 前言
PVE 是目前開源界好用虛擬化系統，但也有超多進階化設定可供調整...



## 啟用NVME開機
1. 在VM中Hardware增加PCI Device，勾選ROM-Bar
2. Options中把Boot Order加入hostpci
3. 檢查PVE主機設定檔嵌套式虛擬化為開啟，並把VM上CPU type調整為Host並開啟NUMA即可(用指令或WebUI都可以)
```
cat /sys/module/kvm_intel/parameters/nested   //檢查輸出為Y
qm set <vmid> --cpu host
```


## 安裝驅動
雖然安裝包有提供setup.exe可一鍵安裝，但必須去系統管理員檢查，把有缺的驅動補上
### VirtIO Net 網路驅動
`Etherent` 控制裝置：`/NetKVM/OS類型`

### 更換 VirtIO SCSI 控制器

### Virtiofs

## SDN 取得IP
目前SDN功能還不穩定，目前版本以8.4.16測試，按圖施工
![](pvesdn20260228.png)

安裝dnsmasq才可在VM自動獲取IP
```
apt install dnsmasq
# disable default instance
systemctl disable --now dnsmasq
# 檢查dnsmasq是否啟用
ps aux | grep dnsmasq
```

## SDN Fabrics
```
apt update
apt install frr frr-pythontools
systemctl enable frr.service
```


## 去虛擬化


## HA功能

## ＯＣＩ功能



## 參考資料
1.　[BUBU 知識庫 & 秉迅資訊.Studio](https://wiki.freedomstu.com/)


