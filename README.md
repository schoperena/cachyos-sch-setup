# 🟢 CachyOS SCH Setup — Mega Installer

Automated post-installation and configuration scripts for **CachyOS (GNOME / KDE)**. One script to rule them all — sets up a unified workstation with a green dark aesthetic, hardware optimization, GNOME extensions, Secure Boot, and more.

> **Language:** Supports **English** (default) and **Spanish**. You'll be prompted at the start.
>
> **Idempotent:** Safe to re-run — detects already installed packages and skips them.

---

## 🚀 Quick Start (Full Interactive Setup)

```bash
curl -fsSL https://raw.githubusercontent.com/schoperena/cachyos-sch-setup/main/cachyos-mega-setup.sh | bash
```

## 🔧 Run Individual Modules

You can also run specific modules independently:

```bash
# Download the script first
curl -fsSL https://raw.githubusercontent.com/schoperena/cachyos-sch-setup/main/cachyos-mega-setup.sh -o cachyos-mega-setup.sh
chmod +x cachyos-mega-setup.sh

# Run individual modules
./cachyos-mega-setup.sh base         # Terminal, themes, fonts, Fish, OMF
./cachyos-mega-setup.sh desktop      # GNOME/KDE customization and extensions
./cachyos-mega-setup.sh hardware     # CPU/GPU optimization & power management
./cachyos-mega-setup.sh software     # Browser, Steam, Bambu Studio, VS Code
./cachyos-mega-setup.sh printer      # Brother printer installation
./cachyos-mega-setup.sh secureboot   # Secure Boot signing with sbctl
./cachyos-mega-setup.sh limine       # Limine kernel cmdline patch
./cachyos-mega-setup.sh --help       # Show all available modules
```

### One-Liners for Individual Modules

| Module | One-liner |
|---|---|
| Secure Boot | `curl -fsSL .../cachyos-mega-setup.sh \| bash -s secureboot` |
| Limine Patch | `curl -fsSL .../cachyos-mega-setup.sh \| bash -s limine` |
| Brother Printer | `curl -fsSL .../cachyos-mega-setup.sh \| bash -s printer` |
| Hardware Only | `curl -fsSL .../cachyos-mega-setup.sh \| bash -s hardware` |

*(Replace `...` with `https://raw.githubusercontent.com/schoperena/cachyos-sch-setup/main`)*

---

## What Each Module Does

### Module 1: `base` — Base System Setup

- **Dual Boot clock fix** — Syncs hardware clock for Windows compatibility
- **Terminal stack** — Alacritty + Zellij + Fish Shell + Oh My Fish + bobthefish + Fastfetch
- **Nerd Fonts** — MesloLGS Nerd Font for terminal icons
- **Catppuccin green theme** — Unified dark green palette across tools
- ✅ Detects OMF and bobthefish if already installed

### Module 2: `desktop` — Desktop Customization (Auto-Detects GNOME / KDE)

**GNOME:**
- Orchis-Green-Dark GTK theme (including GTK4/Libadwaita)
- Tela-circle-green-dark icon pack
- GNOME Browser Connector for web-based extension management
- **10 Extensions auto-installed and enabled:**
  - User Themes, Places Menu, Drive Menu, System Monitor (from `gnome-shell-extensions`)
  - Caffeine (from repos), Dash to Dock (from AUR)
  - Extension List, Tiling Assistant, Transparent Top Bar (from extensions.gnome.org)
  - Tailscale Status (optional)

**KDE Plasma:**
- Orchis KDE theme + Kvantum engine
- Custom "SchoperenaGreen" color scheme
- Tela-circle-green-dark icon pack

### Module 3: `hardware` — Hardware Optimization

| Hardware | Action |
|---|---|
| Intel CPU | `intel-media-driver` + `libva-intel-driver` for VA-API |
| Intel 12th gen+ | + `thermald` for P-core/E-core thermal management |
| AMD CPU | Verifies `mesa` (VA-API included since mesa absorbed the old packages) |
| NVIDIA GPU | Uses NVIDIA-specific builds, allows envycontrol on laptops |

**Laptop (battery detected):**
- `auto-cpufreq` + `powertop` for power saving
- **Masks** `power-profiles-daemon` (prevents GNOME/KDE from restarting it)
- `envycontrol` for NVIDIA Optimus laptops

### Module 4: `software` — Optional Software (All Optional)

All packages are asked before installation:
- 🌐 Browser (Google Chrome / Brave)
- 🎮 Steam
- 🖨️ Bambu Studio (auto-detects NVIDIA)
- 💻 Visual Studio Code

### Module 5: `printer` — Brother Printer

- Asks for model and IP (defaults: DCP-L2640DW / 10.0.2.220)
- Enables multilib, CUPS, downloads official Brother installer
- Registers scanner via `brsaneconfig5`

### Module 6: `secureboot` — Secure Boot

- Verifies UEFI mode and Setup Mode
- `sbctl` keys → `--microsoft` enrollment → Limine signing
- Guided instructions if Setup Mode not active

### Module 7: `limine` — Limine Cmdline Patch

- Pacman hook to protect custom kernel parameters across updates
- Base default: `usbcore.autosuspend=-1`
- **NVIDIA GPUs**: Auto-detects and adds `nvidia_drm.modeset=1` and `nvidia_drm.fbdev=1`.
- **AMD GPUs**: Auto-detects and adds `amd_pstate=active`.

---

## ⚠️ Post-Installation Notes

1. **Restart terminal** — Close and reopen for Nerd Font to load in Fish
2. **GNOME** — Open **Extensions** app, enable **User Themes** for top bar theme
3. **KDE** — Open **Kvantum Manager**, select `Orchis-dark`. Enable **Blur** in Desktop Effects
4. **NVIDIA laptops** — `sudo envycontrol -s integrated` + reboot for max battery
5. **BitLocker** — Suspend BitLocker in Windows before Secure Boot signing
6. **Printer** — Log out/in after setup for `lp` group to take effect
