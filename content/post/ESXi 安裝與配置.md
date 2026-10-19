---
title: ESXi 安裝與配置
date: 2026-02-19
toc: true
tags:
  - vmware
  - 虛擬化
---
RVTools：好用Windows管理ESXi虛擬機軟體
PowerCLI：Windows管理ESXi虛擬機命令列
## 常用指令
```
esxcfg-nics -l   //檢查所有網孔
```
### 取消ESXi 虛擬內存
開機後按`Shift+o` 在cdromBoot runweasel 後面加入`autoPartitionOSDataSize = 4096`  

## 跳過vCenter 記憶體檢查
跳過vCenter Setup介面的硬件檢查[[1]](#_ftn1)

If Your homelab ESX have not sufficient RAM (8 GB for 6.0 and 10 GB for 6.5) is possible to pass hardware check
vCenter 6.0 – run: installer.exe "SKIP_HARDWARE_CHECKS=1"
vCenter 6.5 – edit file:
vcsa-ui-installer\win32\resources\app\resources\layout.json
```
set:
   "tiny": {
        "cpu": 2,
        "memory": 4096,
        "host-count": 10,
        "vm-count": 100,
        "disk-swap": "25GB",
```

---

[[1]](#_ftnref1) https://communities.vmware.com/t5/vCenter-Server-Discussions/Not-enough-memory/td-p/2658357


## 直通設定
### 直通內顯
UHD 630 直通方法
1. 主機/管理/系統/高級設定，在`VMkernel.Boot.disableACSCheck` 修改為 True，作用為IOMMU強制獨立分組
2. 主機->管理->硬體，UHD Graphics 630 切換為直通
3. 使用SSH連進ESXi，並輸入`esxcli system settings kernel set -s vga -v FALSE`
4. 在虛擬機選項/高級/編輯設置，添加參數 `hypervisor.cpuid.v0` 為 `FALSE` ，欺騙作業系統不在虛擬機執行
5. 在VM中的PCIE設備添加UHD Graphics 630

### 直通SATA控制器
```
lspci -v | grep "Class 0106" -B 1
## 填入以下資訊
vi /etc/vmware/passthru.map
#Intel Corporation Lynx Point AHCI Controller
8086 31e3 d3d0 false

## 重開機即可
```


### 直通RDM硬碟
1. 儲存區/裝置，可以看到目前的外部硬碟與SSD，這邊先從名稱點進去，記錄第二塊硬碟名稱複製`Local ATA Disk (t10.ATA_____WDC_WD5000AACS2D00ZUB0________________________WD2DWCASU2603567)` 括弧裡面名稱
![](static/Pasted%20image%2020260718173909.png)
2. 進入ESXi Shell輸入指令
```
vmkfstools -z /vmfs/devices/disks/t10.ATA_____WDC_WD5000AACS2D00ZUB0________________________WD2DWCASU260
3567 /vmfs/volumes/datastore1/wd500g_rdm.vmdk
```
3. 把這個 `wd500g_rdm.vmdk` 加入虛擬機即可
![](static/Pasted%20image%2020260718174428.png)
## 常用指令
```
# esxcli vm process list #獲取正在運行的虛擬機器的資訊
# esxcli vm process kill --type=hard --world-id=245735 #關閉虛擬機器
```


## 自動關機
在esxi的shell命令列中不支援cron命令，只能修改計畫任務（/var/spool/crontab/root），但由於這個檔每次重啟後會被自動重置，所以我們需要設置開機自動向計畫任務檔裡添加定時關機，將腳本放在vmfs/volumes/datastore1/不會被重置目錄裡

1.我們需要修改（/etc/rc.local.d/local.sh)，在**exit 0這一行之前**添加如下的腳本，使其每次開機都自動添加定時任務。
```
#关闭cron进程（关闭进程后修改计划任务root文件）
/bin/kill $(cat /var/run/crond.pid)

#向/var/spool/crontab/root里添加关闭虚拟机、关机的计划任务
/bin/echo '40 13 * * * /vmfs/volumes/datastore1/vm-shutdown.sh' >> /var/spool/cron/crontabs/root[[1]](#_ftn1)
/bin/echo '45 13 * * * /vmfs/volumes/datastore1/esxi-shutdown.sh' >> /var/spool/cron/crontabs/root

#重启cron进程（将加载修改后的root文件）
/usr/lib/vmware/busybox/bin/busybox crond
```

2.由於/etc/rc.local.d/local.sh檔重啟後會丟失，所以需要手動執行一次下面的命令。（local.sh檔每次更改後想要永久保存設置的話，就需要手動執行一次。）
`/sbin/auto-backup.sh`

3.先透過執行vim-cmd vmsvc/getallvms獲取需關機VM，後vi /vmfs/volumes/datastore1/vm-shutdown.sh填入以下內容
```
#!/bin/sh
#关闭虚拟机(有安装VMware tools的虚拟机使用power.shutdown,没有的就只能使用power.off来进行强制关机。)
vim-cmd vmsvc/power.shutdown 2
vim-cmd vmsvc/power.shutdown 3
vim-cmd vmsvc/power.shutdown 4
vim-cmd vmsvc/power.off 5
```

4.vi /vmfs/volumes/datastore1/esxi-shutdown.sh 填入以下內容
```
#!/bin/sh
#关闭esxi主机电源
/sbin/poweroff
```

5.將兩個腳本增加可執行權限[[1]](#_ftn1)
```
chmod +x /vmfs/volumes/datastore1/vm-shutdown.sh
chmod +x /vmfs/volumes/datastore1/esxi-shutdown.sh
```

最後重啟ESXi，執行cat /var/spool/cron/crontabs/root，出現腳本即完成
![](Pasted%20image%2020260506222806.png)
  

---

[[1]](#_ftnref1) Linux檔案的基本權限就有九個，分別是owner/group/others三種身份各有自己的read/write/execute權限，chmod +x為可執行、chmod 777全部可以rwx
40 13 、45 13 處表示任務執行時間，格式為[分] [時] [日] [月份] [星期]，由於esxi的系統時間採用的是UTC時間（國際標準時間），而中國是UTC+8，所以想要在北京時間22:40時關閉虛擬機器的話，就只需要用22-8算出UTC時間為14，任務執行時間填寫為40 14 、45 14 就可以了。


## 斷線除錯
實際案例遇到i219v當拔除超過5分鐘後就無法再連線，根據排除因為i219v是消費級晶片,第一思路關閉自動協商調整成1000Mbps失效，第二關閉EEE省電模組寫死在驅動，雖然ESXi 可以使用但是社群版驅動`ne1000` ，BIOS也找不到可以關閉EEE選項，只好直接放棄ESXi

```
esxcli network nic tso set -n vmnic0 -e 0
```
持久化設定
/etc/rc.local.d/local.sh 在exit0 之前加入下面這條
```
esxcli network nic tso set -n vmnic0 -e 0
```
重開機生效
```
/sbin/auto-backup.sh
```

ESXI 7升8
![[Pasted image 20260321174801.png]]


## 嵌套式虛擬化
在vSphere 編輯設定／虛擬設定／向客體作業系統公開硬體協助虛擬化或在ESXi編輯 vmx為vhv.enable = "TRUE"　

![484](static/Pasted%20image%2020261012224004.png)

## 網路關係
![475](static/mermaid-diagram.png)

| 名稱                     | 是什麼                        | 用途                                    |
| ---------------------- | -------------------------- | ------------------------------------- |
| **vmnic0**             | ESXi 主機的實體網卡               | 連接外部實體網路                              |
| **vSwitch0**           | 虛擬交換器                      | 在 VM、ESXi 介面與實體網卡之間轉送封包               |
| **VM Network**         | 給 VM 使用的 Port Group（連接埠群組） | VM 網卡選這個，就接到對應的虛擬網路                   |
| **Management Network** | 給管理介面使用的 Port Group        | 承載 ESXi 管理流量                          |
| **vmk0**               | VMkernel 網路介面              | ESXi 的管理 IP 通常設在這裡，例如 `192.168.8.100` |

| 設定                               | 設成 Reject（拒絕）                                | 設成 Accept（接受）                  |
| -------------------------------- | -------------------------------------------- | ------------------------------ |
| **混雜模式** Promiscuous Mode        | VM 通常只收到發給自己 MAC 的封包，以及適用的廣播／多播              | 允許 VM 收到該虛擬網路中原本不是發給自己 MAC 的封包 |
| **MAC 位址變更** MAC Address Changes | 客體 OS 將網卡 MAC 改成與 VMware 設定不同時，阻止送到新 MAC 的流量 | 允許送到變更後 MAC 的流量                |
| **偽造傳輸** Forged Transmits        | 送出的封包，來源 MAC 與網卡目前有效 MAC 不同時，丟棄封包            | 允許送出來源 MAC 不同的封包               |

## VMware VCSA 8 修改主机名和重置证书
## 第一步使用 VAMI 界面修改域名

### [](https://songxwn.com/vcsa8-resetCA/#%E6%AD%A5%E9%AA%A4%EF%BC%9A "步骤：")步骤：

1. **登录 VAMI 管理界面（VCSA后台）**
    
    |   |
    |---|
    |https://<vcsa-ip>:5480|
    
    使用 root 账户登录
    
2. **导航到网络设置**
    
    - 点击左侧菜单 **“Networking”** 或 **“网络”**
    - 选择 **“Edit”** 或 **“编辑”**
3. **修改主机名**
    
    - 在 **“Hostname”** 字段输入新的 FQDN
    - 保存更改
4. **重启服务**
    
    |   |
    |---|
    |service-control --stop --all  <br>service-control --start --all|
    

## [](https://songxwn.com/vcsa8-resetCA/#%E7%AC%AC%E4%BA%8C%E6%AD%A5%EF%BC%9A%E9%87%8D%E7%BD%AE%E8%AF%81%E4%B9%A6 "第二步：重置证书")第二步：重置证书

### [](https://songxwn.com/vcsa8-resetCA/#%E6%AD%A5%E9%AA%A4%EF%BC%9A-1 "步骤：")步骤：

0. **登录 VAMI 管理界面（VCSA后台）**

开启SSH，bash等服务。

1. **SSH 登录到 vCSA**
    
    |   |
    |---|
    |ssh root@<vcsa-ip>|
    
2. **启用 Bash Shell**
    
    |   |
    |---|
    |shell|
    
3. **修改主机名 - 确保老的域名已删除**
    
    |   |
    |---|
    |# 设置新主机名  <br>hostnamectl set-hostname <new-hostname.domain.com>  <br>  <br># 验证修改  <br>hostnamectl|
    
4. **更新 /etc/hosts 文件**
    
    |   |
    |---|
    |vi /etc/hosts|
    
    确保包含：
    
    |   |
    |---|
    |<IP地址>  <new-hostname.domain.com>  <new-hostname>|
    
5. **重新生成证书（如果需要，或证书过期）**
    
    |   |
    |---|
    |/usr/lib/vmware-vmca/bin/certificate-manager|
    
    选择选项 8（Reset all Certificates）- 注意过程中要求输入IP和FQDN 得是VCSA的。
    
6. **重启所有服务 - 可选**
    
    |   |
    |---|
    |service-control --stop --all  <br>service-control --start --all|
    

## [](https://songxwn.com/vcsa8-resetCA/#%E9%87%8D%E8%A6%81%E6%B3%A8%E6%84%8F%E4%BA%8B%E9%A1%B9 "重要注意事项")重要注意事项

⚠️ **修改前必须做：**

1. **完整备份**
    
    - 使用文件级备份或快照
    - 备份数据库
2. **DNS 记录更新**
    
    - 在 DNS 服务器上更新 A 记录和 PTR 记录
    - 确保正向和反向解析都正确
3. **证书考虑**
    
    - 如果使用自定义证书，需要重新申请
    - 默认证书需要重新生成
4. **检查依赖关系**
    
    - vCenter HA 配置
    - 外部 PSC（如果有）
    - 已集成的解决方案（vROps, vRLI 等）

## [](https://songxwn.com/vcsa8-resetCA/#%E9%AA%8C%E8%AF%81%E6%AD%A5%E9%AA%A4 "验证步骤")验证步骤

|   |
|---|
|# 检查主机名  <br>hostname  <br>hostname -f  <br>  <br># 检查 DNS 解析  <br>nslookup <new-hostname>  <br>  <br># 检查服务状态  <br>service-control --status --all  <br>  <br># 检查 vCenter 服务  <br>vmon-cli --list --all|

## [](https://songxwn.com/vcsa8-resetCA/#%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98 "常见问题")常见问题

**Q: 是否需要重启 vCSA？**  
A: 不需要完全重启，重启服务即可

**Q: 会影响虚拟机吗？**  
A: 不会，但管理功能会短暂中断

**Q: 许可证需要重新激活吗？**  
A: 不需要