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

`Etherent` 控制裝置：`/NetKVM/OS類型` : VirtIO Net 網路驅動
PCI 控制器裝置 、`PCI\VEN_1AF4&DEV_1003`：**VirtIO Console Driver** `D:\vioserial\w10\amd64`
大型存放控制器、PCI\VEN_1AF4&DEV_105A：VirtIO Balloon Driver
SCSI 控制器
Virtiofs

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
整合NetBox，讓Proxmox可以透過NetBox獲取IP (在Zone的IPAM要選NetBox)
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

## PowerDNS 整合




## 編輯LXC容器檔案





## Olivetin Addons
`find / -name "*olivetin*"`
`systemctl start OliveTin.service`
`sudo systemctl restart OliveTin.service`
`nano /etc/OliveTin/config.yaml`




找到下面路徑
```
root@pve-server:~# find / -name "*olivetin*"
/var/www/olivetin
/var/lib/dpkg/info/olivetin.conffiles
/var/lib/dpkg/info/olivetin.md5sums
/var/lib/dpkg/info/olivetin.list
find: ‘/proc/12645/task/12645/net’: Invalid argument
find: ‘/proc/12645/net’: Invalid argument
```
修改下面資料




### 修改硬碟大小
當範本使用vmdk磁碟，Clone出來的大小為已配額大小，而且vmdk格式使用縮減指令，盡量使用qcow2
當要Shrink虛擬磁碟，需透過指令縮寫指令
```
qemu-img resize --shrink /var/lib/vz/images/148/vm-148-disk-0.qcow2 50G
qm rescan --vmid 148  //重新偵測硬碟大小
```


### 啟用防火牆
1. `Datacenter/Firewall/Option` 選項Firewall切換成Yes
2. `Node/Firewall` 選項Firewall切換成Yes
3. VM選項Firewall切換成Yes
 
### 增加本機額外儲存設備
1. `Node/Disks/Directory` 在Create Directory 可將空磁碟格式化成Ext4 
2. `Datacenter/Storage` 按add/Directory 可以選擇要掛載存放檔案類型 iso、虛擬硬碟等用途
\* ISO檔可以直接掛載NAS 存放區域節省本機空間
## PVE Tools 9
工具地址 `https://github.com/Mapleawaa/PVE-Tools-9`


## 從ESXi 遷移
會有驅動問題，在Windows不能開機就選SATA
![](260404-pve.png)

## P2V
把目前開機的作業系統,使用對應軟體可直接熱轉換
Disk2vhd
StarWind V2V
先不要使用上傳Proxmox功能(9.0.1.848)，不穩定速度慢
![](260404-v2v.png)


## PVE 使用vDSM掛載 iSCSI

1. 先在Node/VM的Hardware 新增一塊 Hard Disk (sata3)
![](Pasted-img-20260406141556.png)
2. 建立儲存集區
![[Pasted-img-20260406142129.png]]
3. 在DSM 硬碟格式化成儲存空間
![[Pasted-img-20260406142351.png]]
4. SAN Manager 建立LUN及Target
![[Pasted-img-20260406142723.png]]

5. Windows 掛載iSCSi，選探索入口輸入Synology IP 位置，按下進階，連線方式跟啟動IP絕對不要用預設值不然會導致逾時無法連線，本機介面卡選ISCSI Inititaor、啟動器IP選擇自己本機電腦位置(有出現多個IP是因為電腦本身有多個網路介面)，如果iSCSI有設定密碼要勾選CHAP登入
![[Pasted-img-20260406143049.png]]
 6. 都設定正確就會在目標自動出現target，按連線即可
![[Pasted-img-20260406143515.png]]




## 顯卡直通

1. 開啟主機板對應功能
intel vt-d
amd IOMMU SVM

2.追加grub
nano /etc/default/grub，在 GRUB_CMDLINE_LINUX_DEFAULT="quiet" 後面打上 `intel_iommu=on iommu=pt initcall_blacklist=sysfb_init pcie_acs_override=downstream`
更新grub
update-grub

3.增加vfio


屏蔽顯卡
nano /etc/modprobe.d/pve-blacklist.conf
```
# nvidia
blacklist nouveau
blacklist nvidia
blacklist nvidiafb
# amd
blacklist amdgpu
blacklist radeon
# intel
blacklist snd_hda_codec_hdmi
blacklist snd_hda_intel
blacklist snd_hda_codec
blacklist snd_hda_core
```

>無法正常關機Deadlock有時是開源驅動對顯卡的 **電源狀態切換 (D3 state)** 記得沒直通需求也要屏蔽nouveau


針對nvidia 
/etc/modprobe.d/kvm.conf
```
options kvm ignore_msrs=1 report_ignored_msrs=0
```

重新編譯內核
update-initramfs -u -k all




## 參考資料
- [BUBU 知識庫 & 秉迅資訊.Studio](https://wiki.freedomstu.com/)
- [第 12 屆 iThome 鐵人賽 DevOps with Proxmox](https://ithelp.ithome.com.tw/2020-12th-ironman)


