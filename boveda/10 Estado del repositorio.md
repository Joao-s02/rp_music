---
tipo: estado
estado: primer-incremento-compilado
actualizado: 2026-10-26
---
# Estado del repositorio

## Estado actual

Trabajo local vigente: **0.2.4+6** (ver [[18 Pruebas 0.2.3 y correcciones 0.2.4]]); antecedente **0.2.3+5**, interfaz Stitch y correcciones posteriores al informe 0.2.2. Consultar [[16 Pruebas 0.2.2 y rediseno 0.2.3]] y la actualización al final de esta nota para evidencia y paquetes. La última publicación es v0.2.4-alpha.1; consultar su confirmación al final de esta nota.

Identidad confirmada el 2026-10-25: el usuario eligió `assets/branding/rp-music-variant-a.png`. Integrado en lanzador Android adaptativo, ICO Windows para ventana/bandeja e iconos web. Windows debug compilado y APK Android release completo compilado tras instalar/seleccionar Temurin JDK 17.0.20.1+1 en usuario y Flutter; firma APK v2 verificada. APK 0.2.2+4 local con icono A en `build/app/outputs/flutter-apk/app-release.apk`, sin publicar ni reemplazar adjuntos de dist. Pautas de diseño documentadas; tema Flutter sin rediseñar. Ver [[15 Identidad visual e icono]] y docs/COMPILACION.md para validación y límites.

Actualización 2026-10-25: aplicación `0.2.2+4` publicada como `v0.2.2-alpha.1`, con notificaciones, volumen y bandeja. Etiqueta en `9f1e4f80966d5d020235200e23b6b58170c8b7fc`, fuentes en `main`, ocho adjuntos verificados por tamaño/digest y release confirmada como preliminar publicada. Ver [[14 Pruebas 0.2.1 y correcciones 0.2.2]] para límites y pendientes. El estado que sigue describe antecedentes de 0.2.1/0.2.0.

Actualización posterior: aplicación `0.2.1+3`, publicada como release preliminar `v0.2.1-alpha.1` en GitHub tras autorización. Etiqueta sobre `4b094e164123a5615285e5637043a4bcf24811c5`; seis adjuntos y sus hashes verificados. Ver [[13 Pruebas reales y correcciones 0.2.1]] para implementación, evidencia y pendientes. Las afirmaciones de la primera base que siguen describen el antecedente 0.2.0.

Raíz: `C:\joao\flutter\music_reprod\rp_music`. El usuario autorizó la reconstrucción. Se reemplazaron las fuentes de aplicación y pruebas del alfa, y se conservan Git, bóveda y plataformas. Manifiesto `rp_music`, versión `0.2.0+2`.

La implementación y sus decisiones provisionales están en [[11 Reconstruccion - primera base]]. El README contiene instrucciones reales de ejecución y la guía del ejemplo está en `examples/extensions/README.md`.

## Verificación realizada

- Flutter 3.47.6 y Dart 3.13.5 instalados y ejecutados.
- Análisis estático de código y pruebas: sin problemas.
- Suite: 13 pruebas aprobadas, incluidas navegación móvil/escritorio y carreras de reproducción con motor simulado.
- Compilación Android debug: `build/app/outputs/flutter-apk/app-debug.apk`.
- Compilación Windows debug: `build/windows/x64/runner/Debug/rp_music.exe`. El ejecutable necesita los DLL y carpeta de datos que lo acompañan; no distribuir solo el EXE.
- No hay pruebas manuales en dispositivo, comprobación física de audio, mediciones de rendimiento ni validación de todos los formatos. No se ha abierto la bóveda visualmente en Obsidian.

Windows no tenía habilitado soporte habitual de symlinks. Se prepararon junctions temporales en `windows/flutter/ephemeral/.plugin_symlinks` sin cambiar ajustes globales. El backend `just_audio_windows` necesitó una definición de compatibilidad de cabeceras coroutine con Visual Studio 2026, limitada a ese target en CMake. Reevaluar backend antes de estabilidad.

## Funcionalidad aún pendiente

Letras, edición de etiquetas, restauración de sesión, cola editable, bandeja y controles del sistema Windows, gapless/fundidos, carátulas de biblioteca, benchmarks, permisos de extensiones, panel de consumo, runtime ejecutable e integraciones con servicios. La personalización importable actual es declarativa, no el SDK completo. Web queda fuera del incremento.

## Antecedentes y conservación

