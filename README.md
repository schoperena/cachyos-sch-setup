# 🟢 CachyOS SCH Setup & Secure Boot

Este repositorio contiene scripts de post-instalación y configuración automatizada para **CachyOS (GNOME)**. Diseñados para configurar un entorno de desarrollo estéticamente unificado (Cyberpunk/Verde), optimizar el hardware inteligentemente y configurar el Arranque Seguro (Secure Boot) para Dual Boot con Windows sin fricciones.

---

## 🛠️ 1. Setup Universal (Personalización y Hardware)

El script principal transforma una instalación limpia de CachyOS en una estación de trabajo lista para usar, detectando tu hardware para aplicar los ajustes exactos que necesitas (PC de Escritorio vs. Portátil).

### Características

- **Detección de hardware inteligente:** detecta si usas batería e instala utilidades (`auto-cpufreq`, `powertop`) y aceleración de video (`intel-media-driver` o `mesa-vdpau`) según tu CPU.
- **Soporte GPU / Optimus:** configura `envycontrol` automáticamente en portátiles con NVIDIA. Instala la versión de Bambu Studio adecuada (NVIDIA o genérica).
- **Terminal Hacker-Chic:** instala y configura **Alacritty** + **Zellij** + **Fish Shell** (con el tema bobthefish y Fastfetch), todo unificado en una paleta de colores verde oscuro.
- **Tema Orchis Green:** aplica el tema Orchis oscuro con acentos verdes en GNOME (incluyendo Libadwaita/GTK4) y el pack de iconos Tela Circle.
- **Corrección Dual Boot:** sincroniza el reloj del sistema (RTC a hora local) para evitar desajustes al cambiar a Windows.

### 🚀 Instalación

```bash
curl -fsSL https://raw.githubusercontent.com/schoperena/cachyos-sch-setup/main/cachyos-sch-setup.sh | bash
```

---

## 🔒 2. Configuración de Secure Boot (sbctl + Limine)

Script interactivo diseñado para firmar tu sistema CachyOS y permitir un Dual Boot seguro con Windows sin romper las firmas de Microsoft.

### Características

- **Comprobación de entorno:** verifica que el sistema esté en modo UEFI y comprueba la existencia de `sbctl` (instalándolo si es necesario).
- **Detección de Setup Mode:** comprueba si has borrado las llaves de fábrica en tu BIOS. Si no lo has hecho, te guía paso a paso e incluso te ofrece reiniciar directamente a la BIOS para hacerlo.
- **Inscripción segura:** crea llaves locales y las inscribe manteniendo la compatibilidad obligatoria con Microsoft (`--microsoft`).
- **Firma automática:** utiliza `limine-enroll-config` para firmar automáticamente el gestor de arranque de CachyOS.

### 🚀 Ejecución

```bash
curl -fsSL https://raw.githubusercontent.com/schoperena/cachyos-sch-setup/main/secure-boot-cachyos-sch.sh | bash
```

---

## 🖨️ 3. Instalación de Impresora Brother DCP-L2640DW

Script de instalación automática para la impresora/escáner Brother DCP-L2640DW en Arch Linux y sus derivados (CachyOS, Manjaro, etc.). Gestiona todas las dependencias, descarga los drivers oficiales de Brother y configura tanto la impresión vía CUPS como el escáner vía SANE.

### Características

- **Detección de distribución:** soporta Arch Linux / derivados (pacman) y Debian / Ubuntu (apt).
- **Multilib automático:** habilita el repositorio `[multilib]` en `pacman.conf` si no está activo, necesario para el driver `i386`.
- **Dependencias completas:** instala `cups`, `dpkg`, `curl`, `wget`, `sane` y `lib32-glibc` según lo que falte.
- **Driver oficial:** descarga e instala `dcpl2640dwpdrv` y `brscan5` directamente desde los servidores de Brother.
- **Configuración de escáner:** registra el dispositivo en `brsaneconfig5` por IP.
- **No interactivo:** todas las respuestas al instalador de Brother se pasan automáticamente por stdin.

### Requisitos previos

- La impresora debe estar conectada a la red y accesible por IP.
- Edita la variable `PRINTER_IP` al inicio del script si tu impresora usa una IP distinta a `10.0.2.220`.

### 🚀 Instalación

Descarga el script y ejecuta como root:

```bash
curl -fsSL https://raw.githubusercontent.com/schoperena/cachyos-sch-setup/main/install-brother-dcp-l2640dw.sh -o install-brother-dcp-l2640dw.sh
chmod +x install-brother-dcp-l2640dw.sh
sudo ./install-brother-dcp-l2640dw.sh
```

O directamente:

```bash
curl -fsSL https://raw.githubusercontent.com/schoperena/cachyos-sch-setup/main/install-brother-dcp-l2640dw.sh | sudo bash
```

Tras la instalación, imprime una página de prueba con:

```bash
lpr -P DCP-L2640DW /usr/share/cups/data/testprint
```

---

## 🔧 4. Protección de parámetros de kernel en Limine

Las actualizaciones de `limine` o del kernel regeneran `/boot/limine.conf` y pueden borrar parámetros personalizados de la línea `CMDLINE`. Esta solución instala un **hook de pacman** que reinyecta automáticamente los parámetros requeridos cada vez que eso ocurra.

Por defecto protege `usbcore.autosuspend=-1`. Para agregar más parámetros, edita el array `REQUIRED_PARAMS` en `/usr/local/bin/limine-patch-cmdline`.

### 🚀 Instalación

```bash
curl -fsSL https://raw.githubusercontent.com/schoperena/cachyos-sch-setup/main/install-limine-patch.sh | sudo bash
```

El one-liner descarga e instala dos archivos:

- `/usr/local/bin/limine-patch-cmdline` — script que parchea `limine.conf`
- `/etc/pacman.d/hooks/limine-cmdline-patch.hook` — hook que lo dispara automáticamente al actualizar `limine`, `linux`, `linux-cachyos*` o `mkinitcpio`

---

## ⚠️ Notas Post-Instalación

1. **Reinicia la terminal:** tras ejecutar el *Setup Universal*, cierra Alacritty y vuelve a abrirlo para que la nueva fuente *Nerd Font* cargue correctamente en tu prompt de Fish.
2. **GNOME Shell:** abre la aplicación **Extensiones** de GNOME y activa **User Themes** para que la barra superior del escritorio aplique el tema verde.
3. **Portátiles con NVIDIA:** si el script instaló EnvyControl, ejecuta `sudo envycontrol -s integrated` y reinicia cuando necesites maximizar la autonomía de batería.
4. **BitLocker en Windows:** *antes* de usar el script de Secure Boot, suspende BitLocker en Windows o ten a mano tu clave de recuperación de 48 dígitos.
5. **Grupo `lp` (impresora):** tras ejecutar el script de Brother, cierra sesión y vuelve a entrar para que la pertenencia al grupo `lp` surta efecto.
