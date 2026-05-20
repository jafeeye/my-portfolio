---
title: PVE 安裝各系統 ESXi CML ..
date: 2026-02-17
toc: true
---
## CML
### 簡介
新版CML採用Ubuntu 24.10發行版製作，原理是開機先將`cml_2.9.1xx.iso`進行掛載，此時會自動進行安裝程式把cml跟GRUB安裝好，在第二次開機會出現GRUB的CML選單，接續才進行帳號及IP位置初始化設定。 會一起安裝cookpit port為9090，可透過這邊設定一些選項


BIOS：OVMF (UEFI)  
硬碟：EFI Disk (預設大小)、Hard Disk (scsi0)100G，並設定Async IO為native  
CD/DVD (ide0)：cml_2.9.1xx.iso (第一次自動安裝完可以移除)  
CD/DVD (ide1)：refplat-20250616-fcs.iso  
在安裝時使用了固定IP,但因為用了IPAM,這邊就給他自動取得


![CML](static/cml0217.png)<span style="display:none">.</span>


## Nested ESXi
### 簡介
先確認PVE系統設定檔
```
cat /etc/modprobe.d/kvm-intel.conf
options kvm-intel nested=Y  //Intel開啟嵌套虛擬化
options kvm ignore_msrs=y  //Intel開啟嵌套虛擬化
options kvm-amd nested=Y ept=Y //amd開啟嵌套虛擬化
```
安裝嵌套式ESXi，要在PVE中啟用**Enable NUMA**，才能進入使用畫面  

| 類型                  | 設定                       | 說明                                                                      |
| ------------------- | ------------------------ | ----------------------------------------------------------------------- |
| Processors Type     | **Host**、**Enable NUMA** |                                                                         |
| BIOS Type           | **SeaBIOS**              |                                                                         |
| Network Type        | **VMware vmxnet3**       |                                                                         |
| **Guest OS**        | Linux,6.x - 2.6 Kernel   |                                                                         |
| **SCSI Controller** | VMware PVSCSI            |                                                                         |
| **Bus/Device**      | SATA                     | - Ensure you’re using SATA controller for the disk (not SCSI or VirtIO) |
| **Discard**         | Checked                  |                                                                         |


## EVE-NG
最小大小為50G，但為擴充開機磁碟設定為100G
Vitro SCSI Single

1. 先放入iso檔後，安裝檔會進行cloud-init自動化安裝後重開機，第一次開機要先登入帳號密碼進行下一步安裝設定，帳號/密碼為 `root/eve`，登入後會到藍色畫面做初始化設定，再重開機就可以看到ip
![](260308-eveng.png)
2. 進入網頁後登入初始密碼 `admin/eve`，此時再進行帳號設定
![](260308-evengui.png)



## Harvester
| Option                   | Required Value   |
| ------------------------ | ---------------- |
| OS Type                  | `Other OS Types` |
| CPU Type                 | `Host`           |
| Network Type (Harvester) | `e1000`          |


## Nutanix
| 類型              | 設定          |
| --------------- | ----------- |
| Processors Type | **Host**    |
| BIOS Type       | **SeaBIOS** |
| Network Type    | e1000       |
|                 | VirtIO SCSI |


1. 安裝單節點要有3顆硬碟,分別200G指派C (CVM boot)、D(data)，還有一顆50G指派H(Hypervisor boot)，RAM 要26G,不然到最後會安裝失敗,再來會到hypervisor installation in progress 會比較久需要等一下
![](Pasted%20image%2020260509142345.png)
2. 進到這個畫面代表安裝完成
![](Pasted%20image%2020260509162455.png)
3. 安裝完後在重開機,進入登入畫面,帳號`root`密碼`nutanix/4u`
![](Pasted%20image%2020260509142535.png)
4. 然後等10幾分鐘元件在背景安裝完成後,使用ssh 登入192.168.8.71 ,帳號nutanix 密碼`nutanix/4u` ,輸入以下指令
```
cluster status 
cluster -s 192.168.8.71 --redundancy_factor=1 create
```
![](Pasted%20image%2020260509142822.png)
6. 出現success代表安裝成功
![](Pasted%20image%2020260509170115.png)
7. 設定叢集名稱及IP
```
ncli cluster edit-params new-name=CENUC
ncli cluster set-external-ip-address external-ip-address=192.168.8.72
ncli cluster get-name-servers
ncli cluster get-ntp-servers
```

![](Pasted%20image%2020260509170959.png)

8. 登入畫面  `https://192.168.8.71:9440/` 預設帳號及密碼`admin`、 `nutanix/4u`
![](Pasted%20image%2020260509165853.png)


## Xen Orchestra


## Rancher


## OpenShift

官網詳細SNO安裝文件 https://docs.okd.io/4.20/installing/installing_sno/install-sno-installing-sno.html
1.先加3筆DNS 的A紀錄,然後在linux反查是不是正確
```
dig +short api.okd.tutoriallabcluster.lan
dig +short api-int.okd.tutoriallabcluster.lan
dig +short console-openshift-console.apps.okd.tutoriallabcluster.lan
```
2.安裝podman
3.執行下面指令

```
$ OKD_VERSION=<okd_version>
$ export ARCH=<architecture>
$ export HOST_ARCH=$(uname -m)
$ curl -L https://github.com/okd-project/okd/releases/download/$OKD_VERSION/openshift-client-linux-$OKD_VERSION.tar.gz -o oc.tar.gz
$ tar zxf oc.tar.gz
$ chmod +x oc
```

