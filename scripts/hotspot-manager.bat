@echo off
setlocal EnableDelayedExpansion

:: hotspot-manager.bat — Windows 11 Mobile Hotspot CLI
:: Uses PowerShell and WinRT APIs to toggle the built-in Windows Hotspot.

title Mobile Hotspot Manager

cls
echo.
echo  ============================================================
echo     Mobile Hotspot Manager
echo  ============================================================
echo.
echo   This tool toggles the built-in Windows 11 Mobile Hotspot
echo   so you can share your connection with other devices.
echo.

:: Check current status via PowerShell WinRT API
echo   Checking hotspot status...
for /f "usebackq tokens=*" %%S in (`powershell -NoProfile -Command ^
    "try { [Windows.Networking.Connectivity.NetworkInformation,Windows.Networking.Connectivity,ContentType=WindowsRuntime] | Out-Null; $profile = [Windows.Networking.Connectivity.NetworkInformation]::GetInternetConnectionProfile(); $tether = [Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager,Windows.Networking.NetworkOperators,ContentType=WindowsRuntime]::CreateFromConnectionProfile($profile); if ($tether.TetheringOperationalState -eq 'On') { 'ON' } else { 'OFF' } } catch { 'ERROR' }"`) do (
    set "STATUS=%%S"
)

if "!STATUS!"=="ERROR" (
    echo  [ERROR] Cannot access Mobile Hotspot API. Your Wi-Fi adapter
    echo  might not support tethering, or the service is disabled.
    echo.
    pause
    exit /b 1
)

echo.
echo   Current Status: [ !STATUS! ]
echo.
echo     1 - Turn Hotspot ON
echo     2 - Turn Hotspot OFF
echo     3 - Open Hotspot Settings (to change password)
echo.

set /p "PICK=   Choice (1-3): "

if "!PICK!"=="1" goto :TurnOn
if "!PICK!"=="2" goto :TurnOff
if "!PICK!"=="3" goto :Settings

echo  Invalid choice.
pause
exit /b 1

:: -----------------------------------------------------------
:TurnOn
echo.
if "!STATUS!"=="ON" (
    echo  Hotspot is already ON.
    echo.
    pause
    exit /b 0
)

echo  Starting Mobile Hotspot...
powershell -NoProfile -Command ^
    "$profile = [Windows.Networking.Connectivity.NetworkInformation]::GetInternetConnectionProfile(); $tether = [Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager]::CreateFromConnectionProfile($profile); $tether.StartTetheringAsync() | Out-Null"

timeout /t 2 /nobreak >nul
echo   [OK] Hotspot started. Devices can now connect.
echo.
pause
exit /b 0

:: -----------------------------------------------------------
:TurnOff
echo.
if "!STATUS!"=="OFF" (
    echo  Hotspot is already OFF.
    echo.
    pause
    exit /b 0
)

echo  Stopping Mobile Hotspot...
powershell -NoProfile -Command ^
    "$profile = [Windows.Networking.Connectivity.NetworkInformation]::GetInternetConnectionProfile(); $tether = [Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager]::CreateFromConnectionProfile($profile); $tether.StopTetheringAsync() | Out-Null"

timeout /t 2 /nobreak >nul
echo   [OK] Hotspot stopped.
echo.
pause
exit /b 0

:: -----------------------------------------------------------
:Settings
echo.
echo  Opening Windows Settings...
start ms-settings:network-mobilehotspot
exit /b 0
