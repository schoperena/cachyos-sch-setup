#!/bin/bash
# =============================================================================
#  🟢 CachyOS SCHOPERENA — Mega Setup Script v2 (EN/ES)
# =============================================================================
#  One-liner:
#    curl -fsSL https://raw.githubusercontent.com/schoperena/cachyos-sch-setup/main/cachyos-mega-setup.sh | bash
# =============================================================================
#  Module mode: ./cachyos-mega-setup.sh [module]
#    Modules: base, desktop, hardware, software, printer, secureboot, limine
#    No argument = full interactive setup
# =============================================================================
set -uo pipefail

# === CLI Argument Parsing ===
RUN_MODULE="${1:-all}"
if [ "$RUN_MODULE" = "--help" ] || [ "$RUN_MODULE" = "-h" ]; then
    echo "Usage: ./cachyos-mega-setup.sh [module]"
    echo ""
    echo "Modules:"
    echo "  (none)       Full interactive setup (asks everything)"
    echo "  base         Terminal, themes, fonts, Fish, OMF"
    echo "  desktop      GNOME/KDE customization and extensions"
    echo "  hardware     CPU/GPU optimization and power management"
    echo "  software     Browser, Steam, Bambu Studio, VS Code"
    echo "  printer      Brother printer installation"
    echo "  secureboot   Secure Boot signing with sbctl"
    echo "  limine       Limine kernel cmdline patch"
    echo ""
    exit 0
fi

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'
BOLD='\033[1m'; DIM='\033[2m'

# =============================================================================
#  i18n System — All user-facing strings
# =============================================================================
LANG_SEL="en"