Al crear la bóveda existían fuentes alfa y un documento `arquitectura-reproductor-flutter.md`. Ese documento es histórico: sus paquetes y prioridades no son decisiones actuales por defecto. No hay migración de la biblioteca alfa; los nuevos datos se guardan en `v2` dentro del soporte de aplicación.

La publicación fue solicitada por el usuario y completada en `Joao-s02/rp_music`: release preliminar `v0.2.0-alpha.1`, fuentes en `main`, APK y paquete Windows compilados en modo release, instrucciones, ejemplo y sumas SHA-256. La etiqueta apunta a `bdd01f012e3f6e8e61ac13ad6565ce32911beae8`. GitHub confirmó publicación y cinco adjuntos completos. Ver [[12 Release 0.2.0-alpha.1]]. Siguientes prioridades: [[06 Primera version]] y [[07 Preguntas e investigacion]].

## Trabajo local posterior: 0.2.3+5

Rediseño Flutter basado en el ZIP Stitch, tipografías integradas, álbumes en tarjetas, minirreproductor móvil y reproductor ampliado; eliminación persistida de listas con confirmación. Iconos dinámicos del servicio protegidos del recorte release, estado/cola/duración y diagnóstico multimedia. 30 pruebas aprobadas y sonda release aprobada en emulador API 37. Paquetes finales y comparación causal registrados en [[16 Pruebas 0.2.2 y rediseno 0.2.3]]. Sin publicar ni enviar fuentes a GitHub. Los cambios previos de identidad e iconos se conservaron.

Comprobación final 0.2.3: APK universal/ARM64 y Windows x64 compilados en release en `dist/0.2.3`, con guías, ejemplo y SHA-256; firmas Android v2, certificado de actualización coincidente, código 5 y ABIs verificados. Recursos multimedia presentes en ambos APK y comprobación negativa de regresión correcta. ZIP Windows íntegro y sin plugin de integración. La comparación causal release y el retesteo físico pendiente se detallan en [[16 Pruebas 0.2.2 y rediseno 0.2.3]]. Análisis limpio y diff sin errores.

## Publicación solicitada de 0.2.3 — 2026-10-25

El usuario autorizó publicar la release en GitHub. Se prepara `v0.2.3-alpha.1` como preliminar con fuentes, APK universal/ARM64, Windows x64, guías, ejemplo y SHA-256. Se mantienen los binarios comprobados; confirmar URL y adjuntos tras publicar.

## Publicación confirmada — 2026-10-25

- [Release v0.2.3-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.2.3-alpha.1) publicada como preliminar; GitHub confirmó `isDraft=false` e `isPrerelease=true`.
- Etiqueta sobre `498ceee98d08ca10e12132e62bfc59170786db9a`; fuentes enviadas a main. Esta confirmación es posterior al commit etiquetado.
- Siete adjuntos en estado uploaded: APK universal, APK ARM64, Windows x64, USO.md, PRUEBAS-0.2.3.md, descubrir.json y SHA256SUMS.txt. Todos verificados contra archivos locales por tamaño y digest SHA-256 de GitHub.
- Se actualizaron las guías para distribución y se reempaquetó Windows: ZIP final de 14 438 947 bytes; binarios compilados sin cambios. Ambos APK mantienen los tamaños y hashes comprobados. Las referencias originales y licencias se conservaron intactas, incluidos sus espacios finales; comprobación de formato del código propio correcta.
- La publicación no sustituye el retesteo físico Galaxy/Poco ni resuelve los pendientes anteriores de Tecno y sonido de cierre Windows. No se modificaron releases anteriores.

## Trabajo vigente local: 0.2.4+6

Actualizador opcional, buscador móvil con foco estable, biblioteca vacía según referencia, logs copiados/exportados/importados y servicio foreground mantenido entre pausas/cambios con liberación al detener. Dependencia audio_service 0.18.19 seleccionada mediante copia local con dos ajustes nativos documentados, sin modificar Pub global. 42 pruebas aprobadas, análisis limpio y pruebas nativas Android de segundo plano y validación del APK aprobadas. Evidencia, empaquetado y límites en [[18 Pruebas 0.2.3 y correcciones 0.2.4]]. No se publicó esta versión.

Resultado final 0.2.4: paquetes locales en dist/0.2.4 (universal 57 047 748 bytes; ARM64 21 337 361; Windows ZIP 14 506 646), guías y SHA-256. Firmas v2/certificado compatibles, código 6, arquitecturas, recursos multimedia, alineación y ZIP Windows comprobados. 42 pruebas aprobadas, análisis limpio y regresiones nativas documentadas en [[18 Pruebas 0.2.3 y correcciones 0.2.4]]. Sin publicación; retesteo prolongado Galaxy/Poco y actualización completa entre releases públicas pendientes.

