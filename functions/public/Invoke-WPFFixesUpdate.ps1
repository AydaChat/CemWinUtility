function Invoke-WPFFixesUpdate {

    <#

    .SYNOPSIS
        Performs various tasks in an attempt to repair Windows Update

    .DESCRIPTION
        1. (Aggressive Only) Scans the system for corruption using the Invoke-WPFSystemRepair function
        2. Stops Windows Update Services
        3. Remove the QMGR Data file, which stores BITS jobs
        4. (Aggressive Only) Renames the DataStore and CatRoot2 folders
            DataStore - Contains the Windows Update History and Log Files
            CatRoot2 - Contains the Signatures for Windows Update Packages
        5. Renames the Windows Update Download Folder
        6. Deletes the Windows Update Log
        7. (Aggressive Only) Resets the Security Descriptors on the Windows Update Services
        8. Reregisters the BITS and Windows Update DLLs
        9. Removes the WSUS client settings
        10. Resets WinSock
        11. Gets and deletes all BITS jobs
        12. Sets the startup type of the Windows Update Services then starts them
        13. Forces Windows Update to check for updates

    .PARAMETER Aggressive
        If specified, the script will take additional steps to repair Windows Update that are more dangerous, take a significant amount of time, or are generally unnecessary

    #>

    param($Aggressive = $false)

    Write-Progress -Id 0 -Activity "Windows Update Onarılıyor" -PercentComplete 0
    Step-WinUtilJob -State "Indeterminate"
    Write-Host "Windows Update Onarımı Başlatılıyor..."
    # Wait for the first progress bar to show, otherwise the second one won't show
    Start-Sleep -Milliseconds 200

    if ($Aggressive) {
        Invoke-WPFSystemRepair
    }


    Write-Progress -Id 0 -Activity "Windows Update Onarılıyor" -Status "Windows Update Hizmetleri Durduruluyor..." -PercentComplete 10
    # Stop the Windows Update Services
    $services = @("BITS", "wuauserv", "appidsvc", "cryptsvc")
    for ($i = 0; $i -lt $services.Count; $i++) {
        $svc = $services[$i]
        $pct = [int](($i / $services.Count) * 100)
        Write-Progress -Id 2 -ParentId 0 -Activity "Hizmetler Durduruluyor" -Status "Durduruluyor: $svc..." -PercentComplete $pct
        Stop-Service -Name $svc -Force
    }
    Write-Progress -Id 2 -ParentId 0 -Activity "Hizmetler Durduruluyor" -Status "Tamamlandı" -PercentComplete 100


    # Remove the QMGR Data file
    Write-Progress -Id 0 -Activity "Windows Update Onarılıyor" -Status "Dosyalar Yeniden Adlandırılıyor/Kaldırılıyor..." -PercentComplete 20
    Write-Progress -Id 3 -ParentId 0 -Activity "Dosyaları Yeniden Adlandırma/Kaldırma" -Status "QMGR Veri dosyaları kaldırılıyor..." -PercentComplete 0
    Remove-Item "$env:allusersprofile\Application Data\Microsoft\Network\Downloader\qmgr*.dat" -ErrorAction SilentlyContinue


    if ($Aggressive) {
        # Rename the Windows Update Log and Signature Folders
        Write-Progress -Id 3 -ParentId 0 -Activity "Dosyaları Yeniden Adlandırma/Kaldırma" -Status "Windows Update Günlüğü, İndirme ve İmza Klasörü yeniden adlandırılıyor..." -PercentComplete 20
        Rename-Item $env:systemroot\SoftwareDistribution\DataStore DataStore.bak -ErrorAction SilentlyContinue
        Rename-Item $env:systemroot\System32\Catroot2 catroot2.bak -ErrorAction SilentlyContinue
    }

    # Rename the Windows Update Download Folder
    Write-Progress -Id 3 -ParentId 0 -Activity "Dosyaları Yeniden Adlandırma/Kaldırma" -Status "Windows Update İndirme Klasörü yeniden adlandırılıyor..." -PercentComplete 20
    Rename-Item $env:systemroot\SoftwareDistribution\Download Download.bak -ErrorAction SilentlyContinue

    # Delete the legacy Windows Update Log
    Write-Progress -Id 3 -ParentId 0 -Activity "Dosyaları Yeniden Adlandırma/Kaldırma" -Status "Eski Windows Update günlüğü kaldırılıyor..." -PercentComplete 80
    Remove-Item $env:systemroot\WindowsUpdate.log -ErrorAction SilentlyContinue
    Write-Progress -Id 3 -ParentId 0 -Activity "Dosyaları Yeniden Adlandırma/Kaldırma" -Status "Tamamlandı" -PercentComplete 100


    if ($Aggressive) {
        # Reset the Security Descriptors on the Windows Update Services
        Write-Progress -Id 0 -Activity "Windows Update Onarılıyor" -Status "WU Hizmeti Güvenlik Tanımlayıcıları Sıfırlanıyor..." -PercentComplete 25
        Write-Progress -Id 4 -ParentId 0 -Activity "WU Hizmeti Güvenlik Tanımlayıcıları Sıfırlanıyor" -Status "BITS Güvenlik Tanımlayıcısı Sıfırlanıyor..." -PercentComplete 0
        Start-Process -NoNewWindow -FilePath "sc.exe" -ArgumentList "sdset", "bits", "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)" -Wait
        Write-Progress -Id 4 -ParentId 0 -Activity "WU Hizmeti Güvenlik Tanımlayıcıları Sıfırlanıyor" -Status "wuauserv Güvenlik Tanımlayıcısı Sıfırlanıyor..." -PercentComplete 50
        Start-Process -NoNewWindow -FilePath "sc.exe" -ArgumentList "sdset", "wuauserv", "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)" -Wait
        Write-Progress -Id 4 -ParentId 0 -Activity "WU Hizmeti Güvenlik Tanımlayıcıları Sıfırlanıyor" -Status "Tamamlandı" -PercentComplete 100
    }


    # Reregister the BITS and Windows Update DLLs
    Write-Progress -Id 0 -Activity "Windows Update Onarılıyor" -Status "DLL Dosyaları Yeniden Kaydediliyor..." -PercentComplete 40
    $oldLocation = Get-Location
    Set-Location $env:systemroot\system32
    $i = 0
    $DLLs = @(
        "atl.dll", "urlmon.dll", "mshtml.dll", "shdocvw.dll", "browseui.dll",
        "jscript.dll", "vbscript.dll", "scrrun.dll", "msxml.dll", "msxml3.dll",
        "msxml6.dll", "actxprxy.dll", "softpub.dll", "wintrust.dll", "dssenh.dll",
        "rsaenh.dll", "gpkcsp.dll", "sccbase.dll", "slbcsp.dll", "cryptdlg.dll",
        "oleaut32.dll", "ole32.dll", "shell32.dll", "initpki.dll", "wuapi.dll",
        "wuaueng.dll", "wuaueng1.dll", "wucltui.dll", "wups.dll", "wups2.dll",
        "wuweb.dll", "qmgr.dll", "qmgrprxy.dll", "wucltux.dll", "muweb.dll", "wuwebv.dll"
    )
    foreach ($dll in $DLLs) {
        if ($i % 5 -eq 0 -or $i -eq ($DLLs.Count - 1)) {
            Write-Progress -Id 5 -ParentId 0 -Activity "DLL Dosyaları Yeniden Kaydediliyor" -Status "Kaydediliyor: $dll..." -PercentComplete (($i / $DLLs.Count) * 100)
        }
        $i++
        Start-Process -NoNewWindow -FilePath "regsvr32.exe" -ArgumentList "/s", $dll
    }
    Set-Location $oldLocation
    Write-Progress -Id 5 -ParentId 0 -Activity "DLL Dosyaları Yeniden Kaydediliyor" -Status "Tamamlandı" -PercentComplete 100


    # Remove the WSUS client settings
    if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate") {
        Write-Progress -Id 0 -Activity "Windows Update Onarılıyor" -Status "WSUS istemci ayarları kaldırılıyor..." -PercentComplete 60
        Write-Progress -Id 6 -ParentId 0 -Activity "WSUS istemci ayarları kaldırılıyor" -PercentComplete 0
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" -Name "AccountDomainSid" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" -Name "PingID" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" -Name "SusClientId" -ErrorAction SilentlyContinue
        Write-Progress -Id 6 -ParentId 0 -Activity "WSUS istemci ayarları kaldırılıyor" -Status "Tamamlandı" -PercentComplete 100
    }

    # Remove Group Policy Windows Update settings
    Write-Progress -Id 0 -Activity "Windows Update Onarılıyor" -Status "Grup İlkesi Windows Update ayarları kaldırılıyor..." -PercentComplete 60
    Write-Progress -Id 7 -ParentId 0 -Activity "Grup İlkesi Windows Update ayarları kaldırılıyor" -PercentComplete 0
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ExcludeWUDriversInQualityUpdate" -ErrorAction SilentlyContinue
    Write-Host "Windows Update sürücü güncelleme ilkeleri varsayılana döndürülüyor..."
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontPromptForWindowsUpdate" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontSearchWindowsUpdate" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DriverUpdateWizardWuSearchEnabled" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ExcludeWUDriversInQualityUpdate" -ErrorAction SilentlyContinue
    Write-Host "Windows Update otomatik yeniden başlatma ilkesi varsayılana döndürülüyor..."
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUPowerManagement" -ErrorAction SilentlyContinue
    Write-Host "TÜM Windows Update İlke ayarları temizleniyor..."
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "BranchReadinessLevel" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "DeferFeatureUpdatesPeriodInDays" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "DeferQualityUpdatesPeriodInDays" -ErrorAction SilentlyContinue
    Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKCU:\Software\Microsoft\WindowsSelfHost" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKCU:\Software\Policies" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\Software\Microsoft\Policies" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\Software\Microsoft\WindowsSelfHost" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\Software\Policies" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\Software\WOW6432Node\Microsoft\Policies" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Process -NoNewWindow -FilePath "secedit" -ArgumentList "/configure", "/cfg", "$env:windir\inf\defltbase.inf", "/db", "defltbase.sdb", "/verbose" -Wait
    Start-Process -NoNewWindow -FilePath "cmd.exe" -ArgumentList "/c RD /S /Q $env:WinDir\System32\GroupPolicyUsers" -Wait
    Start-Process -NoNewWindow -FilePath "cmd.exe" -ArgumentList "/c RD /S /Q $env:WinDir\System32\GroupPolicy" -Wait
    Start-Process -NoNewWindow -FilePath "gpupdate" -ArgumentList "/force" -Wait
    Write-Progress -Id 7 -ParentId 0 -Activity "Grup İlkesi Windows Update ayarları kaldırılıyor" -Status "Tamamlandı" -PercentComplete 100


    # Reset WinSock
    Write-Progress -Id 0 -Activity "Windows Update Onarılıyor" -Status "WinSock Sıfırlanıyor..." -PercentComplete 65
    Write-Progress -Id 7 -ParentId 0 -Activity "WinSock Sıfırlanıyor" -Status "WinSock Sıfırlanıyor..." -PercentComplete 0
    Start-Process -NoNewWindow -FilePath "netsh" -ArgumentList "winsock", "reset"
    Start-Process -NoNewWindow -FilePath "netsh" -ArgumentList "winhttp", "reset", "proxy"
    Start-Process -NoNewWindow -FilePath "netsh" -ArgumentList "int", "ip", "reset"
    Write-Progress -Id 7 -ParentId 0 -Activity "WinSock Sıfırlanıyor" -Status "Tamamlandı" -PercentComplete 100


    # Get and delete all BITS jobs
    Write-Progress -Id 0 -Activity "Windows Update Onarılıyor" -Status "BITS işleri siliniyor..." -PercentComplete 75
    Write-Progress -Id 8 -ParentId 0 -Activity "BITS işleri siliniyor" -Status "BITS işleri siliniyor..." -PercentComplete 0
    Get-BitsTransfer | Remove-BitsTransfer
    Write-Progress -Id 8 -ParentId 0 -Activity "BITS işleri siliniyor" -Status "Tamamlandı" -PercentComplete 100


    # Change the startup type of the Windows Update Services and start them
    Write-Progress -Id 0 -Activity "Windows Update Onarılıyor" -Status "Windows Update Hizmetleri Başlatılıyor..." -PercentComplete 90
    Write-Progress -Id 9 -ParentId 0 -Activity "Windows Update Hizmetleri Başlatılıyor" -Status "BITS Başlatılıyor..." -PercentComplete 0
    Get-Service BITS | Set-Service -StartupType Manual -PassThru | Start-Service
    Write-Progress -Id 9 -ParentId 0 -Activity "Windows Update Hizmetleri Başlatılıyor" -Status "wuauserv Başlatılıyor..." -PercentComplete 25
    Get-Service wuauserv | Set-Service -StartupType Manual -PassThru | Start-Service
    Write-Progress -Id 9 -ParentId 0 -Activity "Windows Update Hizmetleri Başlatılıyor" -Status "AppIDSvc Başlatılıyor..." -PercentComplete 50
    # The AppIDSvc service is protected, so the startup type has to be changed in the registry
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\AppIDSvc" -Name "Start" -Value "3" # Manual
    Start-Service AppIDSvc
    Write-Progress -Id 9 -ParentId 0 -Activity "Windows Update Hizmetleri Başlatılıyor" -Status "CryptSvc Başlatılıyor..." -PercentComplete 75
    Get-Service CryptSvc | Set-Service -StartupType Manual -PassThru | Start-Service
    Write-Progress -Id 9 -ParentId 0 -Activity "Windows Update Hizmetleri Başlatılıyor" -Status "Tamamlandı" -PercentComplete 100


    # Force Windows Update to check for updates
    Write-Progress -Id 0 -Activity "Windows Update Onarılıyor" -Status "Güncelleme taraması zorlanıyor..." -PercentComplete 95
    Write-Progress -Id 10 -ParentId 0 -Activity "Güncelleme taraması zorlanıyor" -Status "Güncelleme taraması zorlanıyor..." -PercentComplete 0
    try {
        (New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()
    } catch {
        Write-WinUtilLog -Level "ERROR" -Component "Updates" -Message "Failed to create Windows Update COM object: $_"
        Write-Warning "Failed to create Windows Update COM object: $_"
    }
    Start-Process -NoNewWindow -FilePath "wuauclt" -ArgumentList "/resetauthorization", "/detectnow"
    Write-Progress -Id 10 -ParentId 0 -Activity "Güncelleme taraması zorlanıyor" -Status "Tamamlandı" -PercentComplete 100
    Write-Progress -Id 0 -Activity "Windows Update Onarılıyor" -Status "Tamamlandı" -PercentComplete 100

    Show-WinUtilMessage -Message "Varsayılan ayarlar yüklendi.`n Lütfen bilgisayarınızı yeniden başlatın" -Title "Windows Update'i Sıfırla" -Button "OK" -Icon "Information" | Out-Null

    # Remove the progress bars
    foreach ($id in 0..10) {
        Write-Progress -Id $id -Activity "Completed" -Completed -ErrorAction SilentlyContinue
    }
}
