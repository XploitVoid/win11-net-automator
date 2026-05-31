@echo off
setlocal EnableDelayedExpansion

:: adguard-routing.bat — Route DNS to a local AdGuard Home instance
:: Detects Wi-Fi/Ethernet automatically, asks for the AG IP, applies it.

title AdGuard Home DNS Setup

:: Admin check
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] This needs to run as Administrator.
    echo  Right-click the script ^> Run as administrator.
    echo.
    pause
    exit /b 1
)

cls
echo.
echo  ============================================================
echo     AdGuard Home — DNS Routing Setup
echo  ============================================================
echo.
echo   This will set your local AdGuard Home server as the
echo   primary DNS resolver on your active network adapter.
echo.

:: -----------------------------------------------------------
:: Figure out which adapter is connected
:: Check for Wi-Fi first (more common on laptops), then Ethernet
:: -----------------------------------------------------------

set "IFACE="

for /f "tokens=*" %%A in ('netsh interface show interface ^| findstr /i "Connected"') do (
    echo %%A | findstr /i "Wi-Fi" >nul && (
        if not defined IFACE set "IFACE=Wi-Fi"
    )
    echo %%A | findstr /i "Ethernet" >nul && (
        if not defined IFACE set "IFACE=Ethernet"
    )
)

if not defined IFACE (
    echo  [ERROR] No active Wi-Fi or Ethernet adapter found.
    echo  Make sure you're connected to a network first.
    echo.
    pause
    exit /b 1
)

echo  Using adapter: %IFACE%
echo.

:: -----------------------------------------------------------
:: Ask for the AdGuard Home IP
:: Basic validation — just check it's not empty and has a dot
:: (proper IP validation in batch is painful, this is good enough)
:: -----------------------------------------------------------

:AskIP
set "AG_IP="
set /p "AG_IP=  AdGuard Home IP address: "

if not defined AG_IP (
    echo  Please enter something.
    echo.
    goto AskIP
)

:: Sanity check
echo !AG_IP! | findstr /r "\." >nul
if %errorlevel% neq 0 (
    echo  That doesn't look like an IP. Example: 192.168.1.100
    echo.
    goto AskIP
)

echo.
echo  Will set DNS on "%IFACE%" to %AG_IP%
echo.
set /p "OK=  Look good? (Y/N): "
if /i not "!OK!"=="Y" (
    echo.
    echo  Cancelled.
    echo.
    pause
    exit /b 0
)

echo.

:: Apply it
echo  Setting DNS...
netsh interface ip set dns name="%IFACE%" static %AG_IP% primary >nul 2>&1

if %errorlevel% neq 0 (
    echo  [ERROR] netsh failed. Double-check the IP and adapter name.
    echo.
    pause
    exit /b 1
)

echo  [OK] DNS set to %AG_IP%

:: Flush the cache so it takes effect right away
echo  Flushing DNS cache...
ipconfig /flushdns >nul 2>&1
echo  [OK] Cache cleared.
echo.

echo  ============================================================
echo   All done. DNS is now pointing to %AG_IP%
echo  ============================================================
echo.
echo   To undo this later:
echo   netsh interface ip set dns "%IFACE%" dhcp
echo.

pause
exit /b 0
