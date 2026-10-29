# RP Music

Reproductor Flutter para Android y Windows, ampliable mediante extensiones. Biblioteca local sin cuenta ni conexión; actualizaciones y consultas en línea opcionales.

**Versión en publicación: 0.3.15-alpha.1**, aplicación **0.3.15+24**. [Descargar Android universal, ARM64 y Windows](https://github.com/Joao-s02/rp_music/releases/tag/v0.3.15-alpha.1).

[Guía vigente](docs/USO.md) · [Pruebas](docs/PRUEBAS-0.3.15.md) · [Cambios](docs/CAMBIOS-0.3.15.md) · [Documentación](docs/README.md)

## Novedades 0.3.15 — instalación Android

Android retira el permiso para iniciar instalaciones. La app consulta versiones y abre la descarga oficial; el usuario instala el APK desde Archivos. Firma de producción con transición compatible, datos y funciones musicales conservados. **Actualizar desde Archivos sin desinstalar**, especialmente desde 0.3.13.

Play Protect bloqueó el control y aceptó el universal corregido en emulador. El usuario confirma instalación directa sin advertencia en su teléfono. No garantiza el resultado en todos los equipos; ARM64 físico y análisis específico pendientes. 166 pruebas aprobadas/una optativa omitida y análisis limpio. [Uso](docs/USO-0.3.15.md) · [Resultados](boveda/44%20Diagnostico%20local%20de%20instalacion%20y%20actualizaciones%20manuales.md). Android universal/ARM64 y Windows en preparación para publicación. Catálogo de extensiones conservado.

## Novedades 0.3.13

Corrección de álbum para los cuatro paquetes YouTube (0.5.2 / Explorador0.2.2), indicador de cola más lento, álbumes con funda/surcos RP y emblemas de extensiones. Catálogo como acción principal, personalización plegable y botón explícito «Aceptar todo e instalar». Búsqueda/categorías/resultados de fuentes renovados. Letras sincronizadas conservadas. Descarga nativa Windows comprobada con álbum/pista incrustados, 55 líneas sincronizadas y audio conservado.

[Instalación y uso](docs/USO-0.3.13.md) · [Resultados y límites](boveda/42%20Albumes%20y%20extensiones%20con%20identidad%20RP%200.3.13.md). 164 pruebas aprobadas/una optativa omitida y análisis limpio. Android universal y Windows completo compilados y verificados localmente; pendiente prueba física Android. Publicada con cuatro actualizaciones de catálogo y siete adjuntos verificados.

## Novedades 0.3.12 — letras y reproductor

Descargas priorizan letras sincronizadas de la misma interpretación sin alterar el álbum. Letras vivas y vista Escena con transiciones, fondo animado por posición y controles ocultables; EnhancedLRC usa tiempos por palabra solo cuando existen. Reproductor ampliado fijo y adaptable, volumen tras botón, origen sin duplicar, carátula sin borde cian y cola centrada con indicador animado/pausa. [Cómo probar](docs/PROBAR-0.3.12.md) · [Evidencia y límites](boveda/41%20Letras%20dinamicas%20y%20reproductor%20fijo%200.3.12.md).

Paquetes externos: YouTube Android/Windows0.5.1, Explorador Android/Windows0.2.1 y Letras locales0.1.1, app mínima0.3.12. Cinco actualizaciones disponibles en el catálogo; versiones anteriores conservadas. Recuperación de LRC para archivos anteriores solo en caché privada, sin escribir música. Entrega completa publicada con siete adjuntos verificados. 155 pruebas aprobadas/una optativa omitida y análisis limpio; descarga real con55 líneas LRC y audio conservado comprobada.

## Novedades0.3.11

Gesto horizontal sobre carátula/minirreproductor; widgets Android compacto, horizontal y carátula redimensionables; listas y álbumes de fuentes con portada grande. Descarga de álbum con carpeta única, cola/cancelación e identidad común de metadatos; prioridad al álbum de origen y agrupación por artista del álbum. Fotos de artistas mediante fuente autorizada y caché privada offline. Los paquetes API2 se instalan por separado y requieren revisar el nuevo permiso de biblioteca. [Cómo probar](docs/PROBAR-0.3.11.md) · [Evidencia y límites](boveda/40%20Gestos%20widgets%20albumes%20y%20descargas%200.3.11.md). Publicados Android universal/ARM64 y Windows completo con guías, licencias y hashes.

El usuario confirma en0.3.10 YouTube Windows con sonido/descarga y lectura M4A/OPUS sin errores. Verificación local0.3.11:147 pruebas aprobadas/una optativa omitida y análisis limpio; seis canciones de un álbum real exportadas con etiquetas/portadas coherentes, foto guardada y recuperada offline. Android universal/ARM64 y Windows publicados; widgets/selector requieren Android físico.

## Audio Windows y YouTube — 0.3.10

- Windows usa just_audio_media_kit/libmpv en lugar del backend WinRT anterior. M4A reales y OPUS reproducidos; controles MP3/FLAC/MP4/WAV también comprobados. Android conserva su motor y parches audio_service.
- Diagnóstico conserva error nativo y tiempos con URLs redactadas. Cargas fallidas o interrumpidas no bloquean la siguiente canción; límite Windows de 30 segundos.
- Catálogo externo: YouTube Windows 0.4.1 y YouTube Explorador Windows 0.1.0 independientes, API 2, app mínima 0.3.10. Código de proveedores Android conservado.
- Radio por internet 0.1.1 renueva enlace y registra clic en una consulta. Radio original preservada; actualización se ofrece desde app 0.3.9.

Verificación: 142 pruebas aprobadas, una de red optativa omitida, análisis limpio y cinco casos nativos Windows. YouTube API 2 y Explorador JS reprodujeron audio real con controles/revocación. Radio ensayada inició aproximadamente en cinco segundos; no es garantía para toda red/estación ni comparación con la misma emisora del usuario.

Pendientes: Android físico en esta versión, escucha prolongada y más emisoras/equipos. La latencia Android API 3 de 3–6 segundos informada por el usuario sigue pendiente; este cambio Windows no la declara solucionada. Dependencias de audio fijadas y experimentales; licencias y procedencia nativa incluidas. No modifica música local ni releases previas.

## Explorador y radio JavaScript — 0.3.9

API 3 añade consultas HTTP por etapas, cancelación y audio remoto autorizado mediante el reproductor de la app. Explorador musical (YouTube Music público, sin cuenta) y Radio por internet (Radio Browser, filtros/favoritas privadas) son opciones independientes del catálogo de [rp-music-extensions](https://github.com/Joao-s02/rp-music-extensions). Requieren app 0.3.9 y se instalan por separado; no están incluidos en APK/ZIP. [Alcance y pruebas](boveda/37%20Explorador%20y%20radio%20JavaScript.md).

La radio admite inicialmente emisoras HTTPS MP3/AAC sin HLS. En 0.3.9 no se había corregido YouTube Windows; 0.3.10 añade reproducción nativa comprobada. Cuenta, sincronización, descargas e importación de listas desde las nuevas pantallas JS siguen pendientes.

Publicados Android universal/ARM64 y Windows completo con guías/hashes. 138 pruebas aprobadas, una optativa omitida y análisis limpio; navegación/resolución pública y radio nativa Windows comprobadas. Android físico pendiente por ausencia de dispositivo. [Instalar y probar las extensiones](docs/PROBAR-JAVASCRIPT-0.3.9.md).

Informe posterior del usuario: las dos extensiones funcionan en Android, pero las búsquedas y aperturas de contenido API3 tardan3–6s percibidos. YouTube API2 se conserva; [diagnóstico de latencia y propuestas](boveda/38%20Latencia%20de%20extensiones%20API%203.md), sin mejora aplicada ni medición Android instrumentada todavía.

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

Biblioteca/preferencias/sesión en soporte privado v2, programas en v3 y letras en lyrics; no borrar esas carpetas. No se migran datos de la antigua alfa 0.1. [Guía completa](docs/USO-0.3.10.md).

## Extensiones

Para app0.3.11: YouTube Android/Windows0.5.0 y YouTube Explorador Android/Windows0.2.0. Actualizar desde el catálogo y revisar el permiso de biblioteca para retratos. Variantes anteriores conservadas.

[Repositorio de extensiones](https://github.com/Joao-s02/rp-music-extensions): Extensiones → Explorar repositorio → Consultar → instalar/actualizar → revisar permisos. También importar .rpmx. No vienen instaladas ni dentro del APK/ZIP ni como adjuntos de releases de la app.

Compatibles con 0.3.8: **Laboratorio JS 0.1.0** (pantalla experimental independiente), **YouTube Explorador 0.1.0** (Android experimental, independiente de la estable), **YouTube Android 0.4.0**, **Letras locales 0.1.0**, Biblioteca viva 0.1.1 y Pulso nocturno 0.1.0. Consultar el catálogo y actualizar YouTube para recibir la nueva lógica; Letras locales es un proveedor independiente de la fuente musical. Variantes para clientes anteriores conservadas. Spotify ya no se ofrece; una instalación previa puede eliminarse manualmente. Desde 0.3.10 se ofrecen YouTube Windows 0.4.1 y YouTube Explorador Windows 0.1.0 como opciones API 2 independientes; Radio se actualiza a 0.1.1.

Fuentes, lógica específica, paquetes y pruebas de proveedores pertenecen solo a ese repositorio. El principal contiene reproductor, motor/SDK y capacidades genéricas; prototipos heredados siguen como deuda de migración. [Contrato API 2](docs/EXTENSIONES-API-2.md).

## Verificación y pendientes

El usuario confirma buen funcionamiento de 0.3.8 y sus extensiones JavaScript. No se especificaron dispositivo, plataforma ni recorrido de esta confirmación; los límites y pruebas pendientes se conservan.

**122 pruebas aprobadas (120 de app y 2 de extensión)**, análisis de cambios sin incidencias. Prueba de red optativa omitida en esta suite; su resultado positivo de 0.3.5 se conserva como antecedente. Como antecedentes de 0.3.5, los tres casos aportados por el usuario recuperaron letras sincronizadas desde resultados reales YouTube. Prueba completa con paquete real: letras/portada/álbum incrustados en copia de audio sintético, original intacto. Lectura y reproducción nativa Windows aprobadas; ffprobe/ffmpeg confirmaron etiquetas y audio decodificable. No se suman repeticiones como casos nuevos.

El usuario confirma buen funcionamiento de 0.3.6 y se cierra la incidencia M4A según su informe. Continúan pendientes pruebas específicas documentadas de SD/SAF, permisos, widget y escucha prolongada en varios equipos. Metadatos/letras dependen de cobertura/red; no se garantizan todas las canciones/ediciones. Esa comprobación de 0.3.6 no incluía YouTube Windows; su corrección y pruebas están en 0.3.10. Detalles: [corrección y confirmación](boveda/34%20Descarga%20M4A%20no%20visible%20en%20biblioteca.md).


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


Capturas demostrativas0.3.12 (no Android físico): [Escena de letras](design/verification/lyrics-0.3.12-scene.png) · [Reproductor fijo](design/verification/player-0.3.12-360.png).

## Antecedente del aviso Android (0.3.12–0.3.14)

Un usuario reporta que, después del análisis de Play Protect, aparece advertencia de posible daño en0.3.12/0.3.13 aunque permite instalar. Bloqueo de instalación reproducido en emulador; causa aún sin confirmar. Se verificó que los APK publicados usan certificado de depuración; la integridad de descarga no sustituye una revisión de seguridad. [Hallazgos y pendientes](boveda/43%20Play%20Protect%20y%20firma%20de%20Android.md).

## Candidato de revisión 0.3.14+23

Firma de producción con transición compatible (Android9+; firmante anterior enAndroid6–8), bloqueo de builds sin credenciales y actualizador que reconoce linaje. Actualización sin desinstalar/lista conservada y análisis instalado de Play Protect sin alertas comprobados en emuladorAPI37. No equivale al resultado de instalación del teléfono afectado; causa original aún no confirmada. [Cómo probar](docs/PROBAR-PLAY-PROTECT-0.3.14.md) · [Firma y custodia](docs/ANDROID-SIGNING.md). Candidato aceptado; publicación autorizada en preparación. 164 pruebas aprobadas/una optativa omitida y análisis limpio.

Resultado posterior del usuario: el aviso de app dañina persiste en el teléfono al probar el candidato. El problema permanece abierto; el análisis sin alertas del emulador no confirma una solución.

Análisis externo autorizado: [VirusTotal0.3.14](https://www.virustotal.com/gui/file/779936fdcae781ed5ab87ab7e08345043365d982ff60e68e2008ba87a904245a/detection) sin motores que marquen malicioso, pero Google figura Failure. No confirma solución del aviso del teléfono. Revisión oficial preparada, no enviada.

## Resultado 0.3.15 confirmado por el usuario

Comparación controlada en emulador API37: el APK con permiso de instalación fue bloqueado; sin ese permiso, Play Protect respondió «This app looks safe» y la actualización terminó correctamente, conservando la lista de prueba y fecha original. Android release adopta actualizaciones desde la web/Archivos, manteniendo música y extensiones. 166 pruebas aprobadas, una optativa omitida y análisis del código sin incidencias. El usuario confirmó después instalación directa sin advertencia en su teléfono. [Alcance y pruebas](boveda/44%20Diagnostico%20local%20de%20instalacion%20y%20actualizaciones%20manuales.md). Candidato aceptado; publicación autorizada en preparación.
