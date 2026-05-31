@echo off
setlocal EnableDelayedExpansion

:: gaming-mode.bat — Network Optimizer for Gamers
:: Disables background heavy services and tweaks TCP/Registry for latency.

title Gaming Network Mode

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] Run as Administrator required for registry tweaks.
    echo.
    pause
    exit /b 1
)

cls
echo.
echo  ============================================================
echo     Gaming Network Mode
echo  ============================================================
echo.
echo   This mode pauses background tasks that hog bandwidth
echo   (Windows Update, OneDrive) and adjusts registry values
echo   to prioritize network latency (Ping) over throughput.
echo.
echo     1 - Enable Gaming Mode
echo     2 - Restore Normal Mode
echo.

set /p "PICK=   Choice (1-2): "

if "!PICK!"=="1" goto :Enable
if "!PICK!"=="2" goto :Disable

echo  Invalid choice.
pause
exit /b 1

:: -----------------------------------------------------------
:Enable
echo.
echo  Pausing background services...

:: Windows Update (wuauserv)
sc config wuauserv start=demand >nul 2>&1
net stop wuauserv >nul 2>&1
echo   [OK] Windows Update stopped.

:: Background Intelligent Transfer Service (BITS)
sc config bits start=demand >nul 2>&1
net stop bits >nul 2>&1
echo   [OK] BITS stopped.

:: Delivery Optimization (DoSvc)
sc config DoSvc start=demand >nul 2>&1
net stop DoSvc >nul 2>&1
echo   [OK] Delivery Optimization stopped.

:: Kill OneDrive sync temporarily if running
tasklist | find /i "OneDrive.exe" >nul
if %errorlevel% equ 0 (
    taskkill /f /im OneDrive.exe >nul 2>&1
    echo   [OK] OneDrive paused.
)

echo.
echo  Optimizing Registry for latency...

:: NetworkThrottlingIndex
:: Default is usually 10. ffffffff disables throttling entirely.
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f >nul 2>&1

:: SystemResponsiveness
:: Default is 20 (20% CPU reserved for system). 0 dedicates all to foreground (games).
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f >nul 2>&1

:: TcpAckFrequency and TCPNoDelay (Nagle's Algorithm)
:: These are applied globally to interfaces to prioritize sending small game packets immediately.
for /f "skip=2 tokens=1,2*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"') do (
    reg add "%%A" /v TCPNoDelay /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "%%A" /v TcpAckFrequency /t REG_DWORD /d 1 /f >nul 2>&1
)

echo   [OK] TCP No-Delay and Throttling optimized.

echo.
echo  ============================================================
echo   Gaming Mode is now ACTIVE.
echo   Ping is prioritized. Background downloads are halted.
echo  ============================================================
echo.
pause
exit /b 0

:: -----------------------------------------------------------
:Disable
echo.
echo  Restoring background services...

sc config wuauserv start=auto >nul 2>&1
net start wuauserv >nul 2>&1
echo   [OK] Windows Update enabled.

sc config bits start=auto >nul 2>&1
net start bits >nul 2>&1
echo   [OK] BITS enabled.

sc config DoSvc start=auto >nul 2>&1
net start DoSvc >nul 2>&1
echo   [OK] Delivery Optimization enabled.

:: Restart OneDrive
start "" "%LOCALAPPDATA%\Microsoft\OneDrive\OneDrive.exe" /background >nul 2>&1
echo   [OK] OneDrive restarted.

echo.
echo  Restoring Registry defaults...

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 10 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 20 /f >nul 2>&1

for /f "skip=2 tokens=1,2*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"') do (
    reg delete "%%A" /v TCPNoDelay /f >nul 2>&1
    reg delete "%%A" /v TcpAckFrequency /f >nul 2>&1
)

echo   [OK] TCP defaults restored.

echo.
echo  ============================================================
echo   Gaming Mode DISABLED. System restored to normal.
echo  ============================================================
echo.
pause
exit /b 0
