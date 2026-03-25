#!/usr/bin/env bash
# =============================================================================
# install-brother-dcp-l2640dw.sh
# Instalación automática de la impresora Brother DCP-L2640DW en Arch Linux
# Probado en CachyOS (basado en Arch) - Marzo 2026
# =============================================================================

set -euo pipefail

# --- Colores para output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log()    { echo -e "${GREEN}[OK]${NC}    $*"; }
info()   { echo -e "${BLUE}[INFO]${NC}  $*"; }
warn()   { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()  { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# --- Configuración ---
PRINTER_MODEL="DCP-L2640DW"
PRINTER_IP="10.0.2.220"              # <-- Cambia esto si tu IP es diferente
INSTALLER_URL="https://download.brother.com/welcome/dlf006893/linux-brprinter-installer-2.2.6-0.gz"
INSTALLER_GZ="linux-brprinter-installer-2.2.6-0.gz"
INSTALLER_BIN="linux-brprinter-installer-2.2.6-0"
WORKDIR="$(mktemp -d /tmp/brother-install-XXXXXX)"

# =============================================================================
# Verificaciones previas
# =============================================================================

check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "Este script debe ejecutarse como root. Usa: sudo $0"
    fi
}

detect_distro() {
    if command -v pacman &>/dev/null; then
        DISTRO="arch"
        log "Distribución detectada: Arch Linux / derivado"
    elif command -v apt-get &>/dev/null; then
        DISTRO="debian"
        log "Distribución detectada: Debian / Ubuntu"
    else
        error "Distribución no soportada. Solo Arch y Debian/Ubuntu."
    fi
}

# =============================================================================
# Instalación de dependencias
# =============================================================================

install_deps_arch() {
    info "Instalando dependencias en Arch Linux..."

    local pkgs=()

    if ! pacman -Qi cups &>/dev/null; then
        pkgs+=(cups)
    fi
    if ! pacman -Qi dpkg &>/dev/null; then
        pkgs+=(dpkg)
    fi
    if ! pacman -Qi curl &>/dev/null; then
        pkgs+=(curl)
    fi
    if ! pacman -Qi wget &>/dev/null; then
        pkgs+=(wget)
    fi
    if ! pacman -Qi sane &>/dev/null; then
        pkgs+=(sane)
    fi
    if ! pacman -Qi lib32-glibc &>/dev/null; then
        pkgs+=(lib32-glibc)  # Necesario para el driver i386
    fi

    if [[ ${#pkgs[@]} -gt 0 ]]; then
        info "Paquetes a instalar: ${pkgs[*]}"
        pacman -S --noconfirm --needed "${pkgs[@]}"
    else
        log "Todas las dependencias ya están instaladas."
    fi
}

install_deps_debian() {
    info "Instalando dependencias en Debian/Ubuntu..."
    apt-get update -qq
    apt-get install -y --no-install-recommends \
        cups curl wget sane libsane \
        libcurl4 libc6 dpkg
}

install_deps() {
    case "$DISTRO" in
        arch)    install_deps_arch ;;
        debian)  install_deps_debian ;;
    esac
}

# =============================================================================
# Habilitar y configurar CUPS
# =============================================================================

setup_cups() {
    info "Habilitando servicio CUPS..."
    systemctl enable --now cups
    log "CUPS habilitado y en ejecución."

    # Agregar usuario actual al grupo lp
    local real_user="${SUDO_USER:-$USER}"
    if id -nG "$real_user" | grep -qw lp; then
        warn "El usuario '$real_user' ya pertenece al grupo 'lp'."
    else
        usermod -aG lp "$real_user"
        log "Usuario '$real_user' añadido al grupo 'lp'."
    fi
}

# =============================================================================
# Habilitar multilib para paquetes i386 (solo Arch)
# =============================================================================

enable_multilib() {
    if [[ "$DISTRO" != "arch" ]]; then return; fi

    if grep -q "^\[multilib\]" /etc/pacman.conf; then
        log "Repositorio multilib ya está habilitado."
        return
    fi

    warn "Habilitando repositorio multilib para soporte i386..."
    sed -i '/^#\[multilib\]/{N; s/#\[multilib\]\n#Include/[multilib]\nInclude/}' /etc/pacman.conf

    if grep -q "^\[multilib\]" /etc/pacman.conf; then
        pacman -Sy --noconfirm
        log "Multilib habilitado y base de datos actualizada."
    else
        warn "No se pudo habilitar multilib automáticamente. Puede que el driver i386 falle."
        warn "Edita /etc/pacman.conf manualmente y descomenta [multilib] e Include."
    fi
}

# =============================================================================
# Descargar e instalar el driver Brother
# =============================================================================

download_installer() {
    info "Descargando instalador Brother desde:"
    info "  $INSTALLER_URL"
    cd "$WORKDIR"
    wget -T 30 --show-progress -O "$INSTALLER_GZ" "$INSTALLER_URL"
    log "Descarga completa."
}

prepare_installer() {
    info "Descomprimiendo y preparando el instalador..."
    cd "$WORKDIR"
    gunzip -f "$INSTALLER_GZ"
    chmod +x "$INSTALLER_BIN"
    log "Instalador listo: $WORKDIR/$INSTALLER_BIN"
}

run_brother_installer() {
    info "Ejecutando el instalador Brother (modo no interactivo)..."
    cd "$WORKDIR"

    # El instalador de Brother es un script interactivo.
    # Pasamos las respuestas esperadas por stdin:
    #
    #  Línea 1: modelo de impresora
    #  Línea 2: "y" aceptar instalación de paquetes
    #  Línea 3: "y" aceptar licencia del driver de impresión
    #  Línea 4: "y" aceptar instalar el escáner (brscan5)
    #  Línea 5: "y" aceptar licencia brscan5
    #  Línea 6: "y" aceptar instalar brscan-skey
    #  Línea 7: "y" aceptar licencia brscan-skey
    #  Línea 8: "y" especificar URI del dispositivo (Device URI)
    #  Línea 9: "10" elegir "Specify IP address"
    #  Línea 10: IP de la impresora
    #  Línea 11: "n" no hacer test de impresión (lo haremos luego)

    printf '%s\n' \
        "$PRINTER_MODEL" \
        "y" \
        "y" \
        "y" \
        "y" \
        "y" \
        "y" \
        "y" \
        "10" \
        "$PRINTER_IP" \
        "n" \
        | ./"$INSTALLER_BIN" || true
    # '|| true' porque el instalador puede salir con código distinto de 0
    # aunque la instalación sea exitosa (por los symlinks que fallan en Arch)

    log "Instalador Brother finalizado."
}

# =============================================================================
# Configurar escáner (brscan5)
# =============================================================================

configure_scanner() {
    info "Registrando escáner con brsaneconfig5..."
    if command -v brsaneconfig5 &>/dev/null; then
        brsaneconfig5 -a name="$PRINTER_MODEL" model="$PRINTER_MODEL" ip="$PRINTER_IP"
        log "Escáner registrado correctamente."
    else
        warn "brsaneconfig5 no encontrado. El escáner puede no estar disponible."
    fi
}

# =============================================================================
# Verificación final
# =============================================================================

verify_installation() {
    info "Verificando instalación..."
    echo ""

    if lpstat -p "$PRINTER_MODEL" &>/dev/null 2>&1; then
        log "Impresora '$PRINTER_MODEL' registrada en CUPS."
    else
        warn "No se encontró la impresora en CUPS. Puede necesitar configuración manual."
        warn "Abre http://localhost:631 en tu navegador para gestionar CUPS."
    fi

    if command -v brsaneconfig5 &>/dev/null; then
        local scan_result
        scan_result=$(brsaneconfig5 -q 2>&1 || true)
        if echo "$scan_result" | grep -qi "$PRINTER_MODEL"; then
            log "Escáner '$PRINTER_MODEL' detectado correctamente."
        else
            warn "El escáner no aparece en brsaneconfig5 -q"
        fi
    fi

    echo ""
    echo -e "${GREEN}=================================================================${NC}"
    echo -e "${GREEN} Instalación completada.${NC}"
    echo -e "${GREEN}=================================================================${NC}"
    echo ""
    echo -e "  Modelo:     ${BLUE}$PRINTER_MODEL${NC}"
    echo -e "  IP:         ${BLUE}$PRINTER_IP${NC}"
    echo -e "  CUPS UI:    ${BLUE}http://localhost:631${NC}"
    echo ""
    echo -e "  Para imprimir una página de prueba:"
    echo -e "  ${YELLOW}lpr -P $PRINTER_MODEL /usr/share/cups/data/testprint${NC}"
    echo ""
    echo -e "  Para escanear (si tienes simple-scan o xsane instalado):"
    echo -e "  ${YELLOW}simple-scan${NC}  o  ${YELLOW}xsane${NC}"
    echo ""

    # Recordatorio de re-login para que surta efecto el grupo lp
    local real_user="${SUDO_USER:-$USER}"
    echo -e "${YELLOW}NOTA:${NC} Cierra sesión y vuelve a entrar como '$real_user'"
    echo -e "       para que los cambios del grupo 'lp' tengan efecto."
    echo ""
}

# =============================================================================
# Limpieza
# =============================================================================

cleanup() {
    info "Limpiando archivos temporales en $WORKDIR..."
    rm -rf "$WORKDIR"
}

# =============================================================================
# Main
# =============================================================================

main() {
    echo ""
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BLUE} Instalador automático Brother DCP-L2640DW - Arch Linux${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo ""

    check_root
    detect_distro
    enable_multilib
    install_deps
    setup_cups
    download_installer
    prepare_installer
    run_brother_installer
    configure_scanner
    verify_installation
    cleanup
}

main "$@"
