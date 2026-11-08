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