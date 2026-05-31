@echo off
setlocal EnableDelayedExpansion

:: lltk-profile-sync.bat
:: Quick power profile switcher for Lenovo Legion Toolkit
::
:: You need:
::   - Lenovo Legion Toolkit installed
::     https://github.com/BartoszCichworthy/LenovoLegionToolkit
::   - LenovoToolkitCLI.exe in your system PATH

title LLTK Profile Sync

echo.
echo  =========================================================
echo   LLTK Profile Sync
echo  =========================================================
echo.

:: Make sure LLTK is actually accessible
where LenovoToolkitCLI.exe >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo  Can't find LenovoToolkitCLI.exe in PATH.
    echo.
    echo  Install Lenovo Legion Toolkit and add it to PATH first.
    echo  https://github.com/BartoszCichworthy/LenovoLegionToolkit
    echo.
    goto :Done
)

echo   Pick a profile:
echo.
echo     1 - Quiet         (low fans, power saving)
echo     2 - Balance        (middle ground)
echo     3 - Performance    (full send)
echo.

set /p "PICK=   Choice (1-3): "

set "PICK=!PICK: =!"

if "!PICK!"=="1" (
    set "PROFILE=quiet"
    set "LABEL=Quiet"
) else if "!PICK!"=="2" (
    set "PROFILE=balance"
    set "LABEL=Balance"
) else if "!PICK!"=="3" (
    set "PROFILE=performance"
    set "LABEL=Performance"
) else (
    echo.
    echo  Invalid choice: "!PICK!"
    echo  Run again and pick 1, 2, or 3.
    echo.
    goto :Done
)

echo.
echo  Switching to %LABEL%...

LenovoToolkitCLI.exe quickAction --name "%PROFILE%" >nul 2>&1
set "RC=%ERRORLEVEL%"

echo.
if %RC% equ 0 (
    echo  [OK] Profile set to %LABEL%.
) else (
    echo  [ERROR] Failed (exit code %RC%). Is LLTK running?
)

echo.

:Done
endlocal
pause
