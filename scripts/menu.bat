@echo off
setlocal EnableDelayedExpansion

:: menu.bat — Main hub for Win11 Net Automator
:: Lists all available scripts and lets you run them by number.

title Win11 Net Automator - Main Menu

:: Force run in the script directory so it can find the other bats
cd /d "%~dp0"

:MenuLoop
cls
echo.
echo  ============================================================
echo     🌐 Win11 Net Automator
echo  ============================================================
echo.
echo   [ Dashboards ^& Info ]
echo     1. Network Dashboard     (net-info.bat)
echo     2. DNS Benchmark         (dns-benchmark.bat)
echo     3. Saved Wi-Fi Passwords (wifi-passwords.bat)
echo.
echo   [ Tuning ^& Fixing ]
echo     4. Network Flush ^& Reset  (network-flush.bat)
echo     5. TCP/MTU Speed Tuner   (speed-tuner.bat) - *Coming soon*
echo     6. Gaming Network Mode   (gaming-mode.bat) - *Coming soon*
echo     7. Auto-Healer Monitor   (auto-healer.bat) - *Coming soon*
echo.
echo   [ Privacy ^& Routing ]
echo     8. Enable DNS over HTTPS (enable-doh.bat)
echo     9. AdGuard Home Routing  (adguard-routing.bat)
echo    10. System-wide Adblock   (hosts-adblock.bat)
echo    11. Windows Telemetry Blocker (telemetry-block.bat)
echo    12. MAC Address Spoofer   (mac-spoof.bat)
echo.
echo   [ Misc ]
echo    13. Lenovo Legion Toolkit Sync (lltk-profile-sync.bat)
echo    14. Mobile Hotspot Manager (hotspot-manager.bat) - *Coming soon*
echo.
echo     0. Exit
echo.

set /p "PICK=   Choice: "

if "%PICK%"=="1" start "" cmd /c "net-info.bat"
if "%PICK%"=="2" start "" cmd /c "dns-benchmark.bat"
if "%PICK%"=="3" start "" cmd /c "wifi-passwords.bat"
if "%PICK%"=="4" start "" cmd /c "network-flush.bat"
if "%PICK%"=="8" start "" cmd /c "enable-doh.bat"
if "%PICK%"=="9" start "" cmd /c "adguard-routing.bat"
if "%PICK%"=="10" start "" cmd /c "hosts-adblock.bat"
if "%PICK%"=="11" start "" cmd /c "telemetry-block.bat"
if "%PICK%"=="12" start "" cmd /c "mac-spoof.bat"
if "%PICK%"=="13" start "" cmd /c "lltk-profile-sync.bat"

:: The "Coming Soon" ones (for now)
if "%PICK%"=="5" start "" cmd /c "speed-tuner.bat"
if "%PICK%"=="6" start "" cmd /c "gaming-mode.bat"
if "%PICK%"=="7" start "" cmd /c "auto-healer.bat"
if "%PICK%"=="14" start "" cmd /c "hotspot-manager.bat"

if "%PICK%"=="0" exit /b 0

goto MenuLoop
