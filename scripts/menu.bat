@echo off
:: menu.bat — Main hub for Win11 Net Automator (TUI Launcher)
title Win11 Net Automator Launcher

:: Force run in the script directory so it can find the PowerShell script
cd /d "%~dp0"

:: Launch the native PowerShell Terminal UI (TUI)
powershell -NoProfile -ExecutionPolicy Bypass -File "terminal-menu.ps1"

exit /b 0
