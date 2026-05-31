@echo off
setlocal EnableDelayedExpansion

:: speed-tuner.bat — TCP & MTU Speed Optimizer
:: Optimizes Windows 11 TCP/IP stack for high-speed fiber or low latency.

title TCP / MTU Speed Tuner

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] Run as Administrator required for network tuning.
    echo.
    pause
    exit /b 1
)

cls
echo.
echo  ============================================================
echo     TCP ^& MTU Speed Tuner
echo  ============================================================
echo.
echo   This optimizes the underlying Windows network stack.
echo   - Enables Window Auto-Tuning for high-speed fiber
echo   - Enables ECN (Explicit Congestion Notification)
echo   - Enables RSS (Receive Side Scaling) for multi-core CPUs
echo.
echo     1 - Apply Speed Optimizations
echo     2 - Restore Windows Defaults
echo.

set /p "PICK=   Choice (1-2): "

if "!PICK!"=="1" goto :Optimize
if "!PICK!"=="2" goto :Restore

echo  Invalid choice.
pause
exit /b 1

:: -----------------------------------------------------------
:Optimize
echo.
echo  Applying network optimizations...

:: 1. TCP Window Auto-Tuning (Good for gigabit fiber)
netsh int tcp set global autotuninglevel=normal >nul 2>&1
echo   [OK] TCP Auto-Tuning: Normal

:: 2. Receive Side Scaling (Offloads processing across multiple CPU cores)
netsh int tcp set global rss=enabled >nul 2>&1
echo   [OK] Receive Side Scaling: Enabled

:: 3. Explicit Congestion Notification (Reduces packet loss/latency under load)
netsh int tcp set global ecncapability=enabled >nul 2>&1
echo   [OK] ECN Capability: Enabled

:: 4. Disable Heuristics (Prevents Windows from randomly throttling TCP)
netsh int tcp set heuristics disabled >nul 2>&1
echo   [OK] Window Scaling Heuristics: Disabled

:: 5. Chimney Offload (Usually better disabled on modern OS to prevent driver bugs)
netsh int tcp set global chimney=disabled >nul 2>&1
echo   [OK] Chimney Offload: Disabled

echo.
echo  ============================================================
echo   Network Stack Optimized!
echo   You might need to restart your PC for maximum effect.
echo  ============================================================
echo.
pause
exit /b 0

:: -----------------------------------------------------------
:Restore
echo.
echo  Restoring Windows defaults...

netsh int tcp set global autotuninglevel=normal >nul 2>&1
echo   [OK] TCP Auto-Tuning restored to default (Normal).

netsh int tcp set global rss=default >nul 2>&1
echo   [OK] Receive Side Scaling restored.

netsh int tcp set global ecncapability=disabled >nul 2>&1
echo   [OK] ECN Capability disabled (Windows default).

netsh int tcp set heuristics default >nul 2>&1
echo   [OK] Heuristics restored.

netsh int tcp set global chimney=default >nul 2>&1
echo   [OK] Chimney Offload restored.

echo.
echo  ============================================================
echo   Default settings restored.
echo  ============================================================
echo.
pause
exit /b 0
