@echo off
setlocal EnableDelayedExpansion

:: mac-spoof.bat — Change/Randomize MAC Address
:: Modifies the NetworkAddress registry key for the active adapter
:: to bypass time-limited public Wi-Fi or tracking.

title MAC Address Spoofer

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] Need admin rights to change MAC address.
    echo.
    pause
    exit /b 1
)

cls
echo.
echo  ============================================================
echo     MAC Address Spoofer
echo  ============================================================
echo.
echo   This temporarily changes your network adapter's MAC address.
echo   Useful for bypassing Wi-Fi time limits or tracking.
echo.
echo   Warning: This will momentarily drop your network connection.
echo.

:: -----------------------------------------------------------
:: Find Active Wi-Fi or Ethernet Adapter
:: -----------------------------------------------------------
set "ADAPTER="
set "ADAPTER_DESC="
set "CURRENT_MAC="

for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command ^
    "$net = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and (Get-NetIPConfiguration -InterfaceIndex $_.ifIndex -ErrorAction SilentlyContinue).IPv4DefaultGateway } | Select-Object -First 1; if ($net) { Write-Output ($net.Name + '|' + $net.InterfaceDescription + '|' + $net.MacAddress) }"`) do (
    for /f "tokens=1,2,3 delims=|" %%N in ("%%A") do (
        set "ADAPTER=%%N"
        set "ADAPTER_DESC=%%O"
        set "CURRENT_MAC=%%P"
    )
)

if not defined ADAPTER (
    echo  [ERROR] No active network connection found.
    echo.
    pause
    exit /b 1
)

echo   Adapter:      !ADAPTER!
echo   Hardware:     !ADAPTER_DESC!
echo   Current MAC:  !CURRENT_MAC!
echo.
echo     1 - Randomize MAC Address
echo     2 - Restore Original Hardware MAC
echo.

set /p "PICK=   Choice (1-2): "

if "!PICK!"=="1" goto :Randomize
if "!PICK!"=="2" goto :Restore

echo  Invalid choice.
echo.
pause
exit /b 1

:: -----------------------------------------------------------
:Randomize
echo.
echo  Generating random MAC address...

:: Generate a locally administered MAC address.
:: The second character must be 2, 6, A, or E to be valid for Windows spoofing.
for /f "usebackq tokens=*" %%M in (`powershell -NoProfile -Command ^
    "$chars = '0123456789ABCDEF'; $mac = '02' + ($chars[(Get-Random -Maximum 16)]) + ($chars[(Get-Random -Maximum 16)]) + ($chars[(Get-Random -Maximum 16)]) + ($chars[(Get-Random -Maximum 16)]) + ($chars[(Get-Random -Maximum 16)]) + ($chars[(Get-Random -Maximum 16)]) + ($chars[(Get-Random -Maximum 16)]) + ($chars[(Get-Random -Maximum 16)]) + ($chars[(Get-Random -Maximum 16)]) + ($chars[(Get-Random -Maximum 16)]); $mac"`) do (
    set "NEW_MAC=%%M"
)

echo  New MAC will be: !NEW_MAC!
echo.
echo  Applying to registry and restarting adapter...

:: PowerShell handles finding the right registry key based on the adapter description and setting it
powershell -NoProfile -Command ^
    "$desc = '!ADAPTER_DESC!'; $net = Get-NetAdapter -InterfaceDescription $desc; if ($net) { Set-NetAdapterAdvancedProperty -Name $net.Name -DisplayName 'Network Address' -DisplayValue '!NEW_MAC!' -NoRestart; Disable-NetAdapter -Name $net.Name -Confirm:$false; Enable-NetAdapter -Name $net.Name -Confirm:$false; exit 0 } else { exit 1 }"

if %errorlevel% neq 0 (
    :: Fallback if AdvancedProperty fails (some drivers don't support the property name exactly)
    echo  [WARN] Advanced Property method failed. Trying direct WMI/Registry...
    powershell -NoProfile -Command ^
        "$adapter = Get-NetAdapter -Name '!ADAPTER!'; $path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\*'; $keys = Get-ItemProperty $path | Where-Object { $_.DriverDesc -match $adapter.InterfaceDescription }; if ($keys) { $keyPath = $keys[0].PSPath; Set-ItemProperty -Path $keyPath -Name 'NetworkAddress' -Value '!NEW_MAC!'; Disable-NetAdapter -Name '!ADAPTER!' -Confirm:$false; Enable-NetAdapter -Name '!ADAPTER!' -Confirm:$false; exit 0 } else { exit 1 }"
    
    if !errorlevel! neq 0 (
        echo  [ERROR] Failed to spoof MAC. Your network driver might not support it.
        echo.
        pause
        exit /b 1
    )
)

echo   [OK] MAC Address Spoofed successfully!
echo.
pause
exit /b 0

:: -----------------------------------------------------------
:Restore
echo.
echo  Restoring original MAC address...

powershell -NoProfile -Command ^
    "$adapter = Get-NetAdapter -Name '!ADAPTER!'; $path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\*'; $keys = Get-ItemProperty $path | Where-Object { $_.DriverDesc -match $adapter.InterfaceDescription }; if ($keys) { $keyPath = $keys[0].PSPath; Remove-ItemProperty -Path $keyPath -Name 'NetworkAddress' -ErrorAction SilentlyContinue; Disable-NetAdapter -Name '!ADAPTER!' -Confirm:$false; Enable-NetAdapter -Name '!ADAPTER!' -Confirm:$false; exit 0 } else { exit 1 }"

if %errorlevel% neq 0 (
    echo  [ERROR] Failed to restore MAC.
    echo.
    pause
    exit /b 1
)

echo   [OK] Hardware MAC Address restored.
echo.
pause
exit /b 0
