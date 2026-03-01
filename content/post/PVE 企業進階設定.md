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

PVE主機是`192.168.8.80` 環境是使用`192.168.8.0/24`，要把VM 用SDN分配成 `192.168.10.0/24`，但又希望8.x網段可以連去10.x網段，要開啟路由表功能
```
# 檢查PVE封包轉發
cat /proc/sys/net/ipv4/ip_forward
# 開啟PVE封包轉發
sysctl -w net.ipv4.ip_forward=1
# 永久化
vi /etc/sysctl.conf 中加入 net.ipv4.ip_forward=1
```

- Windows 加入路由表 `route -p add 192.168.10.0 mask 255.255.255.0 192.168.8.80`
- 路由器加入路由表
## SDN Fabrics
```
apt update
apt install frr frr-pythontools
systemctl enable frr.service
```
## 去虛擬化


## HA功能

## OCI功能

## ceph


## NetBox API 整合
整合NetBox，讓Proxmox在獲取IP可以透過IPAM
1. 打開NetBox，輸入token
![](netbox01260301.png)

2. 因為API要使用SSL連線，必須把憑證匯入PVE信任憑證，
```
openssl s_client -showcerts -connect 192.168.8.128:443 </dev/null 2>/dev/null | openssl x509 -outform PEM > /usr/local/share/ca-certificates/netbox.crt
#更新系統信任清單
update-ca-certificates
```
3. 憑證匯入後加入API出現hotsname錯誤，代表PVE認可憑證，不過IP位置憑證內登記的名字（可能是 `netbox.example.com`）跟 IP 對不起來，直接在PVE查看 fingerprint 
![](netbox260301.png)
```
openssl x509 -in /usr/local/share/ca-certificates/netbox.crt -noout -fingerprint -sha256
```
4. 直接填入API位置 `https://192.168.8.x/api` ，並且填入FingerPrint跟token完成
![](pvenetbox260301.png)

## 參考資料
1.　[BUBU 知識庫 & 秉迅資訊.Studio](https://wiki.freedomstu.com/)


