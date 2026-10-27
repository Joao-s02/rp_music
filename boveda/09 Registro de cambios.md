---
tipo: historial
estado: vigente
actualizado: 2026-10-26
---
# Registro de cambios

> **Registro histórico:** cada entrada describe el contexto y la verificación de su momento. El estado vigente se consulta en [[10 Estado del repositorio]]; decisiones por tema desde [[00 Inicio]]. Las correcciones posteriores no convierten todas las afirmaciones antiguas en estado actual.

## 2026-10-25 — Corrección de selección del compilador Java

- El usuario pidió resolver el bloqueo de compilación Android. Se añadió Eclipse Temurin JDK 17.0.20.1+1 en la carpeta `.jdks` del usuario, descargado desde la API oficial de Adoptium y con SHA-256 verificado: E53A79C3C3D86865BD7E787903884331068E71321714FFD44F145785AFFC7CB0.
- Gradle detectó el JDK completo, pero seguía priorizando el JRE actual: se seleccionó el nuevo JDK en JAVA_HOME del usuario y en `flutter config --jdk-dir`. Se conservan el JRE y el Java de Android Studio; no se modificaron dependencias ni se fijaron rutas personales en archivos Gradle versionados.
- Guía reproducible en docs/COMPILACION.md, basada en documentación oficial de Adoptium y Gradle. Gradle javaToolchains confirmó Is JDK=true y javac 17.0.20.1. Tras seleccionar el JDK activo, desapareció el error JAVA_COMPILER.
- La verificación Gradle directa encontró un registro automático que aún incluía integration_test de debug. El flujo completo `flutter build apk --release` regeneró los archivos de release y terminó con BUILD SUCCESSFUL. Evitar omitir esa preparación si los registros no corresponden al modo de compilación.
- APK local 0.2.2+4 con nuevo icono: 54 358 404 bytes, firma v2 correcta, SHA-256 37E12C6997AEDB0E7784DEE7EA7F469B514B835CF6FA1D1079B4E5EEEF89DC4C. No se publicó ni se reemplazaron adjuntos distribuidos; pendiente prueba física. Estado actualizado en [[10 Estado del repositorio]] y [[15 Identidad visual e icono]].

## 2026-10-25 — Variante A elegida e integrada como icono

- El usuario eligió A y autorizó convertirla en icono de la aplicación. Sustituye los iconos Flutter de Android, Windows y web; se conserva el maestro y los antecedentes.
- Android tiene cinco densidades y recurso adaptativo con margen; Windows ICO de siete resoluciones usado por ventana y bandeja; web incluye iconos para máscara y metadatos coherentes.
- Se documentó la identidad vigente en [[15 Identidad visual e icono]]: marca, paleta, tipografía, espacios, formas, componentes y discrepancias entre tokens/narrativa del MD. El documento original permanece completo en assets/branding. No se rediseñó el tema Flutter.
- Se añadió regeneración reproducible con tools/generar_iconos.py. Dimensiones PNG/ICO comprobadas, revisión visual del adaptativo, recursos Android compilados con AAPT2 y compilación Windows debug correcta. `git diff --check` sin errores.
- APK completo sin validar: intentos Flutter cancelados tras espera sin resultado; intento Gradle offline falló porque Java 17 detectado es JRE sin JAVA_COMPILER para android_file_picker. No se alteró Java global. Pendiente JDK requerido y recompilación Android; sin publicación ni comprobación física de lanzadores.

## 2026-10-25 — Tres variantes de icono para elegir

- El usuario indicó que la primera propuesta no le convencía del todo y pidió variantes de la misma idea.
- Se generaron, revisaron visualmente y conservaron tres PNG y sus prompts: geométrico, entrelazado y orgánico. Ver [[15 Identidad visual e icono]].
- Ninguno está elegido o integrado; se conserva el original. Sin cambios de código, compilaciones ni publicaciones.

## 2026-10-25 — Propuesta de icono desde boceto

- A petición del usuario, se creó un PNG de RP con ecualizador siguiendo su boceto y el documento Nocturnal Pulse; recurso, referencia y prompt conservados en `assets/branding/`.
- Revisión visual realizada: RP cian, cinco barras violetas y fondo oscuro. Propuesta pendiente de aprobación e integración por plataforma; no se cambiaron lanzadores ni se hicieron compilaciones o publicaciones. Ver [[15 Identidad visual e icono]].

## 2026-10-24 — Creación de la red de conocimiento

- Se consolidaron la petición original y tres rondas de entrevista en [[08 Entrevista consolidada]].
- Se documentaron visión, biblioteca, reproducción, extensiones y rendimiento con enlaces entre notas.
- Se separaron requisitos confirmados, propuestas, investigaciones pendientes y hechos comprobados.
- Se creó [[01 Contexto para agentes]] y una instrucción `AGENTS.md` en la raíz para mantener la bóveda durante trabajos futuros.
- Se registró el enfoque inicial aceptado y se identificaron decisiones técnicas todavía no tomadas.
- Se inspeccionaron archivos de la raíz, manifiesto Flutter y comienzo del documento histórico de arquitectura. El estado Git inicial no mostró cambios.
- Se conserva el código alfa. No se ejecutaron pruebas de la aplicación, no se eligieron dependencias, no se investigaron APIs o políticas y no se inició la reconstrucción.
- Validación documental: véase [[10 Estado del repositorio]].

## 2026-10-24 — Reconstrucción autorizada y primer incremento

- El usuario pidió comenzar y autorizó eliminar el código anterior. Se reemplazaron `lib` y `test`, conservando Git, bóveda y plataformas.
- Se implementaron biblioteca local de raíz única, escaneo fuera de interfaz, persistencia con respaldo, reproducción y primera interfaz española adaptable. Detalles y limitaciones en [[11 Reconstruccion - primera base]].
- Se añadió una extensión declarativa importable y su guía; no es el runtime programable completo.
- Se corrigió una captura no transferible al isolate de guardado detectada por pruebas. Se comprobó también que selecciones rápidas no reproduzcan pistas obsoletas y que pausar durante la carga impida autoplay posterior.
- 13 pruebas aprobadas; análisis estático sin problemas; compilaciones debug Android y Windows correctas. No hubo pruebas físicas de reproducción ni benchmarks.
- Windows requirió enlaces temporales de compilación dentro del proyecto y una definición de compatibilidad de Visual Studio 2026 limitada al backend de audio.
- Se reemplazó el README del alfa por instrucciones y estado verificable; no se publicó ni se envió nada a GitHub.

