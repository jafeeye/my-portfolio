---
title: Proxmox 實體網卡設定與斷線除錯
toc: true
date: 2026-10-17
tags:
  - PVE
---

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

修改 hosts
![](Pasted%20image%2020260524125131.png)



## 固定網卡名稱

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


## 斷線除錯
當大量設備連入PVE主機出現突然主機無法連線，可能是相容性問題，USB網卡也會有斷線問題，針對這些問題都是關閉休眠功能

1. 檢查Log檔，發現是 Detected Hardware Unit Hang
```
journalctl -ef 

journalctl -b -1 -e 
journalctl --until "2026-02-27 11:00:00" -n 100 -r
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

4. 因要下次開機也生效， nano`/etc/network/interfaces` 修改設定，在iface en219v inet manual 下面直接加入一行
```
iface en219v inet manual
        post-up /usr/sbin/ethtool -K en219v tso off
```

完整範例
```
auto lo
iface lo inet loopback
iface enp5s0 inet manual
iface enp4s0 inet manual
iface eno1 inet manual
iface en219v inet manual
        post-up /usr/sbin/ethtool -K en219v tso off gso off
auto vmbr0
iface vmbr0 inet static
        address 192.168.8.14/24
        gateway 192.168.8.1
        bridge-ports eno1 en219v
        bridge-stp off
        bridge-fd 0
        bridge-vlan-aware yes
        bridge-vids 2-4094
        
auto vmbr1
iface vmbr1 inet static
        address 192.168.4.3/24
        bridge-ports none
        bridge-stp off
        bridge-fd 0

auto vlan0
iface vlan0 inet manual
        vlan-raw-device eno1

source /etc/network/interfaces.d/*
```

5. 重啟網路服務 systemctl restart networking

關閉USB網卡 tso gso `post-up /usr/sbin/ethtool -K enx00e01c680083 tso off gso`
![](Pasted%20image%2020260524123306.png)
