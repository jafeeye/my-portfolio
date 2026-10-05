

# 1. ����ð��λ��������A��
$Services = @("DiagTrack", "dmwappushservice", "WerSvc", "OneSyncSvc")
foreach ($Service in $Services) {
    if (Get-Service -Name $Service -ErrorAction SilentlyContinue) {
        Stop-Service -Name $Service -Force -Confirm:$false -ErrorAction SilentlyContinue
        Set-Service -Name $Service -StartupType Disabled
        Write-Host "�w���ΪA��: $Service" -ForegroundColor Green
    }
}

# 2. �ק�n���ɥH������Ʀ��� (DataCollection)
$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (!(Test-Path $RegistryPath)) { New-Item -Path $RegistryPath -Force }
Set-ItemProperty -Path $RegistryPath -Name "AllowTelemetry" -Value 0

# �����\���s�u�� (���W�e)
$DeliveryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
if (!(Test-Path $DeliveryPath)) { New-Item -Path $DeliveryPath -Force }
Set-ItemProperty -Path $DeliveryPath -Name "DODownloadMode" -Value 0

# 3. ���έp�e���Ȥ��������� (�̯� CPU ������)
$Tasks = @(
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Autochk\Proxy",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
)
foreach ($Task in $Tasks) {
    Disable-ScheduledTask -TaskName $Task -ErrorAction SilentlyContinue
    Write-Host "�w���Υ���: $Task" -ForegroundColor Cyan
}


# 4. ����Windows Defender
Uninstall-WindowsFeature -Name Windows-Defender


# 5. �����ϺЭ���
Disable-ScheduledTask -TaskName "ScheduledDefrag" -TaskPath "\Microsoft\Windows\Defrag\"
Stop-Service -Name "defragsvc"
Set-Service -Name "defragsvc" -StartupType Disabled

Write-Host "Windows �����w���\�����C��ĳ���� VM �H����귽�C" -ForegroundColor Yellow
Write-Host "Windows Defender �w�����C" -ForegroundColor Yellow
Write-Host "Windows �ϺЭ��դw�����C" -ForegroundColor Yellow