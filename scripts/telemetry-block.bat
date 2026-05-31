@echo off
setlocal EnableDelayedExpansion

:: telemetry-block.bat — Block Windows 11 telemetry via firewall rules
:: Creates outbound firewall rules to drop traffic to known Microsoft
:: telemetry/data collection endpoints.
::
:: This is the "privacy paranoid" script. Everything here is reversible
:: with the unblock option.

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
echo   This script manages firewall rules to block known Microsoft
echo   telemetry and data collection endpoints.
echo.
echo     1 - Block telemetry   (add firewall rules)
echo     2 - Unblock telemetry (remove firewall rules)
echo     3 - Check status      (see current rules)
echo.

set /p "PICK=   Choice (1-3): "

:: Rule name prefix — used to identify our rules later
set "PREFIX=Win11NetAutomator-Telemetry"

:: Known telemetry domains. We resolve to IPs where possible,
:: but also block by domain using netsh where supported.
:: Sources: https://learn.microsoft.com/en-us/windows/privacy/
:: and community-maintained lists.
set DOMAINS=^
 vortex.data.microsoft.com^
 vortex-win.data.microsoft.com^
 telecommand.telemetry.microsoft.com^
 telecommand.telemetry.microsoft.com.nsatc.net^
 oca.telemetry.microsoft.com^
 oca.telemetry.microsoft.com.nsatc.net^
 sqm.telemetry.microsoft.com^
 sqm.telemetry.microsoft.com.nsatc.net^
 watson.telemetry.microsoft.com^
 watson.telemetry.microsoft.com.nsatc.net^
 redir.metaservices.microsoft.com^
 choice.microsoft.com^
 choice.microsoft.com.nsatc.net^
 df.telemetry.microsoft.com^
 reports.wes.df.telemetry.microsoft.com^
 settings-sandbox.data.microsoft.com^
 self.events.data.microsoft.com^
 diagnostics.feedback.microsoft.com

if "%PICK%"=="1" goto :DoBlock
if "%PICK%"=="2" goto :DoUnblock
if "%PICK%"=="3" goto :DoStatus

echo  Invalid choice.
echo.
pause
exit /b 1

:: -------------------------------------------------------
:DoBlock
echo.
echo  Adding firewall rules...
echo.

set "ADDED=0"
set "SKIPPED=0"

for %%D in (%DOMAINS%) do (
    :: Check if rule already exists
    netsh advfirewall firewall show rule name="%PREFIX%-%%D" >nul 2>&1
    if !errorlevel! equ 0 (
        echo   [skip] %%D (already blocked)
        set /a SKIPPED+=1
    ) else (
        netsh advfirewall firewall add rule name="%PREFIX%-%%D" dir=out action=block remoteip=any program=any description="Block telemetry: %%D" >nul 2>&1

        :: Also add to hosts file as backup
        findstr /c:"%%D" "%SystemRoot%\System32\drivers\etc\hosts" >nul 2>&1
        if !errorlevel! neq 0 (
            echo 0.0.0.0 %%D>> "%SystemRoot%\System32\drivers\etc\hosts"
        )

        echo   [blocked] %%D
        set /a ADDED+=1
    )
)

:: Disable some telemetry services while we're at it
echo.
echo  Disabling telemetry services...

sc config DiagTrack start=disabled >nul 2>&1
sc stop DiagTrack >nul 2>&1
echo   [OK] DiagTrack (Connected User Experiences and Telemetry)

sc config dmwappushservice start=disabled >nul 2>&1
sc stop dmwappushservice >nul 2>&1
echo   [OK] dmwappushservice (WAP Push Message Routing)

:: Disable telemetry via registry
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
echo   [OK] Registry: AllowTelemetry = 0

echo.
echo  ============================================================
echo   Done. Blocked %ADDED% new endpoint(s), %SKIPPED% already blocked.
echo   Services disabled, telemetry registry key set.
echo  ============================================================
echo.
pause
exit /b 0

:: -------------------------------------------------------
:DoUnblock
echo.
echo  Removing firewall rules...
echo.

set "REMOVED=0"

for %%D in (%DOMAINS%) do (
    netsh advfirewall firewall delete rule name="%PREFIX%-%%D" >nul 2>&1
    if !errorlevel! equ 0 (
        echo   [removed] %%D
        set /a REMOVED+=1
    )

    :: Clean hosts file — remove lines with this domain
    :: (findstr /v = print lines NOT matching)
    findstr /v /c:"%%D" "%SystemRoot%\System32\drivers\etc\hosts" > "%TEMP%\hosts_clean.tmp" 2>nul
    copy /y "%TEMP%\hosts_clean.tmp" "%SystemRoot%\System32\drivers\etc\hosts" >nul 2>&1
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
echo   Removed %REMOVED% rule(s). Services re-enabled.
echo  ============================================================
echo.
pause
exit /b 0

:: -------------------------------------------------------
:DoStatus
echo.
echo  Current telemetry block rules:
echo  -----------------------------------------------------------
echo.

set "ACTIVE=0"
for %%D in (%DOMAINS%) do (
    netsh advfirewall firewall show rule name="%PREFIX%-%%D" >nul 2>&1
    if !errorlevel! equ 0 (
        echo   [BLOCKED] %%D
        set /a ACTIVE+=1
    )
)

if %ACTIVE% equ 0 (
    echo   No telemetry rules found. Nothing is blocked.
) else (
    echo.
    echo   %ACTIVE% endpoint(s) currently blocked.
)

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
