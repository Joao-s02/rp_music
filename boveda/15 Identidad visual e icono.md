---
tipo: identidad-visual
estado: identidad-tema-y-fuentes-integrados
actualizado: 2026-10-26
---
# Identidad visual e icono

## Decisión confirmada

El usuario eligió explícitamente la **variante A** como nuevo icono de RP Music y pidió conservar la identidad visual basada en ella y en **Nocturnal Pulse**. Esta nota es la referencia vigente. El primer resultado y las variantes B/C se conservan como antecedentes; A deja de ser una propuesta.

## Estado actual de integración

Icono A integrado en recursos de plataforma. Tema Flutter cian/violeta y fuentes locales Inter/Plus Jakarta Sans integrados desde 0.2.3; álbumes renovados en 0.3.2 y reproductor expandido en 0.3.3. Fuentes de implementación: lib/app/music_theme.dart, lib/app/album_detail_view.dart, lib/app/expanded_player.dart y declaración de fuentes en pubspec.yaml.

Las tablas siguientes conservan la referencia de diseño; no todos sus tamaños/efectos se aplican literalmente ni una función ilustrada equivale a implementación. El ecualizador queda reservado a una extensión, no está en el reproductor. Alcance y pruebas: [[16 Pruebas 0.2.2 y rediseno 0.2.3]], [[28 Pruebas 0.3.1 y mejoras 0.3.2]], [[29 Pruebas 0.3.2 y mejoras 0.3.3]].

## Fuentes conservadas

- [Icono maestro aprobado A](../assets/branding/rp-music-variant-a.png).
- [Documento original completo](../assets/branding/DESIGN-reference.md), copia de DESIGN(1).md.
- [Prompt de A](../assets/branding/icon-variant-a-prompt.txt), generado con la herramienta integrada de imágenes. Los iconos de plataforma se derivan del PNG sin regenerar el dibujo.

## Marca y composición

**RP Music**: letras RP separadas, gruesas y geométricas, esquinas suaves y huecos circulares. Debajo, cinco barras violetas, la central más alta. Letras cian sobre fondo oscuro opaco. Sensación nocturna, limpia y centrada en música local.

Conservar proporciones, separación y orden del maestro. No estirar ni añadir marcos, textos pequeños, biseles o brillos intensos. El monograma es un dibujo propio, no texto para recomponer con una fuente. Proteger letras y barras con márgenes ante recortes del sistema.

## Paleta y discrepancias del MD

El MD contiene tokens YAML y ejemplos narrativos con valores distintos. Se conservan ambos. Como convención de esta integración, usar los **tokens para roles de tema** y los **acentos narrativos para la marca**. Contrastar cada token con music_theme.dart: los roles principales ya se aplican; el documento conserva también alternativas no implementadas. El PNG generado presenta variaciones; estos hex son referencias de diseño, no una medición uniforme del recurso.

| Rol | Referencia |
| --- | --- |
| Fondo base y fondo adaptativo | #10131A |
| Contenedores, de menor a mayor elevación | #0B0E15, #191B23, #1D1F27, #272A32, #32353D |
| Superficie brillante | #363941 |
| Cian de marca, reproducción y progreso | #00D2C4 |
| Primario de tema / cian luminoso | #47EFE0 |
| Tinte cian | #28DDCF |
| Violeta de marca y ecualizador | #8B5CF6 |
| Secundario de tema / contenedor | #D0BCFF / #571BC1 |
| Texto principal / secundario de tema | #E1E2EC / #BACAC7 |
| Contorno / variante | #859491 / #3B4A47 |
| Terciario cálido / contenedor | #FFCFA3 / #FFA94F |
| Error / contenedor | #FFB4AB / #93000A |

La narrativa propone además fondos #0A0D14, #131926 y #1A2234, texto #FFFFFF y metadatos #94A3B8. Son referencias alternativas conservadas, no un segundo tema implementado. Los pares de contraste on-primary/on-secondary y las familias fixed completas están en el MD original enlazado.

Cian para reproducción, progreso, selección y foco; violeta para visualización y acentos secundarios. Divisores sutiles con blanco al 8 %. Comprobar contraste al implementar componentes.

## Tipografía

**Plus Jakarta Sans** para títulos y **Inter** para cuerpo, metadatos y etiquetas. Valores originales en rem; 1 rem = 16 px sirve solo de referencia de diseño, no conversión automática a Flutter. Respetar el escalado de texto del sistema.

| Rol | Familia | Tamaño / altura en rem | Peso |
| --- | --- | --- | --- |
| display-lg | Plus Jakarta Sans | 3.5 / 4 | 800 |
| headline-lg | Plus Jakarta Sans | 2.25 / 2.75 | 700 |
| headline-lg-mobile | Plus Jakarta Sans | 1.75 / 2.25 | 700 |
| headline-md | Plus Jakarta Sans | 1.5 / 2 | 600 |
| body-lg | Inter | 1.125 / 1.75 | 400 |
| body-md | Inter | 1 / 1.5 | 400 |
| body-sm | Inter | 0.875 / 1.25 | 400 |
| label-md | Inter | 0.875 / 1.25 | 600 |
| label-sm | Inter | 0.75 / 1 | 500 |
| code-xs | Inter | 0.6875 / 0.875 | 500 |

Títulos con espaciado ligeramente cerrado; tiempos con cifras tabulares. Artista y álbum al menos body-sm. El MD llama monoespaciados a los chips técnicos, aunque declara Inter en code-xs: resolver esa discrepancia al implementarlos, sin asumir que Inter es monoespaciada.

