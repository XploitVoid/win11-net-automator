@echo off
:: menu.bat — Main hub for Win11 Net Automator (GUI Launcher)
title Win11 Net Automator Launcher

:: Force run in the script directory so it can find the PowerShell script
cd /d "%~dp0"

:: Launch the native PowerShell GUI
:: -WindowStyle Hidden prevents the blue PS console from showing
start "" powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File "net-automator-gui.ps1"

exit /b 0
