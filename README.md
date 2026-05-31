<div align="center">

# 🌐 Win11 Net Automator

**Batch scripts to fix your Windows 11 networking headaches.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![OS: Windows 11](https://img.shields.io/badge/OS-Windows%2011-0078D4?logo=windows11&logoColor=white)](https://www.microsoft.com/windows/windows-11)
[![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen.svg)](https://github.com/XploitVoid/win11-net-automator/pulls)

</div>

---

I got tired of manually configuring DNS, flushing network stacks, and clicking through settings every time I set up a new machine or debug connectivity issues. So I wrote these scripts to automate the boring stuff.

This repo is a collection of `.bat` scripts (with PowerShell under the hood where needed) that handle DNS over HTTPS setup, AdGuard Home routing, Lenovo Legion power profiles, and full network resets.

## What's in the box

| Script | What it does |
|--------|-------------|
| `enable-doh.bat` | Sets up DNS over HTTPS with Cloudflare + Google DNS. Registers DoH templates, configures the adapter, writes registry flags — the whole nine yards. |
| `adguard-routing.bat` | Points your DNS to a local AdGuard Home instance. Detects your active adapter automatically. |
| `lltk-profile-sync.bat` | Quick switcher for Lenovo Legion Toolkit power profiles (Quiet/Balance/Performance). Saves you from opening the GUI. |
| `network-flush.bat` | Nuclear option — flushes DNS, releases/renews IP, resets Winsock and TCP/IP stack. For when nothing else works. |

## Before you start

- **Windows 11** — these scripts use Win11-specific features (especially the DoH stuff)
- **Run as Admin** — every script checks for elevation and will bail out if you forget
- **Lenovo Legion Toolkit** — only needed for `lltk-profile-sync.bat`. Make sure `LenovoToolkitCLI.exe` is in your PATH

## How to use

```bash
git clone https://github.com/XploitVoid/win11-net-automator.git
cd win11-net-automator
```

Then right-click any script in `scripts/` → **Run as administrator**. Or from an elevated terminal:

```batch
scripts\enable-doh.bat
scripts\adguard-routing.bat
scripts\network-flush.bat
scripts\lltk-profile-sync.bat
```

Each script has interactive prompts and will walk you through what it's doing.

## Scripts in detail

### `enable-doh.bat`

Enables encrypted DNS on your active network adapter. It:
- Registers Cloudflare (`1.1.1.1`, `1.0.0.1`) and Google (`8.8.8.8`, `8.8.4.4`) as DoH servers
- Detects whichever adapter you're actually using
- Sets all four as your DNS servers (Cloudflare primary, Google fallback)
- Writes the `DohFlags` registry entries so Windows enforces encrypted-only mode
- Falls back to `netsh` if the PowerShell cmdlet doesn't cooperate

### `adguard-routing.bat`

If you're running AdGuard Home on your LAN, this script points your machine's DNS at it. It auto-detects whether you're on Wi-Fi or Ethernet, asks for the AdGuard IP, validates the input, and applies it. DNS cache gets flushed automatically after.

### `lltk-profile-sync.bat`

Simple menu to switch power profiles through the Lenovo Legion Toolkit CLI. Pick 1/2/3 and it calls `LenovoToolkitCLI.exe` with the right arguments. Not much more to it.

### `network-flush.bat`

Runs the classic network reset sequence (`flushdns` → `release` → `renew` → `winsock reset` → `ip reset`) with proper error tracking. Offers to reboot when it's done since Winsock/TCP resets need a restart to fully apply.

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
