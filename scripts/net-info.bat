@echo off
setlocal EnableDelayedExpansion

:: net-info.bat — Network Dashboard
:: Gathers local IP, public IP, MAC, DNS, and current ping into one clean view.

title Network Dashboard

echo.
echo  ============================================================
echo     Network Dashboard
echo  ============================================================
echo.
echo   Gathering network info... (this might take a few seconds)
echo.

:: -----------------------------------------------------------
:: 1. Find Active Adapter and Local IP
:: -----------------------------------------------------------
set "ADAPTER="
set "LOCAL_IP="
set "MAC="
set "SPEED="

for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command ^
    "$net = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and (Get-NetIPConfiguration -InterfaceIndex $_.ifIndex -ErrorAction SilentlyContinue).IPv4DefaultGateway } | Select-Object -First 1; if ($net) { Write-Output ($net.Name + '|' + $net.MacAddress + '|' + $net.LinkSpeed) }"`) do (
    for /f "tokens=1,2,3 delims=|" %%N in ("%%A") do (
        set "ADAPTER=%%N"
        set "MAC=%%O"
        set "SPEED=%%P"
    )
)

if not defined ADAPTER (
    echo  [ERROR] No active network connection found.
    echo.
    pause
    exit /b 1
)

:: Get Local IP
for /f "usebackq tokens=*" %%I in (`powershell -NoProfile -Command ^
    "(Get-NetIPAddress -InterfaceAlias '!ADAPTER!' -AddressFamily IPv4).IPAddress"`) do (
    set "LOCAL_IP=%%I"
)

:: -----------------------------------------------------------
:: 2. Get DNS Servers
:: -----------------------------------------------------------
set "DNS_SERVERS="
for /f "usebackq tokens=*" %%D in (`powershell -NoProfile -Command ^
    "(Get-DnsClientServerAddress -InterfaceAlias '!ADAPTER!' -AddressFamily IPv4).ServerAddresses -join ', '"`) do (
    set "DNS_SERVERS=%%D"
)

:: -----------------------------------------------------------
:: 3. Get Public IP (via ifconfig.me)
:: -----------------------------------------------------------
set "PUBLIC_IP="
for /f "usebackq tokens=*" %%P in (`powershell -NoProfile -Command ^
    "try { (Invoke-RestMethod -Uri 'https://ifconfig.me/ip' -TimeoutSec 5) } catch { 'Unavailable' }"`) do (
    set "PUBLIC_IP=%%P"
)

:: -----------------------------------------------------------
:: 4. Ping Test (Google DNS)
:: -----------------------------------------------------------
set "PING_MS="
for /f "usebackq tokens=*" %%M in (`powershell -NoProfile -Command ^
    "$p = Get-WmiObject Win32_PingStatus -Filter \"Address='8.8.8.8'\"; if ($p.StatusCode -eq 0) { Write-Output ($p.ResponseTime.ToString() + 'ms') } else { Write-Output 'Timeout' }"`) do (
    set "PING_MS=%%M"
)
if not defined PING_MS set "PING_MS=Timeout"

:: -----------------------------------------------------------
:: Display Dashboard
:: -----------------------------------------------------------
cls
echo.
echo  ============================================================
echo     Network Dashboard
echo  ============================================================
echo.
echo   Adapter:      !ADAPTER!
echo   Link Speed:   !SPEED!
echo   MAC Address:  !MAC!
echo.
echo   Local IP:     !LOCAL_IP!
echo   Public IP:    !PUBLIC_IP!
echo.
echo   DNS Servers:  !DNS_SERVERS!
echo   Ping (8.8.8.8): !PING_MS!
echo.
echo  ============================================================
echo.

endlocal
pause
exit /b 0