## Guía de futuras entradas

## 2026-10-24 — Preparación de release solicitada

- El usuario autorizó publicar APK, aplicación Windows e instrucciones en GitHub.
- Se comprobó el remoto `Joao-s02/rp_music`, la rama `main` y coincidencia con el remoto antes de publicar.
- Se iniciaron compilaciones release y se prepararon guía, notas, ejemplo y empaquetado Windows completo. Estado y resultado final en [[12 Release 0.2.0-alpha.1]].

## Formato de próximas entradas

## 2026-10-24 — Release publicada y verificada

- Se publicaron las fuentes reconstruidas en `main` y la release preliminar `v0.2.0-alpha.1` sobre `bdd01f012e3f6e8e61ac13ad6565ce32911beae8`.
- Compilaciones release correctas; APK y ZIP Windows completo con guía y ejemplo, más instrucciones y SHA-256 como adjuntos independientes.
- GitHub confirmó `isDraft=false`, cinco archivos en estado `uploaded`, tamaños y digest coincidentes. Etiqueta remota comprobada.
- Guía de instalación y límites disponible en `docs/USO.md`. La firma Android sigue siendo de desarrollo y no hubo pruebas físicas de audio ni en instalación limpia.
- Resultado y enlaces en [[12 Release 0.2.0-alpha.1]].

## Convención de siguientes registros

## 2026-10-24 — Informe de pruebas reales y correcciones 0.2.1

- Se registraron seis problemas y resultados positivos comunicados por el usuario en tres celulares y una PC; detalles de equipos, Windows y tiempos en [[13 Pruebas reales y correcciones 0.2.1]].
- Se implementaron progreso y caché de escaneo, listas disponibles/ausentes y eliminación de entradas, sesión persistente y diseño adaptado al teclado.
- Se sustituyó el backend Windows y se introdujo una prueba de audio nativo. El primer caso con backend nuevo pasó; no se reprodujo exactamente el crash original con los WAV generados.
- 18 pruebas unitarias/de interfaz y una prueba nativa Windows ampliada aprobadas; análisis estático limpio. Compilaciones release Android y Windows y ZIP verificado en `dist/0.2.1`. Se añadieron guía y plan de retesteo. No se publicó otra release; siguen pendientes medición en los celulares y comprobación con los archivos originales de Windows.

## Próximas entradas

## 2026-10-24 — Publicación solicitada de correcciones 0.2.1

- El usuario autorizó publicar la nueva release. Se verificó que `main` local y remoto coinciden antes de incorporar las correcciones pendientes.
- Se preparan `v0.2.1-alpha.1`, notas de cambios, guías actualizadas y adjuntos con hashes renovados. Estado final en [[13 Pruebas reales y correcciones 0.2.1]].

## Convención para próximos cambios

## 2026-10-24 — Release 0.2.1 publicada

- Publicadas las fuentes de correcciones en `main` y la release preliminar `v0.2.1-alpha.1`, etiqueta en `4b094e164123a5615285e5637043a4bcf24811c5`.
- APK, ZIP Windows completo, guía, plan de pruebas, ejemplo y SHA-256: seis adjuntos en estado `uploaded`, tamaños/digest verificados automáticamente contra los archivos locales.
- Se actualizaron y reempaquetaron las guías con enlaces de distribución; los binarios coinciden con las compilaciones previamente comprobadas. No se sustituyó la release anterior.
- Confirmación y límites en [[13 Pruebas reales y correcciones 0.2.1]].

## Formato de siguientes registros

## 2026-10-25 — Segundo informe real y correcciones 0.2.2

- El usuario confirmó mejoras de indexación/listas Android y estabilidad/formato Windows; reportó notificaciones ausentes, falta de volumen/bandeja y cierre de audio lento, e instalación inválida en Tecno Android 16.
- Se implementaron propagación multimedia y permiso de notificaciones, volumen persistente, bandeja Win32 y cierre coordinado. No se añadieron permisos generales de archivos por la hipótesis del antivirus.
- APK 0.2.1 local válido en firma y alineación; causa del rechazo Tecno aún pendiente. Se prepara variante ARM64 y diagnóstico ADB manual.
- 25 pruebas y una prueba nativa Windows final aprobadas; análisis limpio. APK universal/ARM64 y ZIP Windows compilados y verificados con guías y SHA-256 en `dist/0.2.2`. La variante ARM64 utiliza separación por ABI sin inflar el código de versión. Estado final y límites en [[14 Pruebas 0.2.1 y correcciones 0.2.2]]. No se publicó otra release.

## Siguientes registros

## 2026-10-25 — Publicación solicitada de 0.2.2

- El usuario autorizó crear la release de la nueva versión. Se comprobó coincidencia de `main` local y remoto antes de incorporar los cambios.
- Preparación de `v0.2.2-alpha.1`, fuentes, APK universal/ARM64, Windows, guías y diagnóstico. Estado final en [[14 Pruebas 0.2.1 y correcciones 0.2.2]].

## Próximos registros

## 2026-10-25 — Release 0.2.2 publicada y verificada

- Publicadas fuentes y release preliminar `v0.2.2-alpha.1` sobre `9f1e4f80966d5d020235200e23b6b58170c8b7fc`.
- Ocho adjuntos completos verificados automáticamente por tamaño y SHA-256: ambos APK, Windows, dos guías, diagnóstico manual, ejemplo y sumas.
- Se actualizaron guías y ZIP para distribución manteniendo los binarios comprobados. No se sustituyeron releases anteriores.
- Confirmación, URL y límites de retesteo en [[14 Pruebas 0.2.1 y correcciones 0.2.2]].

## Convención de registros siguientes

Registrar fecha, petición o motivo, decisiones y su estado, notas afectadas, comprobaciones y límites, y siguientes pendientes. No rellenar resultados antes de verificarlos.

