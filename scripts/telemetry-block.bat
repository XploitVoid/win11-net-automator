@echo off
setlocal EnableDelayedExpansion

:: telemetry-block.bat — Block Windows 11 telemetry via hosts file + firewall
:: Uses hosts file as primary blocker (reliable, domain-level)
:: and firewall rules by resolved IP as secondary layer.

title Windows 11 Telemetry Blocker

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] Need admin rights for firewall changes.
    echo.
    pause
    exit /b 1
)

cls
echo.
echo  ============================================================
echo     Windows 11 Telemetry Blocker
echo  ============================================================
echo.
echo   This script manages firewall rules and hosts entries to
echo   block known Microsoft telemetry endpoints.
echo.
echo     1 - Block telemetry   (add rules + hosts entries)
echo     2 - Unblock telemetry (remove everything)
echo     3 - Check status
echo.

set /p "PICK=   Choice (1-3): "

set "PREFIX=Win11NetAutomator-Telemetry"
set "HOSTS_FILE=%SystemRoot%\System32\drivers\etc\hosts"
set "MARKER=# win11-net-automator telemetry block"

:: Telemetry domains list
set "D_COUNT=0"
for %%D in (
    vortex.data.microsoft.com
    vortex-win.data.microsoft.com
    telecommand.telemetry.microsoft.com
    telecommand.telemetry.microsoft.com.nsatc.net
    oca.telemetry.microsoft.com
    oca.telemetry.microsoft.com.nsatc.net
    sqm.telemetry.microsoft.com
    sqm.telemetry.microsoft.com.nsatc.net
    watson.telemetry.microsoft.com
    watson.telemetry.microsoft.com.nsatc.net
    redir.metaservices.microsoft.com
    choice.microsoft.com
    choice.microsoft.com.nsatc.net
    df.telemetry.microsoft.com
    reports.wes.df.telemetry.microsoft.com
    settings-sandbox.data.microsoft.com
    self.events.data.microsoft.com
    diagnostics.feedback.microsoft.com
) do (
    set "DOMAIN[!D_COUNT!]=%%D"
    set /a D_COUNT+=1
)

if "!PICK!"=="1" goto :DoBlock
if "!PICK!"=="2" goto :DoUnblock
if "!PICK!"=="3" goto :DoStatus

echo  Invalid choice.
echo.
pause
exit /b 1

:: -------------------------------------------------------
:DoBlock
echo.
echo  Adding hosts entries + firewall rules...
echo.

set "ADDED=0"
set "SKIPPED=0"

for /L %%I in (0,1,17) do (
    set "D=!DOMAIN[%%I]!"

    :: --- Hosts file (primary block) ---
    findstr /c:"!D!" "%HOSTS_FILE%" >nul 2>&1
    if !errorlevel! equ 0 (
        echo   [skip] !D! (already in hosts)
        set /a SKIPPED+=1
    ) else (
        echo 0.0.0.0 !D! %MARKER%>> "%HOSTS_FILE%"
        echo   [hosts] !D!
        set /a ADDED+=1
    )

    :: --- Firewall by resolved IP (secondary block) ---
    :: Resolve domain to IP, then block that IP specifically
    for /f "usebackq skip=1 tokens=*" %%R in (`nslookup !D! 2^>nul ^| findstr /r "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" ^| findstr /v "Server:"`) do (
        set "LINE=%%R"
        :: Extract just the IP from "Address:  x.x.x.x"
        for /f "tokens=2 delims=: " %%A in ("!LINE!") do (
            set "RESOLVED_IP=%%A"
            :: Only add if we got something that looks like an IP
            echo !RESOLVED_IP! | findstr /r "^[0-9]" >nul 2>&1
            if !errorlevel! equ 0 (
                netsh advfirewall firewall show rule name="%PREFIX%-!D!" >nul 2>&1
                if !errorlevel! neq 0 (
                    netsh advfirewall firewall add rule name="%PREFIX%-!D!" dir=out action=block remoteip=!RESOLVED_IP! description="Block telemetry: !D!" >nul 2>&1
                    echo   [firewall] !D! ^(!RESOLVED_IP!^)
                )
            )
        )
    )
)

