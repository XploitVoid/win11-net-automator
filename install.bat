@echo off
setlocal EnableDelayedExpansion

:: install.bat — Win11 Net Automator Installer
:: Copies files to ProgramData, adds to PATH, and adds Right-Click Menu.

title Installer - Win11 Net Automator

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] Installation requires Administrator rights.
    echo  Right-click ^> Run as administrator.
    echo.
    pause
    exit /b 1
)

set "INSTALL_DIR=C:\ProgramData\win11-net-automator"
set "SRC_DIR=%~dp0scripts"
if not exist "%SRC_DIR%" set "SRC_DIR=%~dp0"

cls
echo.
echo  ============================================================
echo     Win11 Net Automator — System Installation
echo  ============================================================
echo.
echo   This will:
echo    1. Copy all scripts to %INSTALL_DIR%
echo    2. Add the directory to your system PATH (so you can run
echo       commands like 'menu' or 'net-info' from anywhere)
echo    3. Add a "Win11 Net Automator" option to your Desktop
echo       right-click context menu.
echo.
echo     1 - Install
echo     2 - Uninstall
echo.

set /p "PICK=   Choice (1-2): "

if "!PICK!"=="1" goto :Install
if "!PICK!"=="2" goto :Uninstall

echo  Invalid choice.
pause
exit /b 1

:: -----------------------------------------------------------
:Install
echo.
echo  [1/3] Copying files to %INSTALL_DIR%...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%" >nul 2>&1
copy /y "%SRC_DIR%\*.bat" "%INSTALL_DIR%\" >nul 2>&1
copy /y "%SRC_DIR%\*.ps1" "%INSTALL_DIR%\" >nul 2>&1
echo   - Files copied.

echo.
echo  [2/3] Adding to System PATH...
:: Check if already in PATH
echo %PATH% | findstr /i "%INSTALL_DIR%" >nul 2>&1
if %errorlevel% equ 0 (
    echo   - Already in PATH.
) else (
    powershell -NoProfile -Command ^
        "$p = [Environment]::GetEnvironmentVariable('PATH', 'Machine'); [Environment]::SetEnvironmentVariable('PATH', $p + ';%INSTALL_DIR%', 'Machine')"
    echo   - PATH updated. (May require restarting terminal apps)
)

echo.
echo  [3/3] Adding Desktop Right-Click Menu...
:: Add registry keys for desktop background context menu
reg add "HKCR\Directory\Background\shell\Win11NetAutomator" /ve /d "🌐 Win11 Net Automator" /f >nul 2>&1
reg add "HKCR\Directory\Background\shell\Win11NetAutomator\command" /ve /d "cmd.exe /c start /b \"\" \"%INSTALL_DIR%\menu.bat\"" /f >nul 2>&1
echo   - Context menu added.

echo.
echo  ============================================================
echo   Installation Complete!
echo  ============================================================
echo.
echo   - Right-click anywhere on your desktop to open the Menu.
echo   - Or open Terminal and type: menu
echo.
pause
exit /b 0

:: -----------------------------------------------------------
:Uninstall
echo.
echo  [1/3] Removing files...
if exist "%INSTALL_DIR%" (
    rmdir /s /q "%INSTALL_DIR%" >nul 2>&1
    echo   - Files deleted.
) else (
    echo   - Files not found.
)

echo.
echo  [2/3] Removing from System PATH...
:: Removing from PATH cleanly via PowerShell
powershell -NoProfile -Command ^
    "$p = [Environment]::GetEnvironmentVariable('PATH', 'Machine'); $p = ($p -split ';' | Where-Object { $_ -ne '%INSTALL_DIR%' }) -join ';'; [Environment]::SetEnvironmentVariable('PATH', $p, 'Machine')"
echo   - PATH cleaned.

echo.
echo  [3/3] Removing Desktop Right-Click Menu...
reg delete "HKCR\Directory\Background\shell\Win11NetAutomator" /f >nul 2>&1
echo   - Context menu removed.

echo.
echo  ============================================================
echo   Uninstalled Successfully.
echo  ============================================================
echo.
pause
exit /b 0
