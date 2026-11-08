@echo off
chcp 65001 >nul
title CemWinUtility - Windows Yardımcı Programı
cd /d "%~dp0"

echo ====================================================
echo          CemWinUtility Başlatılıyor...
echo ====================================================
echo.

if not exist "%~dp0winutil.ps1" (
    echo Derlenmiş dosya bulunamadı, derleniyor...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Compile.ps1"
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0winutil.ps1"

