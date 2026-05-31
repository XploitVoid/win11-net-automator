@echo off
setlocal EnableDelayedExpansion

:: enable-doh.bat — Sets up DNS over HTTPS on Win11
:: Uses Cloudflare (1.1.1.1 / 1.0.0.1) and Google (8.8.8.8 / 8.8.4.4)

title Enable DNS over HTTPS
color 0B

echo.
echo  ============================================================
echo     DNS over HTTPS (DoH) Setup
echo  ============================================================
echo.

:: Admin check
net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo  [ERROR] Not running as admin. Right-click ^> Run as administrator.
    echo.
    pause
    exit /b 1
)

echo  [OK] Admin privileges confirmed.
echo.

:: -----------------------------------------------------------
:: Register DoH templates with netsh
:: Win11 needs these registered before it'll use DoH for a server.
:: If the entry already exists, "add" fails, so we try "set" instead.
:: -----------------------------------------------------------

echo  Registering DoH server templates...
echo  -----------------------------------------------------------
echo.

:: Cloudflare 1.1.1.1
echo  - Cloudflare 1.1.1.1
netsh dns add encryption server=1.1.1.1 dohtemplate=https://cloudflare-dns.com/dns-query autoupgrade=yes udpfallback=no >nul 2>&1
if %errorlevel% neq 0 (
    netsh dns set encryption server=1.1.1.1 dohtemplate=https://cloudflare-dns.com/dns-query autoupgrade=yes udpfallback=no >nul 2>&1
    echo    updated (was already registered^)
) else (
    echo    registered
)

:: Cloudflare 1.0.0.1
echo  - Cloudflare 1.0.0.1
netsh dns add encryption server=1.0.0.1 dohtemplate=https://cloudflare-dns.com/dns-query autoupgrade=yes udpfallback=no >nul 2>&1
if %errorlevel% neq 0 (
    netsh dns set encryption server=1.0.0.1 dohtemplate=https://cloudflare-dns.com/dns-query autoupgrade=yes udpfallback=no >nul 2>&1
    echo    updated (was already registered^)
) else (
    echo    registered
)

:: Google 8.8.8.8
echo  - Google 8.8.8.8
netsh dns add encryption server=8.8.8.8 dohtemplate=https://dns.google/dns-query autoupgrade=yes udpfallback=no >nul 2>&1
if %errorlevel% neq 0 (
    netsh dns set encryption server=8.8.8.8 dohtemplate=https://dns.google/dns-query autoupgrade=yes udpfallback=no >nul 2>&1
    echo    updated (was already registered^)
) else (
    echo    registered
)

:: Google 8.8.4.4
echo  - Google 8.8.4.4
netsh dns add encryption server=8.8.4.4 dohtemplate=https://dns.google/dns-query autoupgrade=yes udpfallback=no >nul 2>&1
if %errorlevel% neq 0 (
    netsh dns set encryption server=8.8.4.4 dohtemplate=https://dns.google/dns-query autoupgrade=yes udpfallback=no >nul 2>&1
    echo    updated (was already registered^)
) else (
    echo    registered
)

echo.

:: -----------------------------------------------------------
:: Find the active adapter (one that has a default gateway)
:: -----------------------------------------------------------

echo  Looking for active network adapter...

for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command ^
    "(Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and (Get-NetIPConfiguration -InterfaceIndex $_.ifIndex -ErrorAction SilentlyContinue).IPv4DefaultGateway } | Select-Object -First 1).Name"`) do (
    set "ADAPTER=%%A"
)

if not defined ADAPTER (
    color 0C
    echo  [ERROR] Couldn't find an active adapter. Are you connected?
    echo.
    pause
    exit /b 1
)

echo  [OK] Using: "!ADAPTER!"
echo.

:: -----------------------------------------------------------
:: Assign all 4 DNS servers to the adapter
:: Try PowerShell first, fall back to netsh if that fails
:: -----------------------------------------------------------

echo  Configuring DNS on "!ADAPTER!"...

powershell -NoProfile -Command ^
    "Set-DnsClientServerAddress -InterfaceAlias '!ADAPTER!' -ServerAddresses ('1.1.1.1','1.0.0.1','8.8.8.8','8.8.4.4'); if (-not $?) { exit 1 }" 2>nul

if %errorlevel% neq 0 (
    echo  PowerShell failed, trying netsh...
    netsh interface ipv4 set dnsservers name="!ADAPTER!" static 1.1.1.1 primary validate=no >nul 2>&1
    netsh interface ipv4 add dnsservers name="!ADAPTER!" 1.0.0.1 index=2 validate=no >nul 2>&1
    netsh interface ipv4 add dnsservers name="!ADAPTER!" 8.8.8.8 index=3 validate=no >nul 2>&1
    netsh interface ipv4 add dnsservers name="!ADAPTER!" 8.8.4.4 index=4 validate=no >nul 2>&1
)

echo  [OK] DNS servers set.
echo.

:: -----------------------------------------------------------
:: Write DoH registry flags
:: DohFlags = 2 means "encrypted only" (no plaintext fallback)
:: This is per-server, under the adapter's GUID in the Dnscache key
:: -----------------------------------------------------------

echo  Enabling DoH enforcement via registry...

set "REG_BASE=HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters"

:: Grab adapter GUID
for /f "usebackq delims=" %%G in (`powershell -NoProfile -Command ^
    "(Get-NetAdapter -Name '!ADAPTER!').InterfaceGuid"`) do (
    set "IF_GUID=%%G"
)

if not defined IF_GUID (
    echo  [WARN] Couldn't get adapter GUID. You may need to enable DoH manually in Settings.
    echo.
    goto :FlushDNS
)

:: Set DohFlags=2 for each server
for %%S in (1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4) do (
    reg add "%REG_BASE%\!IF_GUID!\DohInterfaceSettings\Doh\%%S" /v DohFlags /t REG_DWORD /d 2 /f >nul 2>&1
    if !errorlevel! neq 0 (
        echo  [WARN] Registry write failed for %%S
    )
)

echo  [OK] DoH flags written.
echo.

:FlushDNS
:: Flush and show results
ipconfig /flushdns >nul 2>&1
echo  [OK] DNS cache flushed.
echo.

:: Quick verification
echo  Current DNS config for "!ADAPTER!":
echo.
powershell -NoProfile -Command ^
    "Get-DnsClientServerAddress -InterfaceAlias '!ADAPTER!' -AddressFamily IPv4 | Format-Table -Property ServerAddresses -AutoSize"

echo.
echo  ============================================================
echo   Done! DoH is now active.
echo  ============================================================
echo.
echo   DNS:  1.1.1.1 / 1.0.0.1 (Cloudflare)
echo         8.8.8.8 / 8.8.4.4 (Google)
echo   Mode: Encrypted only
echo.
echo   You might need to restart the adapter or reboot for
echo   everything to kick in.
echo.

endlocal
pause
exit /b 0
