---
title: Proxmox SoftGPU
toc: true
date: 2026-10-18
tags:
  - PVE
---
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