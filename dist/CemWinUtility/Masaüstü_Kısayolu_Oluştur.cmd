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
    "$desktop = [Environment]::GetFolderPath('Desktop'); " ^
    "$shortcutPath = Join-Path $desktop 'CemWinUtility.lnk'; " ^
    "$targetScript = Join-Path $pwd 'winutil.ps1'; " ^
    "$iconPath = Join-Path $pwd 'winutil.ico'; " ^
    "$wsh = New-Object -ComObject WScript.Shell; " ^
    "$sc = $wsh.CreateShortcut($shortcutPath); " ^
    "$sc.TargetPath = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'; " ^
    "$sc.Arguments = '-NoProfile -ExecutionPolicy Bypass -File \"\"' + $targetScript + '\"\"'; " ^
    "$sc.WorkingDirectory = $pwd.Path; " ^
    "$sc.Description = 'CemWinUtility (Windows Yardımcı Programı)'; " ^
    "if (Test-Path $iconPath) { $sc.IconLocation = $iconPath + ',0' }; " ^
    "$sc.Save(); " ^
    "$bytes = [System.IO.File]::ReadAllBytes($shortcutPath); " ^
    "$bytes[0x15] = $bytes[0x15] -bor 0x20; " ^
    "[System.IO.File]::WriteAllBytes($shortcutPath, $bytes); " ^
    "Write-Host 'BAŞARILI: Masaüstünüze CemWinUtility kısayolu eklendi!' -ForegroundColor Green"

echo.
echo İşlem tamamlandı. Pencereyi kapatmak için bir tuşa basın.
pause >nul