load_strings() {
if [ "$LANG_SEL" = "es" ]; then
  S_LANG_Q="Selecciona idioma / Select language:"; S_LANG_1="1) English"; S_LANG_2="2) Español"
  S_BANNER_SUB="Instalador unificado de todo el sistema"
  S_DET_DE="Escritorio detectado"; S_DET_CPU="CPU detectado"; S_ARCH_L="Arquitectura"; S_HYBRID="Híbrida (P-core / E-core)"
  S_SUDO="[!] Ingresa tu contraseña para autorizar la instalación:"
  S_CFG="📋  CONFIGURACIÓN DEL SETUP"
  S_BRW_Q="¿Qué navegador web prefieres instalar?"; S_BRW_3="Ninguno / Mantener el actual"
  S_SEL="Selecciona"; S_DEF="default"
  S_STM_Q="¿Instalar Steam (gaming)?"; S_BMB_Q="¿Instalar Bambu Studio (impresión 3D)?"
  S_VSC_Q="¿Instalar Visual Studio Code?"
  S_IVC="Instalando Visual Studio Code"; S_VCD="IDE: Visual Studio Code instalado"
  S_PRT_Q="¿Instalar impresora Brother?"
  S_PRT_MD="Modelo por defecto"; S_PRT_MQ="Modelo de impresora (Enter para default)"
  S_PRT_ID="IP por defecto"; S_PRT_IQ="IP de la impresora (Enter para default)"
  S_SB_Q="¿Firmar el bootloader (Secure Boot)?"; S_SB_N="Requiere haber borrado las llaves de fábrica en BIOS."
  S_LM_Q="¿Instalar el parche de Limine (protege parámetros de kernel)?"
  S_TS_Q="¿Instalar la extensión Tailscale Status para GNOME?"; S_TS_N="Gestionar conexiones Tailscale desde el escritorio."
  S_SUM="✅  RESUMEN DE SELECCIÓN"
  S_L_DE="Escritorio"; S_L_CPU="CPU"; S_L_BRW="Navegador"; S_L_PRT="Impresora"; S_L_VSC="VS Code"
  S_YES="Sí"; S_NO="No"; S_NOINST="No instalar"
  S_CONFIRM="¿Todo correcto? Enter para continuar o Ctrl+C para cancelar..."
  S_YN="(s/N):"; S_YN_RE="^[Ss]$"; S_YN_Y="s"
  S_M1="⚙️  MÓDULO 1: Setup Base del Sistema"
  S_CLK="Ajustando el reloj local para Dual Boot"; S_CLK_D="Reloj sincronizado para Dual Boot"
  S_BASE="Instalando herramientas base, temas y Nerd Fonts"; S_BASE_D="Herramientas base instaladas/verificadas"
  S_ALA="Configurando Alacritty..."; S_ALA_D="Alacritty configurado con tema Catppuccin verde"
  S_ZEL="Configurando tema verde para Zellij..."; S_ZEL_D="Zellij configurado con tema cachy-green"
  S_OMF_DL="Descargando Oh My Fish"; S_OMF_IN="Instalando Oh My Fish"
  S_OMF_EX="Oh My Fish ya instalado."; S_OMF_D="Oh My Fish instalado"
  S_BOB_IN="Instalando tema bobthefish"; S_BOB_EX="Tema bobthefish ya configurado."; S_BOB_D="Tema bobthefish instalado"
  S_FSH="Inyectando configuraciones en Fish..."; S_FSH_D="Fish Shell configurado con bobthefish + Fastfetch"
  S_M2="🎨  MÓDULO 2: Personalización del Escritorio"
  S_GT="Instalando herramientas de GNOME"; S_GT_D="GNOME Tweaks, conector y extensiones base instalados"
  S_CAF="Instalando Caffeine (repos)"; S_D2D="Instalando Dash to Dock (AUR)"
  S_THM="Aplicando tema Orchis-Green-Dark en GNOME..."; S_THM_D="Apariencia GNOME: Orchis-Green-Dark"
  S_ENX="Habilitando extensiones de repos..."; S_END="Habilitada"
  S_EXD="Extensiones base habilitadas: User Themes, Places, Drive Menu, System Monitor, Caffeine, Dash to Dock"
  S_DLE="Descargando extensiones de extensions.gnome.org..."; S_INE="Instalando extensión"
  S_EAD="Extensiones adicionales: Extension List, Tiling Assistant, Transparent Top Bar"
  S_TSD="Extensión Tailscale Status instalada"
  S_KKV="Instalando Kvantum y herramientas KDE"; S_KOR="Instalando tema Orchis para KDE Plasma"
  S_KCF="Configurando personalización verde en KDE Plasma..."
  S_KD1="KDE: Orchis Dark + Kvantum + esquema verde Schoperena"; S_KD2="Iconos: Tela-circle-green-dark en KDE"
  S_DUK="Escritorio no reconocido. Saltando personalización."; S_DSK="Personalización: Saltada"
  S_M3="🔧  MÓDULO 3: Optimización de Hardware"
  S_IVA="Instalando aceleración de video Intel"; S_IVD="-> Aceleración Intel (VA-API) configurada"
  S_ITH="Instalando thermald (térmico Intel híbrida)"; S_ITA="Activando thermald"
  S_ITD="-> Intel 12th gen+: thermald activado para P-core/E-core"
  S_AVA="Verificando aceleración AMD (incluida en mesa)"; S_AVD="-> Aceleración AMD verificada (en mesa)"
  S_LAP="Hardware: Batería presente (Perfil Portátil)"; S_DST="Hardware: Escritorio (Máximo Rendimiento)"
  S_PWR="Instalando utilidades de ahorro de energía"
  S_ENV="Instalando EnvyControl para NVIDIA"; S_EVD="-> NVIDIA: EnvyControl configurado"
  S_EVT="   Usa 'sudo envycontrol -s integrated' para máxima batería"
  S_PPS="Deteniendo power-profiles-daemon"; S_PPM="Enmascarando power-profiles-daemon"
  S_ACF="Activando auto-cpufreq"; S_PWT="Activando powertop auto-tune"
  S_PWD="-> auto-cpufreq y powertop habilitados"
  S_M4="📦  MÓDULO 4: Software Opcional"
  S_IBR="Instalando navegador"; S_BRD="Navegador instalado"; S_BRS="Navegador: Mantuvo el predeterminado"
  S_IST="Instalando Steam"; S_STD="Gaming: Steam instalado"
  S_IBN="Instalando Bambu Studio (NVIDIA)"; S_IBA="Instalando Bambu Studio (Genérica)"
  S_BND="Impresión 3D: Bambu Studio (NVIDIA)"; S_BAD="Impresión 3D: Bambu Studio instalado"
  S_M5="🖨️  MÓDULO 5: Impresora Brother"
  S_MLB="Habilitando repositorio multilib..."; S_MLS="Sincronizando multilib"; S_MLD="Multilib habilitado"
  S_MLF="No se pudo habilitar multilib."
  S_PDP="Instalando dependencias de impresora"; S_CPS="Habilitando CUPS"; S_LPD="añadido al grupo lp"
  S_DBR="Descargando instalador Brother"; S_DCM="Descomprimiendo instalador Brother..."
  S_RBR="Ejecutando instalador Brother para"; S_SCN="Registrando escáner"
  S_POK="registrada en CUPS"; S_PVR="Verificar en http://localhost:631"; S_PDN="configurada (IP:"
  S_M6="🔒  MÓDULO 6: Secure Boot — Firma del Bootloader"
  S_NUE="Error: Sistema no arrancó en modo UEFI."; S_NU2="Secure Boot no disponible en Legacy/BIOS."
  S_SBS="Secure Boot: SALTADO (no UEFI)"
  S_SBE="sbctl ya instalado."; S_SBI="Estado de Secure Boot:"
  S_SMD="Setup Mode detectado."; S_CKY="Creando llaves criptográficas"
  S_EKY="Inscribiendo llaves (compatibilidad Microsoft)"; S_SBT="Firmando bootloader Limine y Kernel"
  S_VFY="Verificación final de firmas:"; S_SBD="Secure Boot: Llaves creadas y bootloader firmado"
  S_SBR="   -> Reinicia y activa Secure Boot en BIOS"
  S_NSM="Setup Mode no habilitado."; S_FKY="Llaves de fábrica siguen en la placa."
  S_INS="📋 INSTRUCCIONES:"
  S_IN1="1. Reinicia y entra a la BIOS."; S_IN2="2. Seguridad > Desactiva Secure Boot."
  S_IN3="3. Borra llaves (Clear Secure Boot Keys)."; S_IN4="4. Guarda (F10) y re-ejecuta este script."
  S_SBF="Secure Boot: No se pudo firmar (Setup Mode no activo)"
  S_RBQ="¿Reiniciar a la BIOS?"; S_RBG="Reiniciando a la BIOS..."
  S_M7="🔧  MÓDULO 7: Limine Kernel Cmdline Patch"
  S_LMS="Instalando limine-patch-cmdline"; S_LMH="Instalando hook de pacman para Limine"
  S_LMA="Aplicando parche inicial a limine.conf"; S_LMD="Limine Patch: Hook instalado"
  S_FTL="📋  RESUMEN DE LA INSTALACIÓN SCHOPERENA"
  S_GN="📝 NOTAS POST-INSTALACIÓN (GNOME):"
  S_G1="Cierra sesión y vuelve a entrar para activar extensiones."
  S_G2="Abre Extensiones o GNOME Tweaks para ajustar extensiones."
  S_G3="Activa User Themes para que la barra superior aplique el tema."
  S_G4="gnome-browser-connector permite instalar más extensiones desde"
  S_KN="📝 NOTAS POST-INSTALACIÓN (KDE):"
  S_K1="Cierra sesión para que el tema surta efecto."
  S_K2="Abre Kvantum Manager y selecciona 'Orchis-dark'."
  S_K3="En Configuración > Apariencia > Colores, selecciona SchoperenaGreen."
  S_K4="Activa Desenfoque en Efectos del Escritorio."
  S_CMP="¡Mega Setup v2 completado! 🎉"; S_CLT="Cierra esta terminal y abre una nueva."
  S_DON="completado."; S_FAI="falló. Revisa /tmp/setup_cachyos_schoperena.log"
  S_GDF="No se detectó la versión de GNOME Shell."
  S_ENF="Extensión no encontrada para GNOME"; S_ENU="Sin URL de descarga para"
else
  S_LANG_Q="Select language / Selecciona idioma:"; S_LANG_1="1) English"; S_LANG_2="2) Español"
  S_BANNER_SUB="Unified system installer"
  S_DET_DE="Desktop detected"; S_DET_CPU="CPU detected"; S_ARCH_L="Architecture"; S_HYBRID="Hybrid (P-core / E-core)"
  S_SUDO="[!] Please enter your password to authorize the installation:"
  S_CFG="📋  SETUP CONFIGURATION"
  S_BRW_Q="Which web browser do you prefer?"; S_BRW_3="None / Keep current"
  S_SEL="Select"; S_DEF="default"
  S_STM_Q="Install Steam (gaming)?"; S_BMB_Q="Install Bambu Studio (3D printing)?"
  S_VSC_Q="Install Visual Studio Code?"
  S_IVC="Installing Visual Studio Code"; S_VCD="IDE: Visual Studio Code installed"
  S_PRT_Q="Install Brother printer?"
  S_PRT_MD="Default model"; S_PRT_MQ="Printer model (Enter for default)"
  S_PRT_ID="Default IP"; S_PRT_IQ="Printer IP (Enter for default)"
  S_SB_Q="Sign bootloader (Secure Boot)?"; S_SB_N="Requires factory keys cleared in BIOS."
  S_LM_Q="Install Limine patch (protects kernel parameters)?"
  S_TS_Q="Install Tailscale Status extension for GNOME?"; S_TS_N="Manage Tailscale connections from desktop."
  S_SUM="✅  SELECTION SUMMARY"
  S_L_DE="Desktop"; S_L_CPU="CPU"; S_L_BRW="Browser"; S_L_PRT="Printer"
  S_YES="Yes"; S_NO="No"; S_NOINST="Don't install"
  S_CONFIRM="All correct? Press Enter to continue or Ctrl+C to cancel..."
  S_YN="(y/N):"; S_YN_RE="^[Yy]$"; S_YN_Y="y"
  S_M1="⚙️  MODULE 1: Base System Setup"
  S_CLK="Adjusting local clock for Dual Boot"; S_CLK_D="Hardware clock synced for Dual Boot"
  S_BASE="Installing base tools, themes and Nerd Fonts"; S_BASE_D="Base tools installed/verified"
  S_ALA="Configuring Alacritty..."; S_ALA_D="Alacritty configured with Catppuccin green theme"
  S_ZEL="Configuring green theme for Zellij..."; S_ZEL_D="Zellij configured with cachy-green theme"
  S_OMF_DL="Downloading Oh My Fish"; S_OMF_IN="Installing Oh My Fish"
  S_OMF_EX="Oh My Fish already installed."; S_OMF_D="Oh My Fish installed"
  S_BOB_IN="Installing bobthefish theme"; S_BOB_EX="bobthefish already configured."; S_BOB_D="bobthefish theme installed"
  S_FSH="Injecting Fish configurations..."; S_FSH_D="Fish Shell configured with bobthefish + Fastfetch"
  S_M2="🎨  MODULE 2: Desktop Customization"
  S_GT="Installing GNOME tools"; S_GT_D="GNOME Tweaks, browser connector and base extensions installed"
  S_CAF="Installing Caffeine (repos)"; S_D2D="Installing Dash to Dock (AUR)"
  S_THM="Applying Orchis-Green-Dark theme on GNOME..."; S_THM_D="GNOME appearance: Orchis-Green-Dark"
  S_ENX="Enabling extensions from repos..."; S_END="Enabled"
  S_EXD="Base extensions enabled: User Themes, Places, Drive Menu, System Monitor, Caffeine, Dash to Dock"
  S_DLE="Downloading extensions from extensions.gnome.org..."; S_INE="Installing extension"
  S_EAD="Additional extensions: Extension List, Tiling Assistant, Transparent Top Bar"
  S_TSD="Tailscale Status extension installed"
  S_KKV="Installing Kvantum and KDE tools"; S_KOR="Installing Orchis theme for KDE Plasma"
  S_KCF="Configuring dark green customization on KDE Plasma..."
  S_KD1="KDE: Orchis Dark + Kvantum + Schoperena green scheme"; S_KD2="Icons: Tela-circle-green-dark on KDE"
  S_DUK="Desktop not recognized. Skipping customization."; S_DSK="Customization: Skipped"
  S_M3="🔧  MODULE 3: Hardware Optimization"
  S_IVA="Installing Intel video acceleration"; S_IVD="-> Intel acceleration (VA-API) configured"
  S_ITH="Installing thermald (Intel hybrid thermal)"; S_ITA="Enabling thermald"
  S_ITD="-> Intel 12th gen+: thermald enabled for P-core/E-core"
  S_AVA="Verifying AMD acceleration (included in mesa)"; S_AVD="-> AMD acceleration verified (in mesa)"
  S_LAP="Hardware: Battery present (Laptop Profile)"; S_DST="Hardware: Desktop PC (Max Performance)"
  S_PWR="Installing power saving utilities"
  S_ENV="Installing EnvyControl for NVIDIA"; S_EVD="-> NVIDIA: EnvyControl configured"
  S_EVT="   Use 'sudo envycontrol -s integrated' for max battery"
  S_PPS="Stopping power-profiles-daemon"; S_PPM="Masking power-profiles-daemon"
  S_ACF="Enabling auto-cpufreq"; S_PWT="Enabling powertop auto-tune"
  S_PWD="-> auto-cpufreq and powertop enabled"
  S_M4="📦  MODULE 4: Optional Software"
  S_IBR="Installing browser"; S_BRD="Browser installed"; S_BRS="Browser: Kept default"
  S_IST="Installing Steam"; S_STD="Gaming: Steam installed"
  S_IBN="Installing Bambu Studio (NVIDIA)"; S_IBA="Installing Bambu Studio (Generic)"
  S_BND="3D Printing: Bambu Studio (NVIDIA)"; S_BAD="3D Printing: Bambu Studio installed"
  S_M5="🖨️  MODULE 5: Brother Printer"
  S_MLB="Enabling multilib repository..."; S_MLS="Syncing multilib"; S_MLD="Multilib enabled"
  S_MLF="Could not enable multilib automatically."
  S_PDP="Installing printer dependencies"; S_CPS="Enabling CUPS"; S_LPD="added to lp group"
  S_DBR="Downloading Brother installer"; S_DCM="Decompressing Brother installer..."
  S_RBR="Running Brother installer for"; S_SCN="Registering scanner"
  S_POK="registered in CUPS"; S_PVR="Verify at http://localhost:631"; S_PDN="configured (IP:"
  S_M6="🔒  MODULE 6: Secure Boot — Bootloader Signing"
  S_NUE="Error: System did not boot in UEFI mode."; S_NU2="Secure Boot unavailable on Legacy/BIOS."
  S_SBS="Secure Boot: SKIPPED (not UEFI)"
  S_SBE="sbctl already installed."; S_SBI="Secure Boot status:"
  S_SMD="Setup Mode detected."; S_CKY="Creating custom cryptographic keys"
  S_EKY="Enrolling keys (Microsoft compatibility)"; S_SBT="Signing Limine bootloader and Kernel"
  S_VFY="Final signature verification:"; S_SBD="Secure Boot: Keys created and bootloader signed"
  S_SBR="   -> Reboot and enable Secure Boot in BIOS"
  S_NSM="Setup Mode not enabled."; S_FKY="Factory keys still on motherboard."
  S_INS="📋 INSTRUCTIONS:"
  S_IN1="1. Reboot and enter BIOS (UEFI)."; S_IN2="2. Security > Disable Secure Boot."
  S_IN3="3. Clear keys (Clear Secure Boot Keys)."; S_IN4="4. Save (F10) and re-run this script."
  S_SBF="Secure Boot: Could not sign (Setup Mode not active)"
  S_RBQ="Reboot to BIOS?"; S_RBG="Rebooting to BIOS..."
  S_M7="🔧  MODULE 7: Limine Kernel Cmdline Patch"
  S_LMS="Installing limine-patch-cmdline"; S_LMH="Installing pacman hook for Limine"
  S_LMA="Applying initial patch to limine.conf"; S_LMD="Limine Patch: Hook installed"
  S_FTL="📋  SCHOPERENA INSTALLATION SUMMARY"
  S_GN="📝 POST-INSTALL NOTES (GNOME):"
  S_G1="Log out and back in to activate new extensions."
  S_G2="Open Extensions or GNOME Tweaks to configure extensions."
  S_G3="Enable User Themes for the top bar to apply the theme."
  S_G4="gnome-browser-connector lets you install more extensions from"
  S_KN="📝 POST-INSTALL NOTES (KDE):"
  S_K1="Log out and back in for the theme to take effect."
  S_K2="Open Kvantum Manager and select 'Orchis-dark'."
  S_K3="In System Settings > Appearance > Colors, select SchoperenaGreen."
  S_K4="Enable Blur in Desktop Effects for transparency."
  S_CMP="Mega Setup v2 completed successfully! 🎉"; S_CLT="Close this terminal and open a new one."
  S_DON="completed."; S_FAI="failed. Check /tmp/setup_cachyos_schoperena.log"
  S_GDF="Could not detect GNOME Shell version."
  S_ENF="Extension not found for GNOME"; S_ENU="No download URL for"
fi
}

