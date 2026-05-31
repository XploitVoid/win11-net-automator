@echo off
setlocal EnableDelayedExpansion

:: dns-benchmark.bat — Measure response time of popular DNS servers
:: Uses PowerShell's Measure-Command with Resolve-DnsName to get
:: actual query latency, not just ping.

title DNS Benchmark

cls
echo.
echo  ============================================================
echo     DNS Benchmark
echo  ============================================================
echo.
echo   Testing response time for popular DNS servers...
echo   (resolving github.com, cloudflare.com, google.com per server)
echo.
echo   This takes about 30 seconds. Hang tight.
echo.
echo  -----------------------------------------------------------
echo.

:: We'll test against these domains — mix of popular sites
set "TEST_DOMAINS=github.com cloudflare.com google.com"
set "ROUNDS=3"

:: Define DNS servers to test
:: Format: Name|IP
set "DNS[0]=Cloudflare|1.1.1.1"
set "DNS[1]=Cloudflare 2|1.0.0.1"
set "DNS[2]=Google|8.8.8.8"
set "DNS[3]=Google 2|8.8.4.4"
set "DNS[4]=Quad9|9.9.9.9"
set "DNS[5]=OpenDNS|208.67.222.222"
set "DNS[6]=AdGuard|94.140.14.14"
set "DNS[7]=CleanBrowsing|185.228.168.9"
set "DNS_COUNT=8"

:: Store results for sorting later
set "RESULT_IDX=0"

for /L %%I in (0,1,7) do (
    :: Parse name and IP
    for /f "tokens=1,2 delims=|" %%N in ("!DNS[%%I]!") do (
        set "SNAME=%%N"
        set "SIP=%%O"
    )

    :: Run benchmark via PowerShell
    :: We query multiple domains and average the results for accuracy
    for /f "usebackq" %%R in (`powershell -NoProfile -Command ^
        "$domains = @('github.com','cloudflare.com','google.com'); $times = @(); foreach($d in $domains) { $ms = (Measure-Command { try { Resolve-DnsName $d -Server '!SIP!' -DnsOnly -ErrorAction SilentlyContinue } catch {} }).TotalMilliseconds; $times += $ms }; [math]::Round(($times ^| Measure-Object -Average).Average, 1)"`) do (
        set "AVG=%%R"
    )

    :: Pad the name for alignment
    set "DISPLAY=!SNAME!                    "
    set "DISPLAY=!DISPLAY:~0,20!"

    echo   !DISPLAY!  !SIP!	!AVG! ms
    set "R_NAME[!RESULT_IDX!]=!SNAME!"
    set "R_IP[!RESULT_IDX!]=!SIP!"
    set "R_MS[!RESULT_IDX!]=!AVG!"
    set /a RESULT_IDX+=1
)

echo.
echo  -----------------------------------------------------------
echo.

:: Find the fastest one
set "BEST_MS=99999"
set "BEST_NAME="
set "BEST_IP="

for /L %%I in (0,1,7) do (
    if defined R_MS[%%I] (
        :: PowerShell comparison since batch can't do decimals
        for /f %%C in ('powershell -NoProfile -Command "if ([double]'!R_MS[%%I]!' -lt [double]'!BEST_MS!') { 'yes' } else { 'no' }"') do (
            if "%%C"=="yes" (
                set "BEST_MS=!R_MS[%%I]!"
                set "BEST_NAME=!R_NAME[%%I]!"
                set "BEST_IP=!R_IP[%%I]!"
            )
        )
    )
)

echo   Fastest: %BEST_NAME% (%BEST_IP%) at %BEST_MS% ms
echo.

:: Offer to apply the fastest DNS
set /p "APPLY=  Set %BEST_NAME% (%BEST_IP%) as your DNS? (Y/N): "
if /i not "!APPLY!"=="Y" (
    echo.
    echo  OK, no changes made.
    echo.
    pause
    exit /b 0
)

:: Need admin for this part
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] Need admin to change DNS. Run as administrator.
    echo.
    pause
    exit /b 1
)

:: Detect active adapter
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command ^
    "(Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and (Get-NetIPConfiguration -InterfaceIndex $_.ifIndex -ErrorAction SilentlyContinue).IPv4DefaultGateway } | Select-Object -First 1).Name"`) do (
    set "ADAPTER=%%A"
)

if not defined ADAPTER (
    echo  [ERROR] Can't find active adapter.
    echo.
    pause
    exit /b 1
)

powershell -NoProfile -Command "Set-DnsClientServerAddress -InterfaceAlias '!ADAPTER!' -ServerAddresses ('!BEST_IP!')"
echo.
echo  [OK] DNS on "!ADAPTER!" set to !BEST_IP! (!BEST_NAME!)
echo.
ipconfig /flushdns >nul 2>&1
echo  [OK] DNS cache flushed.
echo.

endlocal
pause
exit /b 0