[How to deploy SNO OKD / Openshift ](https://www.youtube.com/watch?v=TcN6EJVduwk)

## GNS3
| 類型              | 設定          |
| --------------- | ----------- |
| Processors Type | **Host**    |
| BIOS Type       | **SeaBIOS** |
| Network Type    | VirtIO      |
| Disk            | Not add     |

1.在 [Github](https://github.com/GNS3/gns3-gui/releases/) 下載 `GNS3.VM.KVM.3.x.x.zip` 用scp把檔案上傳至`/var/lib/vz/images/<vmid>`，可以使用qm scan 直接掃出檔案或qm importdisk (會重新轉檔)匯入
qm scan
```
qm rescan --vmid <vmid>
```

qm importdisk
```
qm importdisk <vmid> <path/xxxx.qcow2> <storage>
qm importdisk 134 /var/lib/vz/images/GNS3_VM-disk001.qcow2 local
qm importdisk 134 /var/lib/vz/images/GNS3_VM-disk002.qcow2 local
rm -rf /var/lib/vz/images/GNS3_VM-disk00x.qcow2
```

2.匯入成功後出現unused disk，按edit在BUS/Device選擇Virto Block，再按add完成
![pvesct0217.png](static/pvesct0217.png)

3.在Option把 Boot Order中把硬碟打勾並移動開機順序才能開機
![pvesr260217.png](static/pvesr260217.png)

## VyOS
企業用戶有提供各虛擬化平台安裝檔，不是企業用戶只提供一般安裝檔


## Windows 7
1. 因為版本或更新問題，實測在32位元 qemu agent 有相容性問題無法安裝，最後vxKex先裝上，再執行先qemu-agent.msi ，跳出priviledge fail到 `C:\Program Files\qemu-ga` 右鍵相容性成W10，再去msi按retry可成功安裝，再去Options啟用 Qemu Guest Agent，安裝完可在管理介面看到IP並控制開關機
![](Pastedimage20260222114258.png)
2. 安裝spice-guest-tool，裝完可以畫面隨Chome視窗放大縮小
3. 啟用noVNC剪貼簿，編輯VM中Hardward/Display，在Clipboard選VNC即會出現對應功能
![](Pastedimage20260222114008.png)


## iVentoy LXC

1.敲入參數
```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/jafeeye/MyScripts/refs/heads/main/iventoy.sh)"
```
2.參考 [YT影片](https://www.youtube.com/watch?v=TNseK41A0DQ)，使用Advanced 並且輸入`192.168.8.X/24` 自訂成以下參數
![](iventoy260228.png)
3.安裝後豋入SCP把ISO檔放進去就可以啟動服務
![](iventoyscr260228.png)


## Gitlab LXC

![](260308-gitlab.png)



## VDSM LXC
1. 執行LXC腳本,設定容器權限
- bash -c "$(wget -qLO - https://raw.githubusercontent.com/databreach/virtual-dsm-lxc/main/virtual-dsm-lxc-gpu.sh)"
- Enter the LXC Container ID of the container created above (e.g. `101`).
- Enter the GPU / vGPU card ID (e.g. for card1 you would enter `1`).
- Enter the GPU / vGPU renderD ID (e.g. for renderD129 you would enter `129`).

2. Install Docker and run virtual-dsm
- Start the LXC Container created above and login to its console via the Proxmox UI or SSH.
- Install sudo、curl、Docker 
  `apt update && apt install -y curl sudo`
  `curl -fsSL https://get.docker.com -o get-docker.sh`
- Run virtual-dsm in docker using the mount points created: `docker run -it --rm -p 5000:5000 --cap-add NET_ADMIN --device-cgroup-rule='c *:* rwm' --sysctl net.ipv4.ip_forward=1 --device /dev/net/tun --device /dev/kvm --device /dev/vhost-net --device /dev/dri --stop-timeout 60 -v /vdsm/storage1:/storage -v /vdsm/storage2:/storage2 -e CPU_CORES=2 -e RAM_SIZE=4096M -e DISK_SIZE=16G -e DISK2_SIZE=2T -e DISK_FMT=qcow2 -e ALLOCATE=N -e GPU=Y vdsm/virtual-dsm:latest`
### Edits
- Replaced `-e ALLOCATE=N` with new disk feature `-e DISK_FMT=qcow2`.
- Re-added `-e ALLOCATE=N` to be used in combination with qcow2.
- Removed obsolete `DEV=N` parameter.

Docker套娃，設定群暉Docker服務
```shell
vi /var/packages/ContainerManager/etc/dockerd.json
systemctl daemon-reload
systemctl restart pkg-ContainerManager-dockerd
```


https://github.com/vdsm/virtual-dsm/issues/382
參考影片：https://www.youtube.com/watch?v=LKZKsyZULYM




## 參考資料
1. 安裝qemu-agent fail方法：https://forum.proxmox.com/threads/how-to-install-qemu-guest-agent-on-windows7-including-ver7600-7601-sp1-and-also-vista.136016/、提供qemu-ga 安裝vxKex思路：https://blog.qdac.cc/?p=5818
2. pveCLI 提供許多pve特殊教學：https://pvecli.xuan2host.com/proxmox-host-name-change/