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
企業用戶有提供各虛擬化平台安裝檔，不是企業用戶只提供一般安裝檔


## iVentoy

1.敲入參數
```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/jafeeye/MyScripts/refs/heads/main/iventoy.sh)"
```
2.參考 [YT影片](https://www.youtube.com/watch?v=TNseK41A0DQ)，使用Advanced 並且輸入`192.168.8.X/24` 自訂成以下參數
![](iventoy260228.png)
3.安裝後豋入SCP把ISO檔放進去就可以啟動服務
![](iventoyscr260228.png)


## Windows 7
1. 因為版本或更新問題，實測在32位元 qemu agent 有相容性問題無法安裝，最後vxKex先裝上，再執行先qemu-agent.msi ，跳出priviledge fail到 `C:\Program Files\qemu-ga` 右鍵相容性成W10，再去msi按retry可成功安裝，再去Options啟用 Qemu Guest Agent，安裝完可在管理介面看到IP並控制開關機
![](Pastedimage20260222114258.png)
2. 安裝spice-guest-tool，裝完可以畫面隨Chome視窗放大縮小
3. 啟用noVNC剪貼簿，編輯VM中Hardward/Display，在Clipboard選VNC即會出現對應功能
![](Pastedimage20260222114008.png)





## 參考資料
1. 安裝qemu-agent fail方法：https://forum.proxmox.com/threads/how-to-install-qemu-guest-agent-on-windows7-including-ver7600-7601-sp1-and-also-vista.136016/、提供qemu-ga 安裝vxKex思路：https://blog.qdac.cc/?p=5818
2. pveCLI 提供許多pve特殊教學：https://pvecli.xuan2host.com/proxmox-host-name-change/