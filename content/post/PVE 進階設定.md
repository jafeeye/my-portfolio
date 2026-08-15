---
title: PVE 進階設定
date: 2026-02-28
toc: true
---
## 前言
PVE 是目前開源界好用虛擬化系統，但也有超多進階化設定可供調整...


## 優化: PVE 調整Swap
預設PVE沒調整狀態下為60
```
## 強制清除目前所有高swap
swapoff -a && swapon -a
## 查看目前swap狀態,預設沒調整為60
cat /proc/sys/vm/swappiness
## 臨時關閉swap為0
sysctl vm.swappiness=0
## 永久調整,swap都為0
nano /etc/sysctl.conf >> vm.swappiness=0
```
- [排障笔记-解决PVE中节点SWAP占用过高问题&一些关于PVE宿主硬盘的题外话](https://blog.welain.com/articles/2023/notes-about-pve/)

## 優化: E1000斷線問題
通常再過一段時間網站PVE入口連不上或ESXi插拔網線後連不上，通常是驅動問題導致
除錯顯示log

```
journalctl -b -1 -e 
journalctl --until "2026-02-27 11:00:00" -n 100 -r
```

發現這條，懷疑是驅動出現 `Detected Hardware Unit Hang`，關閉電源休眠可解決問題
`Feb 27 15:25:25 pve-server kernel: e1000e 0000:00:1f.6 eno1: NIC Link is Up 1000 Mbps Full Duplex, Flow`

```
# 關閉卸載功能 Hardware Unit Hang
ethtool -K enx00e01c680083 tso off gso off 
ethtool -K eno1 tso off gso off 
# 重新啟動網卡服務 
systemctl restart networking
```

Proxmox 重啟後 `ethtool` 的設定會消失，請編輯網路設定檔：
1. 在 `iface eno1 inet manual` 下方增加一行： `post-up /usr/sbin/ethtool -K eno1 tso off gso off`

## 優化: 刪除local-lvm
```
lvremove pve/data
lvextend -l +100%FREE -r pve/root
```

## 優化: 固定網卡名稱

实现方案(pve9)

| **網卡名稱範例**          | **命名類型**     | **實際代表的硬體意義**            | **常見出現場景**          |
| ------------------- | ------------ | ------------------------ | ------------------- |
| **`eno1`**          | 板載 (Onboard) | 主機板內建的有線網卡               | 實體伺服器、PC 主機板原生網口    |
| **`ens18`**         | 插槽 (Slot)    | 虛擬或實體熱插拔插槽第 18 號         | **PVE 虛擬機 (VM) 內部** |
| **`enp1s0`**        | 匯流排 (PCIe)   | PCIe Bus 1, Slot 0 的實體網卡 | 實體機補插的獨立網卡、擴充卡      |
| **`nic0` / `eth0`** | 自訂 / 傳統      | 人為綁定 MAC 或老舊核心隨機分配       | 經維運優化後的環境、老舊 Linux  |
注意：在 Proxmox VE 9（基于 Debian 13）中，固定网卡名称的方式与 PVE 8（基于 Debian 12）有所不同，主要是因为 Debian 13 对 udev 规则的处理逻辑做了调整，传统的 70-persistent-net.rules 方式可能不再生效。
在 PVE 9 中，推荐通过 systemd 的 .link 配置文件 来固定网卡名称，这是更现代且兼容的方式。
步骤如下：
1. 找出需要固定的网卡 MAC 地址
```
$ ip addr
2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master vmbr0 state UP group default qlen 1000
link/ether 04:d4:c4:57:af:9d brd ff:ff:ff:ff:ff:ff
```
2. 创建 .link 配置文件`vi /etc/systemd/network/10-static-en219v.link` 内容为
```
[Match] 
MACAddress=04:d4:c4:57:af:9d
[Link] 
Name=en219v
```
3. 修改 vmbr0 的配置
因为一般都是远程操作，为了安全起见，重命名前后的两个网卡名字都加入到 vmbr0，以防万一出错时无法连接管理网络：`nano /etc/network/interfaces`内容为：

目前对设备名称使用以下命名约定：

- 以太网设备：en*，systemd 网络接口名称。此命名方案用于自版本 5.0 以来的新 Proxmox VE 安装。
- 以太网设备：eth[N]，其中 0 ≤ N （eth0， eth1， …）此命名方案用于在5.0版本之前安装的Proxmox VE主机。升级到 5.0 时，名称将保持原样。
- 网桥名称：vmbr[N]，其中 0 ≤ N ≤ 4094 （vmbr0 - vmbr4094）
- bond：bond[N]，其中 0 ≤ N （bond0， bond1， …）
- VLAN：只需将 VLAN 编号添加到设备名称中，用句点分隔（eno1.50、bond1.30）

```
iface en219v inet manual
iface eno1 inet manual

auto vmbr0
iface vmbr0 inet static
       ......
       bridge-ports eno1 en219v

```

4. 更新`update-initramfs -u -k all` 重启`reboot`之后查看网卡名称发现已经固定：
```
$ ip addr 
2: en100g1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master vmbr0 state UP group default qlen 1000 link/ether 8c:3a:8e:88:7d:5a brd ff:ff:ff:ff:ff:ff altname enx8c2a8e886d5a
```
5. 修复 vmbr0 的 bridge-ports，把改名之前的网卡名字去掉。
对于只有多个网卡的情况，操作要复杂一下，主要是需要区分是哪些网卡。如我这里有一台机器上有 100g 和 25g 两块双头网卡， 提供四个网口，其中 100g 网卡提供两个网口，25g 网卡提供两个网口。需要通过下面两个命令找出哪些网卡是 100g 网卡，哪些网卡是 25g 网卡， 记录好 mac 地址，然后再逐个网口进行操作：
```
ip addr
lspci | grep Ethernet

vi /etc/systemd/network/10-static-en25g1.link
vi /etc/systemd/network/10-static-en25g2.link
vi /etc/systemd/network/10-static-en100g1.link
vi /etc/systemd/network/10-static-en100g2.link

```


## USB 網卡優化設定

想在不插網卡下加增加速度，方式是bridge 一張USB網卡，因為USB網卡也會有斷線問題，解決方式為一樣關閉休眠功能

```
auto lo
iface lo inet loopback

iface nic0 inet manual

auto vmbr0
iface vmbr0 inet static
        address 192.168.8.90/24
        gateway 192.168.8.1
        bridge-ports nic0 enx00e01c680083
        bridge-stp off
        bridge-fd 0
        post-up /usr/sbin/ethtool -K enx00e01c680083 tso off gso off

iface nic1 inet manual
source /etc/network/interfaces.d/*
```

- bridge-ports nic0 enx00e01c680083 //bridge到enx00e01c680083這張USB網卡
- post-up /usr/sbin/ethtool -K enx00e01c680083 tso off gso off  //關閉休眠功能


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

## 網路
### SDN取得IP
1. 先在Node的Shell 安裝dnsmasq，才能在IPAM正常發DHCP，並且安裝完停用dnsmasq服務 ，PVE會啟動專屬實例。
```
apt install dnsmasq
# disable default instance
systemctl disable --now dnsmasq
# 檢查dnsmasq是否啟用
ps aux | grep dnsmasq
```
2. 目前SDN功能還算測試階段，在此按圖新增一個vnet
![](pvesdn20260228.png)

3. 在VM或LXC網路選擇vnet，當在虛擬機內有順利取得IP即完成
4. 在環境中實際是分配 `192.168.8.0/24` ，IPAM分配 `192.168.10.0/24`，如果想讓外面.8網段的設備順利連入.10網段，需做以下任一設定
	- Windows 加入路由表 
	`route -p add 192.168.10.0 mask 255.255.255.0 192.168.8.14`
	`route print`
	- 路由器加入路由表
5. 現在PVE內部雖然不同網段虛擬機可以互通，但是遇到自訂iptables規則，客製化NAT規則要開啟流量轉發
```
# 檢查PVE封包轉發
cat /proc/sys/net/ipv4/ip_forward
# 開啟PVE封包轉發
sysctl -w net.ipv4.ip_forward=1
# 永久化
vi /etc/sysctl.conf 中加入 net.ipv4.ip_forward=1
```

### SDN取得DNS+cloud-init

1. 編輯 `nano /etc/pve/sdn/subnets.cfg`
```
subnet: local-192.168.10.0-24 
        vnet vnet0 
        dhcp-range start-address=192.168.10.150,end-address=192.168.10.250 
        gateway 192.168.10.1 
        snat 1
        dhcp-dns-server 192.168.10.123 
        reversednszone 10.168.192.in-addr.arpa.
```
2. 重啟SDN服務 `pvesh set /cluster/sdn`

https://qiita.com/marokiki/items/38195892d0b1775c2385#%E3%83%86%E3%83%B3%E3%83%97%E3%83%AC%E3%83%BC%E3%83%88%E3%82%92%E7%94%A8%E3%81%84%E3%81%9Fvm%E3%81%AE%E4%BD%9C%E6%88%90

### SDN Fabrics
```
apt update
apt install frr frr-pythontools
systemctl enable frr.service
```

### OPNSense + 切Vlan
1. Node/System/Network 在橋接網口開啟vlan aware
2. 建立VM那邊vlan填上設定的數值

### PVE網口設定
在banner會放上IP位置是從檔案去改的 nano /etc/issue
修改主機ip
1. nano /etc/network/interfaces
2. nano /etc/hosts
![](static/default-network-setup-bridge.svg)
如果硬碟拔去新機器，無法進入畫面去檢查 `/etc/network/interfaces` ，裡面的vmbr0 的bridge port 是不是指派成新機器的網孔，因為新的機器被指成eno1，再去下ifup vmbr0即可

在一般安裝時,PVE只會綁定安裝時的網孔做管理孔,在一般裝況下多網口的機器一定只能有一個管理口,不然會導致網路風暴,如果想暫時綁定多網口可以都登入PVE,可以這樣做
預設PVE給一個橋接網口vmbr0, bridge port 為目前管理孔
nano /etc/network/interfaces
```
auto lo iface lo inet loopback 
iface enp1s0 inet manual 
iface enp2s0 inet manual 
iface enp3s0 inet manual 
auto vmbr0 
iface vmbr0 inet static 
address 192.168.1.100/24 
gateway 192.168.1.1 
bridge-ports enp1s0 enp2s0 enp3s0 # 把本機三個孔都綁進來 
bridge-stp on # 關鍵：開啟 STP,不然會網路風暴
bridge-fd 2
```
也可以指定不同vmbr 其他Ip 這樣就是雙管理口

```
auto lo
iface lo inet loopback

auto nic0
iface nic0 inet manual
auto nic1
iface nic1 inet manual
auto nic2
iface nic2 inet manual
auto nic3
iface nic3 inet manual
iface wlp4s0 inet manual

auto vmbr0
iface vmbr0 inet static
        address 192.168.1.5/24
        gateway 192.168.1.1
        bridge-ports nic2
        bridge-stp on

auto vmbr1
iface vmbr1 inet manual
        address 192.168.8.49/24
        gateway 192.168.8.1
        bridge-ports nic1
        bridge-stp off
        bridge-fd 0

source /etc/network/interfaces.d/*
```

關閉USB網卡 tso gso `post-up /usr/sbin/ethtool -K enx00e01c680083 tso off gso`
![](Pasted%20image%2020260524123306.png)

修改 hosts
![](Pasted%20image%2020260524125131.png)


### BOND

### OSPF

### 網路路由
![](static/default-network-setup-routed.svg)

```
种常见情况是，你有一个公共 IP（在本例中假定为 198.51.100.5），以及一个用于 VM 的额外 IP 块 （203.0.113.16/28）。对于此类情况，我们建议进行以下设置：

auto lo
iface lo inet loopback

auto eno0
iface eno0 inet static
        address  198.51.100.5/29
        gateway  198.51.100.1
        post-up echo 1 > /proc/sys/net/ipv4/ip_forward
        post-up echo 1 > /proc/sys/net/ipv4/conf/eno0/proxy_arp


auto vmbr0
iface vmbr0 inet static
        address  203.0.113.17/28
        bridge-ports none
        bridge-stp off
        bridge-fd 0

```

### OpenVSwtch

https://www.zenwen.tw/proxmox-network-config-ovs-and-sdn/

## 去虛擬化


## HA功能

## OCI功能
![](Pasted%20image%2020260524123542.png)
目前功能還是有缺陷
- **映像相容性**：非完整 OS 映像無法產生系統容器，需自行包裝或選擇更完整的映像 (Proxmox 官方說明)。
- **init 系統缺失**：應用容器無 init，若需使用 systemd 等服務管理，必須手動安裝或改用系統容器。
- **網路與存儲設定**：OCI 映像不包含 Proxmox 的網路或存儲設定，必須在容器建立後手動調整。
- **安全設定**：在 9.1 版本中，OCI 容器仍缺少完整的 AppArmor 或 SELinux 支援，容器內部的安全策略需自行配置。
- **性能差異**：LXC 直接使用 OCI 映像時，若映像體積過大，容器啟動時間可能延長；此外，某些映像使用的壓縮格式不受 LXC 支援，導致解壓失敗。
```
# 下載並安裝最新 pveam pveam update # 直接拉取 OCI 映像 pveam add lxc --from-oci docker.io/library/redis:7.2 # 建立容器實例 pct create 100 /var/lib/vz/template/cache/lxc/redis-7.2.tar.gz --rootfs local-lvm:10 --net0 name=eth0,bridge=vmbr0,ip=dhcp

```

## ceph


## LXC
### 編輯LXC容器檔案

### 建立LXC容器
1. 這邊使用PromCenter 示範
![](Pasted%20image%2020260519205443.png)
2. apt update && apt install -y curl
3. apt update && apt install -y sudo
4. curl -fsSL https://proxcenter.io/install/community | bash
5. 加入 API,Privilege Separation打勾取消
 ![](Pasted%20image%2020260519210337.png)

### 修改LXC設定
nano /etc/pve/lxc
```
lxc.cgroup2.devices.allow: c 10:232 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file 0 0
lxc.mount.entry: /dev/kvm dev/kvm none bind,create=file 0 0
lxc.cgroup.devices.allow: c 10:200 rwm # for compatibility
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/vhost-net dev/vhost-net none bind,create=file 0 0
lxc.apparmor.profile: unconfined
lxc.cap.drop:
------如果要加入共享核顯要加以下代碼--------
lxc.cgroup2.devices.allow: c 226:0 rwm
lxc.cgroup2.devices.allow: c 226:128 rwm
lxc.cgroup2.devices.allow: c 29:0 rwm
lxc.mount.entry: /dev/dri/card0 dev/dri/card0 none bind,optional,create=file
lxc.mount.entry: /dev/dri/renderD128 dev/dri/renderD128 none bind,optional,create=file
```

### LXC 設定
nesting=1 # 啟用容器嵌套,可在裡面跑docker


## Addons: Olivetin 
找到下面路徑修改下面資料
```
root@pve-server:~# find / -name "*olivetin*"
/var/www/olivetin
/var/lib/dpkg/info/olivetin.conffiles
/var/lib/dpkg/info/olivetin.md5sums
/var/lib/dpkg/info/olivetin.list
find: ‘/proc/12645/task/12645/net’: Invalid argument
find: ‘/proc/12645/net’: Invalid argument

systemctl start OliveTin.service
sudo systemctl restart OliveTin.service
nano /etc/OliveTin/config.yaml
```

無法登入可能是Datacenter的防火牆打開,LXC預設沒通過防火牆規則


## Addons : MicroVM
```
curl -sLO $(curl -s https://api.github.com/repos/rcarmo/pve-microvm/releases/latest | grep browser_download_url | grep '.deb' | cut -d'"' -f4)
dpkg -i pve-microvm_*.deb
```
![](static/Pasted%20image%2020260711232519.png)

## 硬碟修改
### 匯入VM硬碟
```
qm importdisk <VMID> <虛擬機硬碟檔> <匯入位置> --format <格式> 
qm importdisk 149 /var/lib/vz/images/WIN-8B2EOR9COIE.qcow2 local --format qcow2
```
搬移qcow 至 /var/lib/vz/images/VMID編號  ，qm rescan --vmid 149
硬碟雖然可以不跟預設vm-101.qcow2 但是檔名不能有空白

### 修改VM硬碟大小
當範本使用vmdk磁碟，Clone出來的大小為已配額大小，而且vmdk格式使用縮減指令，盡量使用qcow2
當要Shrink虛擬磁碟，需透過指令縮寫指令
```
qemu-img resize --shrink /var/lib/vz/images/148/vm-148-disk-0.qcow2 50G
qm rescan --vmid 148  //重新偵測硬碟大小
```


### 轉換VM硬碟

如果使用qcow+discard+ssd emulation+SCSI 較能隨時回收空間
vmdk qcow 互轉
cd /var/lib/vz/images/147/
qemu-img convert -f vmdk -O qcow2 -c vm-147-disk-0.vmdk vm-147-disk-0.qcow2

縮減磁碟
使用GParted 開機移動磁區
qemu-img resize --shrink vm-147-disk-0.qcow2 160G
qemu-img info 可以檢查真實大小
如果還是沒有壓縮進去Windows能不能做最佳化,不行先修復磁碟錯誤,在最佳化磁碟就會變壓縮下來

WEBGUI/Move disk 可以做轉換格式動作
![](Pasted%20image%2020260530180758.png)

## LVM 擴容處理
常用幾種格式
LVM:放光碟檔及一些不重要檔案，大概切16 GB ~ 32 GB
LVM-thin:跑VM核心，剩下全部都給他
Zfs-pool

Vda：ioblock 
![](Pasted%20image%2020260530181126.png)

刪除Local-LVM (適用軟路由)
預設PVE的儲存路徑如下，LVM 與LVM-Thin 預設是不一樣儲存區
- **`local` (Directory 檔案系統)：** 專門用來放 ISO 鏡像、LXC 範本、備份檔（Backup），它的實體路徑在 Debian 的 `/var/lib/vz`。
- **`local-lvm` (LVM-Thin 區塊儲存)：** 專門用來分配給虛擬機或容器當作硬碟（也就是你剛才砍掉的那個空間）。
但其實有小技巧可以將兩個空間合併，這樣local才可以取回原本local-Lvm的容量
```
vgs
## 將自由空間「全數塞給」根目錄（pve-root）
lvextend -l +100%FREE /dev/pve/root
## 重整檔案系統
resize2fs /dev/pve/root
```


系統合併Local-lvm後又要差分LVM分區
1. 因為整塊硬碟都是Ext4了，所以要使用GParted進入命令列
2. 輸入命令列
```
1.檢查磁碟狀態
df -Th /
pvs
lvs 
vgs
vgscan 
vgchange -ay 

$lvs
LV   VG  Attr       LSize
root pve -wi-a----- <944.87g
swap pve -wi-a-----    8.00g

#確保分區沒被掛載，不然資料會損毀
$mount | grep pve-root
#檢查檔案系統有無問題
e2fsck -f /dev/pve/root
#縮小Ext4檔案系統
resize2fs /dev/pve/root 250G
#縮小LV (這邊為255g)
lvreduce -L 255G /dev/pve/root
#保險對齊一次檔案系統

```
3. LVM-Thin Pool 建立
```
#看出目前剩餘空間

$vgs
VG  #PV #LV #SN Attr   VSize    VFree
pve   1   2   0 wz--n- <952.87g <689.87g

#建立LVM-Thin
$lvcreate -l 100%FREE --thinpool pve/data

#看現在系統所有lvs
$lvs
LV   VG  Attr       LSize    Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
data pve twi-a-tz-- <689.70g             0.00   10.42
root pve -wi-ao----  255.00g
swap pve -wi-ao----    8.00g
```
4. 把剛剛創立的lvs掛載上去就完成LVM-thin建立
![](static/Pasted%20image%2020260718223625.png)

## 啟用防火牆
1. `Datacenter/Firewall/Option` 選項Firewall切換成Yes
2. `Node/Firewall` 選項Firewall切換成Yes
3. VM選項Firewall切換成Yes
 

## 增加本機額外儲存設備
1. `Node/Disks/Directory` 在Create Directory 可將空磁碟格式化成Ext4 
2. `Datacenter/Storage` 按add/Directory 可以選擇要掛載存放檔案類型 iso、虛擬硬碟等用途
\* ISO檔可以直接掛載NAS 存放區域節省本機空間

## PVE Tools 9
工具地址 `https://github.com/Mapleawaa/PVE-Tools-9`


## 遷移: 從ESXi 
會有驅動問題，在Windows不能開機就選SATA
![](260404-pve.png)

## 遷移: P2V
1. 把目前開機的作業系統,使用對應軟體可直接熱轉換
- Disk2vhd
- StarWind V2V
2. 先不要使用上傳Proxmox功能(9.0.1.848)，不穩定速度慢
![](260404-v2v.png)

## 遷移: Migrate
在PDM刪除Local-LVM 還是有辦法進行遷移，無法遷移是因為小版本號不一致，盡量保持不同台版本一致
最大影響快照在CT 模式做不了
- 403 Permission check failed (changing feature flags (except nesting) is only allowed for root@pam)：LXC 打開 `features: nesting=1,keyctl=1`
![](static/Pasted%20image%2020260711175052.png)
如果之前刪除local-LVM會導致無法移轉raw硬碟檔去local分區，解決方法是創一個local-LVM分區或是重新Resign把硬碟轉成qcow

## 遷移: 轉換至ESXi
![](PixPin_2026-05-02_00-17-16.png)


## 不同虛擬機下硬碟掛載到目前VM
正常的思路是把目前VMID做Detach，然後再把VM硬碟改名成目前使用VM，但對於想暫時掛載不方便，直接使用指令直接掛載

```
qm config 104 | grep disk
# 假設目標是 VM 101，且你要掛載為 scsi1
qm set 147 --scsi1 local:104/vm-104-disk-1.qcow2

```

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








## 直通技術
SR-IOV：Intel主機板晶片做出限制，必須Server主板才能啟用，目的讓直通的設備能多VM共享使用，目前11代Intel核顯已經可以使用此技術

ACS Patch
Iommu group
Gvt-g
Io-pathrough
ASUS BIOS 可開啟項目
Iommu group
SR-IOV
VT-d
進階/VMX
Advanced/System Agent(SA)/VT-d
PCH-FW Configuration/PTT，PTT Enable
AMD RESET BUG

使用SPICE 虛擬視窗+noVNC不偏移安裝方法[https://pvecli.xuan2host.com/spice-novnc/](https://pvecli.xuan2host.com/spice-novnc/)

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

## 顯卡直通

1. 開啟主機板對應功能
- intel vt-d
- amd IOMMU SVM

2. 追加grub
nano /etc/default/grub，在 GRUB_CMDLINE_LINUX_DEFAULT="quiet" 後面打上 `intel_iommu=on iommu=pt initcall_blacklist=sysfb_init pcie_acs_override=downstream`

- intel_iommu 和 amd_iommu=on 為開啟IOMMU
- video=vesafb:off video=efifb:off 不載入 vesafb 是 veas設備 的 fb ，efifb 是指 uefi設備 的 fb ，在 PVE 7.3 之後版本用initcall_blacklist=sysfb_init 替代（來源於PVE 7.3 優化和顯卡直通）
- pcie_acs_override=downstream 是為了將 iommu groups拆分，方便直通一些板載的設備（來源於加強硬體直通的功能）

2. 更新grub
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

## 正確刪除節點
因為會有`corosync.conf` 同步問題，正確的刪除方法如下，假設有三台Node A,B,C ，要踢掉Node C (**此方法適用只退一台**)
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
3. Node C重開機 (要真的安全就把Node A跟B 都先關了)
```
# 停止 C 機器殘留的叢集通訊服務 
systemctl stop corosync.service 
# 刪除舊的通訊錄檔案 
rm -f /etc/pve/corosync.conf
```
## 全部退出節點
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



## 建立WS Server 範本
1. 先建立VM,在安裝畫面去找Vitro 驅動使用Vitro iSCSi硬碟，並安裝完WS Server
2. 調整時區以及安裝必要驅動及軟體或更新
3. 執行Sysprep 後關機
4. 轉換成範本



## 安裝Ｗin11
一定要選UEFI 才能安裝
登入Shift+F10 start ms-cxh:localonly

## LXC 安裝cockit開啟共享

```
#安裝Cockpit
apt install cockpit -y
#安裝File Sharing之前需要的東西
apt install samba make curl unzip -y
#下載 
curl -LO https://github.com/45Drives/cockpit-file-sharing/releases/download/v3.2.0/cockpit-file-sharing_3.2.0_generic.zip
#解壓縮
unzip cockpit-file-sharing_3.2.0_generic.zip
#進入資料夾
cd cockpit-file-sharing_3.2.0_generic
#安裝
make install
#停用root登入
/etc/cockpit/disallowed-users
# 選用安裝cockpit-identities
https://github.com/45drives/cockpit-identities
```
![](Pasted%20image%2020260514224035.png)
## 參考資料
- [BUBU 知識庫 & 秉迅資訊.Studio](https://wiki.freedomstu.com/)
- [第 12 屆 iThome 鐵人賽 DevOps with Proxmox](https://ithelp.ithome.com.tw/2020-12th-ironman)


lspci -vv | grep BAR


## 救援PVE
如果SSD面臨Read-Only無法快掛前兆,可使用隨身碟進行快速救援
1. 使用Paragon Disk Manager或類似軟體把隨身碟格式化成EXT4
2. 插入PVE掛載
- 重要路徑
	- /var/lib/vz/template/
	- /var/lib/vz/images/
	- /etc/pve/qemu-server/
	- /etc/pve/lxc/
```
lsblk   //偵測掛載區(這邊是偵測到,但掛載還要下指令)
mount -t ext4 /dev/sdb1 /run  //把隨身碟掛載到run上
// 救援檔案
cp /etc/pve/qemu-server/*.conf /run/
cp /etc/pve/lxc/*.conf /run/

umount /run

```
3. 重新匯入,匯入`/var/lib/vz/images/` 的相關LXC跟VM硬碟檔,最後再匯入conf檔即可出現虛擬機
```
cp -r /run/images  /var/lib/vz/
cp *.conf /etc/pve/nodes/hp-pve/lxc/
root@hp-pve:/# cp *.conf /etc/pve/nodes/hp-pve/qemu-server/
```

4. 如果出現錯誤修復硬碟(lxc118為例)
```
lxc-start -n 118 -F -lDEBUG -o /tmp/lxc-118-debug.log
tail -n 50 /tmp/lxc-118-debug.log
pct stop 118
losetup -fP /var/lib/vz/images/118/vm-118-disk-0.raw
losetup -a
fsck -y /dev/loop0
losetup -d /dev/loop0
```

5. Migration會因為LXC容器預設會放去local-lvm，搬移的時候要去選
因此要手動scp把檔案般回原位即可，LXC硬碟的rootfs檔又會有指派問題，直接去改 `nano /etc/pve/lxc/118.conf` 比較快

![](Pasted%20image%2020260530172644.png)

開機磁區被GRUB改名字 (initramfs：發生兩塊硬碟都安裝PVE情形)
- **`Found volume group "pve-OLD-3001C008" ... 2 logical volume(s) now active`** （系統成功抓到了 LVM 磁碟群組，但它的名字叫 `pve-OLD-3001C008`）
- **`ALERT! /dev/mapper/pve-root does not exist. Dropping to a shell!`** （系統崩潰大喊：我找不到當初寫死在引導設定檔裡的 `/dev/mapper/pve-root`！）
```
lvm vgrename pve-OLD-3001C008 pve
lvm vgchange -ay pve
exit
```


## 模擬非x86 machines
https://forum.proxmox.com/threads/qemu-for-proxmox-pve-qemu-with-all-supported-kvm-and-emulated-cpus-debug-and-release-dep-builds-available.66486/
https://www.nicksherlock.com/2024/09/emulating-mips-guests-in-proxmox-8/



## 使用xterm.js
- CT容器預設開箱即用，不用特別做設定
VM做法 [官網說明文件](https://pve.proxmox.com/wiki/Serial_Terminal)
1. qm set 101 -serial0 socket
2. 編輯grub，加入下面這串，做`update-grub` 或`grub2-mkconfig --output=/boot/grub2/grub.cfg`
`GRUB_CMDLINE_LINUX="quiet console=tty0 console=ttyS0,115200"`

## 更新PVE
免費版作法
![](static/Pasted%20image%2020260712124046.png)
```
# 讓系統用新軟體源刷新清單，並用 pveupgrade 啟動升級
apt-get update
pveupgrade
```

無訂閱源比企業源更新還快


## PVE 高 io delay
籌劃提供診斷命令與結果解讀方法。以下是實際排查步驟,照順序做下去就能抓出問題出在哪:
1. 先看整體 IO Delay 走勢
```bash
top
```
看右上角 `%wa`(wait)這欄,或用:
```bash
sar -u 1 5
```
確認目前 IO delay 是持續高還是偶發尖峰(例如備份時才會飆高)。
2. 查是哪顆實體磁碟在拖慢
```bash
iostat -x 1
```
重點看:
- **`%util`**:接近 100% 表示這顆碟已經滿載
- **`await`**:平均等待時間(ms),數字越大越慢。HDD 正常約在 10ms 內,SSD/NVMe 應該在 1ms 以內,超過 20-50ms 就有問題
- **`r/s` `w/s`**:每秒讀寫次數,配合 `%util` 看是不是硬碟被操爆

3. 檢查磁碟健康狀態
```bash
smartctl -a /dev/sdX
```
重點看:
- `Reallocated_Sector_Ct`(重新配置磁區數,越多代表硬碟開始壞了)
- `Current_Pending_Sector`
- SSD 的話看 `Media_Wearout_Indicator` 或 `Percentage Used`(NVMe)
4. 如果是用 ZFS
```bash
zpool iostat -v 1
zpool status
arc_summary | head -30
```

- `zpool status` 看有沒有 DEGRADED 或 resilvering 中
- `arc_summary` 看 ARC 命中率(Hit % 太低代表記憶體不夠)

5.如果是 Ceph
```bash
ceph -s
ceph osd perf
```

看 `ceph osd perf` 裡每個 OSD 的 `apply_latency` / `commit_latency`,異常高的那顆 OSD 就是兇手。

### 6. 確認是不是備份工作造成的
```bash
cat /var/log/pve/tasks/index | grep vzdump
```

或直接看 PVE 網頁介面的 Tasks 紀錄,對照 IO delay 飆高的時間點是否吻合。
### 7. 檢查是否有大量 Swap 使用
```bash
free -h
vmstat 1
```

`si` `so` 欄位(swap in/out)如果持續非 0,代表記憶體不足導致額外磁碟 IO。

**建議做法**:先跑 `iostat -x 1 10`,把結果貼給我(或截圖),我可以幫你直接判讀是哪顆磁碟、哪個環節出問題。
Analyzed storage migration from directory-based to ZFS pools
現在配置很清楚了。你有 **`local`(dir 類型)** 儲存,以及兩個 **ZFS pool 儲存**(`local_images`、`rpool-2`)可用。問題是這 19 個 VM/CT 全部都存在 `local` 這個 dir 儲存上,用 raw 檔案 + loop device 的方式運作,而你其實已經有 ZFS pool 可以用區塊裝置(zvol)的方式跑,效能會好很多。

### 先確認實體磁碟現況
```bash
iostat -x 1 5
zpool status
zpool list
df -h /var/lib/vz
```

這樣可以確認:

1. `local`(dir)背後掛的實體磁碟是什麼、目前 `%util`/`await` 多高
2. `local_images` 和 `rpool-2` 這兩個 ZFS pool 是不是用不同的實體磁碟(如果是,遷移過去才有意義;如果 `local` 跟 ZFS pool 其實共用同一組實體磁碟,那遷移只能減少 loop device 開銷,底層磁碟瓶頸還是存在)

### 解法方向(確認磁碟資訊後可以動手做)

**把這些 VM/CT 的磁碟從 `local` 搬到 `local_images` 或 `rpool-2`**,這樣會變成 ZFS zvol(區塊裝置),不再需要 loop device。

- **VM**:在 PVE 網頁介面 → 選 VM → Hardware → 選中磁碟 → **Disk Action → Move Storage**,選目標為 `local_images` 或 `rpool-2`,可以線上不關機做(前提是原本磁碟格式支援)
- **CT**:同樣在 Resources 裡選 rootfs → **Volume Action → Move Storage**

也可以用指令批次做,例如:

bash

```bash
qm move-disk <VMID> scsi0 local_images
# 或 CT:
pct move-volume <CTID> rootfs local_images
```

由於你有 19 個要搬,建議先搬 1-2 個測試效果,確認 IO delay 有沒有下降,再決定要不要全部搬,同時要注意搬移過程本身會消耗 IO,建議挑離峰時間、一個一個慢慢搬,不要同時搬多個。

先麻煩貼一下上面那幾個指令的結果,我再幫你確認底層磁碟狀況跟遷移的優先順序。

root@isbdtester03:~# zpool list NAME SIZE ALLOC FREE CKPOINT EXPANDSZ FRAG CAP DEDUP HEALTH ALTROOT rpool-2 928G 18.6G 909G - - 10% 2% 1.00x ONLINE -

Investigated missing storage pool and plotted diagnostic strategy

看起來 `local_images` 這個 pool 在這台 `isbdtester03` 上並不存在(storage.cfg 裡它是設定給 `nodes: isbdtester` 這個節點用的,不是 `isbdtester03`),所以你這台機器目前只有 **`rpool-2`**(928G,只用了 18.6G)可以用,而且看起來空間還很充裕。

這代表:你這台機器上有一個幾乎全空的 ZFS pool(`rpool-2`),卻沒有拿來用,19 個 VM/CT 全部擠在 `local`(dir,raw+loop)上運作 — 這基本上就是問題的核心。

### 還需要確認的資訊

麻煩貼一下:

bash

```bash
zpool status rpool-2
iostat -x 1 5
df -h /var/lib/vz
```

想確認:

1. `rpool-2` 背後是什麼硬碟(HDD/SSD/NVMe),以及是不是跟 `/var/lib/vz`(local)所在的磁碟是**不同一組實體硬碟**
2. 目前 `iostat` 顯示哪顆磁碟 `%util` 最高、`await` 最誇張

如果 `rpool-2` 跟 `local` 是接在不同實體硬碟上,那把這 19 個 VM 搬去 `rpool-2` 會有立竿見影的效果 —— 既去掉了 loop device 開銷,又把負載分散到目前幾乎閒置的磁碟上。

這樣說起來 我在家裡刪除local-lvm 把ct容器放在local 裡面跑是不是也會發生這個問題

分析了刪除本地儲存後仍會遭遇相同問題。

是的,會發生一模一樣的問題,而且原理完全相同。

### 為什麼會這樣

`local-lvm` 是 **LVM-thin**,幫每個 CT/VM 分配獨立的 **Logical Volume(LV)**,LV 本質上就是一個區塊裝置,容器可以直接掛載使用,不需要額外轉一層。

如果改成把 CT 放在 `local`(dir 類型儲存),PVE 對 CT 的處理方式是:

1. 在 `/var/lib/vz/images/<CTID>/` 底下建立一個 **`.raw` 檔案**當作這個容器的磁碟映像
2. 因為容器需要「掛載」一個檔案系統才能跑,而 `.raw` 檔案本身只是普通檔案,不能直接掛載
3. 所以 PVE 會透過 **loop device** 把這個 raw 檔案「包裝」成一個假的區塊裝置,再掛載給容器用

這樣就會多一層開銷:「容器 IO → 檔案系統 → loop device 轉換 → 底層檔案系統 → 實體磁碟」,比起 LVM-thin 的「容器 IO → LV(區塊裝置)→ 實體磁碟」多繞了一大圈。

### 影響程度

- 如果只有 1-2 個 CT,可能感覺不明顯
- 但只要 CT 數量一多(像你這台伺服器有 19 個),loop device 的管理開銷(`kworker/u*:*+loopN` 那種核心執行緒)就會疊加起來,IO delay 就會明顯竄升,跟你現在遇到的狀況一樣

### 建議

家裡如果也打算跑多個 CT,建議:

- **保留 LVM-thin**(不要刪),或
- 改用 **ZFS**(建立一個 zfspool 儲存,CT 磁碟會變成 zvol,一樣是區塊裝置,沒有 loop device 問題)

只要是能提供「區塊裝置」的儲存類型(LVM-thin、ZFS zvol、Ceph RBD),CT 都不會用到 loop device;只要是 `dir` 類型(檔案系統目錄)存 CT 的 raw 磁碟,就一定會有 loop device 開銷。VM 的話因為 QEMU 本身就是用檔案模擬磁碟(不透過 loop device),所以 VM 放 `dir` 存 raw 檔案不會有這個問題,只有 CT 才會受影響。

