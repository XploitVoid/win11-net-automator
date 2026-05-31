<div align="center">

# 🌐 Win11 Net Automator v3.0

**The Ultimate Networking Automation Suite for Windows 11.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![OS: Windows 11](https://img.shields.io/badge/OS-Windows%2011-0078D4?logo=windows11&logoColor=white)](https://www.microsoft.com/windows/windows-11)
[![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen.svg)](https://github.com/XploitVoid/win11-net-automator/pulls)

</div>

---

I got tired of manually configuring DNS, flushing network stacks, and clicking through settings every time I set up a new machine or debug connectivity issues. So I wrote these scripts to automate the boring stuff.

**Version 3.0 is here!** We have entirely replaced the old text-based command-line menu with a gorgeous, native Windows **Graphical User Interface (GUI)**. 

## 🚀 How to Install & Use

1. Clone or download this repository:
```bash
git clone https://github.com/XploitVoid/win11-net-automator.git
cd win11-net-automator
```
2. Right-click **`install.bat`** and select **Run as administrator**.
3. **Done!** You can now access the beautiful new Dashboard from anywhere:
   - **Desktop Context Menu:** Right-click anywhere on your desktop and select `🌐 Win11 Net Automator` to open the GUI.
   - **Terminal:** Open Command Prompt or PowerShell anywhere and simply type `menu` to launch the GUI.

*(When you click a button in the GUI, it will automatically prompt you for Administrator privileges via UAC).*

## What's in the box

| Tool | What it does |
|--------|-------------|
| `net-automator-gui.ps1` | **[NEW]** The native Dark Mode GUI dashboard. Features categorized buttons, hover effects, and automatic UAC elevation. |
| `gaming-mode.bat` | Pauses bandwidth-heavy background tasks (Updates, OneDrive) and optimizes TCP/Registry for the absolute lowest gaming ping. |
| `speed-tuner.bat` | Tunes your Windows TCP/IP stack (Auto-Tuning, RSS, ECN) to max out high-speed fiber or Wi-Fi 6 connections. |
| `auto-healer.bat` | A background monitor that constantly checks your internet connection and automatically resets your adapter if the connection drops. |
| `hotspot-manager.bat`| Quickly toggle the built-in Windows 11 Mobile Hotspot on or off directly from the terminal via modern WinRT APIs. |
| `net-info.bat` | Clean dashboard showing your active adapter, local IP, public IP, MAC address, DNS servers, and current ping. |
| `mac-spoof.bat` | Randomizes your network adapter's MAC address to bypass public Wi-Fi limits or tracking. Fully reversible. |
| `hosts-adblock.bat` | Downloads and applies the StevenBlack hosts file for system-wide ad and malware blocking. Reversible. |
| `enable-doh.bat` | Sets up DNS over HTTPS with Cloudflare + Google DNS. Registers DoH templates, configures the adapter, writes registry flags. |
| `adguard-routing.bat` | Points your DNS to a local AdGuard Home instance. Detects your active adapter automatically. |
| `dns-benchmark.bat` | Tests 8 popular DNS servers for response time, shows you the fastest, and offers to apply it. |
| `network-flush.bat` | Nuclear option — flushes DNS, releases/renews IP, resets Winsock and TCP/IP stack. For when nothing else works. |
| `telemetry-block.bat` | Blocks Windows 11 telemetry endpoints via firewall + hosts file. Disables tracking services. Fully reversible. |
| `wifi-passwords.bat` | Lists all saved Wi-Fi profiles and their passwords in one shot. |
| `lltk-profile-sync.bat` | Quick switcher for Lenovo Legion Toolkit power profiles (Quiet/Balance/Performance). |

## Changelog

### v3.0.0 (The GUI Update)
- **New Interface:** Replaced the text-based command prompt menu with a sleek, native PowerShell Graphical User Interface (`net-automator-gui.ps1`).
- **Modern UX:** Features a dark theme, color-coded categories, and responsive hover effects.
- **Smart UAC:** The GUI runs cleanly as a standard user and only requests Administrator elevation precisely when a script button is clicked.
- **Seamless Integration:** `install.bat` and the Desktop right-click menu have been updated to seamlessly launch the new visual dashboard.

### v2.0.0 (The Masterpiece Update)
- **New Installer:** Added `install.bat` which securely copies scripts to `C:\ProgramData`, sets up system PATH variables, and injects a permanent `Win11 Net Automator` option into the Desktop right-click context menu.
- **New Script:** `gaming-mode.bat` — optimize Windows registry and services for low-latency gaming.
- **New Script:** `speed-tuner.bat` — tweak TCP Window Auto-Tuning, RSS, and ECN for gigabit fiber.
- **New Script:** `auto-healer.bat` — background daemon that detects internet drops and resets the adapter automatically.
- **New Script:** `hotspot-manager.bat` — toggle Windows Mobile Hotspot instantly using WinRT PowerShell APIs.

### v1.2.1
- **Fix (net-info):** Resolved an issue where Ping parsing failed on non-English (e.g., Thai) Windows versions by switching to a locale-independent WMI query.
- **Fix (hosts-adblock):** Prevented the script from accidentally overwriting and deleting custom telemetry rules generated by `telemetry-block.bat`.

### v1.2.0
- **New:** `net-info.bat` — a clean dashboard for all your network stats (IPs, MAC, DNS, Ping).
- **New:** `mac-spoof.bat` — randomize your MAC address to bypass tracking/limits.
- **New:** `hosts-adblock.bat` — apply StevenBlack's hosts file for system-wide adblocking.

### v1.1.1
- **Fix:** Fixed 11 bugs across all scripts, including telemetry blocker logic, DNS benchmark variables, Wi-Fi password extraction for SSIDs with colons, and minor UX improvements.

### v1.1.0
- **New:** `dns-benchmark.bat` — benchmark DNS servers and auto-apply the fastest
- **New:** `telemetry-block.bat` — block/unblock Windows 11 telemetry (firewall + hosts + services + registry)
- **New:** `wifi-passwords.bat` — view all saved Wi-Fi passwords at once
- Reorganized README for better readability

### v1.0.0
- Initial release with `enable-doh.bat`, `adguard-routing.bat`, `network-flush.bat`, `lltk-profile-sync.bat`

## Contributing

Found a bug? Want to add a new script? PRs are welcome.

1. Fork the repo
2. Create a branch (`git checkout -b fix/whatever`)
3. Commit your changes
4. Push and open a PR

If you're adding a new `.bat` file, try to follow the existing style:
- `@echo off` at the top
- Admin check early on
- Comments for the non-obvious stuff (you don't need to comment `echo`)
- Clean output with status indicators

Not sure if your idea fits? Open an issue first and we can discuss.

## License

MIT — do whatever you want with it. See [LICENSE](LICENSE).
