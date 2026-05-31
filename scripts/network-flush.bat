@echo off
setlocal EnableDelayedExpansion

:: network-flush.bat — Full network stack reset
:: The "turn it off and on again" of networking, but automated.

title Network Flush and Reset

:: Need admin for netsh resets
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] Run this as Administrator.
    echo.
    pause
    exit /b 1
)

cls
echo.
echo  ============================================================
echo     Network Flush ^& Reset
echo  ============================================================
echo.
echo   Going to run:
echo     1. ipconfig /flushdns
echo     2. ipconfig /release
echo     3. ipconfig /renew
echo     4. netsh winsock reset
echo     5. netsh int ip reset
echo.
echo  ============================================================
echo.
timeout /t 2 /nobreak >nul

set "FAILS=0"

:: -- 1. Flush DNS --
echo  [1/5] Flushing DNS cache...
ipconfig /flushdns
if %errorlevel% neq 0 (
    echo    Warning: something went wrong
    set /a FAILS+=1
) else (
    echo   OK
)
echo.

:: -- 2. Release IP --
echo  [2/5] Releasing IP address...
ipconfig /release
if %errorlevel% neq 0 (
    echo    Warning: release failed (might be fine on static IP)
    set /a FAILS+=1
) else (
    echo   OK
)
echo.

:: -- 3. Renew IP --
echo  [3/5] Renewing IP address...
echo   (This might take up to 30 seconds if your DHCP is slow)
ipconfig /renew
if %errorlevel% neq 0 (
    echo    Warning: renew failed
    set /a FAILS+=1
) else (
    echo   OK
)
echo.

:: -- 4. Winsock reset --
:: This clears the Winsock catalog. Fixes issues caused by
:: broken LSPs or VPN remnants that mess with the network stack.
echo  [4/5] Resetting Winsock...
netsh winsock reset
if %errorlevel% neq 0 (
    echo    Warning: winsock reset had issues
    set /a FAILS+=1
) else (
    echo   OK
)
echo.

:: -- 5. TCP/IP reset --
:: Rewrites the TCP/IP registry keys back to defaults.
:: Pretty much a clean slate for the IP stack.
echo  [5/5] Resetting TCP/IP stack...
netsh int ip reset
if %errorlevel% neq 0 (
    echo    Warning: TCP/IP reset had issues
    set /a FAILS+=1
) else (
    echo   OK
)
echo.

:: Summary
echo  ============================================================
if %FAILS% equ 0 (
    echo   All done, no errors.
) else (
    echo   Done with %FAILS% warning(s). Check the output above.
)
echo  ============================================================
echo.
echo   You should probably restart for the Winsock/TCP changes
echo   to fully take effect.
echo.

choice /c YN /m "  Restart now?"
if %errorlevel% equ 1 (
    echo.
    echo   Restarting in 15 seconds... (close this window to cancel)
    shutdown /r /t 15 /c "Network reset - restarting"
)

echo.
pause
exit /b 0
