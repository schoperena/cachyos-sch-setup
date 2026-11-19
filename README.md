# 🟢 CachyOS SCH Setup — Mega Installer

Automated post-installation and configuration scripts for **CachyOS (GNOME / KDE)**. One script to rule them all — sets up a unified workstation with a green dark aesthetic, hardware optimization, GNOME extensions, Secure Boot, and more.

> **Language:** Supports **English** (default) and **Spanish**. You'll be prompted at the start.
>
> **Idempotent:** Safe to re-run — detects already installed packages and skips them.
>
> **Pre-flight update:** Script now runs `sudo pacman -Syu --noconfirm` at startup and aborts if it fails.

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
./cachyos-mega-setup.sh software     # Browser, Steam, Bambu Studio, VLC, Spotify, KeePassXC, VS Code, Codex CLI, Claude Code
./cachyos-mega-setup.sh printer      # Brother printer installation
./cachyos-mega-setup.sh secureboot   # Secure Boot signing with sbctl
./cachyos-mega-setup.sh limine       # Limine kernel parameters (+ theme)
./cachyos-mega-setup.sh --help       # Show all available modules
```

### One-Liners for Individual Modules

| Module | One-liner |
|---|---|
| Secure Boot | `curl -fsSL .../cachyos-mega-setup.sh \| bash -s secureboot` |
| Limine Params | `curl -fsSL .../cachyos-mega-setup.sh \| bash -s limine` |
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
- Keeps CachyOS fish defaults (aliases, PATH) and auto-starts Zellij (not inside VS Code terminals)
- Existing configs are backed up as `*.bak.<timestamp>` before being overwritten
- ✅ Detects OMF and bobthefish if already installed

### Module 2: `desktop` — Desktop Customization (Auto-Detects GNOME / KDE)

**GNOME:**
- Orchis-Green-Dark GTK theme (including GTK4/Libadwaita)
- Tela-circle-green-dark icon pack
- GNOME Browser Connector for web-based extension management
- **10 Extensions auto-installed and enabled:**
  - User Themes, Places Menu, Drive Menu, System Monitor (from `gnome-shell-extensions`)
  - Caffeine and Dash to Dock (from repos)
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
| NVIDIA GPU | Enables NVIDIA laptop tooling with `envycontrol` |
| Intel/AMD CPU | Ensures matching microcode package (`intel-ucode` / `amd-ucode`) |
| Multicore systems | Enables `irqbalance` for interrupt distribution |

**Laptop (battery detected):**
- `auto-cpufreq` + `powertop` for power saving
- `fwupd` enabled for firmware updates
- **Masks** `power-profiles-daemon` (prevents GNOME/KDE from restarting it)
- `powertop --auto-tune` service keeps USB autosuspend **off** (avoids laggy USB mice/keyboards)
- `envycontrol` for NVIDIA Optimus laptops
- Intel hybrid laptops get extra profile notes (`thermald + irqbalance + microcode`)

### Module 4: `software` — Optional Software

All packages are asked before installation. Bambu Studio and VLC default to yes:
- 🌐 Browser (Google Chrome / Brave)
- 🎮 Steam + `cachyos-gaming-meta` + `gamemode` / `lib32-gamemode` (enables `gamemoded.service` automatically; adds `nvidia-prime` on hybrid NVIDIA laptops)
- 🖨️ Bambu Studio via Flatpak from Flathub (`com.bambulab.BambuStudio`)
- 🎬 VLC from repos
- 🎵 Spotify from AUR (optional)
- 🔐 KeePassXC via user Flatpak from Flathub (`org.keepassxc.KeePassXC`, optional)
- 💻 Visual Studio Code
- 🤖 Codex CLI (`openai-codex` from Arch repos, updates with the system)
- 🧠 Claude Code (official native installer, `~/.local/bin`, auto-updates)

### Module 5: `printer` — Brother Printer

- Asks for model and IP (defaults: DCP-L2640DW / 10.0.2.220)
- Enables multilib, CUPS, downloads official Brother installer
- Registers scanner via `brsaneconfig5`

### Module 6: `secureboot` — Secure Boot

- Verifies UEFI mode and Setup Mode
- `sbctl` keys → `--microsoft` enrollment → Limine signing (`limine-enroll-config`)
- After that, `limine-update` re-signs Limine automatically on every update
- Guided instructions if Setup Mode not active

### Module 7: `limine` — Limine Kernel Parameters

- Uses CachyOS's official `limine-entry-tool` config: parameters are appended to `KERNEL_CMDLINE[default]` in `/etc/default/limine` (or `/etc/kernel/cmdline`), then `limine-update` regenerates `limine.conf`
- No pacman hook needed — `limine-update` rebuilds entries from that config on every kernel update. The old `limine-cmdline-patch.hook` is removed if present
- Base default: `usbcore.autosuspend=-1`
- **NVIDIA GPUs**: Auto-detects and adds `nvidia_drm.modeset=1` and `nvidia_drm.fbdev=1`
- Adds a `/Windows` entry (Limine 8+ syntax) if `bootmgfw.efi` is on the same ESP, and migrates old `:Windows` entries
- If `limine.conf` is edited by hand, runs `limine-enroll-config` to re-enroll the checksum (if enabled) and re-sign for Secure Boot
- Helper installed at `/usr/local/bin/limine-patch-cmdline` (re-run with `sudo limine-patch-cmdline`)

**Optional Limine theme** (menu with terminal preview):

| # | Theme | Source |
|---|---|---|
| 0 | CachyOS wallpaper + green Catppuccin palette | [`diegons490/cachyos-limine-theme`](https://github.com/diegons490/cachyos-limine-theme) |
| 1–16 | catppuccin-mocha, nord, gruvbox, tokyo-night, rose-pine, dracula, solarized-dark, synthwave, neon-city, matrix, crt-amber, crt-green, gameboy, old-bios, glass, minimal | [`Spont-427/limine-theme`](https://github.com/Spont-427/limine-theme) (MIT) |

- Both sources are pinned to a commit and verified by sha256 before use; wallpapers for themes 1–16 are generated locally (no image downloads)
- Only global options at the top of `limine.conf` are changed (entries untouched); a timestamped backup is kept and restored on failure
- Wallpapers carry a `#blake2b` hash, so they still show with Secure Boot + an enrolled config
- Framed themes use the display's native resolution, or fall back to no frame
- Ends with `limine-enroll-config` (re-enroll checksum if enabled + re-sign for Secure Boot)

---

## ⚠️ Post-Installation Notes

1. **Restart terminal** — Close and reopen for Nerd Font to load in Fish
2. **GNOME** — Open **Extensions** app, enable **User Themes** for top bar theme
3. **KDE** — Open **Kvantum Manager**, select `Orchis-dark`. Enable **Blur** in Desktop Effects
4. **Steam + Gamemode** — Add to game Launch Options: `gamemoderun %command%` (hybrid NVIDIA laptop: `gamemoderun prime-run %command%`)
5. **NVIDIA laptops** — `sudo envycontrol -s integrated` + reboot for max battery
6. **BitLocker** — Suspend BitLocker in Windows before Secure Boot signing
7. **Printer** — Log out/in after setup for `lp` group to take effect
