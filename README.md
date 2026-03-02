# **🟢 CachyOS SCH Setup & Secure Boot**

Este repositorio contiene scripts de post-instalación y configuración automatizada para **CachyOS (GNOME)**. Diseñados para configurar un entorno de desarrollo estéticamente unificado (Cyberpunk/Verde), optimizar el hardware inteligentemente y configurar el Arranque Seguro (Secure Boot) para Dual Boot con Windows sin fricciones.

## **🛠️ 1\. Setup Universal (Personalización y Hardware)**

El script principal transforma una instalación limpia de CachyOS en una estación de trabajo lista para usar, detectando tu hardware para aplicar los ajustes exactos que necesitas (PC de Escritorio vs. Portátil).

### **✨ Características**

* **🧠 Detección de Hardware Inteligente:** Detecta si usas batería e instala utilidades (auto-cpufreq, powertop) y aceleración de video (intel-media-driver o mesa-vdpau) según tu CPU.  
* **🎮 Soporte GPU / Optimus:** Configura envycontrol automáticamente en portátiles con NVIDIA. Instala la versión de Bambu Studio adecuada (NVIDIA o genérica).  
* **💻 Terminal Hacker-Chic:** Instala y configura **Alacritty** \+ **Zellij** \+ **Fish Shell** (con el tema bobthefish y Fastfetch), todo unificado en una paleta de colores verde oscuro.  
* **🎨 Tema Orchis Green:** Aplica el tema Orchis oscuro con acentos verdes en GNOME (incluyendo Libadwaita/GTK4) y el pack de iconos Tela Circle.  
* **⏰ Corrección Dual Boot:** Sincroniza el reloj del sistema (RTC a hora local) para evitar desajustes al cambiar a Windows.

### **🚀 Instalación (Setup Universal)**

Abre tu terminal y ejecuta:
```
curl \-fsSL https://raw.githubusercontent.com/schoperena/cachyos-sch-setup/main/cachyos-sch-setup.sh | bash
```
## **🔒 2\. Configuración de Secure Boot (sbctl \+ Limine)**

Script interactivo diseñado para firmar tu sistema CachyOS y permitir un Dual Boot seguro con Windows sin romper las firmas de Microsoft.

### **✨ Características**

* **🔍 Comprobación de Entorno:** Verifica que el sistema esté en modo UEFI y comprueba la existencia de sbctl (instalándolo si es necesario).  
* **✅ Detección de 'Setup Mode':** Comprueba si has borrado las llaves de fábrica en tu BIOS. Si no lo has hecho, te guía paso a paso e incluso te ofrece reiniciar directamente a la BIOS para hacerlo.  
* **🔑 Inscripción Segura:** Crea llaves locales y las inscribe manteniendo la compatibilidad obligatoria con Microsoft (--microsoft).  
* **✍️ Firma Automática:** Utiliza limine-enroll-config para firmar automáticamente el gestor de arranque de CachyOS.

### **🚀 Ejecución (Secure Boot)**

Abre tu terminal y ejecuta:
```
curl \-fsSL https://raw.githubusercontent.com/schoperena/cachyos-sch-setup/main/secure-boot-cachyos-sch.sh | bash
```
## **⚠️ Notas Post-Instalación**

1. **Reinicia la terminal:** Tras ejecutar el *Setup Universal*, cierra Alacritty y vuelve a abrirlo para que la nueva fuente *Nerd Font* cargue correctamente en tu prompt de Fish.  
2. **GNOME Shell:** Recuerda abrir la aplicación **Extensiones** de GNOME y activar la extensión **User Themes** para que la barra superior del escritorio aplique el tema verde.  
3. **Portátiles con NVIDIA:** Si el script instaló EnvyControl, recuerda ejecutar sudo envycontrol \-s integrated y reiniciar cuando necesites exprimir al máximo la batería.  
4. **BitLocker en Windows:** *Antes* de usar el script de Secure Boot, asegúrate de suspender BitLocker en Windows o tener tu clave de recuperación de 48 dígitos a la mano.