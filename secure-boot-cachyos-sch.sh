#!/bin/bash

# =========================================================
#  Funciones de Interfaz Visual (Spinner y Tareas)
# =========================================================

# Función para ocultar el output verboso y mostrar un spinner elegante
run_task() {
    local text="$1"
    shift
    "$@" > /tmp/secure_boot_schoperena.log 2>&1 &
    local pid=$!
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r\e[36m[%c] %s...\e[0m" "$spinstr" "$text"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    
    wait $pid
    if [ $? -eq 0 ]; then
        printf "\r\e[32m[✔] %s completado.\e[0m\033[K\n" "$text"
    else
        printf "\r\e[31m[✖] %s falló. Revisa /tmp/secure_boot_schoperena.log\e[0m\033[K\n" "$text"
    fi
}

echo -e "\e[32m=========================================================\e[0m"
echo -e "\e[32m  🔒 Configuración de Secure Boot (Dual Boot) SCHOPERENA \e[0m"
echo -e "\e[32m=========================================================\e[0m"
echo ""

# 0. Verificar si el sistema está en modo EFI
if [ ! -d "/sys/firmware/efi" ]; then
    echo -e "\e[31m[✖] Error: Este sistema no ha arrancado en modo UEFI.\e[0m"
    echo -e "Secure Boot no se puede configurar en sistemas Legacy/BIOS."
    exit 1
fi

# 1. Pedir permisos de SUDO
echo -e "\e[33m[!] Por favor, ingresa tu contraseña para autorizar los cambios:\e[0m"
sudo -v
(while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null) &
echo ""

# 2. Comprobar e instalar sbctl si no existe
if ! command -v sbctl >/dev/null 2>&1; then
    run_task "Instalando herramienta de Secure Boot (sbctl)" paru -S --noconfirm --needed sbctl
else
    printf "\e[32m[✔] sbctl ya está instalado.\e[0m\n"
fi
echo ""

# 3. Mostrar el estado actual al usuario (Única parte verbosa por seguridad)
echo -e "\e[34m[ℹ] Estado actual de Secure Boot:\e[0m"
sudo sbctl status
echo ""

# 4. Comprobar si el Setup Mode está activado (Llaves borradas)
# sbctl status suele imprimir "Setup Mode: ✓ Enabled" cuando las llaves están borradas
if sudo sbctl status | grep -q -i "Setup Mode:.*Enabled"; then
    echo -e "\e[32m✅ Modo Configuración (Setup Mode) detectado. Las llaves están borradas.\e[0m"
    echo -e "Procediendo con la generación e inscripción de llaves..."
    echo ""

    # Ejecutar proceso de firmas
    run_task "Creando llaves criptográficas personalizadas" sudo sbctl create-keys
    
    # Parámetro crítico: --microsoft para no romper Windows
    run_task "Inscribiendo llaves (Incluyendo compatibilidad Microsoft)" sudo sbctl enroll-keys --microsoft
    
    # Script específico de CachyOS para firmar Limine
    run_task "Firmando el gestor de arranque Limine y Kernel" sudo limine-enroll-config
    
    echo ""
    echo -e "\e[34m[ℹ] Verificación final de firmas:\e[0m"
    sudo sbctl verify
    echo ""
    
    echo -e "\e[32m=========================================================\e[0m"
    echo -e "\e[32m  🎉 ¡PROCESO DE FIRMADO COMPLETADO! \e[0m"
    echo -e "\e[32m=========================================================\e[0m"
    echo -e "\e[36mÚltimo paso:\e[0m"
    echo "1. Reinicia el equipo e ingresa a tu BIOS."
    echo "2. Cambia el 'Secure Boot' de 'Disabled' a 'Enabled'."
    echo "   (Mantén el modo de llaves en 'Custom' si te lo pregunta)."
    echo "3. Guarda los cambios y disfruta tu Dual Boot seguro."
    echo ""
    read -p "¿Deseas reiniciar directamente a la BIOS ahora? (s/n): " REBOOT_NOW </dev/tty
    if [[ "$REBOOT_NOW" =~ ^[Ss]$ ]]; then
        echo -e "\e[33mReiniciando hacia la BIOS...\e[0m"
        sudo systemctl reboot --firmware-setup
    fi

else
    # El Setup Mode NO está activado
    echo -e "\e[31m❌ ATENCIÓN: El modo 'Setup Mode' no está habilitado.\e[0m"
    echo -e "\e[33mEsto significa que las llaves de fábrica siguen instaladas en la placa base.\e[0m"
    echo ""
    echo -e "\e[36m📋 INSTRUCCIONES PARA CONTINUAR:\e[0m"
    echo "Para poder firmar el sistema, primero debes limpiar las llaves actuales:"
    echo "  1. Reinicia el equipo y entra a la BIOS (UEFI)."
    echo "  2. Ve a la pestaña de Seguridad o Boot."
    echo "  3. Desactiva 'Secure Boot' (Disabled)."
    echo "  4. Busca la opción 'Clear Secure Boot Keys' o cambia a modo 'Custom' para borrarlas."
    echo "  5. Guarda los cambios (F10), inicia CachyOS y vuelve a ejecutar este script."
    echo ""
    
    # Preguntar si desea ir a la BIOS
    read -p "¿Deseas reiniciar directamente a la BIOS en este momento? (s/n): " GOTO_BIOS </dev/tty
    
    if [[ "$GOTO_BIOS" =~ ^[Ss]$ ]]; then
        echo -e "\e[33mReiniciando hacia la BIOS...\e[0m"
        sudo systemctl reboot --firmware-setup
    else
        echo -e "\e[90mOperación cancelada. Ejecuta este script cuando las llaves estén borradas.\e[0m"
        exit 0
    fi
fi