## Formas, espacio y profundidad

- Espaciado de referencia: 4, 8, 16, 24 y 32; margen móvil 16, escritorio 32 y separación de columnas 24.
- Tokens de radio: sm 4, DEFAULT 8, md 12, lg 16, xl 24; full circular/píldora. La narrativa denomina rounded-md al valor 8, distinto del token md 12: para controles estándar seguir el valor narrativo 8; tarjetas 16 y paneles/minirreproductor 24.
- Profundidad por tonos oscuros y bordes tenues. Acrílico opcional al 85 %, desenfoque de referencia 16 y halo cian al 12 %. Evitar sombras duras y verificar coste según [[05 Rendimiento]].

## Pautas de interfaz del documento

- Android: cuatro columnas de referencia, reproducción en zona inferior, minirreproductor separado 12 de navegación y respetando áreas seguras reales.
- Windows: doce columnas, lateral 240–280 y franja de reproducción 80 como referencias adaptables.
- Botón circular reproducir/pausar: 56 móvil, 48 escritorio; escala al presionar 0.95. Iconos de 24 con área interactiva mínima de 44.
- Filas: 56 móvil, mínimo 48; carátula 40. Canción activa con texto cian y fondo cian al 6 %.
- Búsqueda de altura 48, foco cian con halo al 20 %. Chips seleccionados con fondo cian al 15 % y borde/texto cian; chips técnicos violetas.
- Progreso/volumen: pista 4, tirador 12 y 16 al arrastrar. Arte de álbum cuadrado; desplazamiento al enfocar de referencia 2 en escritorio.

Son pautas de referencia, parcialmente aplicadas según el estado de integración anterior y sujetas a accesibilidad/rendimiento, relacionadas con [[03 Biblioteca y reproduccion]] y [[04 Extensiones]]. No modifican por sí solas requisitos funcionales ni prueban que esos componentes existan.

## Recursos de plataforma integrados

- Android: lanzador PNG en cinco densidades (48/72/96/144/192) y recurso adaptativo API 26+ con fondo #10131A y margen de seguridad. Manifiesto ya referencia @mipmap/ic_launcher.
- Windows: windows/runner/resources/app_icon.ico con tamaños 16/24/32/48/64/128/256. Ventana y bandeja reutilizan IDI_APP_ICON.
- Web: favicon 32; iconos 192/512 normales y con margen para máscara. Nombre y colores de manifiesto alineados. No se declara soporte funcional web.
- Regeneración: tools/generar_iconos.py con Pillow. Maestro A intacto. Icono monocromo de notificaciones Android conservado como recurso independiente, adecuado a su rol.

## Verificación histórica de integración inicial y límites

Dimensiones PNG y siete resoluciones ICO verificadas al generar. Recurso adaptativo revisado visualmente. Compilación Windows debug correcta con el nuevo ICO; compilación directa de todos los recursos Android con AAPT2 correcta (`build/icon-resource-check/resources.zip`). `git diff --check` sin errores.

Antecedente: la primera verificación APK quedó bloqueada porque el Java 17 activo era un JRE sin compilador. El 2026-10-25 el usuario pidió corregirlo: se añadió Temurin JDK 17.0.20.1+1 y se seleccionó en JAVA_HOME del usuario y en Flutter. La compilación completa `flutter build apk --release` terminó correctamente; firma v2 verificada y metadatos de RP Music 0.2.2+4 e icono adaptativo presentes. APK local en `build/app/outputs/flutter-apk/app-release.apk` (54 358 404 bytes), SHA-256 37E12C6997AEDB0E7784DEE7EA7F469B514B835CF6FA1D1079B4E5EEEF89DC4C.

Guía: [Compilación y Java](../docs/COMPILACION.md). El flujo completo de Flutter regeneró el registro release sin integration_test; una invocación Gradle directa previa había encontrado ese registro generado para debug. No fue necesario modificar código de la app o de las dependencias.

Ese trabajo inicial de iconos no publicó una release. Después se publicaron versiones con identidad/tema integrados; estado actual en [[10 Estado del repositorio]]. Mantener pendientes las comprobaciones físicas que no tengan evidencia, especialmente lanzadores y combinaciones de accesibilidad.

Ver [[10 Estado del repositorio]] y [[09 Registro de cambios]].

## Aplicación posterior del tema — 2026-10-25

En la primera integración de iconos aún no se habían aplicado tema/fuentes; ese estado inicial quedó superado. El usuario aportó posteriormente un ZIP de pantallas Stitch y pidió aplicar esa interfaz. Se implementan tema, fuentes locales y composición adaptable conservando A; alcance, verificaciones y diferencias funcionales en [[16 Pruebas 0.2.2 y rediseno 0.2.3]]. Las funciones ilustradas no equivalen a implementación.

## Uso audiovisual animado — 2026-10-25

El usuario pidió animar la marca dentro del tráiler aprobado. R/P aparecen escalonadas y las cinco barras cambian de altura; se usan recortes del PNG A, conservando el dibujo del monograma. Esta adaptación solo afecta al vídeo; maestro e iconos instalables intactos. Implementación y comprobaciones en [[19 Trailer de RP Music]].

## Desarrollo local 0.3.13

Informe confirmado de letras 0.3.12 y corrección de álbum/identidad visual/consentimiento conjunto: [[42 Albumes y extensiones con identidad RP 0.3.13]]. No publicada.
