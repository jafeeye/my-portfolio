

# 1. 停止並停用遙測相關服務
$Services = @("DiagTrack", "dmwappushservice", "WerSvc", "OneSyncSvc")
foreach ($Service in $Services) {
    if (Get-Service -Name $Service -ErrorAction SilentlyContinue) {
        Stop-Service -Name $Service -Force -Confirm:$false -ErrorAction SilentlyContinue
        Set-Service -Name $Service -StartupType Disabled
        Write-Host "已停用服務: $Service" -ForegroundColor Green
    }
}

# 2. 修改登錄檔以關閉資料收集 (DataCollection)
$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (!(Test-Path $RegistryPath)) { New-Item -Path $RegistryPath -Force }
Set-ItemProperty -Path $RegistryPath -Name "AllowTelemetry" -Value 0

# 關閉功能更新優化 (省頻寬)
$DeliveryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
if (!(Test-Path $DeliveryPath)) { New-Item -Path $DeliveryPath -Force }
Set-ItemProperty -Path $DeliveryPath -Name "DODownloadMode" -Value 0

# 3. 停用計畫任務中的收集器 (最耗 CPU 的部分)
$Tasks = @(
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Autochk\Proxy",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
)
foreach ($Task in $Tasks) {
    Disable-ScheduledTask -TaskName $Task -ErrorAction SilentlyContinue
    Write-Host "已停用任務: $Task" -ForegroundColor Cyan
}


# 4. 關閉Windows Defender
Uninstall-WindowsFeature -Name Windows-Defender


# 5. 關閉磁碟重組
Disable-ScheduledTask -TaskName "ScheduledDefrag" -TaskPath "\Microsoft\Windows\Defrag\"
Stop-Service -Name "defragsvc"
Set-Service -Name "defragsvc" -StartupType Disabled

Write-Host "Windows 遙測已成功關閉。建議重啟 VM 以釋放資源。" -ForegroundColor Yellow
Write-Host "Windows Defender 已關閉。" -ForegroundColor Yellow
Write-Host "Windows 磁碟重組已關閉。" -ForegroundColor Yellow