## 2026-10-25 — Informe 0.2.2, rediseño Stitch y preparación local 0.2.3

- Requisito: Galaxy A34/Poco X6 siguen sin controles con permiso concedido y APK ARM64; añadir eliminación de listas y cambiar interfaz por el ZIP entregado.
- Implementado: adaptación visual Flutter móvil/escritorio con fuentes locales e identidad A; minirreproductor/reproductor completo, álbumes en tarjetas y eliminación confirmada/persistida sin borrar música.
- Notificaciones: recursos dinámicos audio_service ausentes del APK anterior; regla de conservación ampliada, estado/cola/duración y errores de servicio observados, diagnóstico en Ajustes. La comparación release posterior confirmó la causa en emulador: iconos recortados producen CustomAction sin icono y cero notificaciones; protegidos producen una sesión/notificación sin errores. Sigue pendiente retesteo físico.
- Verificado: 30 pruebas aprobadas, cuatro capturas revisadas con texto 130 %, prueba nativa debug y sonda release con notificación/sesión real y pausa/reanudación en emulador API 37. Límites y resultados finales en [[16 Pruebas 0.2.2 y rediseno 0.2.3]].
- Se conserva el trabajo previo sin publicar, crear repositorios, enviar cambios a GitHub ni alterar historial. Faltan retesteo físico y pendientes previos de Tecno/Windows.

### Resultado final del trabajo 0.2.3

- Comparación release confirmada: la regla anterior produce CustomAction sin icono y ninguna notificación aun con permiso concedido; la regla nueva permite la sesión/notificación y pausa/reanudación sin errores. Comprobación automática añadida para rechazar APK sin los iconos.
- 30 pruebas aprobadas, análisis limpio, revisión de cuatro capturas con texto ampliado e inicio normal de APK final comprobado en emulador. Se registró por separado un aviso transitorio de System UI del emulador y su recuperación, sin atribuirlo a RP Music.
- APK universal (56 489 408 bytes), ARM64 (21 139 469) y ZIP Windows (14 438 895) preparados localmente con guías y SHA-256 en dist/0.2.3. Ambos APK firmados v2, versión 0.2.3+5 y certificado compatible con 0.2.2; recursos y alineación comprobados. Windows EXE 0.2.3+5 y contenido del ZIP verificados.
- Pendiente: confirmación física Galaxy A34/Poco X6, problemas previos Tecno y cierre subjetivo Windows. Sin publicación ni cambios remotos. Ver [[16 Pruebas 0.2.2 y rediseno 0.2.3]].

## Publicación solicitada de 0.2.3 — 2026-10-25

El usuario autorizó publicar la release en GitHub. Se prepara `v0.2.3-alpha.1` como preliminar con fuentes, APK universal/ARM64, Windows x64, guías, ejemplo y SHA-256. Se mantienen los binarios comprobados; confirmar URL y adjuntos tras publicar.

## Publicación confirmada — 2026-10-25

- [Release v0.2.3-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.2.3-alpha.1) publicada como preliminar; GitHub confirmó `isDraft=false` e `isPrerelease=true`.
- Etiqueta sobre `498ceee98d08ca10e12132e62bfc59170786db9a`; fuentes enviadas a main. Esta confirmación es posterior al commit etiquetado.
- Siete adjuntos en estado uploaded: APK universal, APK ARM64, Windows x64, USO.md, PRUEBAS-0.2.3.md, descubrir.json y SHA256SUMS.txt. Todos verificados contra archivos locales por tamaño y digest SHA-256 de GitHub.
- Se actualizaron las guías para distribución y se reempaquetó Windows: ZIP final de 14 438 947 bytes; binarios compilados sin cambios. Ambos APK mantienen los tamaños y hashes comprobados. Las referencias originales y licencias se conservaron intactas, incluidos sus espacios finales; comprobación de formato del código propio correcta.
- La publicación no sustituye el retesteo físico Galaxy/Poco ni resuelve los pendientes anteriores de Tecno y sonido de cierre Windows. No se modificaron releases anteriores.

## 2026-10-25 — Evaluación de actualizaciones opcionales

El usuario plantea comprobar versiones con internet y actualizar desde la app, tomando como referencia el comportamiento que describe de Spoty Flac/Mornye. Se consultaron fuentes oficiales de GitHub y Android, sin verificar esa app concreta. Se documentó viabilidad y flujo propuesto, distinguiendo reproducción sin dependencia de red de consulta opcional. Se identificaron exclusión de prereleases en latest, firma compatible, intervención del instalador Android y flujo distinto para Windows portable. Sin cambios de código, compilaciones ni publicación; valores predeterminados y pruebas entre versiones pendientes. Ver [[17 Actualizaciones opcionales desde la app]] y [[02 Vision y decisiones]].

## 2026-10-25 — Informe 0.2.3 e implementación local 0.2.4

- Usuario autorizó actualizador opcional y pidió corregir teclado, cortes/foreground Android 16, copiar/importar logs y biblioteca con lupa desplegable según imagen.
- Se estabilizó el campo de búsqueda ante viewInsets y se adaptó el estado vacío sin datos simulados. Se añadió diagnóstico seleccionable/copiar/exportar/importar y cien eventos de sesión.
- Se conserva foreground durante pausa/cambio, evitando idle transitorio. Pruebas revelaron que audio_service no liberaba foreground al detener si seguía enlazado: se incorpora copia local MIT con stop explícito de foreground/wake lock y liberación de wake lock de CPU durante pausa. No se cambió caché global.
- Actualizador: GitHub público, SemVer/canales, consulta diaria configurable, sin bloqueo offline, selección ABI, descarga con cancelación y SHA-256, validación nativa de paquete/versión/certificado e instalación confirmada por Android. Windows abre descarga.
- 42 pruebas aprobadas y análisis limpio; prueba debug de cambio automático en segundo plano/pausa/reanudación/detención y sonda release sin errores. Validación nativa con APK real de código superior y rechazo de hash/versión incorrectos aprobada; no se confirmó reemplazo del paquete desde el instalador. Teclado de APK final aceptó texto y conservó foco/IME visibles.
- Retesteo prolongado físico y actualización entre releases públicas futuras pendientes. Detalle y paquetes finales en [[18 Pruebas 0.2.3 y correcciones 0.2.4]]. Sin publicación ni envío a GitHub; conservar la versión 0.2.3 publicada como antecedente.