## Publicación solicitada de 0.2.4 — 2026-10-25

El usuario autorizó subir la nueva release a GitHub. Se prepara v0.2.4-alpha.1 como preliminar, con fuentes y siete adjuntos: APK universal/ARM64, Windows, dos guías, ejemplo y SHA-256. Se mantienen los binarios verificados y se actualizan las guías de distribución. Confirmar publicación, commit y digest de adjuntos al terminar.

## Publicación confirmada — 2026-10-25

- [Release v0.2.4-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.2.4-alpha.1) publicada como preliminar; GitHub confirmó isDraft=false e isPrerelease=true.
- Etiqueta sobre `08f783c1f4c69b475f04d95783004eb6df4ad87b`; fuentes enviadas a main. Esta confirmación es posterior al commit etiquetado.
- Siete adjuntos en estado uploaded, verificados contra los archivos locales por tamaño y digest SHA-256 de GitHub: APK universal/ARM64, ZIP Windows, USO.md, PRUEBAS-0.2.4.md, descubrir.json y SHA256SUMS.txt.
- Se actualizaron las guías y reempaquetó Windows para distribución: ZIP final de 14 506 717 bytes. Binarios compilados y ambos APK se conservaron sin cambios.
- 0.2.4 debe instalarse manualmente sobre la anterior para habilitar detección de versiones futuras. Publicar no sustituye el retesteo prolongado Galaxy A34 Android 16/Poco X6 ni completa por sí solo una actualización entre releases desde el instalador. No se alteraron releases anteriores.

## Tráiler local — 2026-10-25

Se creó un proyecto audiovisual separado en la carpeta hermana rp_music_trailer, solicitada por el usuario. No se modifica Flutter. Composición editable de 30 s con identidad A, capturas de prueba identificadas y extensiones como visión futura. ESLint/TypeScript aprobados. Alcance y comprobación visual en [[19 Trailer de RP Music]]. Sin exportación MP4 ni publicación.

Verificación audiovisual final: cinco fotogramas de las cinco escenas generados/revisados con Remotion y Edge; encuadre aprobado. Sin revisión interactiva integrada por timeout; detalles en [[19 Trailer de RP Music]].

Tráiler actualizado con icono animado en apertura/cierre: R/P escalonadas y barras móviles; comprobación visual y ESLint/TypeScript aprobados. Solo proyecto audiovisual hermano; ver [[19 Trailer de RP Music]].

La música vigente del tráiler es pulse-trap.wav, tras aclaración del usuario (trap urbano). Pista original local y animación de barras a half-time 72 BPM; ver [[19 Trailer de RP Music]]. No modifica la app Flutter.

Pista audiovisual vigente: pulse-dark-trap.wav, dirección oscura/épica solicitada por el usuario; sustituye pulse-trap.wav sin borrarla. Detalles y límites en [[19 Trailer de RP Music]].

## README alineado con 0.2.4 — 2026-10-25

Se actualiza presentación pública para 0.2.4+6/v0.2.4-alpha.1 con novedades, instalación, diagnóstico/actualizador y límites de pruebas existentes. No cambia implementación ni se repiten pruebas de Flutter. El requisito de mantener README en cada actualización se conserva en [[01 Contexto para agentes]].

## Mejoras locales tras pruebas móviles 0.2.4 — 2026-10-25

Código local 0.2.5+7 con reproductor completo, título animado, carátula de sesión Android, iconos simples, Ajustes agrupados y eliminación real confirmada de archivos. Ver [[20 Pruebas 0.2.4 y mejoras 0.2.5]] para validación y límites. Última publicación: v0.2.4-alpha.1.

Validación final del incremento 0.2.5: 46 pruebas aprobadas, análisis limpio y APK release 0.2.5+7 local compilado; comprobación de iconos del APK aprobada. No hay nueva release publicada ni paquete Windows recompilado.

## Publicación autorizada de 0.2.5 — 2026-10-25

El usuario solicita actualizar también escritorio y subir la nueva release a GitHub. Se prepara v0.2.5-alpha.1 preliminar con APK universal/ARM64 y Windows x64, guías, ejemplo y SHA-256. Se autoriza por este pedido el envío de fuentes y publicación; confirmar resultados y adjuntos al terminar. Se preservan versiones anteriores.

## Publicación confirmada de 0.2.5 — 2026-10-25

