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

:: Get all saved profile names
set "COUNT=0"
set "FOUND=0"

for /f "tokens=2 delims=:" %%P in ('netsh wlan show profiles ^| findstr /c:"All User Profile"') do (
    set /a COUNT+=1

    :: Trim leading space
    set "PROFILE=%%P"
    set "PROFILE=!PROFILE:~1!"

    :: Try to extract the password (Key Content line)
    set "KEY="
    for /f "tokens=2 delims=:" %%K in ('netsh wlan show profile name^="!PROFILE!" key^=clear 2^>nul ^| findstr /c:"Key Content"') do (
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
