# Auto-elevate to Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$global:ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$menuOptions = @(
    @{ Name = "[+] Dashboards & Diagnostics"; IsHeader = $true }
    @{ Name = " Network Dashboard"; File = "net-info.bat" }
    @{ Name = " DNS Benchmark"; File = "dns-benchmark.bat" }
    @{ Name = " Wi-Fi Passwords"; File = "wifi-passwords.bat" }
    @{ Name = ""; IsHeader = $true }
    @{ Name = "[+] Performance & Fixing"; IsHeader = $true }
    @{ Name = " TCP/MTU Tuner"; File = "speed-tuner.bat" }
    @{ Name = " Gaming Network Mode"; File = "gaming-mode.bat" }
    @{ Name = " Auto-Healer Monitor"; File = "auto-healer.bat" }
    @{ Name = " Nuclear Network Flush"; File = "network-flush.bat" }
    @{ Name = ""; IsHeader = $true }
    @{ Name = "[+] Privacy & Routing"; IsHeader = $true }
    @{ Name = " Enable DNS over HTTPS"; File = "enable-doh.bat" }
    @{ Name = " AdGuard Home Routing"; File = "adguard-routing.bat" }
    @{ Name = " System-wide Adblock"; File = "hosts-adblock.bat" }
    @{ Name = " Telemetry Blocker"; File = "telemetry-block.bat" }
    @{ Name = " MAC Address Spoofer"; File = "mac-spoof.bat" }
    @{ Name = ""; IsHeader = $true }
    @{ Name = "[+] Utilities"; IsHeader = $true }
    @{ Name = " Mobile Hotspot Manager"; File = "hotspot-manager.bat" }
    @{ Name = " Legion Toolkit Sync"; File = "lltk-profile-sync.bat" }
    @{ Name = ""; IsHeader = $true }
    @{ Name = " Exit"; File = "exit" }
)

# Extract only selectable items
$selectableItems = $menuOptions | Where-Object { -not $_.IsHeader }
$selectedIndex = 0

function Draw-Menu {
    Clear-Host
    Write-Host ""
    Write-Host "    __      ___      ___  ___    _  __     __       _       _ " -ForegroundColor Cyan
    Write-Host "    \ \    / (_)    |_  ||__ \  | |/ /    | |      | |     (_)" -ForegroundColor Cyan
    Write-Host "     \ \  / / _ _ __  | |   ) | | ' /_   _| |__  __| | ___  _ " -ForegroundColor Cyan
    Write-Host "      \ \/ / | | '_ \ | |  / /  |  <| | | | '_ \/ _\` |/ _ \| |" -ForegroundColor Cyan
    Write-Host "       \  /  | | | | || |_/ /_  | . \ |_| | |_) | (_| | (_) | |" -ForegroundColor Cyan
    Write-Host "        \/   |_|_| |_|___|____| |_|\_\__,_|_.__/\__,_|\___/|_|" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "                      Win11 Net Automator" -ForegroundColor Yellow
    Write-Host "          Use [UP] and [DOWN] arrows, press [ENTER] to run" -ForegroundColor DarkGray
    Write-Host ""

    $selectableIdx = 0
    foreach ($item in $menuOptions) {
        if ($item.IsHeader) {
            if ($item.Name -ne "") {
                Write-Host "  $($item.Name)" -ForegroundColor Magenta
            } else {
                Write-Host ""
            }
        } else {
            if ($selectableIdx -eq $selectedIndex) {
                # Selected Item (Highlighted)
                Write-Host "   > $($item.Name) " -ForegroundColor Black -BackgroundColor Cyan
            } else {
                # Normal Item
                Write-Host "     $($item.Name)" -ForegroundColor White
            }
            $selectableIdx++
        }
    }
    Write-Host ""
}

$Host.UI.RawUI.WindowTitle = "Win11 Net Automator (TUI Mode)"

$needsRedraw = $true

while ($true) {
    if ($needsRedraw) {
        Draw-Menu
        $needsRedraw = $false
    }
    $keyInfo = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    if ($keyInfo.VirtualKeyCode -eq 38) { # Up Arrow
        $selectedIndex--
        if ($selectedIndex -lt 0) { $selectedIndex = $selectableItems.Count - 1 }
        $needsRedraw = $true
    }
    elseif ($keyInfo.VirtualKeyCode -eq 40) { # Down Arrow
        $selectedIndex++
        if ($selectedIndex -ge $selectableItems.Count) { $selectedIndex = 0 }
        $needsRedraw = $true
    }
    elseif ($keyInfo.VirtualKeyCode -eq 13) { # Enter
        $needsRedraw = $true
        $selectedItem = $selectableItems[$selectedIndex]
        if ($selectedItem.File -eq "exit") {
            Clear-Host
            exit
        }
        $Target = Join-Path -Path $global:ScriptDir -ChildPath $selectedItem.File
        if (Test-Path $Target) {
            Clear-Host
            Write-Host ">> Launching $($selectedItem.Name)...`n" -ForegroundColor Green
            
            # Execute the batch script cleanly via cmd.exe
            cmd.exe /c "`"$Target`""
            
            Write-Host "`n>> Task completed. Press any key to return to menu..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        } else {
            Write-Host "`nError: Script not found at $Target" -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
}