Resultado final 0.2.4: paquetes locales en dist/0.2.4 (universal 57 047 748 bytes; ARM64 21 337 361; Windows ZIP 14 506 646), guías y SHA-256. Firmas v2/certificado compatibles, código 6, arquitecturas, recursos multimedia, alineación y ZIP Windows comprobados. 42 pruebas aprobadas, análisis limpio y regresiones nativas documentadas en [[18 Pruebas 0.2.3 y correcciones 0.2.4]]. Sin publicación; retesteo prolongado Galaxy/Poco y actualización completa entre releases públicas pendientes.

## Publicación solicitada de 0.2.4 — 2026-10-25

El usuario autorizó subir la nueva release a GitHub. Se prepara v0.2.4-alpha.1 como preliminar, con fuentes y siete adjuntos: APK universal/ARM64, Windows, dos guías, ejemplo y SHA-256. Se mantienen los binarios verificados y se actualizan las guías de distribución. Confirmar publicación, commit y digest de adjuntos al terminar.

## Publicación confirmada — 2026-10-25

- [Release v0.2.4-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.2.4-alpha.1) publicada como preliminar; GitHub confirmó isDraft=false e isPrerelease=true.
- Etiqueta sobre `08f783c1f4c69b475f04d95783004eb6df4ad87b`; fuentes enviadas a main. Esta confirmación es posterior al commit etiquetado.
- Siete adjuntos en estado uploaded, verificados contra los archivos locales por tamaño y digest SHA-256 de GitHub: APK universal/ARM64, ZIP Windows, USO.md, PRUEBAS-0.2.4.md, descubrir.json y SHA256SUMS.txt.
- Se actualizaron las guías y reempaquetó Windows para distribución: ZIP final de 14 506 717 bytes. Binarios compilados y ambos APK se conservaron sin cambios.
- 0.2.4 debe instalarse manualmente sobre la anterior para habilitar detección de versiones futuras. Publicar no sustituye el retesteo prolongado Galaxy A34 Android 16/Poco X6 ni completa por sí solo una actualización entre releases desde el instalador. No se alteraron releases anteriores.

## Tráiler de RP Music — 2026-10-25

Petición del usuario y carpeta confirmada: ../rp_music_trailer. Reutilizado Remotion 4.0.538 para composición Full HD de 30 s y cinco escenas editables. Marca A/fuentes locales, capturas verificadas de la app con datos de prueba identificados y música electrónica original sintetizada. Se distinguen funciones presentes de extensiones futuras. ESLint/TypeScript aprobados; Studio iniciado, navegador integrado con timeout, comprobación de fotogramas pendiente al registrar. Sin cambios Flutter, publicación ni MP4. Ver [[19 Trailer de RP Music]].

Resultado final del tráiler: cinco PNG generados y revisados (uno por escena) con Edge instalado; encuadre y textos correctos. Descarga inicial de Headless interrumpida, alternativa Edge aprobada. ESLint/TypeScript finales aprobados. Límite: vista interactiva integrada con timeout y mezcla completa no escuchada; MP4 no exportado. Detalles en [[19 Trailer de RP Music]].

Corrección de acceso al tráiler: puerto 3000 no disponible; Studio independiente en 3100, HTTP 200 y apertura real en navegador integrado comprobados. Play cambió a Pause. Enlace vigente y alcance en [[19 Trailer de RP Music]].

Icono animado del tráiler a petición del usuario: entrada escalonada R/P, cinco barras violetas con movimiento por fotograma, en apertura y cierre. Se reutilizan recortes del maestro A sin modificarlo. Vista Studio comprobada en fotograma 55 y sin error activo; detalles en [[19 Trailer de RP Music]].

Verificación final del icono animado: ESLint/TypeScript aprobados; alturas distintas comprobadas visualmente en fotogramas 55/67 y reproducción reiniciada desde cero.

Música del tráiler revisada por petición del usuario: nueva base original más animada a 128 BPM, en tono mayor y con batería/bajo más marcados. Se conserva pista anterior; pulso del icono ajustado y nueva pista cargada en Studio con reproducción iniciada. ESLint/TypeScript aprobados; mediciones y límites en [[19 Trailer de RP Music]].

Dirección musical corregida por el usuario: trap urbano con ritmo y atractivo propio, en lugar de base alegre. Instrumental original a 144 BPM/half-time 72 con 808, campanas menores, batería y redobles; antecedentes conservados. WAV y código verificados, pista cargada y reproducción iniciada en Studio. Alcance y métricas en [[19 Trailer de RP Music]].

Nueva revisión musical: el usuario pide trap oscuro y épico. Pista original pulse-dark-trap.wav con pedal grave, metales, 808 saturado e impactos, sin campanas; 140 BPM/half-time 70. WAV/código verificados y reproducción en Studio iniciada. Ver [[19 Trailer de RP Music]].

Miniatura YouTube creada y guardada como PNG/JPEG en design/youtube, usando la marca A como referencia y texto del tráiler. Imagen revisada; no se publica. Ver [[19 Trailer de RP Music]].

El usuario confirmó publicación de su tráiler en YouTube (lobwRKtXv-M) y autorizó añadirlo al README en GitHub. Añadida miniatura enlazada y enlace textual cerca del inicio, usando JPEG local. Se prepara commit/publicación con contexto del tráiler; ver [[19 Trailer de RP Music]].

Integración del tráiler publicada: 026c87e enviado a main; README remoto confirmado por API con miniatura JPEG y enlace YouTube. Confirmación posterior al commit.

## README vigente y mantenimiento obligatorio — 2026-10-25

