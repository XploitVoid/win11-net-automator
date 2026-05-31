@echo off
setlocal EnableDelayedExpansion

:: auto-healer.bat — Network connection monitor and auto-restarter.
:: Pings a reliable server and resets the adapter if the connection drops.

title Auto-Healer (Network Monitor)

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] Auto-Healer needs Administrator rights to restart adapters.
    echo.
    pause
    exit /b 1
)

cls
echo.
echo  ============================================================
echo     Network Auto-Healer
echo  ============================================================
echo.
echo   This script runs in the background. It checks your internet
echo   every 10 seconds. If it drops completely, it will try to
echo   automatically restart your network adapter to fix it.
echo.
echo   Keep this window open. Press Ctrl+C to stop.
echo.
echo  -----------------------------------------------------------

:: Find active adapter to restart if needed
set "ADAPTER="
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command ^
    "(Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and (Get-NetIPConfiguration -InterfaceIndex $_.ifIndex -ErrorAction SilentlyContinue).IPv4DefaultGateway } | Select-Object -First 1).Name"`) do (
    set "ADAPTER=%%A"
)

if not defined ADAPTER (
    echo  [ERROR] No active adapter found. Connect to the internet first.
    echo.
    pause
    exit /b 1
)

echo   Monitoring Adapter: !ADAPTER!
echo   Target: 8.8.8.8 (Google DNS)
echo  -----------------------------------------------------------
echo.

set "FAIL_COUNT=0"

:MonitorLoop
:: Ping once, wait 2 seconds for timeout
ping -n 1 -w 2000 8.8.8.8 >nul 2>&1

if %errorlevel% neq 0 (
    set /a FAIL_COUNT+=1
    echo  [%TIME:~0,8%] Connection failed (Strike !FAIL_COUNT!/3)
    
    if !FAIL_COUNT! geq 3 (
        echo.
        echo  [!TIME:~0,8!] Internet down! Attempting auto-heal...
        
        :: Reset adapter
        echo  [!TIME:~0,8!] Disabling !ADAPTER!...
        powershell -NoProfile -Command "Disable-NetAdapter -Name '!ADAPTER!' -Confirm:$false" >nul 2>&1
        
        timeout /t 3 /nobreak >nul
        
        echo  [!TIME:~0,8!] Enabling !ADAPTER!...
        powershell -NoProfile -Command "Enable-NetAdapter -Name '!ADAPTER!' -Confirm:$false" >nul 2>&1
        
        :: Reset fail count to give it time to reconnect
        set "FAIL_COUNT=-3"
        echo  [!TIME:~0,8!] Auto-heal triggered. Waiting for reconnection...
        echo.
    )
) else (
    if !FAIL_COUNT! neq 0 (
        :: If fail count was negative, it means we just recovered from a heal
        if !FAIL_COUNT! lss 0 (
            echo  [%TIME:~0,8%] Connection restored after auto-heal.
        ) else (
            echo  [%TIME:~0,8%] Connection stable.
        )
    )
    set "FAIL_COUNT=0"
)

:: Wait 10 seconds before next check
timeout /t 10 /nobreak >nul
goto MonitorLoop
