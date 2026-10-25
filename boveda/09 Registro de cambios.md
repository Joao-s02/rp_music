---
tipo: historial
estado: vigente
actualizado: 2026-10-24
---
# Registro de cambios

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

Registrar fecha, petición o motivo, decisiones y su estado, notas afectadas, comprobaciones y límites, y siguientes pendientes. No rellenar resultados antes de verificarlos.