El usuario detectó que la descripción seguía en 0.2.2 y pidió actualizarla, además de exigir mantenimiento en cada actualización. README alineado con 0.2.4+6/v0.2.4-alpha.1: descarga ARM64/universal/Windows, instalación manual inicial, novedades 0.2.3/0.2.4, listas completas, diagnóstico, actualizador, 42 pruebas documentadas y límites de validación física. Tráiler conservado. Regla principal incorporada en [[01 Contexto para agentes]]: revisión completa en cada actualización, diferenciando publicado/local e implementación/propuestas; no autoriza publicaciones por sí misma. Verificación de enlaces locales y diff antes de publicar; no se recompila Flutter por ser documentación.

## 2026-10-25 — Informe móvil 0.2.4 y mejoras locales 0.2.5

El usuario confirma notificaciones visibles y solicita cuatro mejoras. Se implementan reproductor a pantalla completa con título animado, carátula de sesión e iconos vectoriales, Ajustes con tarjetas/botones y borrado irreversible confirmado con limpieza de referencias solo tras éxito. Android requiere escritura SAF; puede ser necesario reelegir carpeta. Se conserva 0.2.4 publicada y trabajo previo de la bóveda/tráiler. Motivos, comprobaciones y pendientes en [[20 Pruebas 0.2.4 y mejoras 0.2.5]]. Sin publicación ni push.

Cierre 0.2.5 local: análisis limpio, 46 pruebas aprobadas, APK release 0.2.5+7 compilado y recursos multimedia verificados. Capturas móvil/escritorio actualizadas. Digest y tamaño en [[20 Pruebas 0.2.4 y mejoras 0.2.5]]. Pendientes: teléfono físico, permisos SAF/SD y Windows nativo.

## Publicación autorizada de 0.2.5 — 2026-10-25

El usuario solicita actualizar también escritorio y subir la nueva release a GitHub. Se prepara v0.2.5-alpha.1 preliminar con APK universal/ARM64 y Windows x64, guías, ejemplo y SHA-256. Se autoriza por este pedido el envío de fuentes y publicación; confirmar resultados y adjuntos al terminar. Se preservan versiones anteriores.

## Publicación confirmada de 0.2.5 — 2026-10-25

[Release v0.2.5-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.2.5-alpha.1) pública como preliminar; GitHub confirmó isDraft=false e isPrerelease=true. Etiqueta sobre 4e65a619a6ebed4b869cb2404f0eee221ae8690c y fuentes enviadas a main. Siete adjuntos en estado uploaded, verificados por tamaño y SHA-256 de GitHub contra dist/0.2.5: APK universal/ARM64, Windows x64, USO.md, PRUEBAS-0.2.5.md, descubrir.json y SHA256SUMS.txt. Windows incluye las mejoras compartidas y prueba nativa aprobada, incluido borrado real. La confirmación se registra después del commit etiquetado.

La publicación conserva releases anteriores y no sustituye las pruebas físicas Android, instalación Tecno, actualización entre releases desde el instalador ni retesteo con los archivos originales de Windows.

## 2026-10-25 — Informe 0.2.5 y entrevista de extensiones

Se trabaja en 0.2.6+8 local: actualizador centrado y ZIP Windows descargable, autorización de escritura al borrar, widget Android y siete criterios de orden persistente. Motivos y validación en [[21 Pruebas 0.2.5 y mejoras 0.2.6]]. La entrevista define primera extensión de biblioteca/listas automáticas/carátulas, permisos, varias activas y recuperación; [[22 Extensiones - alcance del primer sistema]]. Distinguir esos requisitos del runtime aún no implementado. No publicar ni hacer push por este informe.

Cierre 0.2.6 local: análisis limpio, 52 pruebas aprobadas, comprobaciones nativas Android API 37 (sesión/controles del widget/segundo plano) y Windows (audio/bandeja/borrado) aprobadas, APK universal y Windows release compilados y paquetes verificados. Guías y hashes locales actualizados. Límites físicos y de actualización entre releases en [[21 Pruebas 0.2.5 y mejoras 0.2.6]]. Requisitos de extensiones consolidados en [[22 Extensiones - alcance del primer sistema]], sin afirmar implementación del runtime.

## Publicación 0.2.6 autorizada — 2026-10-25

El usuario solicita publicar 0.2.6 antes de comenzar la implementación programable de extensiones. Se prepara v0.2.6-alpha.1 con APK universal/ARM64, Windows x64, guías, ejemplo y hashes. Fuentes de 0.2.6 y requisitos de la entrevista se incluyen; el código nuevo de extensiones será un incremento posterior separado. Confirmar publicación/adjuntos al terminar.

## Publicación 0.2.6 confirmada — 2026-10-25

[Release v0.2.6-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.2.6-alpha.1) pública como preliminar, isDraft=false/isPrerelease=true. Etiqueta sobre 2aa8648d7fe274e5b177ec773456613d6c52215f; fuentes enviadas a main. Siete adjuntos uploaded y verificados por tamaño/digest SHA-256 de GitHub: APK universal/ARM64, Windows, guías, ejemplo y hashes. Las guías se adaptaron para distribución y se reempaquetó el ZIP conservando binarios. No se alteraron releases anteriores. La publicación no completa las pruebas físicas/instalador pendientes. Implementación programable de extensiones autorizada a continuación como trabajo posterior.

## 2026-10-25 — Inicio real del sistema programable

Tras publicar 0.2.6 se implementa 0.3.0+9 local con dart_eval 0.8.5, paquetes API 2, imports puros revisados, ejecución con tiempo limitado, permisos normales/avanzados, varias activas, conflictos y recuperación. Biblioteca viva aporta filtros y listas automáticas; Pulso nocturno, disposición de reproductor y aleatorio. Carátulas propias/mosaico y conservación de datos integradas. Elección técnica, pruebas y límites en [[23 Extensiones programables - primer prototipo]]. No se anuncia como libertad completa de Flutter ni como motor seguro para código hostil; no se publica ni envía este incremento.

Cierre local 0.3.0+9: 65 pruebas aprobadas, análisis limpio, UI móvil/escritorio, regresión nativa Windows y sondas release del intérprete en Windows/Android aprobadas. Aplicaciones normales reconstruidas y verificadas; paquetes y guías en dist/0.3.0-local. No se enviaron estos cambios ni se publicó 0.3.0. Resultados, tamaños, hashes y límites en [[23 Extensiones programables - primer prototipo]].


