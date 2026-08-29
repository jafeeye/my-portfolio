---
title: Solaris
toc: true
---
PVE上安裝
關掉use table point，至少滑鼠不會飄太過去
將硬碟設定SATA

## 安裝步驟
安裝畫面-1
![](static/PixPin_2026-08-23_00-00-43.png)
安裝畫面-2
![](static/PixPin_2026-08-23_00-07-26.png)
安裝畫面-3
![](static/PixPin_2026-08-23_00-24-43.png)


Solaris CDE（Common Desktop Environment）
![](static/Pasted%20image%2020260823095859.png)

從CDE切去JDS
![](static/Pasted%20image%2020260823100158.png)


## 網路
先建議弄成static，DHCP好像會怪怪無法取得IP


## vi
Solaris所使用vi跟現代Linux所用vi不同，現代vi快速鍵高度相容vim，舊的vi有特殊作法
```
先按下 Esc 然後執行以下操作
x     刪除游標目前的字
X     刪除游標左邊的字
dd    刪除整行
D     從游標刪到行尾
i     從游標前開始輸入
a     從游標後開始輸入
A     跳到行尾開始輸入
o     下一行新增一行
u     Undo

```



```
ifconfig e1000g0 192.168.8.50 netmask 255.255.255.0 up
route add default 192.168.8.1
## 檢查
ifconfig e1000g0
ping 192.168.8.1

## 設定hostname
vi /etc/defaultrouter
vi /etc/nodename
```


## ssh
```
mv /etc/dhcp.e1000g0 /etc/dhcp.e1000g0.bak 2>/dev/null
svcadm enable svc:/network/ssh:default
svcadm enable -r svc:/network/ssh:default
svcs network/physical
svcadm restart svc:/network/ssh:default   #重啟ssh服務
svcs ssh                                  #確認目前服務狀態

```
## VNC
```
which vncserver
find /usr -name 'vncserver' -o -name 'Xvnc' 2>/dev/null

vncpasswd
export PATH=$PATH:/usr/openwin/bin
which xauth

```



## 安裝VEN
```
zoneadm list -cv  ## 預設只有global zone，global zone不能修改，需要創另一個zone

zonecfg -z ven-zone    ##建立ven-zone
zonecfg:ven-zone> create
zonecfg:ven-zone> set zonepath=/zones/ven-zone
zonecfg:ven-zone> set ip-type=exclusive
zonecfg:ven-zone> verify
zonecfg:ven-zone> commit
zonecfg:ven-zone> exit

zoneadm list -cv
zoneadm -z ven-zone install
zoneadm -z ven-zone boot
```

在exclusive IP stack等於一個global zone底下有nic跟vnic
```
Proxmox VM
 |
 +-- e1000g0
      |
      Global Zone

 +-- e1000g1
      |
      ven-zone
      ip-type=exclusive
      VEN
```
