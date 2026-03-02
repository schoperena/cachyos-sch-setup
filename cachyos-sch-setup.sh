#!/bin/bash

# =========================================================
#  Funciones de Interfaz Visual (Spinner y Tareas)
# =========================================================

# Esta función oculta el output verboso y muestra un spinner elegante
run_task() {
    local text="$1"
    shift
    # Ejecuta el comando en segundo plano y guarda logs por si falla
    "$@" > /tmp/setup_cachyos_schoperena.log 2>&1 &
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
        printf "\r\e[31m[✖] %s falló. Revisa /tmp/setup_cachyos_schoperena.log\e[0m\033[K\n" "$text"
    fi
}

# Función inteligente para evitar sincronizar repositorios si el paquete ya existe
smart_install() {
    local tool="$1"
    shift
    local missing=()
    
    for pkg in "$@"; do
        # Verifica instantáneamente en la base de datos local si está instalado
        if ! pacman -Qq "$pkg" >/dev/null 2>&1; then
            missing+=("$pkg")
        fi
    done
    
    if [ ${#missing[@]} -eq 0 ]; then
        # Todos los paquetes ya están instalados, salimos con éxito instantáneo
        return 0
    fi
    
    # Instalamos solo los que faltan
    if [ "$tool" = "paru" ]; then
        paru -S --noconfirm --needed "${missing[@]}"
    elif [ "$tool" = "pacman" ]; then
        sudo pacman -S --noconfirm --needed "${missing[@]}"
    fi
}

# Arreglo para guardar el resumen de las cosas que instaló/detectó el script
SUMMARY=()

echo -e "\e[32m=========================================================\e[0m"
echo -e "\e[32m  Iniciando Setup universal cachyos SCHOPERENA           \e[0m"
echo -e "\e[32m=========================================================\e[0m"
echo ""

# 0. Pedir permisos de SUDO desde el principio para que no moleste luego
echo -e "\e[33m[!] Por favor, ingresa tu contraseña para autorizar la instalación:\e[0m"
sudo -v
# Mantener los privilegios de sudo activos en segundo plano mientras el script viva
(while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null) &
echo ""

# Preguntar al usuario por el navegador (</dev/tty evita que falle usando curl | bash)
echo -e "\e[36m¿Qué navegador web prefieres instalar?\e[0m"
echo "1) Google Chrome"
echo "2) Brave Browser"
echo "3) Ninguno / Mantener el actual"
read -p "Selecciona una opción [1-3]: " BROWSER_CHOICE </dev/tty

BROWSER_PKG=""
case $BROWSER_CHOICE in
    1) BROWSER_PKG="google-chrome"; SUMMARY+=("Navegador instalado: Google Chrome") ;;
    2) BROWSER_PKG="brave-bin"; SUMMARY+=("Navegador instalado: Brave Browser") ;;
    *) SUMMARY+=("Navegador: Mantuvo el predeterminado") ;;
esac
echo ""

# 1. Ajustar el reloj para el Dual Boot con Windows
run_task "Ajustando el reloj local para Dual Boot" sudo timedatectl set-local-rtc 1 --adjust-system-clock
SUMMARY+=("Reloj de hardware sincronizado para Dual Boot")

# 2. Instalar todos los paquetes base
run_task "Instalando Zellij, Temas, Python, Fastfetch y Nerd Fonts" smart_install paru zellij gnome-tweaks orchis-theme tela-circle-icon-theme-git python python-pip ttf-meslo-nerd curl git fastfetch
SUMMARY+=("Herramientas de terminal, temas y base instalados/verificados")

# 3. Configurar Alacritty
echo -e "\e[34m[ℹ] Configurando Alacritty...\e[0m"
mkdir -p ~/.config/alacritty
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

# 4. Configurar Zellij
echo -e "\e[34m[ℹ] Configurando tema verde para Zellij...\e[0m"
mkdir -p ~/.config/zellij
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

# 5. Instalar Oh My Fish y el tema bobthefish
if [ ! -d "$HOME/.local/share/omf" ] && [ ! -d "$HOME/.config/omf" ]; then
    run_task "Descargando Oh My Fish" curl -sL https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install -o /tmp/install_omf
    run_task "Instalando Oh My Fish" fish /tmp/install_omf --noninteractive --yes
    rm -f /tmp/install_omf
else
    printf "\r\e[32m[✔] Oh My Fish ya se encontraba instalado.\e[0m\033[K\n"
fi

if ! fish -c "omf list" 2>/dev/null | grep -q "bobthefish"; then
    run_task "Instalando el tema bobthefish para tu Prompt" fish -c "omf install bobthefish"
else
    printf "\r\e[32m[✔] Tema bobthefish ya se encontraba configurado.\e[0m\033[K\n"
fi

