@echo off
title OMORI Rumble Bridge
cd /d "%~dp0"

:: If launched without arguments (double-clicked from Windows), 
:: run the standard standalone PowerShell script.
if "%~1"=="" (
    %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Launch-Rumble.ps1"
    exit /b
)

:: ==========================================================
:: STEAM WRAPPER FLOW (Launched via Steam Launch Options)
:: ==========================================================

:: Phase 1: Prepare environment (Updates, mods, start bridge)
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Launch-Rumble.ps1" -PrepareOnly

if %ERRORLEVEL% neq 0 (
    echo.
    echo ======================================================
    echo  Preparation failed. 
    echo  Read the text above to see what went wrong.
    echo ======================================================
    pause
    exit /b 1
)

:: Phase 2: Launch Game directly from BAT to preserve Steam DRM
start "" %*

:: Phase 3: Monitor game and hold Steam playtime tracking open
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Launch-Rumble.ps1" -MonitorOnly