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

Registrar fecha, petición o motivo, decisiones y su estado, notas afectadas, comprobaciones y límites, y siguientes pendientes. No rellenar resultados antes de verificarlos.