load_strings  # Default English

# === Core Functions ===
run_task() {
    local text="$1"; shift
    "$@" > /tmp/setup_cachyos_schoperena.log 2>&1 &
    local pid=$!; local delay=0.1; local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}; printf "\r${CYAN}[%c] %s...${NC}" "$spinstr" "$text"
        local spinstr=$temp${spinstr%"$temp"}; sleep $delay
    done
    wait $pid; local ec=$?
    [ $ec -eq 0 ] && printf "\r${GREEN}[✔] %s ${S_DON}${NC}\033[K\n" "$text" || printf "\r${RED}[✖] %s ${S_FAI}${NC}\033[K\n" "$text"
    return $ec
}
smart_install() {
    local tool="$1"; shift; local m=()
    for p in "$@"; do pacman -Qq "$p" >/dev/null 2>&1 || m+=("$p"); done
    [ ${#m[@]} -eq 0 ] && return 0
    [ "$tool" = "paru" ] && paru -S --noconfirm --needed "${m[@]}" || sudo pacman -S --noconfirm --needed "${m[@]}"
}
install_gnome_extension() {
    local uuid="$1" gv; gv=$(gnome-shell --version 2>/dev/null | grep -oP '\d+' | head -1)
    [ -z "$gv" ] && { echo -e "${RED}[✖] ${S_GDF}${NC}"; return 1; }
    local info; info=$(curl -sf "https://extensions.gnome.org/extension-info/?uuid=${uuid}&shell_version=${gv}")
    [ -z "$info" ] && { echo -e "${YELLOW}[!] ${S_ENF} $gv: $uuid${NC}"; return 1; }
    local dl; dl=$(echo "$info" | python3 -c "import sys,json;print(json.load(sys.stdin)['download_url'])" 2>/dev/null)
    [ -z "$dl" ] && { echo -e "${YELLOW}[!] ${S_ENU} '$uuid'${NC}"; return 1; }
    local tz; tz=$(mktemp /tmp/gnome-ext-XXXXXX.zip)
    curl -sL "https://extensions.gnome.org${dl}" -o "$tz"
    gnome-extensions install --force "$tz" 2>/dev/null; rm -f "$tz"
    gnome-extensions enable "$uuid" 2>/dev/null || true
}
SUMMARY=()

# === Detect Desktop + CPU ===
detect_desktop() {
    if [ "${XDG_CURRENT_DESKTOP:-}" = "GNOME" ] || echo "${XDG_CURRENT_DESKTOP:-}" | grep -qi "GNOME"; then DESKTOP_ENV="gnome"
    elif echo "${XDG_CURRENT_DESKTOP:-}" | grep -qi "KDE"; then DESKTOP_ENV="kde"
    elif pgrep -x "gnome-shell" >/dev/null 2>&1; then DESKTOP_ENV="gnome"
    elif pgrep -x "plasmashell" >/dev/null 2>&1; then DESKTOP_ENV="kde"
    else DESKTOP_ENV="unknown"; fi
}
detect_cpu() {
    CPU_VENDOR="unknown"; CPU_IS_HYBRID=false; CPU_MODEL_NAME=""
    if grep -qi "GenuineIntel" /proc/cpuinfo 2>/dev/null; then
        CPU_VENDOR="intel"; CPU_MODEL_NAME=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | xargs)
        if echo "$CPU_MODEL_NAME" | grep -qP "i[3579]-(1[2-9]|[2-9]\d)\d{2}" || echo "$CPU_MODEL_NAME" | grep -qi "Core.*Ultra"; then CPU_IS_HYBRID=true; fi
    elif grep -qi "AuthenticAMD" /proc/cpuinfo 2>/dev/null; then
        CPU_VENDOR="amd"; CPU_MODEL_NAME=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | xargs)
    fi
}
detect_desktop; detect_cpu