2026-10-26: autorizado, creado y publicado repositorio público separado rp-music-extensions; catálogo por enlace integrado localmente, permisos antes de instalar y ejemplos retirados del bundle de producción. Ver alcance, verificaciones y límites en [[23 Extensiones programables - primer prototipo]]. La app no se publicó en esta tarea.


Cierre 2026-10-26: repositorio de extensiones público confirmado, main d7d99045340e9d8ad6780f9608a69b0e75012f29. Once pruebas de catálogo/sistema/UI aprobadas; dos UI repetidas tras ajustar diálogo, aprobadas. Análisis final limpio. Builds normales release Android y Windows completados. APK con firma anterior verificada; APK y ZIP Windows sin paquetes de ejemplo ni integration_test. Nuevos archivos locales en dist/0.3.0-catalogo, con USO.md y SHA256SUMS.txt; los artefactos previos se conservan y no incluyen el explorador. No se publicó ni se envió el incremento de la app, ni se afirma una nueva prueba física/AOT de instalación por catálogo.


2026-10-26: usuario confirma descarga/instalación y permisos del catálogo. Código local ahora muestra Instalada para id presente con versión igual o superior (incluye desactivadas); solo una versión remota superior ofrece Actualizar. Tres pruebas del catálogo aprobadas. Este cambio todavía no está en los APK/ZIP anteriores. Se inicia entrevista/investigación de YouTube Music; conexión no implementada, alcance pendiente de respuestas. Ver boveda/24 YouTube Music - definicion e investigacion.md.


2026-10-26: requisitos de YouTube Music confirmados: solo audio dentro de RP Music, segundo plano/pantalla apagada, Android y Windows, sin cuenta, listas/favoritos/historial locales y búsqueda/exploración. Se investigan fuentes primarias oficiales y alternativas no oficiales; elección de vía pendiente de respuesta. No hay streaming remoto implementado ni comprobado. Detalles en boveda/24 YouTube Music - definicion e investigacion.md.


YouTube Music: el usuario aceptó la vía no oficial experimental. Se inicia sonda nativa separada de reproducción; metadatos y primeros bytes HTTP comprobados, reproducción todavía pendiente. La app normal no tiene aún una extensión YouTube conectada. Ver boveda/24 YouTube Music - definicion e investigacion.md. No distribuir binarios de la entrada tools/youtube_audio_probe.dart.


## Cierre de la primera investigación — resultado parcial

La sonda Windows con búfer secuencial recibió 1048576 bytes antes de 403; `ok=false`, dos lecturas nativas. Variante previa con renovación del manifiesto también falló. No se demostró reproducción estable en Windows. No elegir aún estos transportes como arquitectura final ni empaquetar un .rpmx que prometa funcionar en ambas plataformas.

Comprobado: Android emulador AOT pudo cargar/reproducir/pausar/seek mediante rangos y continuó informando reproducción tras HOME/SLEEP; hubo regresión posterior de posición, estabilidad pendiente. Windows sigue fallando; fuente/contenido único de demostración, sin prueba física ni catálogo musical amplio. No hay búsqueda YouTube Music implementada, playlists remotas, favoritos/historial remoto o permisos de red expuestos al SDK. El siguiente paso técnico pendiente es encontrar un transporte/cliente que mantenga reproducción estable en ambas plataformas y repetir el ensayo; el usuario ya autorizó la vía no oficial, no necesita repetirse esa pregunta.

Artefactos de sondas permanecen en build, NO son la app normal. No se publicaron en GitHub ni sustituyeron archivos entregados en dist/0.3.0-catalogo. Antes de empaquetar otra aplicación normal reconstruir lib/main.dart con `flutter build windows --release` y `flutter build apk --release` completos; los registros integration_test pueden quedar de pruebas si se usa --no-pub. Los intentos de sonda Android con --no-pub fallaron por registro residual; el build completo corrigió ese problema.

Pruebas: suite completa final 73 aprobadas, incluyendo comparación de versiones instalada/remota, transporte por rangos, renovación simulada ante 403, búfer secuencial compartido y límites RAM. Una aserción inicial del búfer esperaba descarga completa antes de que sus lectores hubieran terminado el último tramo; se corrigió solicitando el tramo final, sin ocultar errores reales de transporte. Pruebas unitarias no implican éxito de YouTube: son validaciones locales del adaptador.

No hay extensión YouTube Music lista para instalar ni nueva release. Los ejemplos Biblioteca viva/Pulso nocturno y la biblioteca local no usan las dependencias de desarrollo añadidas para esta prueba. El catálogo Instalada/Actualizar sigue siendo un cambio local posterior a los paquetes distribuidos.


2026-10-26: el usuario prioriza Android. Implementada localmente 0.3.1+10 con adaptador YouTube Music sin cuenta, búsqueda de canciones, paquete externo, permiso network.youtube y capacidad source. Se cambió el cliente no oficial tras investigar #386; recepción completa de audio y sonda Android release continua aprobadas, recorrido nativo instalado en depuración aprobado. Suite: 77 pruebas. Límites y pendientes en [[24 YouTube Music - definicion e investigacion]]. Windows/listas/favoritos/historial de la fuente se posponen. No es publicación de la app.


Cierre de empaquetado Android 0.3.1: APK normal y paquete externos verificados, extensión publicada en repositorio separado ae10a9c y descarga por catálogo comprobada. App no publicada. Ver [[24 YouTube Music - definicion e investigacion]].


Cierre verificado: APK final normal instalado en emulador, package com.example.rp_music versionName 0.3.1/versionCode 10, arranque de MainActivity correcto y sin registros de crash. El primer intento de instalación quedó con sesión pendiente y un segundo informó paquete duplicado; se inició en frío el emulador de esta tarea y la instalación normal se completó. No se atribuye ese bloqueo del instalador al código de reproducción ni a teléfonos físicos. Permiso de notificaciones concedido únicamente en emulador para completar el arranque; en teléfonos lo solicita la aplicación.