:: Disable telemetry services
echo.
echo  Disabling telemetry services...

sc config DiagTrack start=disabled >nul 2>&1
sc stop DiagTrack >nul 2>&1
echo   [OK] DiagTrack (Connected User Experiences and Telemetry)

sc config dmwappushservice start=disabled >nul 2>&1
sc stop dmwappushservice >nul 2>&1
echo   [OK] dmwappushservice (WAP Push Message Routing)

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
echo   [OK] Registry: AllowTelemetry = 0

echo.
echo  ============================================================
echo   Done. Added %ADDED% new entries, %SKIPPED% already blocked.
echo   Services disabled, telemetry registry key set.
echo  ============================================================
echo.
pause
exit /b 0

:: -------------------------------------------------------
:DoUnblock
echo.
echo  Removing all telemetry blocks...
echo.

:: --- Remove firewall rules ---
set "REMOVED=0"
for /L %%I in (0,1,17) do (
    set "D=!DOMAIN[%%I]!"
    netsh advfirewall firewall delete rule name="%PREFIX%-!D!" >nul 2>&1
    if !errorlevel! equ 0 (
        echo   [firewall removed] !D!
        set /a REMOVED+=1
    )
)

:: --- Clean hosts file in one pass ---
:: Remove all lines that contain our marker comment
findstr /v /c:"%MARKER%" "%HOSTS_FILE%" > "%TEMP%\hosts_clean.tmp" 2>nul
if !errorlevel! leq 1 (
    copy /y "%TEMP%\hosts_clean.tmp" "%HOSTS_FILE%" >nul 2>&1
    del "%TEMP%\hosts_clean.tmp" >nul 2>&1
    echo   [OK] Hosts file cleaned (single pass)
)

:: Re-enable services
sc config DiagTrack start=auto >nul 2>&1
sc start DiagTrack >nul 2>&1
echo   [OK] DiagTrack re-enabled

sc config dmwappushservice start=auto >nul 2>&1
sc start dmwappushservice >nul 2>&1
echo   [OK] dmwappushservice re-enabled

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 3 /f >nul 2>&1
echo   [OK] Registry: AllowTelemetry = 3 (full)

echo.
echo  ============================================================
echo   Removed %REMOVED% firewall rule(s). Hosts cleaned.
echo   Services re-enabled.
echo  ============================================================
echo.
pause
exit /b 0

:: -------------------------------------------------------
:DoStatus
echo.
echo  Current telemetry block status:
echo  -----------------------------------------------------------
echo.

set "FW_COUNT=0"
set "HOST_COUNT=0"

for /L %%I in (0,1,17) do (
    set "D=!DOMAIN[%%I]!"
    set "STATUS="

    netsh advfirewall firewall show rule name="%PREFIX%-!D!" >nul 2>&1
    if !errorlevel! equ 0 (
        set "STATUS=!STATUS! firewall"
        set /a FW_COUNT+=1
    )

    findstr /c:"!D!" "%HOSTS_FILE%" >nul 2>&1
    if !errorlevel! equ 0 (
        set "STATUS=!STATUS! hosts"
        set /a HOST_COUNT+=1
    )

    if defined STATUS (
        echo   [BLOCKED] !D! (!STATUS:~1!)
    )
)

if %FW_COUNT% equ 0 if %HOST_COUNT% equ 0 (
    echo   No telemetry blocks found.
)

echo.
echo   Firewall rules: %FW_COUNT%  |  Hosts entries: %HOST_COUNT%
echo.
echo  Service status:
for %%S in (DiagTrack dmwappushservice) do (
    for /f "tokens=3" %%T in ('sc query %%S 2^>nul ^| findstr "STATE"') do (
        echo   %%S: %%T
    )
)

echo.
pause
exit /b 0