# === Language Selection + Banner ===
clear; echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   🟢  CachyOS SCHOPERENA — Mega Setup v2               ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""; echo -e "${CYAN}${S_LANG_Q}${NC}"; echo "  ${S_LANG_1}"; echo "  ${S_LANG_2}"
read -p "  [1-2] (default: 1): " LANG_INPUT </dev/tty
[ "${LANG_INPUT:-1}" = "2" ] && LANG_SEL="es"
load_strings
clear; echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   🟢  CachyOS SCHOPERENA — Mega Setup v2               ║${NC}"
echo -e "${GREEN}║       ${S_BANNER_SUB}$(printf '%*s' $((34 - ${#S_BANNER_SUB})) '')║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo -e "${DIM}  ${S_DET_DE}: ${BOLD}${DESKTOP_ENV^^}${NC}"
echo -e "${DIM}  ${S_DET_CPU}: ${BOLD}${CPU_MODEL_NAME:-Unknown}${NC}"
$CPU_IS_HYBRID && echo -e "${DIM}  ${S_ARCH_L}: ${BOLD}${S_HYBRID}${NC}"
echo ""

# === Sudo ===
echo -e "${YELLOW}${S_SUDO}${NC}"; sudo -v
(while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null) &
echo ""

# === Default variable values (for module-only mode) ===
BROWSER_PKG=""; BROWSER_CHOICE=3; INSTALL_STEAM="n"; INSTALL_BAMBU="n"; INSTALL_VSCODE="n"
INSTALL_PRINTER="n"; SIGN_BOOTLOADER="n"; INSTALL_LIMINE_PATCH="n"; INSTALL_TAILSCALE_EXT="n"
PRINTER_MODEL="DCP-L2640DW"; PRINTER_IP="10.0.2.220"