Compilaciones previas conservadas; no se publica release principal ni ZIP Windows en esta fase. APK normal final de 70362924 bytes. Se cierra el emulador propio al terminar. Siguiente validación: teléfono físico del usuario con consulta del catálogo, aceptación de permisos y reproducción de sus búsquedas. No se requieren contraseñas/cookies para esta entrega.


2026-10-26: usuario autoriza publicar 0.3.0 mientras prueba 0.3.1. Preparación separada y alcance en [[25 Release 0.3.0]]; no incluir YouTube ni modificar la copia de pruebas 0.3.1.


Publicación vigente confirmada: v0.3.0-alpha.1, Android universal/ARM64 y Windows, siete adjuntos verificados. Fuente y cierre en [[25 Release 0.3.0]]. 0.3.1 permanece en pruebas separadas; no está en esta release.


Sincronización local final: main apunta a 475eb97 (confirmación documental); tag de código f7b143a. Actualizado solo HEAD/índice, con índice previamente vacío. Verificación SHA-256 confirma que 44 archivos protegidos de 0.3.1 —código, configuración, APK/paquete y PNG previo— permanecen idénticos. La copia de desarrollo continúa en 0.3.1 con cambios sin publicar.


2026-10-26: usuario valida 0.3.1 (búsqueda/audio rápidos, sin bugs ni lag observados) y autoriza nueva release. Diseño reportado queda para próxima versión. Comunicación pública: soporte de extensiones para fuentes de música en la nube, con adaptador inicial Android; no prometer cualquier proveedor ni ocultar límites. Se publica el mismo APK validado; Windows mantiene 0.3.0. Seguimiento en [[26 Release 0.3.1]].


Publicación vigente confirmada: 0.3.1-alpha.1 Android, con cinco adjuntos y README remoto verificados. Mismo APK validado por el usuario; diseño pendiente para siguiente versión. Windows mantiene 0.3.0. Ver [[26 Release 0.3.1]].


2026-10-26 — Nueva instrucción de distribución confirmada por el usuario: cada release debe incluir Android universal/global, APK ARM64 y Windows, un MD de pruebas a realizar, un MD separado de cambios y demás archivos necesarios. Política consolidada en [[27 Publicacion de releases - contenido obligatorio]], enlazada desde Inicio/Contexto para agentes y README. Se fijan nombres de adjuntos, guía de uso, hashes y verificación previa de publicación. No inferir permiso de omitir plataformas por priorizar Android; cualquier excepción requiere instrucción expresa. Cambio documental, sin modificar ni completar automáticamente las releases existentes. Revisión de enlaces y diff realizada; no requiere pruebas de código.


2026-10-26: usuario confirma separación estricta: nuevas extensiones solo en rp-music-extensions, nunca en rp_music. Requisito principal en [[04 Extensiones]], enlazado desde Contexto/Inicio y coherente con [[27 Publicacion de releases - contenido obligatorio]]. Incluye fuentes, paquetes, recursos y pruebas específicos; la app conserva motor/SDK genéricos. Los prototipos/código específico y paquete ya publicados en el principal constituyen migración pendiente, no realizada en este cambio documental. No se borraron código, releases ni historial ni se enviaron cambios a GitHub en esta tarea.


## 2026-10-26 — 0.3.2 local en verificación

Informe físico 0.3.1 y referencia de álbum confirmados. Se implementa nuevo detalle de álbum, SafeArea de fuente, metadatos de servicio y contribución de navegación desde manifiesto; se migra cliente/parser/paquete de fuente al repositorio separado por regla del usuario. SDK HTTP genérico y variantes compatibles de catálogo. Búsqueda real y 64 KiB de audio verificados con programa externo; suite inicial 75 pruebas aprobadas. Ver resultados finales y límites en [[28 Pruebas 0.3.1 y mejoras 0.3.2]]. No se publican app ni release nueva.


Cierre local 0.3.2: tres paquetes normales compilados (universal/ARM64/Windows), guías y hashes en dist/0.3.2-local; APK universal instalado/abierto, firma compatible con 0.3.1 y Windows iniciado. Suite inicial 75 pruebas, comprobación adicional de navegación y prueba nativa Android aprobadas; análisis sin incidencias. Extensión 0.2.0 aparte, actualización con permisos requerida. No hay publicación ni push de estos cambios; probar por archivo local hasta publicar catálogo. Resultados, tamaños, hashes y límites en [[28 Pruebas 0.3.1 y mejoras 0.3.2]].


## 2026-10-26 — autorización de publicación 0.3.2

Usuario autoriza nueva release de GitHub. Preparación de app 0.3.2+11 con Android universal/ARM64, Windows, USO/PRUEBAS/CAMBIOS y hashes; extensión y catálogo exclusivamente en repositorio de extensiones. Ver [[28 Pruebas 0.3.1 y mejoras 0.3.2]] para resultados de publicación cuando se confirmen.


2026-10-26 — publicación confirmada: [v0.3.2-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.3.2-alpha.1), app 0.3.2+11, tag b8fd967. Android universal/ARM64, Windows, USO/PRUEBAS/CAMBIOS y hashes: siete adjuntos públicos verificados por tamaño y SHA-256. Extensión 0.2.0 y catálogo compatible publicados exclusivamente en rp-music-extensions (da3e455); paquete remoto verificado y versión 0.1.0 conservada para 0.3.1. Ya no es entrega solo local. Ver [[28 Pruebas 0.3.1 y mejoras 0.3.2]] para commits, hashes, pruebas y pendientes.


## 2026-10-26 — pruebas 0.3.2 y desarrollo local 0.3.3

Usuario pide reproductor de referencia sin ecualizador y cinco correcciones de biblioteca/reproducción/extensiones. Se implementa UI adaptada a controles reales, lista existente/crear, historial anterior/avance, artistas múltiples por coma y navegación de fuente temática. Variantes específicas solo en rp-music-extensions. Historial/listas/artistas comprobados en pruebas iniciales; ver resultados finales, límites y entregables en [[29 Pruebas 0.3.2 y mejoras 0.3.3]]. No se publica esta versión sin nueva instrucción.


