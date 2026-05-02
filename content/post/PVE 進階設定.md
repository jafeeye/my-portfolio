---
title: PVE 進階設定
date: 2026-02-28
toc: true
---
## 前言
PVE 是目前開源界好用虛擬化系統，但也有超多進階化設定可供調整...



## 使用NVME開機
1. 在VM中Hardware增加PCI Device，勾選ROM-Bar
2. Options中把Boot Order加入hostpci
3. 檢查PVE主機設定檔嵌套式虛擬化為開啟，並把VM上CPU type調整為Host並開啟NUMA即可(用指令或WebUI都可以)
```
cat /sys/module/kvm_intel/parameters/nested   //檢查輸出為Y
qm set <vmid> --cpu host
```


## 驅動安裝
雖然安裝包有提供setup.exe可一鍵安裝，但必須去系統管理員檢查，把有缺的驅動補上

`Etherent` 控制裝置：`/NetKVM/OS類型` : VirtIO Net 網路驅動
PCI 控制器裝置 、`PCI\VEN_1AF4&DEV_1003`：**VirtIO Console Driver** `D:\vioserial\w10\amd64`
大型存放控制器、PCI\VEN_1AF4&DEV_105A：VirtIO Balloon Driver
SCSI 控制器
Virtiofs


- `VEN_1AF4&DEV_1002` or `VEN_1AF4&DEV_1045`, the balloon device.
- `VEN_1AF4&DEV_1003` or `VEN_1AF4&DEV_1043`, the paravirtual serial port device.
- `VEN_1AF4&DEV_1000` or `VEN_1AF4&DEV_1041`, the network device.
- `VEN_1AF4&DEV_1001` or `VEN_1AF4&DEV_1042`, the block device.
- `VEN_1AF4&DEV_1004` or `VEN_1AF4&DEV_1048`, the SCSI block device.
- `VEN_1AF4&DEV_1005` or `VEN_1AF4&DEV_1044`, the entropy source device.
- `VEN_1B36&DEV_0002`, the emulated PCI serial driver.
- `VEN_1B36&DEV_0100`, the video device.
- `VEN_QEMU&DEV_0001`, the guest panic device.

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
- intel vt-d
- amd IOMMU SVM

2. 追加grub
nano /etc/default/grub，在 GRUB_CMDLINE_LINUX_DEFAULT="quiet" 後面打上 `intel_iommu=on iommu=pt initcall_blacklist=sysfb_init pcie_acs_override=downstream`
更新grub
update-grub

3. 增加vfio


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
>GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on pcie_aspm=off acpi=force"


針對nvidia 
/etc/modprobe.d/kvm.conf
```
options kvm ignore_msrs=1 report_ignored_msrs=0
```

重新編譯內核
update-initramfs -u -k all

如果發現VM直通驚嘆號,可能是HDMI欺騙器沒插好也會

6. `VM/Hardwares/Display` 選擇none,關閉虛擬螢幕顯示



## PVE 共享目錄

![](PixPin_2026-04-05_22-57-21.png)


顯卡直通：增加PCI裝置/**所有功能**、 **ROM-Bar** 、 **PCI-Express**、**主要GPU**

> 主要GPU勾選會讓終端不顯示畫面，可以再安裝完驅動再勾

#### Hyper-V 遷移至PVE
1. 將vhdx上傳至PVE目錄，因為UI不能直接傳vhdx，所以使用SFTP上傳
2.  輸入以下指令
```
mkdir /var/lib/vz/hdd
cd /var/lib/vz/hdd
qemu-img convert -O qcow2 WIN10.vhdx vm-103-disk0.qcow2
mv vm-103-disk0.qcow2 /var/lib/vz/images/103/
qm rescan
```
3. BIOS 選擇**OVMF(UEFI)**、**q35**，網路選擇**E1000**
4. 最後要安裝Vitro-win驅動

### PVE 正確刪除節點
#### 離開集群後刪除節點 (離線節點)
```
systemctl stop pve-cluster.service #停止叢集服務
systemctl stop corosync.service #停止叢集服務
pmxcfs -l #將集群系統設置為本地模式
rm /etc/pve/corosync.conf
rm -rf /etc/corosync/*
killall pmxcfs
systemctl start pve-cluster.service #重啟節點服務
#重啟服務後,在資料中心並不會刪除,所以要再刪除節點
cd /etc/pve/nodes
ls
rm -rf /etc/pve/nodes/節點名稱
pvecm delnode
```
####  正常節點
```
cd /etc/pve/nodes/節點名稱
rm -rf ***
pvecm delnode ***
```
#### 叢集設定

PVE HA兩個群集設定
https://youtu.be/TXFYTQKYlno?si=QSdXq5UpXMrB__he



## 建立WS Server 範本
1. 先建立VM,在安裝畫面去找Vitro 驅動使用Vitro iSCSi硬碟，並安裝完WS Server
2. 調整時區以及安裝必要驅動及軟體或更新
3. 執行Sysprep 後關機
4. 轉換成範本



## 把不同虛擬機下硬碟掛載到目前VM
正常的思路是把目前VMID做Detach，然後再把VM硬碟改名成目前使用VM，但對於想暫時掛載不方便，直接使用指令直接掛載

```
qm config 104 | grep disk
# 假設目標是 VM 101，且你要掛載為 scsi1
qm set 147 --scsi1 local:104/vm-104-disk-1.qcow2

```

## 硬碟大小

如果使用qcow+discard+ssd emulation+SCSI 較能隨時回收空間
vmdk qcow 互轉
cd /var/lib/vz/images/147/
qemu-img convert -f vmdk -O qcow2 -c vm-147-disk-0.vmdk vm-147-disk-0.qcow2

縮減磁碟
使用GParted 開機移動磁區
qemu-img resize --shrink vm-147-disk-0.qcow2 160G
qemu-img info 可以檢查真實大小
如果還是沒有壓縮進去Windows能不能做最佳化,不行先修復磁碟錯誤,在最佳化磁碟就會變壓縮下來


## 匯入硬碟
```
qm importdisk 149 /var/lib/vz/images/WIN-8B2EOR9COIE.qcow2 local --format qcow2
```
搬移qcow 至 /var/lib/vz/images/VMID編號  ，qm rescan --vmid 149
硬碟雖然可以不跟預設vm-101.qcow2 但是檔名不能有空白

## 轉換至ESXi
![](PixPin_2026-05-02_00-17-16.png)


## 參考資料
- [BUBU 知識庫 & 秉迅資訊.Studio](https://wiki.freedomstu.com/)
- [第 12 屆 iThome 鐵人賽 DevOps with Proxmox](https://ithelp.ithome.com.tw/2020-12th-ironman)