# For single-module mode, auto-enable relevant flags
if [ "$RUN_MODULE" = "printer" ]; then INSTALL_PRINTER="${S_YN_Y}"; fi
if [ "$RUN_MODULE" = "secureboot" ]; then SIGN_BOOTLOADER="${S_YN_Y}"; fi
if [ "$RUN_MODULE" = "limine" ]; then INSTALL_LIMINE_PATCH="${S_YN_Y}"; fi

# === Mega Menu (only in full interactive mode) ===
if [ "$RUN_MODULE" = "all" ]; then
echo -e "${BOLD}${CYAN}╭───────────────────────────────────────────────────────────╮${NC}"
echo -e "${BOLD}${CYAN}│            ${S_CFG}                   │${NC}"
echo -e "${BOLD}${CYAN}╰───────────────────────────────────────────────────────────╯${NC}"
echo ""
echo -e "${CYAN}1. ${S_BRW_Q}${NC}"; echo "   1) Google Chrome"; echo "   2) Brave Browser"; echo "   3) ${S_BRW_3}"
read -p "   ${S_SEL} [1-3] (${S_DEF}: 3): " BROWSER_CHOICE </dev/tty
BROWSER_CHOICE=${BROWSER_CHOICE:-3}; BROWSER_PKG=""
case $BROWSER_CHOICE in 1) BROWSER_PKG="google-chrome";; 2) BROWSER_PKG="brave-bin";; esac; echo ""

echo -e "${CYAN}2. ${S_STM_Q}${NC}"; read -p "   ${S_YN} " INSTALL_STEAM </dev/tty; INSTALL_STEAM=${INSTALL_STEAM:-n}; echo ""
echo -e "${CYAN}3. ${S_BMB_Q}${NC}"; read -p "   ${S_YN} " INSTALL_BAMBU </dev/tty; INSTALL_BAMBU=${INSTALL_BAMBU:-n}; echo ""
echo -e "${CYAN}3b. ${S_VSC_Q}${NC}"; read -p "   ${S_YN} " INSTALL_VSCODE </dev/tty; INSTALL_VSCODE=${INSTALL_VSCODE:-n}; echo ""
echo -e "${CYAN}4. ${S_PRT_Q}${NC}"; read -p "   ${S_YN} " INSTALL_PRINTER </dev/tty; INSTALL_PRINTER=${INSTALL_PRINTER:-n}
PRINTER_MODEL="DCP-L2640DW"; PRINTER_IP="10.0.2.220"
if [[ "$INSTALL_PRINTER" =~ $S_YN_RE ]]; then
    echo ""; echo -e "${DIM}   ${S_PRT_MD}: ${PRINTER_MODEL}${NC}"
    read -p "   ${S_PRT_MQ}: " INPUT_MODEL </dev/tty; PRINTER_MODEL=${INPUT_MODEL:-$PRINTER_MODEL}
    echo -e "${DIM}   ${S_PRT_ID}: ${PRINTER_IP}${NC}"
    read -p "   ${S_PRT_IQ}: " INPUT_IP </dev/tty; PRINTER_IP=${INPUT_IP:-$PRINTER_IP}
fi; echo ""

echo -e "${CYAN}5. ${S_SB_Q}${NC}"; echo -e "${DIM}   ${S_SB_N}${NC}"
read -p "   ${S_YN} " SIGN_BOOTLOADER </dev/tty; SIGN_BOOTLOADER=${SIGN_BOOTLOADER:-n}; echo ""

echo -e "${CYAN}6. ${S_LM_Q}${NC}"; read -p "   ${S_YN} " INSTALL_LIMINE_PATCH </dev/tty; INSTALL_LIMINE_PATCH=${INSTALL_LIMINE_PATCH:-n}; echo ""

INSTALL_TAILSCALE_EXT="n"
if [ "$DESKTOP_ENV" = "gnome" ]; then
    echo -e "${CYAN}7. ${S_TS_Q}${NC}"; echo -e "${DIM}   ${S_TS_N}${NC}"
    read -p "   ${S_YN} " INSTALL_TAILSCALE_EXT </dev/tty; INSTALL_TAILSCALE_EXT=${INSTALL_TAILSCALE_EXT:-n}; echo ""
fi

# Summary
echo -e "${BOLD}${GREEN}╭───────────────────────────────────────────────────────────╮${NC}"
echo -e "${BOLD}${GREEN}│           ${S_SUM}                       │${NC}"
echo -e "${BOLD}${GREEN}╰───────────────────────────────────────────────────────────╯${NC}"
echo -e "   ${S_L_DE}:        ${BOLD}${DESKTOP_ENV^^}${NC}"
echo -e "   ${S_L_CPU}:           ${BOLD}${CPU_VENDOR^^}${NC} $($CPU_IS_HYBRID && echo "(${S_HYBRID})")"
echo -e "   ${S_L_BRW}:       $([ -n "$BROWSER_PKG" ] && echo "$BROWSER_PKG" || echo "$S_NOINST")"
echo -e "   Steam:          $([[ "$INSTALL_STEAM" =~ $S_YN_RE ]] && echo "$S_YES" || echo "$S_NO")"
echo -e "   Bambu Studio:   $([[ "$INSTALL_BAMBU" =~ $S_YN_RE ]] && echo "$S_YES" || echo "$S_NO")"
echo -e "   VS Code:        $([[ "$INSTALL_VSCODE" =~ $S_YN_RE ]] && echo "$S_YES" || echo "$S_NO")"
echo -e "   ${S_L_PRT}:       $([[ "$INSTALL_PRINTER" =~ $S_YN_RE ]] && echo "$PRINTER_MODEL @ $PRINTER_IP" || echo "$S_NO")"
echo -e "   Secure Boot:    $([[ "$SIGN_BOOTLOADER" =~ $S_YN_RE ]] && echo "$S_YES" || echo "$S_NO")"
echo -e "   Limine Patch:   $([[ "$INSTALL_LIMINE_PATCH" =~ $S_YN_RE ]] && echo "$S_YES" || echo "$S_NO")"
[ "$DESKTOP_ENV" = "gnome" ] && echo -e "   Tailscale:      $([[ "$INSTALL_TAILSCALE_EXT" =~ $S_YN_RE ]] && echo "$S_YES" || echo "$S_NO")"
echo ""; read -p "${S_CONFIRM} " </dev/tty; echo ""

# --- Module-only mode: ask module-specific questions ---
elif [ "$RUN_MODULE" = "printer" ]; then
    echo -e "${DIM}   ${S_PRT_MD}: ${PRINTER_MODEL}${NC}"
    read -p "   ${S_PRT_MQ}: " INPUT_MODEL </dev/tty; PRINTER_MODEL=${INPUT_MODEL:-$PRINTER_MODEL}
    echo -e "${DIM}   ${S_PRT_ID}: ${PRINTER_IP}${NC}"
    read -p "   ${S_PRT_IQ}: " INPUT_IP </dev/tty; PRINTER_IP=${INPUT_IP:-$PRINTER_IP}