Cierre local 0.3.3+12: reproductor renovado sin ecualizador y cinco correcciones implementadas; suite inicial 86, comprobaciones finales con nueva regresión de filtro guardado y análisis aprobados. Audio real Android con anterior/avance y revocación aprobado en primer plano; APK normal instalado/abierto y Windows iniciado. Universal/ARM64/Windows, guías y hashes definitivos en dist/0.3.3-local. Extensiones 0.2.1 de fuente y 0.1.1 de Biblioteca viva en repo separado, variantes locales sin publicar. No se publica esta versión ni se hace push; pruebas físicas pendientes. Ver [[29 Pruebas 0.3.2 y mejoras 0.3.3]].


## 2026-10-26 — autorización de publicación 0.3.3

Usuario autoriza release y actualizaciones de extensiones en su repositorio separado. Preparación con tres plataformas/variantes, guías y hashes; ver [[29 Pruebas 0.3.2 y mejoras 0.3.3]] para la confirmación remota y resultados cuando se complete.


2026-10-26 — publicación confirmada: [v0.3.3-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.3.3-alpha.1), app 0.3.3+12, tag 6107845. Android universal/ARM64, Windows, USO/PRUEBAS/CAMBIOS y hashes: siete adjuntos públicos verificados por tamaño y SHA-256. Fuente 0.2.1 y Biblioteca viva 0.1.1 publicadas en rp-music-extensions (641d970), paquetes remotos verificados y versiones anteriores conservadas en catálogo. Ya no es entrega solo local. Resultados, commits, hashes y límites en [[29 Pruebas 0.3.2 y mejoras 0.3.3]].


## 2026-10-26 — consolidación de la documentación

El usuario solicita ordenar la documentación tras detectar estados antiguos mezclados con actuales. Se reorganizan [[00 Inicio]] y [[01 Contexto para agentes]], y [[10 Estado del repositorio]] queda como resumen único de implementación/distribución/verificación actual. Sus textos anteriores se conservan íntegros como citas en [[30 Archivo de navegacion y estado]], con hashes de conservación; no se borran decisiones ni Git.

Se alinean notas temáticas 02–07 y la identidad 15 con código/evidencia hasta 0.3.3: tema/fuentes ya integrados, backend/JSON/runtime provisionales implementados, catálogo/recuperación publicados, prioridad Android de la fuente y preguntas realmente pendientes. Se corrige la falsa continuidad de estado local/no publicado en las entradas de incorporación. Notas de entrevista/versiones/proyecto quedan delimitadas como históricas, conservando sus resultados y fases.

Nueva [[31 Arquitectura vigente]] basada en rutas del código y pubspec: responsabilidades, flujo, persistencia, fuente genérica, contratos y límites. README principal resumido para la versión actual, docs/README.md como índice y USO.md como entrada a la guía versionada; se corrigen referencias viejas de compilación y SDK. Los documentos de uso/pruebas/cambios versionados, binarios y releases permanecen intactos.

Verificaciones documentales: enlaces Obsidian y rutas Markdown locales comprobados, hashes del traslado histórico coincidentes y alcance de cambios limitado a Markdown. No se ejecutaron pruebas ni builds Flutter: no se cambió implementación, datos, contratos ni versiones. No hay push/publicación de esta limpieza; queda local para revisión. Límites heredados del producto permanecen explícitos en [[07 Preguntas e investigacion]].

## 2026-10-27 — Test 0.3.3 e implementación local 0.3.4

Requisitos y trabajo en [[32 Pruebas 0.3.3 y mejoras 0.3.4]]: controles fijos/carátula adaptable, inicio de letras sincronizadas LRC/TXT, transporte genérico de letras, permiso/selector de descarga y accesos de fuentes. Paquetes solo en checkout externo: YouTube Android/Windows separados y Spotify con vistas previas públicas sin cuenta. Audio completo Spotify permanece sin resolver; no sustituirlo silenciosamente por otro servicio. Verificación de ruta en cuatro tamaños y red/audio de paquetes aprobada; verificaciones finales se anotan en la nota de tarea. Se conservan modificaciones documentales previas y catálogo/releases publicados; no commit/push/publicación.

Cierre de verificaciones 0.3.4: 97 pruebas aprobadas y análisis limpio. Capturas 360/1280 inspeccionadas. Se descarta el búfer automático investigado para Windows: no resolvió los ensayos nativos; broker/motor se conservan sin ese cambio. Windows remoto y Spotify completo siguen pendientes explícitos. Pruebas de lectura de letras y fixture de versión futura corregidos; no se alteró la lógica del actualizador. Estado detallado en [[32 Pruebas 0.3.3 y mejoras 0.3.4]].

Windows normal release recompilado tras sondas, versión 0.3.4+13 y registro sin integration_test comprobados. No se compilaron nuevos APK ni se publicaron artefactos. Capturas históricas 0.3.3 restauradas tras regeneración por suite; nuevas capturas 0.3.4 conservadas.

## 2026-10-27 — Publicación 0.3.4 autorizada

El usuario pide generar y subir la release 0.3.4. Se preparan los siete adjuntos obligatorios y las extensiones en el repositorio separado. Se mantienen los límites conocidos de Windows remoto y Spotify; no se anuncian como funciones completas. Catálogo compatible con 0.3.1/0.3.2/0.3.3 conservado y Spotify oculto a anfitriones anteriores mediante minAppVersion. Publicación y verificación final en [[32 Pruebas 0.3.3 y mejoras 0.3.4]].

Publicación confirmada: v0.3.4-alpha.1, app 0.3.4+13, tag d873ae3ada998fcefc89b4a5f98cd298f9db6204. Siete adjuntos del borrador y API pública verificados por tamaño/digest; SHA256SUMS descargado idéntico. Android universal/ARM64 con firma/ABI/versión comprobadas; sin dispositivo para arranque. ZIP Windows completo y arranque normal 5 s comprobados. Extensiones publicadas en commit 833044ab11a2d03a4fd82134822246fc52149aed, catálogo compatible con anteriores y Windows candidato fuera de catálogo. Las limitaciones permanecen explícitas en [[32 Pruebas 0.3.3 y mejoras 0.3.4]]. Índice y estado actual actualizados; no cambia el código de los binarios con esta confirmación documental.
