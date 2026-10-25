---
title: Proxmox SoftGPU
toc: true
date: 2026-10-18
tags:
  - PVE
---
### win98驅動
- Patcher9X：cpu过快报错补丁
- Patchmem：4GB内存补丁
- xhci98
- vbemp：普通BIOS顯卡任意驅動

參考文章
- [在2025年的实体机上装win98！](https://www.bilibili.com/opus/1017743026828607510) 



## SoftGPU 安裝

第一階段：在 Proxmox VE 建立正確的虛擬機

請注意，**千萬不要使用 PCIe 直通（Passthrough）**。我們必須建立一個標準的古老硬體環境，讓 PVE 宿主機在後台驅動 B580，而虛擬機則負責「模擬」相容規格。

1. 建立虛擬機（Create VM）的關鍵設定：
- **General（一般）**：
    - VM ID 與名稱隨意（例如：`Win98-Retro`）。
- **OS（作業系統）**：
    - 選擇您的 Windows 98 SE 安裝 ISO 映像檔。
    - Type 選擇 **`Other`**。
- **System（系統）**：
    - **Machine（機器）**：務必選擇 **`pc-i440fx-X.X`**（預設通常是這個，千萬不要選 Q35）。
    - **BIOS**：務必選擇 **`Default (SeaBIOS)`**（千萬不要選 OVMF/UEFI）。
    - **SCSI Controller**：選擇 **`LSI 53C895A`**（Win98 原生內建驅動，相容性最佳）。
- **Disks（硬碟）**：
    - Bus/Device：選擇 **`IDE`**（Win98 不支援 VirtIO 或 SATA 原生引導）。
    - Disk size：建議設定在 **`8 GB 到 16 GB`** 之間（硬碟太大 Win98 格式化會報錯）。
- **CPU**：
    - Cores（核心）：**`1`**（Win98 不支援多核心，給 1 核最穩定）。
    - Type（類型）：選擇 **`pentium3`** 或 **`host`**。
- **Memory（記憶體）**：
    - 預設給 **`512 MB`**。
    - _注意：絕對不要超過 512 MB（例如 1024 MB），否則 Win98 開機時會直接噴出「記憶體不足」的致命藍畫面。_
- **Network（網路）**：
    - Model：選擇 **`Intel E1000`**。

2. 顯示卡（Display）核心設定（最關鍵）：

在虛擬機建立完成後，先不要開機。點選該虛擬機 -> **Hardware（硬體）** -> 雙擊 **Display（顯示）**：

- 將其修改為 **`VMware compatible` (vmware)**。
- Memory（視訊記憶體）：設定為 **`16 MB`** 或 **`32 MB`** 即可。
- _原因：SoftGPU 內的 `vmdisp9x` 驅動程式，在 QEMU/PVE 環境下是建立在 VMware 虛擬顯卡架構之上的。_

第二階段：安裝 Windows 98 系統與準備檔案

1. 開啟虛擬機主控台（Console），引導並完成 **Windows 98 Second Edition (SE)** 的標準系統安裝。
2. 安裝完成進入 Win98 桌面後，我們需要把 SoftGPU 的安裝檔案餵給虛擬機。
3. **下載 SoftGPU**：在您的現代電腦上下載最新的 [SoftGPU GitHub Release](https://github.com/JHRobotics/softgpu/releases)（請下載 `softgpu-vX.X.X.iso`映像檔）。
4. **掛載 ISO**：在 PVE 控制台，將虛擬機的 CD/DVD 光碟機改掛載為剛剛下載的 `softgpu` ISO 檔案。

第三階段：在 Windows 98 內安裝 SoftGPU

進入 Win98 桌面後，打開「我的電腦」，點擊光碟機，您會看到 SoftGPU 的自動安裝界面（如果沒有自動彈出，請執行光碟內的 `setup.exe`）。
請依序勾選並安裝以下元件：
1. **安裝 DirectX 9.0c**：
    - 勾選安裝套件包內附的 **DirectX 9.0c (Dec 2006)**。這是跑 3D 遊戲的基石。安裝後系統會要求重新開機，請重啟。
2. **執行 SoftGPU 主安裝程式**：
    - 再次進入光碟，執行安裝程式。
    - **Display Driver**：勾選 **`VMware SVGA Video Driver (vmdisp9x)`**。
    - **3D Acceleration**：勾選 **`DirectX 9 (vmhal9x)`** 以及 **`OpenGL (Mesa9x)`**。
3. **開始安裝**：
    - 點擊「Install」，程式會開始自動複製檔案、注入登錄檔。
    - 期間 Windows 98 可能會跳出提示「正在覆蓋較新的檔案」或「找不到特定 .inf」，一律點擊 **「保留原檔案」** 或 **「確定/繼續」**。
4. **重新開機**：
    - 安裝完成後，務必重新啟動 Windows 98 虛擬機。



Hi. I have to point You at JHRobotic’s „softgpu“ project on git. It’s like magic.
你好。我必須向你推薦 JHRobotic 在 git 上的「softgpu」 專案。它簡直太神奇了。

It brings a 4k+ capable driver for qemu’s STD card in win98 + direct3D/glide wrappers from wine/nine.
它為 qemu 的 STD 顯示卡在 win98 中帶來了支援 4k+ 的驅動程序，以及來自 wine/nine 的 direct3D/glide 封裝器。
I can get around 500 3D2001seMarks or 10 fps in Q3A on PVE streamed via novlc out of the box.
我用 novlc 直接串流 PVE 遊戲，在 Q3A 模式下可以達到大約 500 3D2001seMarks 或 10 fps。

If using virtualbox with HostGPU accelerated pipe (VMSVGA+3D) it’s up to ~5700 3D2001seMarks. Q3A: 60 fps+
如果使用 VirtualBox 並開啟主機 GPU 加速管道 (VMSVGA+3D)，則 3D2001seMark 得分最高可達 5700 分（1001 分）。 Q3A：60 幀/秒以上
I also tried running the 98VM nested on win11/mint with GPU in pass-through... but it’s very slow with kvm on kvm (old host cpu)
我還嘗試在 Win11/Mint 系統上運行嵌套的 98VM，並開啟 GPU 直通…但是 KVM 虛擬機運行速度非常慢（主機 CPU 比較老舊）。
PS: If you start the 98VM on PVE manually with „-display spice-app“ you can either use local or remote (ssh -X) xserver to render the VM display from qemuSTD via spice client app instead of vnc. Either to play locally or forward via sunshine…
PS：如果您在 PVE 上手動啟動 98VM 並使用「-display spice-app」參數，則可以使用本機或遠端（ssh -X）X 伺服器，透過 Spice 用戶端應用程式從 QemuSTD 渲染虛擬機器顯示，而無需使用 VNC。這樣既可以在本地播放，也可以透過 Sunshine 轉送…