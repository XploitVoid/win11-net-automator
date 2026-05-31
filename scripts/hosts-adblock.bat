@echo off
setlocal EnableDelayedExpansion

:: hosts-adblock.bat — System-wide Ad and Malware Blocking
:: Downloads the StevenBlack hosts file and applies it to Windows.
:: Completely reversible.

title System-wide Adblock (Hosts)

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] Need admin rights to modify the hosts file.
    echo.
    pause
    exit /b 1
)

set "HOSTS_FILE=%SystemRoot%\System32\drivers\etc\hosts"
set "BACKUP_FILE=%SystemRoot%\System32\drivers\etc\hosts.win11net.bak"
set "URL=https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"

cls
echo.
echo  ============================================================
echo     System-wide Adblock (Hosts File)
echo  ============================================================
echo.
echo   This uses the famous StevenBlack hosts list to block
echo   ads, malware, and tracking system-wide without needing
echo   browser extensions.
echo.
echo     1 - Enable Adblock  (Download and apply list)
echo     2 - Disable Adblock (Restore original hosts file)
echo.

set /p "PICK=   Choice (1-2): "

if "!PICK!"=="1" goto :Enable
if "!PICK!"=="2" goto :Disable

echo  Invalid choice.
echo.
pause
exit /b 1

:: -----------------------------------------------------------
:Enable
echo.
echo  Backing up current hosts file...
if not exist "%BACKUP_FILE%" (
    copy /y "%HOSTS_FILE%" "%BACKUP_FILE%" >nul 2>&1
    echo   [OK] Backup created.
) else (
    echo   [OK] Backup already exists, keeping original.
)

echo.
echo  Downloading latest adblock list...
echo  (This is about 3MB, might take a moment)

:: Download to a temp file first
set "TEMP_HOSTS=%TEMP%\adblock_hosts.txt"
powershell -NoProfile -Command ^
    "try { Invoke-WebRequest -Uri '%URL%' -OutFile '%TEMP_HOSTS%' -UseBasicParsing; exit 0 } catch { exit 1 }"

if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] Failed to download the list. Check your internet.
    echo.
    pause
    exit /b 1
)

echo   [OK] Download complete.

echo.
echo  Applying to system...

:: Check if telemetry-block.bat has added entries to the current hosts file
:: If so, preserve them by appending them to our newly downloaded adblock list
set "MARKER=# win11-net-automator telemetry block"
findstr /c:"%MARKER%" "%HOSTS_FILE%" > "%TEMP%\telemetry_preserve.tmp" 2>nul
if %errorlevel% equ 0 (
    echo.>> "%TEMP_HOSTS%"
    echo %MARKER%>> "%TEMP_HOSTS%"
    type "%TEMP%\telemetry_preserve.tmp" >> "%TEMP_HOSTS%"
    echo   [OK] Preserved existing telemetry block rules.
)
del "%TEMP%\telemetry_preserve.tmp" >nul 2>&1

:: Apply the combined list to the system
copy /y "%TEMP_HOSTS%" "%HOSTS_FILE%" >nul 2>&1

ipconfig /flushdns >nul 2>&1

echo   [OK] Hosts file updated and DNS flushed.
echo.
echo  ============================================================
echo   Adblock is now ACTIVE.
echo   Ads and trackers will fail to load system-wide.
echo  ============================================================
echo.
del "%TEMP_HOSTS%" >nul 2>&1
pause
exit /b 0

:: -----------------------------------------------------------
:Disable
echo.
if not exist "%BACKUP_FILE%" (
    echo  [ERROR] No backup found. Cannot restore.
    echo.
    pause
    exit /b 1
)

echo  Restoring original hosts file...
copy /y "%BACKUP_FILE%" "%HOSTS_FILE%" >nul 2>&1

ipconfig /flushdns >nul 2>&1

echo   [OK] Original hosts restored and DNS flushed.
echo.
echo  ============================================================
echo   Adblock is now DISABLED.
echo  ============================================================
echo.
pause
exit /b 0
