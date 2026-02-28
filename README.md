# **🟢 CachyOS SCH Setup**

Un script de post-instalación automatizado e inteligente para **CachyOS (GNOME)**. Diseñado para configurar un entorno de desarrollo/hacking estéticamente unificado (Cyberpunk/Verde) y optimizar el hardware automáticamente, ya sea en un PC de escritorio de alto rendimiento o en un portátil.

## **✨ Características Principales**

* **🧠 Detección de Hardware Inteligente:** Aplica perfiles de energía (auto-cpufreq, powertop) y descarga drivers de video específicos solo si detecta que estás usando un portátil (Intel/AMD).  
* **🎮 Soporte Híbrido (Optimus):** Si detecta una GPU NVIDIA en un portátil, instala envycontrol para una gestión de batería extrema.  
* **💻 Terminal de Alto Nivel:** Instala y configura **Alacritty** \+ **Zellij** \+ **Fish Shell**, todo con una paleta de colores verde unificada y fuente *Nerd Font*.  
* **🎨 Tema Orchis Green:** Aplica el tema Orchis oscuro con acentos verdes en todo GNOME (incluyendo apps Libadwaita/GTK4) junto con el pack de iconos Tela Circle.  
* **⏰ Dual Boot Amigable:** Sincroniza automáticamente el reloj del sistema (RTC a hora local) para evitar desajustes de hora al cambiar entre CachyOS y Windows.  
* **🛠️ Herramientas Extra:** Instalación automatizada de **Steam**, **Bambu Studio** (versión normal o NVIDIA según tu hardware) y elección interactiva del navegador web.

## **🚀 Instalación Rápida**

No necesitas clonar el repositorio ni descargar archivos manualmente. Abre tu terminal en una instalación limpia de CachyOS y ejecuta este comando:

```
curl \-fsSL https://raw.githubusercontent.com/schoperena/cachyos-sch-setup/main/cachyos-sch-setup.sh | bash
```

**Nota:** Reemplaza TU\_USUARIO por tu nombre de usuario real en GitHub antes de ejecutar el comando.

## **📦 ¿Qué incluye el entorno de terminal?**

* **Fuente:** MesloLGS Nerd Font (Soporte completo para iconos de Git, Python, etc.).  
* **Prompt:** Oh My Fish con el tema bobthefish (Esquema de color adaptado al terminal).  
* **Multiplexor:** Zellij auto-iniciado de forma segura en Fish.

## **⚠️ Notas Post-Instalación**

1. **Reinicia la terminal:** Una vez que el script finalice, cierra Alacritty y vuelve a abrirlo para que la nueva fuente *Nerd Font* cargue correctamente y los iconos del prompt se muestren perfectos.  
2. **GNOME Shell:** Recuerda abrir la aplicación **Extensiones** de GNOME y activar la extensión **User Themes**. Esto permitirá que la barra superior del escritorio también adopte el tema Orchis.  
3. **Portátiles con NVIDIA:** Si el script detectó tu NVIDIA en un portátil, recuerda ejecutar sudo envycontrol \-s integrated y reiniciar cuando necesites exprimir al máximo la duración de la batería.

*Script creado y optimizado para el ecosistema CachyOS.*