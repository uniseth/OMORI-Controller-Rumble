@echo off
title OMORI Rumble Bridge
cd /d "%~dp0"

%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Launch-Rumble.ps1" %*

:: If PowerShell crashes or exits with an error, this keeps the window open so you can read it
if %ERRORLEVEL% neq 0 (
    echo.
    echo ======================================================
    echo  PowerShell encountered an error. 
    echo  Read the red text above to see what went wrong.
    echo ======================================================
    pause
)