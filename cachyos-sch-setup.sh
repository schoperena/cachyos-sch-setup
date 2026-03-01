#!/bin/bash

echo "========================================================="
echo "  Iniciando Setup Universal (CachyOS - Edición Verde)    "
echo "========================================================="
echo ""

# Preguntar al usuario por el navegador antes de empezar todo el proceso
# Se añade </dev/tty para que funcione correctamente al ejecutar vía curl | bash
echo "¿Qué navegador web prefieres instalar?"
echo "1) Google Chrome"
echo "2) Brave Browser"
echo "3) Ninguno / Mantener el actual"
read -p "Selecciona una opción [1-3]: " BROWSER_CHOICE </dev/tty

BROWSER_PKG=""
case $BROWSER_CHOICE in
    1) BROWSER_PKG="google-chrome" ;;
    2) BROWSER_PKG="brave-bin" ;;
    *) echo " -> Omitiendo instalación de navegador extra." ;;
esac
echo ""

# 1. Ajustar el reloj para el Dual Boot con Windows
echo "[1/8] Ajustando el reloj local para Dual Boot..."
sudo timedatectl set-local-rtc 1 --adjust-system-clock

# 2. Instalar todos los paquetes base (Añadida la Nerd Font para los iconos)
echo "[2/8] Instalando Zellij, Temas, Python y Nerd Fonts..."
paru -S --noconfirm --needed zellij gnome-tweaks orchis-theme tela-circle-icon-theme-git python python-pip ttf-meslo-nerd curl git

# 3. Configurar Alacritty (Esquema Oscuro con acentos Verdes)
echo "[3/8] Configurando Alacritty y la fuente Nerd..."
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
green   = '#a6e3a1' # Verde principal
yellow  = '#f9e2af'
blue    = '#89b4fa'
magenta = '#f5c2e7'
cyan    = '#94e2d5'
white   = '#bac2de'

[colors.bright]
black   = '#585b70'
red     = '#f38ba8'
green   = '#a6e3a1' # Verde brillante
yellow  = '#f9e2af'
blue    = '#89b4fa'
magenta = '#f5c2e7'
cyan    = '#94e2d5'
white   = '#a6adc8'
EOF

# 4. Configurar Zellij (Tema Verde Personalizado)
echo "[4/8] Configurando el tema verde para Zellij..."
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
echo "[5/8] Configurando Fish Shell y el tema bobthefish..."
# Instalación no interactiva de OMF
curl -sL https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install > install_omf
fish install_omf --noninteractive --yes
rm install_omf

# Instalar el tema bobthefish
fish -c "omf install bobthefish"

# Configurar fish (Auto-inicio de Zellij seguro + Configuración del tema)
mkdir -p ~/.config/fish
cat << 'EOF' > ~/.config/fish/config.fish
# Configuración visual de bobthefish (Esquema que hereda el verde de Alacritty)
set -g theme_color_scheme terminal
set -g theme_display_git yes
set -g theme_display_git_dirty yes
set -g theme_nerd_fonts yes
set -g theme_show_exit_status yes

# Auto-inicio de Zellij seguro (Corrige el error de sintaxis)
if status is-interactive
    if not set -q ZELLIJ
        zellij
    end
end
EOF

# 6. Aplicar el tema Orchis Verde en GNOME
echo "[6/8] Aplicando el tema Orchis-Green-Dark en GNOME..."
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Orchis-Green-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle-green-dark'
gsettings set org.gnome.desktop.wm.preferences theme 'Orchis-Green-Dark'

mkdir -p ~/.config/gtk-4.0
if [ -d "/usr/share/themes/Orchis-Green-Dark/gtk-4.0" ]; then
    cp -r /usr/share/themes/Orchis-Green-Dark/gtk-4.0/* ~/.config/gtk-4.0/
fi

# 7. Optimizaciones de hardware inteligentes
echo "[7/8] Detectando hardware para aplicar perfiles de energía..."
if ls /sys/class/power_supply/ | grep -q -i "BAT"; then
    echo "🔋 Batería detectada. Aplicando perfil de Portátil..."
    
    # Detección de CPU para drivers de decodificación de video eficientes
    if grep -q -i "intel" /proc/cpuinfo; then
        echo " -> Procesador Intel detectado. Instalando drivers de video..."
        paru -S --noconfirm --needed intel-media-driver libva-intel-driver auto-cpufreq powertop
    elif grep -q -i "amd" /proc/cpuinfo; then
        echo " -> Procesador AMD detectado. Instalando drivers de video..."
        paru -S --noconfirm --needed libva-mesa-driver mesa-vdpau auto-cpufreq powertop
    else
        paru -S --noconfirm --needed auto-cpufreq powertop
    fi

    # Detección de GPU Dedicada (NVIDIA) en portátiles (Gráficas híbridas)
    if lspci | grep -q -i "nvidia"; then
        echo " -> Gráfica NVIDIA detectada. Instalando EnvyControl..."
        paru -S --noconfirm --needed envycontrol
        echo " ⚠️ NOTA: Para máximo ahorro de batería en este portátil, ejecuta 'sudo envycontrol -s integrated' y reinicia."
    fi

    sudo systemctl disable --now power-profiles-daemon
    sudo systemctl enable --now auto-cpufreq
    
    # Servicio Powertop con el parche "-" para evitar el fallo
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
else
    echo "⚡ No se detectó batería. Modo de Escritorio activado."
fi

# 8. Software adicional (Navegador, Steam y Bambu Studio)
echo "[8/8] Instalando Software Adicional..."

if [ -n "$BROWSER_PKG" ]; then
    echo " -> Instalando el navegador seleccionado ($BROWSER_PKG)..."
    paru -S --noconfirm --needed "$BROWSER_PKG"
fi

echo " -> Instalando Steam usando pacman..."
sudo pacman -S --noconfirm --needed steam

echo " -> Detectando GPU para instalar Bambu Studio..."
if lspci | grep -q -i "nvidia"; then
    echo "    NVIDIA detectada. Instalando bambustudio-nvidia-bin..."
    paru -S --noconfirm --needed bambustudio-nvidia-bin
else
    echo "    Gráfica AMD/Intel detectada. Instalando bambustudio-bin..."
    paru -S --noconfirm --needed bambustudio-bin
fi

echo ""
echo "========================================================="
echo " ¡Configuración Verde completada con éxito! "
echo " Cierra esta terminal y abre una nueva para ver los cambios. "
echo "========================================================="