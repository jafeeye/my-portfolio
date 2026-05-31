---
title: hyper-v 進階功能 WSLg,GPU-PV
date: 2026-03-08
toc: true
---
## 前言
一些Hyper-V 的進階功能，記得使用主機板BIOS要開啟intel VMX、 SR-IOV、 VT-D

EXHyperV
WSLDashboard
NatMappingManager | Windows NAT Manager GUI

## 網路設定
建立NAT
```powershell
Get-NetIPAddress
New-VMSwitch -Name "NATSwitch" -SwitchType Internal
New-NetIPAddress -InterfaceAlias "vEthernet (NATSwitch)" -IPAddress 192.168.80.1 -PrefixLength 24 ;改NAT Pool
Get-NetIPAddress | Where-Object { $_.InterfaceAlias -eq "vEthernet (NATSwitch)" }  ;檢查位置
New-NetNat -Name "NATSwitch" -InternalIPInterfaceAddressPrefix 192.168.80.0/24 ;記得不能跟VMWare衝突

Get-NetNat
Remove-NetNat -Name "NAT-SW" -Confirm:$false
```

### WSL+WSLg

在Win10上啟用Windows 子系統Linux版、Hyper-V
WSL1：使用Linux轉譯內核，不需開WHP，可與VMware 第一層共存 (性能不減)
WSL2：使用WHP轉譯層強制開啟虛擬化型安全性，Hyper-V強制升為第一層，其他虛擬化軟體都跑WHP虛擬化引擎，性能會下降很多

>Win11 24H2 預設開啟VBS虛擬化，檢查方式： msinfo32.exe 虛擬化型安全性為執行中，關閉`bcdedit /set hypervisorlaunchtype off`

### 批量建立
```powershell
[string[]] $arr1 = ("1","2","3","4","5","6","7")
$pc = "W2019K"
foreach ($element in $arr1)
{
  $FullVmName = $pc + $element
  #echo $FullVmName
  New-VHD -Path "C:\HyperVVMs\$FullVmName\MyHd.vhdx" -ParentPath "C:\HyperVVM\Virtual Hard Disks\WS2019.vhdx"        
  New-VM -Name $FullVmName -Generation 1 -VHDPath "C:\HyperVVMs\$FullVmName\MyHd.vhdx" -SwitchName (Get-VMSwitch | Select-Object -First 1 -ExpandProperty Name)
  Set-VMMemory -VMName $FullVmName -DynamicMemoryEnabled $True -StartupBytes 4GB -MinimumBytes 512MB -MaximumBytes 4GB
  Set-VMProcessor -VMName $FullVmName -Count 16
}

大量虛擬機 (新空硬碟)
[string[]] $arr1 = ("1","2","3","4")
$pc = "TES"
$VhdSize = 40GB
foreach ($element in $arr1)
{
    $FullVmName = $pc + $element
    $VmFolder   = "C:\HyperVVMs\$FullVmName"
    New-Item -ItemType Directory -Path $VmFolder -Force | Out-Null
    New-VHD -Path "$VmFolder\MyHd.vhdx" -SizeBytes $VhdSize -Dynamic
    New-VM -Name $FullVmName `
           -Generation 2 `
           -VHDPath "$VmFolder\MyHd.vhdx" `
           -SwitchName (Get-VMSwitch | Select-Object -First 1 -ExpandProperty Name)
    Set-VMMemory -VMName $FullVmName `
                 -DynamicMemoryEnabled $True `
                 -StartupBytes 4GB `
                 -MinimumBytes 512MB `
                 -MaximumBytes 4GB
    Set-VMProcessor -VMName $FullVmName -Count 4
}
參數
-ParentPath 後面是接要繫的父系硬碟.vhdx
-Count 核心數
-Generation 第幾代系統

自訂開機
$vmList = "TES1", "TES2", "TES3", "TES4"
$delay = 30
foreach ($vm in $vmList) {
    Write-Host "正在啟動 $vm ..." -ForegroundColor Cyan
    Start-VM $vm -ErrorAction Continue
    Start-Sleep -Seconds $delay
}
```

### 開啟WHP兼容層
備註:要Windows Server 2022 才能開啟
```
Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -All Install-WindowsFeature Hyper-V -IncludeManagementTools
```
![](260404-whp01.png)

![](Pasted%20image%2020260531144500.png)
### WSLg

安裝桌面環境 `sudo apt-get update && sudo apt-get install -y xfce4 xfce4-goodies`
wsl
```
echo "export XDG_SESSION_TYPE=x11" >> ~/.profile
echo "export GDK_PLATFORM=x11" >> ~/.profile
echo "export GDK_BACKEND=x11" >> ~/.profile
echo "export QT_QPA_PLATFORM=xcb" >> ~/.profile
echo "export WAYLAND_DISPLAY=" >> ~/.profile
source ~/.profile
```

```bash
Xephyr -br -ac -noreset -resizeable -screen 1600x900 :1 &
```

```
export DISPLAY=:1
dbus-run-session startxfce4
```

## 二代機器強制舊式vhd











## 參考資料

1. https://yulun.me/2014/vmware-shortcut-startup-fullscreen/  "快速啟動虛擬機 (建立捷徑 Windows/VMware)"
2. Windows 11 WSL2跑Linux桌面環境與圖形程式的方法，使用WSLg XWayland https://ivonblog.com/posts/run-linux-desktop-on-wsl/
3. [VMware和HyperV(wsl2)共存后性能大幅下降的解决方案 | 骏马金龙](https://www.junmajinlong.com/others/wsl_vmware_hyperv/)

