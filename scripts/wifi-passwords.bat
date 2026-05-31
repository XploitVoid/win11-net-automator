@echo off
setlocal EnableDelayedExpansion

:: wifi-passwords.bat — Show saved Wi-Fi passwords
:: Pulls all saved profiles from netsh and grabs the key for each one

title Wi-Fi Password Viewer

:: Admin not strictly required for this, but some profiles
:: might hide the key without elevation
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [WARN] Not running as admin — some passwords might be hidden.
    echo  For best results, run as administrator.
    echo.
)

cls
echo.
echo  ============================================================
echo     Saved Wi-Fi Passwords
echo  ============================================================
echo.

set "COUNT=0"
set "FOUND=0"

:: tokens=1,* with delims=: grabs everything after the first colon
:: so SSIDs containing ":" won't get truncated
for /f "tokens=1,* delims=:" %%P in ('netsh wlan show profiles ^| findstr /c:"All User Profile"') do (
    set /a COUNT+=1

    :: %%Q has everything after "All User Profile:", trim leading space
    set "PROFILE=%%Q"
    set "PROFILE=!PROFILE:~1!"

    :: Extract password — same trick with tokens=1,* to preserve ":" in passwords
    set "KEY="
    for /f "tokens=1,* delims=:" %%J in ('netsh wlan show profile name^="!PROFILE!" key^=clear 2^>nul ^| findstr /c:"Key Content"') do (
        set "KEY=%%K"
        set "KEY=!KEY:~1!"
    )

    if defined KEY (
        set /a FOUND+=1
        echo   !PROFILE!
        echo     Password: !KEY!
        echo.
    ) else (
        echo   !PROFILE!
        echo     Password: (not stored / open network)
        echo.
    )
)

if %COUNT% equ 0 (
    echo   No saved Wi-Fi profiles found.
    echo.
)

echo  ============================================================
echo   Found %FOUND% password(s) across %COUNT% profile(s).
echo  ============================================================
echo.

endlocal
pause
