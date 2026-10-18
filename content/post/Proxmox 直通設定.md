---
title: Proxmox 直通設定
toc: true
date: 2026-10-18
tags:
  - PVE
  - 直通
---
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