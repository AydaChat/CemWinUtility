# Paketle.ps1 - CemWinUtility Taşınabilir Dağıtım Paketi Oluşturucu
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "     CemWinUtility Dağıtım Paketi Oluşturuluyor...       " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. winutil.ps1 dosyasını derle
Write-Host "[1/4] winutil.ps1 derleniyor..." -ForegroundColor Yellow
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "Compile.ps1")

# 2. Dağıtım klasörünü hazırla
Write-Host "[2/4] Dağıtım klasörü güncelleniyor (dist\CemWinUtility)..." -ForegroundColor Yellow
$distDir = Join-Path $PSScriptRoot "dist\CemWinUtility"

# Eski WinUtil-TR kalıntılarını temizle
$oldDistDir = Join-Path $PSScriptRoot "dist\WinUtil-TR"
if (Test-Path $oldDistDir) { Remove-Item $oldDistDir -Recurse -Force }
$oldZip = Join-Path $PSScriptRoot "dist\WinUtil_Turkce_v1.0.zip"
if (Test-Path $oldZip) { Remove-Item $oldZip -Force }

if (-not (Test-Path $distDir)) {
    New-Item -ItemType Directory -Path $distDir -Force | Out-Null
}

Copy-Item (Join-Path $PSScriptRoot "winutil.ps1") -Destination $distDir -Force
Copy-Item (Join-Path $PSScriptRoot "config\winutil.ico") -Destination $distDir -Force

# CemWinUtility.cmd
$cmdContent = @"
@echo off
chcp 65001 >nul
title CemWinUtility - Windows Yardımcı Programı
setlocal
cd /d "%~dp0"

echo ========================================================
echo        CemWinUtility Başlatılıyor...
echo ========================================================
echo.

:: Yönetici yetkisi kontrolü
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Yönetici izni isteniyor, lütfen gelen uyarıyı onaylayın...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd.exe -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

:: Programı çalıştır
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0winutil.ps1"
"@
[System.IO.File]::WriteAllText((Join-Path $distDir "CemWinUtility.cmd"), $cmdContent, [System.Text.Encoding]::UTF8)

# Masaüstü_Kısayolu_Oluştur.cmd
$shortcutCmdContent = @"
@echo off
chcp 65001 >nul
title CemWinUtility Masaüstü Kısayol Oluşturucu
setlocal
cd /d "%~dp0"

echo ========================================================
echo       CemWinUtility Masaüstü Kısayolu Ekleniyor...
echo ========================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "`$desktop = [Environment]::GetFolderPath('Desktop'); " ^
    "`$shortcutPath = Join-Path `$desktop 'CemWinUtility.lnk'; " ^
    "`$targetScript = Join-Path `$pwd 'winutil.ps1'; " ^
    "`$iconPath = Join-Path `$pwd 'winutil.ico'; " ^
    "`$wsh = New-Object -ComObject WScript.Shell; " ^
    "`$sc = `$wsh.CreateShortcut(`$shortcutPath); " ^
    "`$sc.TargetPath = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'; " ^
    "`$sc.Arguments = '-NoProfile -ExecutionPolicy Bypass -File \"\"' + `$targetScript + '\"\"'; " ^
    "`$sc.WorkingDirectory = `$pwd.Path; " ^
    "`$sc.Description = 'CemWinUtility (Windows Yardımcı Programı)'; " ^
    "if (Test-Path `$iconPath) { `$sc.IconLocation = `$iconPath + ',0' }; " ^
    "`$sc.Save(); " ^
    "`$bytes = [System.IO.File]::ReadAllBytes(`$shortcutPath); " ^
    "`$bytes[0x15] = `$bytes[0x15] -bor 0x20; " ^
    "[System.IO.File]::WriteAllBytes(`$shortcutPath, `$bytes); " ^
    "Write-Host 'BAŞARILI: Masaüstünüze CemWinUtility kısayolu eklendi!' -ForegroundColor Green"

echo.
echo İşlem tamamlandı. Pencereyi kapatmak için bir tuşa basın.
pause >nul
"@
[System.IO.File]::WriteAllText((Join-Path $distDir "Masaüstü_Kısayolu_Oluştur.cmd"), $shortcutCmdContent, [System.Text.Encoding]::UTF8)

# Benioku.txt
$readmeContent = @"
========================================================================
                   CemWinUtility (Windows Yardımcı Programı)
========================================================================

CemWinUtility, Windows kurulumlarını hızlandıran, sistemi optimize eden,
ince ayarlar uygulayan ve Windows güncellemelerini yöneten taşınabilir bir araçtır.

KULLANIM TALİMATI:
-----------------
1. CemWinUtility'yi Başlatmak İçin:
   - Klasör içindeki "CemWinUtility.cmd" dosyasına çift tıklayın.
   - Açılan UAC (Kullanıcı Hesabı Denetimi) uyarısına "Evet" deyin.
   - Program doğrudan arayüzü ile açılacaktır.

2. Masaüstüne Kısayol Eklemek İçin (İsteğe Bağlı):
   - "Masaüstü_Kısayolu_Oluştur.cmd" dosyasına çift tıklayın.
   - Masaüstünüze özel simgesiyle doğrudan Yönetici olarak çalışan
     "CemWinUtility" kısayolu eklenecektir.

ÖNEMLİ BİLGİLER:
---------------
- İnternet bağlantısı olmadan da açılabilir (Offline mod).
- Uygulama kurulumları veya Windows güncelleme kontrolleri için internet gerekir.
- Herhangi bir kurulum gerektirmez, taşınabilirdir (USB bellekten çalıştırılabilir).
========================================================================
"@
[System.IO.File]::WriteAllText((Join-Path $distDir "Benioku.txt"), $readmeContent, [System.Text.Encoding]::UTF8)

# 3. ZIP Arşivini oluştur
Write-Host "[3/4] ZIP arşivi sıkıştırılıyor..." -ForegroundColor Yellow
$zipPath = Join-Path $PSScriptRoot "dist\CemWinUtility_v1.0.zip"
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}
Compress-Archive -Path (Join-Path $distDir "*") -DestinationPath $zipPath -CompressionLevel Optimal

# 4. Bilgilendirme
$zipItem = Get-Item $zipPath
$sizeKb = [math]::Round($zipItem.Length / 1KB, 2)

Write-Host "==========================================================" -ForegroundColor Green
Write-Host " BAŞARILI: CemWinUtility dağıtım paketi hazırlandı!" -ForegroundColor Green
Write-Host " Klasör: $distDir" -ForegroundColor White
Write-Host " ZIP Dosyası: $zipPath ($sizeKb KB)" -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Green
