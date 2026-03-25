#!/usr/bin/env bash
# =============================================================================
# install-limine-patch.sh
# Descarga e instala el hook de pacman y el script que protegen los parámetros
# personalizados de /boot/limine.conf frente a actualizaciones del sistema.
# =============================================================================

set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/schoperena/cachyos-sch-setup/main"
GREEN='\033[0;32m'; NC='\033[0m'
log() { echo -e "${GREEN}[limine-patch]${NC} $*"; }

[[ $EUID -ne 0 ]] && { echo "Ejecuta con sudo: curl ... | sudo bash"; exit 1; }

log "Instalando script en /usr/local/bin/limine-patch-cmdline..."
curl -fsSL "$BASE_URL/limine-patch-cmdline" -o /usr/local/bin/limine-patch-cmdline
chmod +x /usr/local/bin/limine-patch-cmdline

log "Instalando hook en /etc/pacman.d/hooks/limine-cmdline-patch.hook..."
mkdir -p /etc/pacman.d/hooks
curl -fsSL "$BASE_URL/limine-cmdline-patch.hook" -o /etc/pacman.d/hooks/limine-cmdline-patch.hook

log "Aplicando parche inicial..."
/usr/local/bin/limine-patch-cmdline

echo ""
log "Listo. El hook se activará automáticamente en cada actualización del sistema."
