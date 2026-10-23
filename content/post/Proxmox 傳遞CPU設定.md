---
title: Proxmox 傳遞CPU設定
toc: true
date: 2026-10-23
tags:
  - Proxmox
---

1. 確認主機已啟用 nested
在 **Proxmox 主機 Shell** 執行，確認是否為y
```
cat /sys/module/kvm_intel/parameters/nested
```

2. 自訂CPU模型 `nano /etc/pve/virtual-guest/cpu-models.conf`，加入以下參數
```
cpu-model: x86-64-v2-AES-nested
	reported-model qemu64
	flags +nested-virt;+aes;+pni;+popcnt;+sse4.1;+sse4.2;+ssse3;+vmx;+vmx-activity-hlt;+vmx-activity-wait-sipi;+vmx-apicv-x2apic;+vmx-apicv-xapic;+vmx-cr3-load-noexit;+vmx-cr3-store-noexit;+vmx-cr8-load-exit;+vmx-cr8-store-exit;+vmx-desc-exit;+vmx-entry-ia32e-mode;+vmx-entry-load-efer;+vmx-entry-load-pat;+vmx-entry-load-perf-global-ctrl;+vmx-entry-noload-debugctl;+vmx-ept;+vmx-ept-1gb;+vmx-ept-2mb;+vmx-ept-advanced-exitinfo;+vmx-ept-execonly;+vmx-eptad;+vmx-eptp-switching;+vmx-exit-ack-intr;+vmx-exit-load-efer;+vmx-exit-load-pat;+vmx-exit-load-perf-global-ctrl;+vmx-exit-nosave-debugctl;+vmx-exit-save-efer;+vmx-exit-save-pat;+vmx-exit-save-preemption-timer;+vmx-flexpriority;+vmx-hlt-exit;+vmx-ins-outs;+vmx-intr-exit;+vmx-invept;+vmx-invept-all-context;+vmx-invept-single-context;+vmx-invept-single-context-noglobals;+vmx-invlpg-exit;+vmx-invvpid;+vmx-invvpid-all-context;+vmx-invvpid-single-addr;+vmx-io-bitmap;+vmx-io-exit;+vmx-mbec;+vmx-monitor-exit;+vmx-movdr-exit;+vmx-msr-bitmap;+vmx-mtf;+vmx-mwait-exit;+vmx-nmi-exit;+vmx-page-walk-4;+vmx-pause-exit;+vmx-pml;+vmx-preemption-timer;+vmx-rdpmc-exit;+vmx-rdtsc-exit;+vmx-secondary-ctls;+vmx-shadow-vmcs;+vmx-store-lma;+vmx-true-ctls;+vmx-tsc-offset;+vmx-unrestricted-guest;+vmx-vintr-pending;+vmx-vmfunc;+vmx-vmwrite-vmexit-fields;+vmx-vnmi;+vmx-vnmi-pending;+vmx-vpid;+vmx-wbinvd-exit
```

3. 在介面也可以看到自訂cpu 類型
![](static/Pasted%20image%2020261023192119.png)

4. 在例子中是XenServer無法使用完整HVM，先登入XenServer去看log
```
xl dmesg | grep -Ei 'vmx|hvm|hap|ept|disabled|virtual'
```
可以看到錯誤訊息如下
```
(XEN) [00000006c1da3988]   Support for HVM VMs: RSB
(XEN) [00000006c1f3f6fa]   PV L1TF shadowing: Dom0 disabled, DomU disabled
(XEN) [    0.472755] I/O virtualisation disabled
(XEN) [    1.336591] VMX: CPU0 has insufficient Pin-Based Exec Control (00000016; requires 00000009)
(XEN) [    1.345582] VMX: CPU0 has insufficient CPU-Based Exec Control (0401e172; requires 2299968c)
(XEN) [    1.354522] VMX: CPU0 has insufficient VMExit Control (00036fff; requires 00008200)
(XEN) [    1.363420] VMX: failed to initialise.
(XEN) [    1.489840] CPUIDLE: disabled due to no HPET. Force enable with 'cpuidle'.
(XEN) [    1.738332] VIRTUAL MEMORY ARRANGEMENT:
```

5. 再去選CPU Type去啟動
![](static/Pasted%20image%2020261023192506.png)