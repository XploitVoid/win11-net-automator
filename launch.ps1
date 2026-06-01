# ============================================================
#  Win11 Net Automator — Remote Launcher
#  Usage:  irm https://raw.githubusercontent.com/XploitVoid/win11-net-automator/main/launch.ps1 | iex
# ============================================================

# --- Auto-elevate to Administrator ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host ""
    Write-Host "  [*] Requesting Administrator privileges..." -ForegroundColor Yellow
    # Save this script to a temp file and run it elevated with -File
    # (Using -File instead of irm|iex ensures stdin is interactive in the elevated window)
    $tempScript = Join-Path $env:TEMP "win11-net-automator-launch.ps1"
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/XploitVoid/win11-net-automator/main/launch.ps1" -OutFile $tempScript -UseBasicParsing -ErrorAction Stop
    } catch {
        Write-Host "  [ERROR] Failed to download launcher: $_" -ForegroundColor Red
        Read-Host "  Press Enter to exit"
        return
    }
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempScript`"" -Verb RunAs
    return
}

# --- Configuration ---
$RepoZipUrl  = "https://github.com/XploitVoid/win11-net-automator/archive/refs/heads/main.zip"
# Use a fixed name (not random) so we can find/clean it reliably
$TempDir     = Join-Path $env:TEMP "win11-net-automator-launcher"
$ZipFile     = Join-Path $TempDir "repo.zip"

# Clean previous run if exists
if (Test-Path $TempDir) {
    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
}

# --- Banner ---
Clear-Host
Write-Host ""
Write-Host "    __      ___      ___  ___    _  __     __       _       _ " -ForegroundColor Cyan
Write-Host "    \ \    / (_)    |_  ||__ \  | |/ /    | |      | |     (_)" -ForegroundColor Cyan
Write-Host "     \ \  / / _ _ __  | |   ) | | ' /_   _| |__  __| | ___  _ " -ForegroundColor Cyan
Write-Host "      \ \/ / | | '_ \ | |  / /  |  <| | | | '_ \/ _`` | / _ \| |" -ForegroundColor Cyan
Write-Host "       \  /  | | | | || |_/ /_  | . \ |_| | |_) | (_| | (_) | |" -ForegroundColor Cyan
Write-Host "        \/   |_|_| |_|___|____| |_|\_\__,_|_.__/\__,_|\___/|_|" -ForegroundColor Cyan
Write-Host ""
Write-Host "              Win11 Net Automator  -  Remote Launcher" -ForegroundColor Yellow
Write-Host ""

# --- Download ---
Write-Host "  [1/3] Downloading latest version..." -ForegroundColor White
try {
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $RepoZipUrl -OutFile $ZipFile -UseBasicParsing -ErrorAction Stop
    Write-Host "        Done." -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Download failed: $_" -ForegroundColor Red
    Write-Host "          Check your internet connection and try again." -ForegroundColor Red
    Read-Host "  Press Enter to exit"
    return
}

# --- Extract ---
Write-Host "  [2/3] Extracting files..." -ForegroundColor White
try {
    Expand-Archive -Path $ZipFile -DestinationPath $TempDir -Force -ErrorAction Stop
    Write-Host "        Done." -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Extraction failed: $_" -ForegroundColor Red
    Read-Host "  Press Enter to exit"
    return
}

# Find the extracted folder (GitHub names it <repo>-<branch>)
$ExtractedDir = Get-ChildItem -Path $TempDir -Directory | Where-Object { $_.Name -like "win11-net-automator-*" } | Select-Object -First 1
if (-not $ExtractedDir) {
    Write-Host "  [ERROR] Could not find extracted folder." -ForegroundColor Red
    Read-Host "  Press Enter to exit"
    return
}
$RepoRoot   = $ExtractedDir.FullName
$ScriptsDir = Join-Path $RepoRoot "scripts"

Write-Host "  [3/3] Ready!" -ForegroundColor Green

# --- Interactive Menu ---
# NOTE: When run via `irm | iex`, stdin is consumed by the pipe,
# so Read-Host will not work. We handle this by detecting the piped
# context and spawning an interactive console for the chosen action.

Write-Host ""
Write-Host "  ============================================================" -ForegroundColor DarkGray
Write-Host "    What would you like to do?" -ForegroundColor White
Write-Host "  ============================================================" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    1 - Install to system  (ProgramData + PATH + right-click menu)" -ForegroundColor White
Write-Host "    2 - Run Menu now       (one-time run, no installation)" -ForegroundColor White
Write-Host "    3 - Exit" -ForegroundColor DarkGray
Write-Host ""

# Try to read user input — handle the piped stdin case
try {
    $choice = Read-Host "    Choice (1-3)"
} catch {
    $choice = ""
}

# If we got empty/null input (piped context), default to Install
if ([string]::IsNullOrWhiteSpace($choice)) {
    Write-Host "    (Auto-selecting: Install)" -ForegroundColor DarkGray
    $choice = "1"
}

switch ($choice) {
    "1" {
        # --- Option 1: Run the installer ---
        $InstallerPath = Join-Path $RepoRoot "install.bat"
        if (Test-Path $InstallerPath) {
            Write-Host ""
            Write-Host "  >> Launching Installer..." -ForegroundColor Green
            # Run install.bat in a new interactive cmd window so it can
            # accept user input (Install/Uninstall choice)
            $proc = Start-Process cmd.exe -ArgumentList "/c `"`"$InstallerPath`"`"" -Wait -PassThru
        } else {
            Write-Host "  [ERROR] install.bat not found in downloaded files." -ForegroundColor Red
            Read-Host "  Press Enter to exit"
        }
    }
    "2" {
        # --- Option 2: Run the TUI menu directly ---
        $MenuScript = Join-Path $ScriptsDir "terminal-menu.ps1"
        if (Test-Path $MenuScript) {
            Write-Host ""
            Write-Host "  >> Launching Terminal Menu..." -ForegroundColor Green
            # We are already running as Admin (elevated at top of script).
            # Run the TUI in a new window with -Verb RunAs so that it
            # inherits admin and does NOT re-elevate (which would cause
            # the non-admin window to exit immediately, breaking -Wait).
            $proc = Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$MenuScript`"" -Verb RunAs -Wait -PassThru
        } else {
            Write-Host "  [ERROR] terminal-menu.ps1 not found in downloaded files." -ForegroundColor Red
            Read-Host "  Press Enter to exit"
        }
    }
    "3" {
        Write-Host ""
        Write-Host "  Bye!" -ForegroundColor DarkGray
    }
    default {
        Write-Host "  Invalid choice." -ForegroundColor Red
    }
}

# --- Cleanup ---
Write-Host ""
Write-Host "  [*] Cleaning up temporary files..." -ForegroundColor DarkGray
try {
    # Small delay to ensure any child processes have released file handles
    Start-Sleep -Milliseconds 500
    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  [*] Cleaned up." -ForegroundColor DarkGray
} catch {
    Write-Host "  [*] Note: Temp files at $TempDir can be deleted manually." -ForegroundColor DarkGray
}
Write-Host "  [*] Done. Goodbye!" -ForegroundColor Green
Write-Host ""
