# RP Music

Reproductor Flutter para Android y Windows, ampliable mediante extensiones. Biblioteca local sin cuenta ni conexión; actualizaciones y consultas en línea opcionales.

**Versión publicada: 0.3.9-alpha.1**, aplicación **0.3.9+18**. [Descargar Android universal, ARM64 y Windows](https://github.com/Joao-s02/rp_music/releases/tag/v0.3.9-alpha.1).

[Guía vigente](docs/USO.md) · [Pruebas](docs/PRUEBAS-0.3.9.md) · [Cambios](docs/CAMBIOS-0.3.9.md) · [Documentación](docs/README.md)

## Explorador y radio JavaScript — 0.3.9

API 3 añade consultas HTTP por etapas, cancelación y audio remoto autorizado mediante el reproductor de la app. Explorador musical (YouTube Music público, sin cuenta) y Radio por internet (Radio Browser, filtros/favoritas privadas) son opciones independientes del catálogo de [rp-music-extensions](https://github.com/Joao-s02/rp-music-extensions). Requieren app 0.3.9 y se instalan por separado; no están incluidos en APK/ZIP. [Alcance y pruebas](boveda/37%20Explorador%20y%20radio%20JavaScript.md).

La radio admite inicialmente emisoras HTTPS MP3/AAC sin HLS. Esta ampliación no declara corregido YouTube Windows. Cuenta, sincronización, descargas e importación de listas desde las nuevas pantallas JS siguen pendientes.

Publicados Android universal/ARM64 y Windows completo con guías/hashes. 138 pruebas aprobadas, una optativa omitida y análisis limpio; navegación/resolución pública y radio nativa Windows comprobadas. Android físico pendiente por ausencia de dispositivo. [Instalar y probar las extensiones](docs/PROBAR-JAVASCRIPT-0.3.9.md).

## JavaScript y Dart en paralelo — 0.3.8

Motor JavaScript/API 3 en paralelo a API 2/Dart. La extensión define páginas, formularios, botones y acciones mediante componentes nativos combinables; no necesita una pantalla Flutter específica por cada flujo. Laboratorio JS 0.1.0 se ofrece como opción independiente en el catálogo del repositorio de extensiones, fuera del APK/ZIP. Los paquetes YouTube estable y Explorador permanecen intactos y usan Dart. No es Node.js ni HTML/CSS libre. El prototipo0.3.8 no ofrecía red; se añade en 0.3.9. Cuentas y sincronización siguen pendientes. [Contrato experimental](docs/EXTENSIONES-API-3.md) y [evidencia](boveda/36%20Motor%20JavaScript%20paralelo.md).

## Novedades de 0.3.7

Variante independiente **YouTube Explorador 0.1.0**, desarrollada en el repositorio de extensiones conservando YouTube Android 0.4.0 intacta. El anfitrión incorpora navegación por canciones/artistas/álbumes/listas públicas, paginación e importación como copias locales persistentes. Ambas extensiones pueden instalarse y se elige cuál controla Fuente. Sin conexión de cuenta ni sincronización todavía; Publicada como opción experimental. [Alcance y verificaciones](boveda/35%20Ampliacion%20de%20YouTube%20sin%20API%20oficial.md).

## Corrección de 0.3.6

Se corrige el etiquetado de descargas MP4/M4A fragmentadas: se conserva la inicialización antes de los fragmentos y se validan posiciones relativas, sin recodificar. Un archivo real afectado se reparó y decodificó conservando todos sus bloques de audio. La actualización no reescribe descargas anteriores: usar una copia reparada o volver a descargar. [Diagnóstico y límites](boveda/34%20Descarga%20M4A%20no%20visible%20en%20biblioteca.md).

## Funciones incorporadas en 0.3.5

- Lectura automática de letras incrustadas en canciones locales, sin conexión ni extensiones; se mantiene importar LRC/TXT. SYLT en milisegundos añadido.
- Extensión Letras locales: busca al seleccionar canciones sin letra y guarda resultados solo en la app. No modifica tu música local. Reintento manual y caché para evitar consultas repetidas.
- Nuevas descargas M4A compatibles incorporan etiquetas, portada y letras disponibles sin recodificar audio. Aviso cuando faltan datos o el archivo no puede etiquetarse.
- YouTube Android mejora identificación de artista/duración y búsqueda de letras, con nombres normalizados, alternativa y comprobación de versión/duración.
- Spotify cancelado y retirado del catálogo; paquetes históricos conservados. Distribución oficial solo en este GitHub, sin Play Store.

## Disponible

Una raíz con subcarpetas, catálogo persistente, escaneo manual/progresivo, búsqueda, orden y vistas de canciones/álbumes/artistas/carpetas. Favoritos, listas manuales, carátulas propias/mosaico y añadir álbum a lista. Listas automáticas mediante extensión.

Audio local, cola de selección, volumen/silencio, aleatorio/repetición, anterior/avance histórico y restauración sin autoplay. Reproductor adaptable con controles principales fijos. Android: sesión/notificación/controles y widget. Windows: audio local y bandeja/salida. Identidad nocturna cian/violeta, tema claro/oscuro y tipografías integradas.

Borrado confirmado y permiso de escritura cuando corresponda. Actualizador opcional con canales y verificación: instalador Android o ZIP manual Windows. API 1/2 experimental con permisos, recuperación y catálogo por repositorio.

Reconocer MP3/FLAC/M4A/MP4/WAV/OPUS no garantiza todos los códecs/etiquetas en todos los equipos; MP4 se trata como audio. Letras sincronizadas por línea, sin garantía de extracción/sincronización de cualquier variante.

## Instalar y actualizar

Android: instalar universal o ARM64 compatible encima de la anterior, sin desinstalar para conservar datos; firma actual de desarrollo. Windows: extraer todo el ZIP y abrir rp_music.exe junto con DLL y data. Elegir raíz musical y usar Actualizar biblioteca para incorporar cambios; abrir muestra caché sin reescaneo automático.

Biblioteca/preferencias/sesión en soporte privado v2, programas en v3 y letras en lyrics; no borrar esas carpetas. No se migran datos de la antigua alfa 0.1. [Guía completa](docs/USO-0.3.8.md).

## Extensiones

[Repositorio de extensiones](https://github.com/Joao-s02/rp-music-extensions): Extensiones → Explorar repositorio → Consultar → instalar/actualizar → revisar permisos. También importar .rpmx. No vienen instaladas ni dentro del APK/ZIP ni como adjuntos de releases de la app.

Compatibles con 0.3.8: **Laboratorio JS 0.1.0** (pantalla experimental independiente), **YouTube Explorador 0.1.0** (Android experimental, independiente de la estable), **YouTube Android 0.4.0**, **Letras locales 0.1.0**, Biblioteca viva 0.1.1 y Pulso nocturno 0.1.0. Consultar el catálogo y actualizar YouTube para recibir la nueva lógica; Letras locales es un proveedor independiente de la fuente musical. Variantes para clientes anteriores conservadas. Spotify ya no se ofrece; una instalación previa puede eliminarse manualmente. YouTube Windows sigue como candidato manual con fallos nativos conocidos, fuera del catálogo recomendado.

Fuentes, lógica específica, paquetes y pruebas de proveedores pertenecen solo a ese repositorio. El principal contiene reproductor, motor/SDK y capacidades genéricas; prototipos heredados siguen como deuda de migración. [Contrato API 2](docs/EXTENSIONES-API-2.md).

## Verificación y pendientes

El usuario confirma buen funcionamiento de 0.3.8 y sus extensiones JavaScript. No se especificaron dispositivo, plataforma ni recorrido de esta confirmación; los límites y pruebas pendientes se conservan.

**122 pruebas aprobadas (120 de app y 2 de extensión)**, análisis de cambios sin incidencias. Prueba de red optativa omitida en esta suite; su resultado positivo de 0.3.5 se conserva como antecedente. Como antecedentes de 0.3.5, los tres casos aportados por el usuario recuperaron letras sincronizadas desde resultados reales YouTube. Prueba completa con paquete real: letras/portada/álbum incrustados en copia de audio sintético, original intacto. Lectura y reproducción nativa Windows aprobadas; ffprobe/ffmpeg confirmaron etiquetas y audio decodificable. No se suman repeticiones como casos nuevos.

El usuario confirma buen funcionamiento de 0.3.6 y se cierra la incidencia M4A según su informe. Continúan pendientes pruebas específicas documentadas de SD/SAF, permisos, widget y escucha prolongada en varios equipos. Metadatos/letras dependen de cobertura/red; no se garantizan todas las canciones/ediciones. No se declara resuelto YouTube Windows. Detalles: [corrección y confirmación](boveda/34%20Descarga%20M4A%20no%20visible%20en%20biblioteca.md).


Edición general de etiquetas, cola editable, gapless/fundido, ecualizador como extensión y aislamiento fuerte/firmas/métricas del SDK continúan pendientes. Cuentas/listas/favoritos/historial online pendientes. Ampliación de YouTube en [investigación sin API oficial](boveda/35%20Ampliacion%20de%20YouTube%20sin%20API%20oficial.md); no implementada. Sin soporte web. Código público con objetivo de código abierto; licencia concreta todavía sin elegir, licencias de terceros conservadas.

## Desarrollar y colaborar

```sh
flutter pub get
flutter run -d windows
# Android: consultar flutter devices y usar el ID disponible
flutter run -d ID_DEL_DISPOSITIVO
```

[Compilación](docs/COMPILACION.md). No ejecutar tests/builds Flutter concurrentes ni distribuir sondas de integración. Herramientas verificadas durante este desarrollo: Flutter 3.47.6/Dart 3.13.5; comprobar entorno antes de compilar.

Leer AGENTS.md y la [bóveda](boveda/00%20Inicio.md). [Estado actual](boveda/10%20Estado%20del%20repositorio.md), [arquitectura](boveda/31%20Arquitectura%20vigente.md) y [registro](boveda/09%20Registro%20de%20cambios.md). Arquitectura del alfa como antecedente. README/notas se mantienen en cada actualización. [Política de releases](boveda/27%20Publicacion%20de%20releases%20-%20contenido%20obligatorio.md): tres binarios, USO/PRUEBAS/CAMBIOS y hashes; publicar requiere autorización.

## Tráiler

[![RP Music — Tu música. Tus reglas. Ver el tráiler en YouTube](design/youtube/rp-music-miniatura.jpg)](https://youtu.be/lobwRKtXv-M)

▶ **[Ver el tráiler de RP Music en YouTube](https://youtu.be/lobwRKtXv-M)**
