@echo off
chcp 65001 >nul
title CemWinUtility Paketleyici
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Paketle.ps1"
pause