elif [ "$RUN_MODULE" = "software" ]; then
    echo -e "${CYAN}1. ${S_BRW_Q}${NC}"; echo "   1) Google Chrome"; echo "   2) Brave Browser"; echo "   3) ${S_BRW_3}"
    read -p "   ${S_SEL} [1-3] (${S_DEF}: 3): " BROWSER_CHOICE </dev/tty; BROWSER_CHOICE=${BROWSER_CHOICE:-3}
    case $BROWSER_CHOICE in 1) BROWSER_PKG="google-chrome";; 2) BROWSER_PKG="brave-bin";; esac
    echo -e "${CYAN}${S_STM_Q}${NC}"; read -p "   ${S_YN} " INSTALL_STEAM </dev/tty; INSTALL_STEAM=${INSTALL_STEAM:-n}
    echo -e "${CYAN}${S_BMB_Q}${NC}"; read -p "   ${S_YN} " INSTALL_BAMBU </dev/tty; INSTALL_BAMBU=${INSTALL_BAMBU:-n}
    echo -e "${CYAN}${S_VSC_Q}${NC}"; read -p "   ${S_YN} " INSTALL_VSCODE </dev/tty; INSTALL_VSCODE=${INSTALL_VSCODE:-n}
fi  # end menu
# =============================================================================
#  MODULES 1-7: Execution
# =============================================================================

