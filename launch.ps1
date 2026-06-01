# ============================================================
#  Win11 Net Automator — Remote Launcher
#  Usage:  irm https://raw.githubusercontent.com/XploitVoid/win11-net-automator/main/launch.ps1 | iex
# ============================================================

# --- Auto-elevate to Administrator ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host ""
    Write-Host "  [*] Requesting Administrator privileges..." -ForegroundColor Yellow
    # Re-download and execute elevated (cannot pipe across elevation boundary)
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://raw.githubusercontent.com/XploitVoid/win11-net-automator/main/launch.ps1 | iex`"" -Verb RunAs
    return
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
Write-Host "              Win11 Net Automator — Remote Launcher" -ForegroundColor Yellow
Write-Host ""

# --- Configuration ---
$RepoZipUrl = "https://github.com/XploitVoid/win11-net-automator/archive/refs/heads/main.zip"
$TempDir    = Join-Path $env:TEMP "win11-net-automator-$(Get-Random)"
$ZipFile    = Join-Path $TempDir "repo.zip"

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
    pause
    return
}

# --- Extract ---
Write-Host "  [2/3] Extracting files..." -ForegroundColor White
try {
    Expand-Archive -Path $ZipFile -DestinationPath $TempDir -Force -ErrorAction Stop
    Write-Host "        Done." -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Extraction failed: $_" -ForegroundColor Red
    pause
    return
}

# Find the extracted folder (GitHub names it <repo>-<branch>)
$ExtractedDir = Get-ChildItem -Path $TempDir -Directory | Where-Object { $_.Name -like "win11-net-automator-*" } | Select-Object -First 1
if (-not $ExtractedDir) {
    Write-Host "  [ERROR] Could not find extracted folder." -ForegroundColor Red
    pause
    return
}
$RepoRoot   = $ExtractedDir.FullName
$ScriptsDir = Join-Path $RepoRoot "scripts"

# --- Menu ---
Write-Host "  [3/3] Ready!" -ForegroundColor Green
Write-Host ""
Write-Host "  ============================================================" -ForegroundColor DarkGray
Write-Host "    What would you like to do?" -ForegroundColor White
Write-Host "  ============================================================" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    1 - Install to system  (copies to ProgramData + adds to PATH + right-click menu)" -ForegroundColor White
Write-Host "    2 - Run Menu now       (one-time run, no installation)" -ForegroundColor White
Write-Host "    3 - Exit" -ForegroundColor DarkGray
Write-Host ""

$choice = Read-Host "    Choice (1-3)"

switch ($choice) {
    "1" {
        # Run the installer
        $InstallerPath = Join-Path $RepoRoot "install.bat"
        if (Test-Path $InstallerPath) {
            Write-Host ""
            Write-Host "  >> Launching Installer..." -ForegroundColor Green
            cmd.exe /c "`"$InstallerPath`""
        } else {
            Write-Host "  [ERROR] install.bat not found in downloaded files." -ForegroundColor Red
            pause
        }
    }
    "2" {
        # Run the TUI menu directly
        $MenuScript = Join-Path $ScriptsDir "terminal-menu.ps1"
        if (Test-Path $MenuScript) {
            Write-Host ""
            Write-Host "  >> Launching Terminal Menu..." -ForegroundColor Green
            & $MenuScript
        } else {
            Write-Host "  [ERROR] terminal-menu.ps1 not found in downloaded files." -ForegroundColor Red
            pause
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
    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
} catch { }
Write-Host "  [*] Done." -ForegroundColor DarkGray
Write-Host ""