[Release v0.2.5-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.2.5-alpha.1) pública como preliminar; GitHub confirmó isDraft=false e isPrerelease=true. Etiqueta sobre 4e65a619a6ebed4b869cb2404f0eee221ae8690c y fuentes enviadas a main. Siete adjuntos en estado uploaded, verificados por tamaño y SHA-256 de GitHub contra dist/0.2.5: APK universal/ARM64, Windows x64, USO.md, PRUEBAS-0.2.5.md, descubrir.json y SHA256SUMS.txt. Windows incluye las mejoras compartidas y prueba nativa aprobada, incluido borrado real. La confirmación se registra después del commit etiquetado.

La publicación conserva releases anteriores y no sustituye las pruebas físicas Android, instalación Tecno, actualización entre releases desde el instalador ni retesteo con los archivos originales de Windows.

## Trabajo local posterior a 0.2.5

0.2.6+8 en validación con actualizador, permisos, widget y orden; [[21 Pruebas 0.2.5 y mejoras 0.2.6]]. Última publicación sigue v0.2.5-alpha.1. [[22 Extensiones - alcance del primer sistema]] recoge decisiones de entrevista sin afirmar implementación programable.

Cierre 0.2.6 local: análisis limpio, 52 pruebas aprobadas, comprobaciones nativas Android API 37 (sesión/controles del widget/segundo plano) y Windows (audio/bandeja/borrado) aprobadas, APK universal y Windows release compilados y paquetes verificados. Guías y hashes locales actualizados. Límites físicos y de actualización entre releases en [[21 Pruebas 0.2.5 y mejoras 0.2.6]]. Requisitos de extensiones consolidados en [[22 Extensiones - alcance del primer sistema]], sin afirmar implementación del runtime.

## Publicación 0.2.6 autorizada — 2026-10-25

El usuario solicita publicar 0.2.6 antes de comenzar la implementación programable de extensiones. Se prepara v0.2.6-alpha.1 con APK universal/ARM64, Windows x64, guías, ejemplo y hashes. Fuentes de 0.2.6 y requisitos de la entrevista se incluyen; el código nuevo de extensiones será un incremento posterior separado. Confirmar publicación/adjuntos al terminar.

## Publicación 0.2.6 confirmada — 2026-10-25

[Release v0.2.6-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.2.6-alpha.1) pública como preliminar, isDraft=false/isPrerelease=true. Etiqueta sobre 2aa8648d7fe274e5b177ec773456613d6c52215f; fuentes enviadas a main. Siete adjuntos uploaded y verificados por tamaño/digest SHA-256 de GitHub: APK universal/ARM64, Windows, guías, ejemplo y hashes. Las guías se adaptaron para distribución y se reempaquetó el ZIP conservando binarios. No se alteraron releases anteriores. La publicación no completa las pruebas físicas/instalador pendientes. Implementación programable de extensiones autorizada a continuación como trabajo posterior.

## Prototipo programable local 0.3.0+9

Código con motor/programas API 2 y dos ejemplos reales. La release actual permanece v0.2.6-alpha.1, sin este código. Pruebas de intérprete/sistema/UI y sonda Windows release documentadas en [[23 Extensiones programables - primer prototipo]]; consultar cierre de validación antes de distribuir.

Cierre local 0.3.0+9: 65 pruebas aprobadas, análisis limpio, UI móvil/escritorio, regresión nativa Windows y sondas release del intérprete en Windows/Android aprobadas. Aplicaciones normales reconstruidas y verificadas; paquetes y guías en dist/0.3.0-local. No se enviaron estos cambios ni se publicó 0.3.0. Resultados, tamaños, hashes y límites en [[23 Extensiones programables - primer prototipo]].


2026-10-26: autorizado, creado y publicado repositorio público separado rp-music-extensions; catálogo por enlace integrado localmente, permisos antes de instalar y ejemplos retirados del bundle de producción. Ver alcance, verificaciones y límites en [[23 Extensiones programables - primer prototipo]]. La app no se publicó en esta tarea.


2026-10-26: usuario confirma descarga/instalación y permisos del catálogo. Código local ahora muestra Instalada para id presente con versión igual o superior (incluye desactivadas); solo una versión remota superior ofrece Actualizar. Tres pruebas del catálogo aprobadas. Este cambio todavía no está en los APK/ZIP anteriores. Se inicia entrevista/investigación de YouTube Music; conexión no implementada, alcance pendiente de respuestas. Ver boveda/24 YouTube Music - definicion e investigacion.md.


