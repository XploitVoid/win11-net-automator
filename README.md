<div align="center">

# 🌐 Win11 Net Automator v3.1

**The Ultimate Networking Automation Suite for Windows 11.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![OS: Windows 11](https://img.shields.io/badge/OS-Windows%2011-0078D4?logo=windows11&logoColor=white)](https://www.microsoft.com/windows/windows-11)
[![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen.svg)](https://github.com/XploitVoid/win11-net-automator/pulls)

</div>

---

I got tired of manually configuring DNS, flushing network stacks, and clicking through settings every time I set up a new machine or debug connectivity issues. So I wrote these scripts to automate the boring stuff.

**Version 3.1 is here!** We have upgraded the tool into a fully interactive **Terminal User Interface (TUI)** with ASCII art and arrow-key navigation!

## ⚡ Quick Start (One-Liner)

Open **PowerShell as Administrator** and paste:

```powershell
irm https://raw.githubusercontent.com/XploitVoid/win11-net-automator/main/launch.ps1 | iex
```

That's it! The script will download the latest version and give you options to **install** or **run directly**.

---

## 🚀 How to Install & Use (Manual)

1. Clone or download this repository:
```bash
git clone https://github.com/XploitVoid/win11-net-automator.git
cd win11-net-automator
```
2. Right-click **`install.bat`** and select **Run as administrator**.
3. **Done!** You can now access the beautiful new Dashboard from anywhere:
   - **Desktop Context Menu:** Right-click anywhere on your desktop and select `🌐 Win11 Net Automator` to open the GUI.
   - **Terminal:** Open Command Prompt or PowerShell anywhere and simply type `menu` to launch the GUI.

*(When you launch the TUI or select a tool, it will automatically prompt you for Administrator privileges via UAC if needed).*

> [!CAUTION]
> **Disclaimer & Backup Warning:** 
> Some tools in the **Performance & Fixing** and **Privacy & Routing** sections (such as Gaming Mode, Speed Tuner, and Telemetry Blocker) make direct modifications to your Windows Registry, Firewall, and System Services. 
> 
> **It is highly recommended to create a System Restore Point or backup your current network/registry settings before running these optimizations.** While these scripts are designed to be safe and reversible, modifying system networking can sometimes result in unexpected behavior depending on your specific hardware and Windows configuration.

## What's in the box

| Tool | What it does |
|--------|-------------|
| `terminal-menu.ps1` | **[NEW]** The interactive Terminal UI (TUI) menu. Navigate with Arrow Keys and hit Enter to run. Auto-elevates. |
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

### v3.1.0
- **Terminal UI:** Scrapped the GUI because command line is just better. Built an interactive Terminal UI (`terminal-menu.ps1`) so you can navigate with arrow keys instead of typing numbers.
- **ASCII Art:** Added a nice ASCII header.
- **Fixed Executions:** Fixed a weird bug where PowerShell was mangling batch file outputs. Switched to a cleaner CMD bridge.

*(Note: v3.0.0 was a GUI experiment that got removed).*

### v2.0.0
- **Installer:** Turned this from a folder of loose scripts into an actual tool. Run `install.bat` to drop it into ProgramData and get a permanent Desktop right-click menu.
- **New Scripts:** 
  - `gaming-mode.bat`: Pauses Windows Update and OneDrive so you don't lag out in-game.
  - `speed-tuner.bat`: Tweaks TCP auto-tuning for gigabit/fiber connections.
  - `auto-healer.bat`: Runs in the background and restarts your adapter if the internet drops.
  - `hotspot-manager.bat`: Turns on the Windows Mobile Hotspot from the terminal.

### v1.2.1
- **Fix:** Fixed a bug in `net-info.bat` where the ping test failed on non-English Windows versions (switched to WMI).
- **Fix:** Stopped `hosts-adblock.bat` from accidentally deleting telemetry block rules.

### v1.2.0
- Added `net-info.bat` (network dashboard), `mac-spoof.bat` (MAC address randomizer), and `hosts-adblock.bat` (system-wide adblocker).

### v1.1.1
- Squashed a bunch of bugs with the telemetry blocker and Wi-Fi password extraction.

### v1.1.0
- Added `dns-benchmark.bat`, `telemetry-block.bat`, and `wifi-passwords.bat`.

### v1.0.0
- Initial commit. Scripts for DoH, AdGuard, flushing DNS, and Lenovo toolkit syncing.

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