# Configurar fish (AQUI ESTÁ LA MAGIA DEL FASTFETCH)
echo -e "\e[34m[ℹ] Inyectando configuraciones en Fish...\e[0m"
mkdir -p ~/.config/fish
cat << 'EOF' > ~/.config/fish/config.fish
# Configuración visual de bobthefish
set -g theme_color_scheme terminal
set -g theme_display_git yes
set -g theme_display_git_dirty yes
set -g theme_nerd_fonts yes
set -g theme_show_exit_status yes

# Auto-inicio de Zellij seguro + Fastfetch
if status is-interactive
    if not set -q ZELLIJ
        # Si no estamos en Zellij, lo iniciamos
        zellij
    else
        # Si YA estamos dentro de Zellij, mostramos el arte del sistema
        fastfetch
    end
end
EOF

# 6. Aplicar el tema Orchis Verde en GNOME
echo -e "\e[34m[ℹ] Aplicando el tema Orchis-Green-Dark en GNOME...\e[0m"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Orchis-Green-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle-green-dark'
gsettings set org.gnome.desktop.wm.preferences theme 'Orchis-Green-Dark'

mkdir -p ~/.config/gtk-4.0
if [ -d "/usr/share/themes/Orchis-Green-Dark/gtk-4.0" ]; then
    cp -r /usr/share/themes/Orchis-Green-Dark/gtk-4.0/* ~/.config/gtk-4.0/
fi
SUMMARY+=("Apariencia del sistema forzada a Orchis-Green-Dark")

# 7. Optimizaciones de hardware inteligentes
echo -e "\e[34m[ℹ] Detectando componentes de Hardware...\e[0m"
if ls /sys/class/power_supply/ | grep -q -i "BAT"; then
    SUMMARY+=("Hardware detectado: Batería presente (Perfil de Portátil activado)")
    
    if grep -q -i "intel" /proc/cpuinfo; then
        run_task "Instalando aceleración de video Intel" smart_install paru intel-media-driver libva-intel-driver auto-cpufreq powertop
        SUMMARY+=("-> Aceleración de hardware Intel configurada")
    elif grep -q -i "amd" /proc/cpuinfo; then
        run_task "Instalando aceleración de video AMD" smart_install paru libva-mesa-driver mesa-vdpau auto-cpufreq powertop
        SUMMARY+=("-> Aceleración de hardware AMD configurada")
    else
        run_task "Instalando utilidades de batería" smart_install paru auto-cpufreq powertop
    fi

    if lspci | grep -q -i "nvidia"; then
        run_task "Instalando EnvyControl para tarjeta NVIDIA" smart_install paru envycontrol
        SUMMARY+=("-> GPU NVIDIA detectada: EnvyControl configurado (Usa 'sudo envycontrol -s integrated' para máxima batería)")
    fi

    run_task "Activando los servicios de ahorro de energía agresivo" sudo systemctl disable --now power-profiles-daemon && sudo systemctl enable --now auto-cpufreq
    
    sudo bash -c 'cat << "EOF" > /etc/systemd/system/powertop.service
[Unit]
Description=Powertop tunings

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=-/usr/bin/powertop --auto-tune

[Install]
WantedBy=multi-user.target
EOF'
    sudo systemctl daemon-reload
    sudo systemctl enable --now powertop.service
    SUMMARY+=("-> Servicios auto-cpufreq y powertop habilitados en segundo plano")
else
    SUMMARY+=("Hardware detectado: Equipo de Escritorio (Perfil de Máximo Rendimiento)")
fi

# 8. Software adicional
if [ -n "$BROWSER_PKG" ]; then
    run_task "Instalando tu navegador favorito" smart_install paru "$BROWSER_PKG"
fi

run_task "Instalando Steam" smart_install pacman steam
SUMMARY+=("Gaming: Steam verificado")

if lspci | grep -q -i "nvidia"; then
    run_task "Instalando Bambu Studio (Versión optimizada NVIDIA)" smart_install paru bambustudio-nvidia-bin
    SUMMARY+=("Impresión 3D: Bambu Studio (Edición NVIDIA) verificado")
else
    run_task "Instalando Bambu Studio (Versión Genérica)" smart_install paru bambustudio-bin
    SUMMARY+=("Impresión 3D: Bambu Studio verificado")
fi

echo ""
# =========================================================
#  Resumen Final Visual
# =========================================================
echo -e "\e[32m=========================================================\e[0m"
echo -e "\e[32m  📋 RESUMEN DE LA INSTALACIÓN DE SCHOPERENA\e[0m"
echo -e "\e[32m=========================================================\e[0m"
for item in "${SUMMARY[@]}"; do
    echo -e " \e[36m👉\e[0m $item"
done
echo -e "\e[32m=========================================================\e[0m"
echo -e " \e[33m¡Setup completado con éxito!\e[0m"
echo -e " \e[90mCierra esta terminal y abre una nueva para ver los cambios.\e[0m"
echo ""