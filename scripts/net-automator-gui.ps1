Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

# --- FORM SETUP ---
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Win11 Net Automator (v3.0)" # Fixed emoji corruption
$Form.Size = New-Object System.Drawing.Size(650, 740)
$Form.StartPosition = "CenterScreen"
$Form.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0f172a") # Slate-900
$Form.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#f8fafc") # Slate-50
$Form.FormBorderStyle = 'FixedDialog'
$Form.MaximizeBox = $false
$Form.ShowIcon = $false # Cleaner modern look

$TitleFont = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$HeaderFont = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$ButtonFont = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)

# --- GLOBAL VARIABLES ---
$global:ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Helper function to create modern hoverable buttons
function Create-Button {
    param($Text, $X, $Y, $Width, $Height, $BaseColor, $HoverColor, $ScriptFile)
    $Btn = New-Object System.Windows.Forms.Button
    $Btn.Text = $Text
    $Btn.Location = New-Object System.Drawing.Point($X, $Y)
    $Btn.Size = New-Object System.Drawing.Size($Width, $Height)
    $Btn.Font = $ButtonFont
    $Btn.FlatStyle = 'Flat'
    $Btn.FlatAppearance.BorderSize = 1
    $Btn.FlatAppearance.BorderColor = [System.Drawing.ColorTranslator]::FromHtml("#334155") # Subtle border
    $Btn.BackColor = [System.Drawing.ColorTranslator]::FromHtml($BaseColor)
    $Btn.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#ffffff")
    $Btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $Btn.Tag = $ScriptFile
    
    # Hover effect (UX Improvement)
    $Btn.Add_MouseEnter({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml($HoverColor) })
    $Btn.Add_MouseLeave({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml($BaseColor) })
    
    $Btn.Add_Click({
        $File = $this.Tag
        $Target = Join-Path -Path $global:ScriptDir -ChildPath $File
        if (Test-Path $Target) {
            try {
                # Launch batch script elevated via cmd.exe
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$Target`"" -Verb RunAs
            } catch {
                [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, "Error Running Script", 0, 16)
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("Script not found: $File at $Target", "Error", 0, 16)
        }
    })
    return $Btn
}

# Helper for Dividers
function Add-Divider {
    param($Y)
    $Div = New-Object System.Windows.Forms.Label
    $Div.AutoSize = $false
    $Div.Height = 1
    $Div.Width = 590
    $Div.Location = New-Object System.Drawing.Point(20, $Y)
    $Div.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#334155")
    $Form.Controls.Add($Div)
}

# --- UI ELEMENTS ---
$LabelTitle = New-Object System.Windows.Forms.Label
$LabelTitle.Text = "Win11 Net Automator"
$LabelTitle.Font = $TitleFont
$LabelTitle.AutoSize = $true
$LabelTitle.Location = New-Object System.Drawing.Point(20, 25)
$Form.Controls.Add($LabelTitle)

$LabelSub = New-Object System.Windows.Forms.Label
$LabelSub.Text = "Select a tool to launch. Elevated privileges will be requested automatically."
$LabelSub.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
$LabelSub.AutoSize = $true
$LabelSub.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#94a3b8") # Slate-400
$LabelSub.Location = New-Object System.Drawing.Point(24, 60)
$Form.Controls.Add($LabelSub)

# --- SECTION 1: Dashboards & Info ---
$LblSec1 = New-Object System.Windows.Forms.Label
$LblSec1.Text = "Dashboards & Diagnostics"
$LblSec1.Font = $HeaderFont
$LblSec1.AutoSize = $true
$LblSec1.Location = New-Object System.Drawing.Point(20, 105)
$Form.Controls.Add($LblSec1)

$Form.Controls.Add((Create-Button "Network Dashboard" 20 140 190 45 "#2563eb" "#3b82f6" "net-info.bat"))
$Form.Controls.Add((Create-Button "DNS Benchmark" 220 140 190 45 "#2563eb" "#3b82f6" "dns-benchmark.bat"))
$Form.Controls.Add((Create-Button "Wi-Fi Passwords" 420 140 190 45 "#2563eb" "#3b82f6" "wifi-passwords.bat"))

Add-Divider 210

# --- SECTION 2: Tuning & Fixing ---
$LblSec2 = New-Object System.Windows.Forms.Label
$LblSec2.Text = "Performance & Fixing"
$LblSec2.Font = $HeaderFont
$LblSec2.AutoSize = $true
$LblSec2.Location = New-Object System.Drawing.Point(20, 230)
$Form.Controls.Add($LblSec2)

$Form.Controls.Add((Create-Button "TCP/MTU Tuner" 20 265 190 45 "#059669" "#10b981" "speed-tuner.bat"))
$Form.Controls.Add((Create-Button "Gaming Network Mode" 220 265 190 45 "#059669" "#10b981" "gaming-mode.bat"))
$Form.Controls.Add((Create-Button "Auto-Healer Monitor" 420 265 190 45 "#059669" "#10b981" "auto-healer.bat"))
$Form.Controls.Add((Create-Button "Nuclear Network Flush" 20 320 190 45 "#dc2626" "#ef4444" "network-flush.bat"))

Add-Divider 390

# --- SECTION 3: Privacy & Routing ---
$LblSec3 = New-Object System.Windows.Forms.Label
$LblSec3.Text = "Privacy & Routing"
$LblSec3.Font = $HeaderFont
$LblSec3.AutoSize = $true
$LblSec3.Location = New-Object System.Drawing.Point(20, 410)
$Form.Controls.Add($LblSec3)

$Form.Controls.Add((Create-Button "Enable DNS over HTTPS" 20 445 190 45 "#7c3aed" "#8b5cf6" "enable-doh.bat"))
$Form.Controls.Add((Create-Button "AdGuard Home Routing" 220 445 190 45 "#7c3aed" "#8b5cf6" "adguard-routing.bat"))
$Form.Controls.Add((Create-Button "System-wide Adblock" 420 445 190 45 "#7c3aed" "#8b5cf6" "hosts-adblock.bat"))
$Form.Controls.Add((Create-Button "Telemetry Blocker" 20 500 190 45 "#7c3aed" "#8b5cf6" "telemetry-block.bat"))
$Form.Controls.Add((Create-Button "MAC Address Spoofer" 220 500 190 45 "#7c3aed" "#8b5cf6" "mac-spoof.bat"))

Add-Divider 570

# --- SECTION 4: Misc ---
$LblSec4 = New-Object System.Windows.Forms.Label
$LblSec4.Text = "Utilities"
$LblSec4.Font = $HeaderFont
$LblSec4.AutoSize = $true
$LblSec4.Location = New-Object System.Drawing.Point(20, 590)
$Form.Controls.Add($LblSec4)

$Form.Controls.Add((Create-Button "Mobile Hotspot" 20 625 190 45 "#d97706" "#f59e0b" "hotspot-manager.bat"))
$Form.Controls.Add((Create-Button "Legion Toolkit Sync" 220 625 190 45 "#d97706" "#f59e0b" "lltk-profile-sync.bat"))

# Show Window
$Form.ShowDialog() | Out-Null