Resultado de investigación YouTube (2026-10-26): reproducción inicial/pausa/seek comprobadas en emulador Android, continuidad con HOME/SLEEP observada con anomalía posterior de posición. Windows sigue recibiendo 403; **extensión YouTube no lista**. Suite completa: 73 pruebas aprobadas, que no equivalen a validación del servicio remoto. Sondas en tools/youtube_* y resultados/límites en boveda/24 YouTube Music - definicion e investigacion.md. Build outputs actuales son sondas; reconstruir lib/main.dart antes de distribuir. APK/ZIP previos en dist conservados.


2026-10-26: el usuario prioriza Android. Implementada localmente 0.3.1+10 con adaptador YouTube Music sin cuenta, búsqueda de canciones, paquete externo, permiso network.youtube y capacidad source. Se cambió el cliente no oficial tras investigar #386; recepción completa de audio y sonda Android release continua aprobadas, recorrido nativo instalado en depuración aprobado. Suite: 77 pruebas. Límites y pendientes en [[24 YouTube Music - definicion e investigacion]]. Windows/listas/favoritos/historial de la fuente se posponen. No es publicación de la app.


0.3.1 Android final: APK normal instalado y arranque correcto en emulador, firmado y sin sondas; extensión publicada en catálogo ae10a9c y hash verificado. Archivos en dist/0.3.1-android-test. Aplicación principal sin push/release. Ver [[24 YouTube Music - definicion e investigacion]].


2026-10-26: usuario autoriza publicar 0.3.0 mientras prueba 0.3.1. Preparación separada y alcance en [[25 Release 0.3.0]]; no incluir YouTube ni modificar la copia de pruebas 0.3.1.


Publicación vigente confirmada: v0.3.0-alpha.1, Android universal/ARM64 y Windows, siete adjuntos verificados. Fuente y cierre en [[25 Release 0.3.0]]. 0.3.1 permanece en pruebas separadas; no está en esta release.


2026-10-26: usuario valida 0.3.1 (búsqueda/audio rápidos, sin bugs ni lag observados) y autoriza nueva release. Diseño reportado queda para próxima versión. Comunicación pública: soporte de extensiones para fuentes de música en la nube, con adaptador inicial Android; no prometer cualquier proveedor ni ocultar límites. Se publica el mismo APK validado; Windows mantiene 0.3.0. Seguimiento en [[26 Release 0.3.1]].


Publicación vigente confirmada: 0.3.1-alpha.1 Android, con cinco adjuntos y README remoto verificados. Mismo APK validado por el usuario; diseño pendiente para siguiente versión. Windows mantiene 0.3.0. Ver [[26 Release 0.3.1]].


Política de distribución vigente desde 2026-10-26: [[27 Publicacion de releases - contenido obligatorio]]. Esta actualización solo documenta el requisito; no cambia los adjuntos ni el estado histórico de 0.3.1.


2026-10-26: usuario confirma separación estricta: nuevas extensiones solo en rp-music-extensions, nunca en rp_music. Requisito principal en [[04 Extensiones]], enlazado desde Contexto/Inicio y coherente con [[27 Publicacion de releases - contenido obligatorio]]. Incluye fuentes, paquetes, recursos y pruebas específicos; la app conserva motor/SDK genéricos. Los prototipos/código específico y paquete ya publicados en el principal constituyen migración pendiente, no realizada en este cambio documental. No se borraron código, releases ni historial ni se enviaron cambios a GitHub en esta tarea.


2026-10-26: trabajo local vigente 0.3.2+11 en [[28 Pruebas 0.3.1 y mejoras 0.3.2]]: detalle de álbum, áreas seguras, nombre de fuente y navegación aportada por extensión. Se migra la lógica específica de la fuente al repositorio de extensiones; contrato HTTP genérico en la app y actualización de paquete requerida. Material previo de Biblioteca viva/Pulso aún pendiente de migración. No se publica 0.3.2 en esta tarea.


Cierre local 0.3.2: tres paquetes normales compilados (universal/ARM64/Windows), guías y hashes en dist/0.3.2-local; APK universal instalado/abierto, firma compatible con 0.3.1 y Windows iniciado. Suite inicial 75 pruebas, comprobación adicional de navegación y prueba nativa Android aprobadas; análisis sin incidencias. Extensión 0.2.0 aparte, actualización con permisos requerida. No hay publicación ni push de estos cambios; probar por archivo local hasta publicar catálogo. Resultados, tamaños, hashes y límites en [[28 Pruebas 0.3.1 y mejoras 0.3.2]].