# === MODULE 1: Base System ===
if [ "$RUN_MODULE" = "all" ] || [ "$RUN_MODULE" = "base" ]; then
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ${S_M1}${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"; echo ""

run_task "$S_CLK" sudo timedatectl set-local-rtc 1 --adjust-system-clock; SUMMARY+=("$S_CLK_D")
run_task "$S_BASE" smart_install pacman zellij orchis-theme tela-circle-icon-theme-all python python-pip ttf-meslo-nerd curl git fastfetch mesa; SUMMARY+=("$S_BASE_D")

echo -e "${BLUE}[ℹ] ${S_ALA}${NC}"; mkdir -p ~/.config/alacritty
cat << 'EOF' > ~/.config/alacritty/alacritty.toml
[window]
opacity = 0.85
padding = { x = 10, y = 10 }
[window.dimensions]
columns = 100
lines = 30
[font]
size = 11.0
[font.normal]
family = "MesloLGS Nerd Font"
style = "Regular"
[colors.primary]
background = '#1e1e2e'
foreground = '#cdd6f4'
[colors.normal]
black   = '#45475a'
red     = '#f38ba8'
green   = '#a6e3a1'
yellow  = '#f9e2af'
blue    = '#89b4fa'
magenta = '#f5c2e7'
cyan    = '#94e2d5'
white   = '#bac2de'
[colors.bright]
black   = '#585b70'
red     = '#f38ba8'
green   = '#a6e3a1'
yellow  = '#f9e2af'
blue    = '#89b4fa'
magenta = '#f5c2e7'
cyan    = '#94e2d5'
white   = '#a6adc8'
EOF
SUMMARY+=("$S_ALA_D")

echo -e "${BLUE}[ℹ] ${S_ZEL}${NC}"; mkdir -p ~/.config/zellij
cat << 'EOF' > ~/.config/zellij/config.kdl
theme "cachy-green"
themes {
    cachy-green {
        fg "#cdd6f4"
        bg "#1e1e2e"
        black "#1e1e2e"
        red "#f38ba8"
        green "#a6e3a1"
        yellow "#f9e2af"
        blue "#89b4fa"
        magenta "#f5c2e7"
        cyan "#94e2d5"
        white "#bac2de"
        orange "#fab387"
    }
}
EOF
SUMMARY+=("$S_ZEL_D")

if [ ! -d "$HOME/.local/share/omf" ] && [ ! -d "$HOME/.config/omf" ]; then
    run_task "$S_OMF_DL" curl -sL https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install -o /tmp/install_omf
    run_task "$S_OMF_IN" fish /tmp/install_omf --noninteractive --yes; rm -f /tmp/install_omf; SUMMARY+=("$S_OMF_D")
else printf "\r${GREEN}[✔] ${S_OMF_EX}${NC}\033[K\n"; fi
if ! fish -c "omf list" 2>/dev/null | grep -q "bobthefish"; then
    run_task "$S_BOB_IN" fish -c "omf install bobthefish"; SUMMARY+=("$S_BOB_D")
else printf "\r${GREEN}[✔] ${S_BOB_EX}${NC}\033[K\n"; fi

echo -e "${BLUE}[ℹ] ${S_FSH}${NC}"; mkdir -p ~/.config/fish
cat << 'EOF' > ~/.config/fish/config.fish
set -g theme_color_scheme terminal
set -g theme_display_git yes
set -g theme_display_git_dirty yes
set -g theme_nerd_fonts yes
set -g theme_show_exit_status yes
if status is-interactive
    if not set -q ZELLIJ
        zellij
    else
        fastfetch
    end
end
EOF
SUMMARY+=("$S_FSH_D")
fi  # end module base

# === MODULE 2: Desktop Customization ===
if [ "$RUN_MODULE" = "all" ] || [ "$RUN_MODULE" = "desktop" ]; then
echo ""; echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ${S_M2} (${DESKTOP_ENV^^})${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"; echo ""

if [ "$DESKTOP_ENV" = "gnome" ]; then
    run_task "$S_GT" smart_install pacman gnome-tweaks gnome-browser-connector gnome-shell-extensions; SUMMARY+=("$S_GT_D")
    run_task "$S_CAF" smart_install pacman gnome-shell-extension-caffeine
    run_task "$S_D2D" smart_install paru gnome-shell-extension-dash-to-dock
    echo -e "${BLUE}[ℹ] ${S_THM}${NC}"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface gtk-theme 'Orchis-Green-Dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle-green-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.wm.preferences theme 'Orchis-Green-Dark' 2>/dev/null || true
    mkdir -p ~/.config/gtk-4.0
    [ -d "/usr/share/themes/Orchis-Green-Dark/gtk-4.0" ] && cp -r /usr/share/themes/Orchis-Green-Dark/gtk-4.0/* ~/.config/gtk-4.0/
    SUMMARY+=("$S_THM_D")
    echo -e "${BLUE}[ℹ] ${S_ENX}${NC}"
    for eu in "user-theme@gnome-shell-extensions.gcampax.github.com" "places-menu@gnome-shell-extensions.gcampax.github.com" "drive-menu@gnome-shell-extensions.gcampax.github.com" "system-monitor@gnome-shell-extensions.gcampax.github.com" "caffeine@patapon.info" "dash-to-dock@micxgx.gmail.com"; do
        gnome-extensions enable "$eu" 2>/dev/null || true; printf "${GREEN}[✔] ${S_END}: %s${NC}\n" "$eu"
    done; SUMMARY+=("$S_EXD")
    echo ""; echo -e "${BLUE}[ℹ] ${S_DLE}${NC}"
    REXT=("extension-list@tu.berry" "tiling-assistant@leleat-on-github" "transparent-top-bar@ftpix.com")
    [[ "$INSTALL_TAILSCALE_EXT" =~ $S_YN_RE ]] && REXT+=("tailscale-status@maxgallup.github.com")
    for eu in "${REXT[@]}"; do run_task "${S_INE}: $eu" install_gnome_extension "$eu"; done
    SUMMARY+=("$S_EAD")
    [[ "$INSTALL_TAILSCALE_EXT" =~ $S_YN_RE ]] && SUMMARY+=("$S_TSD")
elif [ "$DESKTOP_ENV" = "kde" ]; then
    run_task "$S_KKV" smart_install pacman kvantum
    run_task "$S_KOR" smart_install paru plasma6-themes-orchis-kde-git
    echo -e "${BLUE}[ℹ] ${S_KCF}${NC}"
    mkdir -p ~/.config/Kvantum; echo -e "[General]\ntheme=Orchis-dark" > ~/.config/Kvantum/kvantumrc
    command -v plasma-apply-desktoptheme >/dev/null 2>&1 && plasma-apply-desktoptheme Orchis-dark 2>/dev/null || true
    KWC=""; command -v kwriteconfig6 >/dev/null 2>&1 && KWC="kwriteconfig6" || { command -v kwriteconfig5 >/dev/null 2>&1 && KWC="kwriteconfig5"; }
    if [ -n "$KWC" ]; then
        $KWC --file kdeglobals --group General --key widgetStyle kvantum
        $KWC --file kdeglobals --group General --key ColorScheme SchoperenaGreen
        $KWC --file kdeglobals --group Icons --key Theme Tela-circle-green-dark
    fi
    mkdir -p ~/.local/share/color-schemes
    cat << 'KEOF' > ~/.local/share/color-schemes/SchoperenaGreen.colors
[General]
ColorScheme=SchoperenaGreen
Name=Schoperena Green
[Colors:Window]
BackgroundNormal=30,30,46
ForegroundNormal=205,214,244
[Colors:View]
BackgroundNormal=36,36,54
ForegroundNormal=205,214,244
[Colors:Button]
BackgroundNormal=49,50,68
ForegroundNormal=205,214,244
DecorationFocus=166,227,161
DecorationHover=166,227,161
[Colors:Selection]
BackgroundNormal=166,227,161
ForegroundNormal=30,30,46
[WM]
activeBackground=30,30,46
activeForeground=205,214,244
inactiveBackground=24,24,37
inactiveForeground=127,132,156
KEOF
    [ -n "$KWC" ] && $KWC --file kdeglobals --group General --key ColorScheme SchoperenaGreen
    SUMMARY+=("$S_KD1"); SUMMARY+=("$S_KD2")
else echo -e "${YELLOW}[!] ${S_DUK}${NC}"; SUMMARY+=("$S_DSK"); fi
fi  # end module desktop

# === MODULE 3: Hardware ===
if [ "$RUN_MODULE" = "all" ] || [ "$RUN_MODULE" = "hardware" ]; then
echo ""; echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ${S_M3}${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"; echo ""
if [ "$CPU_VENDOR" = "intel" ]; then
    run_task "$S_IVA" smart_install pacman intel-media-driver libva-intel-driver; SUMMARY+=("$S_IVD")
    if $CPU_IS_HYBRID; then
        run_task "$S_ITH" smart_install pacman thermald
        run_task "$S_ITA" sudo systemctl enable --now thermald; SUMMARY+=("$S_ITD")
    fi
elif [ "$CPU_VENDOR" = "amd" ]; then
    run_task "$S_AVA" smart_install pacman mesa; SUMMARY+=("$S_AVD")
fi
IS_LAPTOP=false; ls /sys/class/power_supply/ 2>/dev/null | grep -q -i "BAT" && IS_LAPTOP=true
if $IS_LAPTOP; then
    SUMMARY+=("$S_LAP"); run_task "$S_PWR" smart_install paru auto-cpufreq powertop
    if lspci | grep -q -i "nvidia"; then
        run_task "$S_ENV" smart_install paru envycontrol; SUMMARY+=("$S_EVD"); SUMMARY+=("$S_EVT")
    fi
    systemctl is-active --quiet power-profiles-daemon 2>/dev/null && run_task "$S_PPS" sudo systemctl stop power-profiles-daemon
    (systemctl is-enabled --quiet power-profiles-daemon 2>/dev/null) && run_task "$S_PPM" sudo systemctl mask power-profiles-daemon
    run_task "$S_ACF" sudo systemctl enable --now auto-cpufreq
    sudo bash -c 'cat << "SVCEOF" > /etc/systemd/system/powertop.service
[Unit]
Description=Powertop tunings
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=-/usr/bin/powertop --auto-tune
[Install]
WantedBy=multi-user.target
SVCEOF'
    sudo systemctl daemon-reload; run_task "$S_PWT" sudo systemctl enable --now powertop.service
    SUMMARY+=("$S_PWD")
else SUMMARY+=("$S_DST"); fi
fi  # end module hardware

# === MODULE 4: Optional Software ===
if [ "$RUN_MODULE" = "all" ] || [ "$RUN_MODULE" = "software" ]; then
echo ""; echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ${S_M4}${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"; echo ""
if [ -n "$BROWSER_PKG" ]; then run_task "${S_IBR} ($BROWSER_PKG)" smart_install paru "$BROWSER_PKG"; SUMMARY+=("${S_BRD}: $BROWSER_PKG")
else SUMMARY+=("$S_BRS"); fi
if [[ "$INSTALL_STEAM" =~ $S_YN_RE ]]; then run_task "$S_IST" smart_install pacman steam; SUMMARY+=("$S_STD"); fi
if [[ "$INSTALL_BAMBU" =~ $S_YN_RE ]]; then
    if lspci | grep -q -i "nvidia"; then run_task "$S_IBN" smart_install paru bambustudio-nvidia-bin; SUMMARY+=("$S_BND")
    else run_task "$S_IBA" smart_install paru bambustudio-bin; SUMMARY+=("$S_BAD"); fi
fi
if [[ "$INSTALL_VSCODE" =~ $S_YN_RE ]]; then run_task "$S_IVC" smart_install paru visual-studio-code-bin; SUMMARY+=("$S_VCD"); fi
fi  # end module software

# === MODULE 5: Brother Printer ===
if [[ "$INSTALL_PRINTER" =~ $S_YN_RE ]]; then
    echo ""; echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ${S_M5} ${PRINTER_MODEL}${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"; echo ""
    INSTALLER_URL="https://download.brother.com/welcome/dlf006893/linux-brprinter-installer-2.2.6-0.gz"
    INSTALLER_GZ="linux-brprinter-installer-2.2.6-0.gz"; INSTALLER_BIN="linux-brprinter-installer-2.2.6-0"
    BROTHER_WORKDIR="$(mktemp -d /tmp/brother-install-XXXXXX)"
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        echo -e "${YELLOW}[!] ${S_MLB}${NC}"
        sudo sed -i '/^#\[multilib\]/{N; s/#\[multilib\]\n#Include/[multilib]\nInclude/}' /etc/pacman.conf
        grep -q "^\[multilib\]" /etc/pacman.conf && { run_task "$S_MLS" sudo pacman -Sy --noconfirm; SUMMARY+=("$S_MLD"); } || echo -e "${YELLOW}[!] ${S_MLF}${NC}"
    fi
    run_task "$S_PDP" smart_install pacman cups dpkg curl wget sane lib32-glibc
    run_task "$S_CPS" sudo systemctl enable --now cups
    REAL_USER="${SUDO_USER:-$USER}"; id -nG "$REAL_USER" | grep -qw lp || { sudo usermod -aG lp "$REAL_USER"; SUMMARY+=("$REAL_USER $S_LPD"); }
    run_task "$S_DBR" bash -c "cd '$BROTHER_WORKDIR' && wget -q -T 30 -O '$INSTALLER_GZ' '$INSTALLER_URL'"
    echo -e "${BLUE}[ℹ] ${S_DCM}${NC}"; cd "$BROTHER_WORKDIR"; gunzip -f "$INSTALLER_GZ"; chmod +x "$INSTALLER_BIN"
    run_task "${S_RBR} $PRINTER_MODEL" bash -c "cd '$BROTHER_WORKDIR'; printf '%s\n' '$PRINTER_MODEL' y y y y y y y 10 '$PRINTER_IP' n | ./'$INSTALLER_BIN' || true"
    command -v brsaneconfig5 &>/dev/null && { run_task "$S_SCN" sudo brsaneconfig5 -a name="$PRINTER_MODEL" model="$PRINTER_MODEL" ip="$PRINTER_IP"; }
    lpstat -p "$PRINTER_MODEL" &>/dev/null 2>&1 && SUMMARY+=("$PRINTER_MODEL $S_POK") || SUMMARY+=("$PRINTER_MODEL: $S_PVR")
    rm -rf "$BROTHER_WORKDIR"; cd ~; SUMMARY+=("Brother $PRINTER_MODEL $S_PDN $PRINTER_IP)")
fi

# === MODULE 6: Secure Boot ===
if [[ "$SIGN_BOOTLOADER" =~ $S_YN_RE ]]; then
    echo ""; echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ${S_M6}${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"; echo ""
    if [ ! -d "/sys/firmware/efi" ]; then
        echo -e "${RED}[✖] ${S_NUE}${NC}"; echo -e "${RED}    ${S_NU2}${NC}"; SUMMARY+=("$S_SBS")
    else
        command -v sbctl >/dev/null 2>&1 || run_task "sbctl" smart_install paru sbctl
        printf "${GREEN}[✔] ${S_SBE}${NC}\n"
        echo -e "${BLUE}[ℹ] ${S_SBI}${NC}"; sudo sbctl status; echo ""
        if sudo sbctl status | grep -q -i "Setup Mode:.*Enabled"; then
            echo -e "${GREEN}✅ ${S_SMD}${NC}"; echo ""
            run_task "$S_CKY" sudo sbctl create-keys
            run_task "$S_EKY" sudo sbctl enroll-keys --microsoft
            run_task "$S_SBT" sudo limine-enroll-config
            echo ""; echo -e "${BLUE}[ℹ] ${S_VFY}${NC}"; sudo sbctl verify; echo ""
            SUMMARY+=("$S_SBD"); SUMMARY+=("$S_SBR")
        else
            echo -e "${RED}❌ ${S_NSM}${NC}"; echo -e "${YELLOW}${S_FKY}${NC}"; echo ""
            echo -e "${CYAN}${S_INS}${NC}"; echo "  $S_IN1"; echo "  $S_IN2"; echo "  $S_IN3"; echo "  $S_IN4"; echo ""
            SUMMARY+=("$S_SBF")
            read -p "${S_RBQ} ${S_YN} " GOTO_BIOS </dev/tty
            [[ "$GOTO_BIOS" =~ $S_YN_RE ]] && { echo -e "${YELLOW}${S_RBG}${NC}"; sudo systemctl reboot --firmware-setup; }
        fi
    fi
fi

# === MODULE 7: Limine Patch ===
if [[ "$INSTALL_LIMINE_PATCH" =~ $S_YN_RE ]]; then
    echo ""; echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ${S_M7}${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"; echo ""
    BASE_URL="https://raw.githubusercontent.com/schoperena/cachyos-sch-setup/main"
    run_task "$S_LMS" sudo bash -c "curl -fsSL '$BASE_URL/limine-patch-cmdline' -o /usr/local/bin/limine-patch-cmdline; chmod +x /usr/local/bin/limine-patch-cmdline"
    run_task "$S_LMH" sudo bash -c "mkdir -p /etc/pacman.d/hooks; curl -fsSL '$BASE_URL/limine-cmdline-patch.hook' -o /etc/pacman.d/hooks/limine-cmdline-patch.hook"
    run_task "$S_LMA" sudo /usr/local/bin/limine-patch-cmdline; SUMMARY+=("$S_LMD")
fi

# === FINAL SUMMARY ===
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║    ${S_FTL}             ║${NC}"
echo -e "${GREEN}╠═══════════════════════════════════════════════════════════╣${NC}"
if [ ${#SUMMARY[@]} -gt 0 ]; then
    for item in "${SUMMARY[@]}"; do echo -e "${GREEN}║${NC} ${CYAN}👉${NC} $item"; done
fi
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
if [ "$DESKTOP_ENV" = "gnome" ]; then
    echo -e " ${YELLOW}${S_GN}${NC}"; echo -e "    • ${S_G1}"; echo -e "    • ${S_G2}"
    echo -e "    • ${S_G3}"; echo -e "    • ${S_G4} ${CYAN}https://extensions.gnome.org${NC}"
elif [ "$DESKTOP_ENV" = "kde" ]; then
    echo -e " ${YELLOW}${S_KN}${NC}"; echo -e "    • ${S_K1}"; echo -e "    • ${S_K2}"
    echo -e "    • ${S_K3}"; echo -e "    • ${S_K4}"
fi
echo ""; echo -e " ${YELLOW}${S_CMP}${NC}"; echo -e " ${DIM}${S_CLT}${NC}"; echo ""
