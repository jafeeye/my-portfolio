---
title: ESXi 安裝設定
date: 2026-02-19
toc: true
tags:
  - vmware
---
### 取消ESXi 虛擬內存
開機後按`Shift+o` 在cdromBoot runweasel 後面加入`autoPartitionOSDataSize = 4096`  


## 跳過vCenter 記憶體檢查
跳過vCenter Setup介面的硬件檢查[[1]](#_ftn1)

If Your homelab ESX have not sufficient RAM (8 GB for 6.0 and 10 GB for 6.5) is possible to pass hardware check
vCenter 6.0 – run: installer.exe "SKIP_HARDWARE_CHECKS=1"
vCenter 6.5 – edit file:
vcsa-ui-installer\win32\resources\app\resources\layout.json

set:
   "tiny": {
        "cpu": 2,
        "memory": 4096,
        "host-count": 10,
        "vm-count": 100,
        "disk-swap": "25GB",

---

[[1]](#_ftnref1) https://communities.vmware.com/t5/vCenter-Server-Discussions/Not-enough-memory/td-p/2658357


### 內顯直通
UHD 630 直通方法
1. 主機/管理/系統/高級設定，在`VMkernel.Boot.disableACSCheck` 修改為 True，作用為IOMMU強制獨立分組
2. 主機->管理->硬體，UHD Graphics 630 切換為直通
3. 使用SSH連進ESXi，並輸入`esxcli system settings kernel set -s vga -v FALSE`
4. 在虛擬機選項/高級/編輯設置，添加參數 `hypervisor.cpuid.v0` 為 `FALSE` ，欺騙作業系統不在虛擬機執行
5. 在VM中的PCIE設備添加UHD Graphics 630

### 直通SATA控制器


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



