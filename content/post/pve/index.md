---
title: PVE 安裝CML ESXi
date: 2026-02-17
toc: true
---
## CML
### 簡介
新版CML採用Ubuntu 24.10發行版製作，原理是開機先將`cml_2.9.1xx.iso`進行掛載，此時會自動進行安裝程式把cml跟GRUB安裝好，在第二次開機會出現GRUB的CML選單，接續才進行帳號及IP位置初始化設定。  

BIOS：OVMF (UEFI)  
硬碟：EFI Disk (預設大小)、Hard Disk (scsi0)100G，並設定Async IO為native  
CD/DVD (ide0)：cml_2.9.1xx.iso (第一次自動安裝完可以移除)  
CD/DVD (ide1)：refplat-20250616-fcs.iso  

![CML](cml0217.png)<span style="display:none">.</span>


## Nested ESXi
### 簡介
安裝嵌套式ESXi，要在PVE中啟用**Enable NUMA**，才能進入使用畫面

| 類型              | 設定                       |
| --------------- | ------------------------ |
| Processors Type | **Host**、**Enable NUMA** |
| BIOS Type       | **SeaBIOS**              |
| Network Type    | **VMware vmxnet3**       |

## GNS3
| 類型              | 設定          |
| --------------- | ----------- |
| Processors Type | **Host**    |
| BIOS Type       | **SeaBIOS** |
| Network Type    | VirtIO      |
| Disk            | Not add     |

1.在 [Github](https://github.com/GNS3/gns3-gui/releases/) 下載 `GNS3.VM.KVM.3.x.x.zip`，並使用scp把檔案上傳至`/var/lib/vz/images`，因為qcow2在proxmox無法直接使用，需匯入指令

```
qm importdisk <vmid> <path/xxxx.qcow2> <storage>
qm importdisk 134 /var/lib/vz/images/GNS3_VM-disk001.qcow2 local
qm importdisk 134 /var/lib/vz/images/GNS3_VM-disk002.qcow2 local
rm -rf /var/lib/vz/images/GNS3_VM-disk00x.qcow2
```

2.匯入成功後出現unused disk，按edit在BUS/Device選擇Virto Block，再按add完成
![pvesct0217.png](pvesct0217.png)

3.在Option把 Boot Order中把硬碟打勾並移動開機順序才能開機
![pvesr260217.png](pvesr260217.png)

## VyOS


### 啟用NVME開機
1. 在VM中Hardware增加PCI Device，勾選ROM-Bar
2. Options中把Boot Order加入hostpci
3. 檢查PVE主機設定檔嵌套式虛擬化為開啟，並把VM上CPU type調整為Host並開啟NUMA即可(用指令或WebUI都可以)
```
cat /sys/module/kvm_intel/parameters/nested   //檢查輸出為Y
qm set <vmid> --cpu host
```