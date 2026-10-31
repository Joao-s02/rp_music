---
tipo: estado-actual
estado: publicado-0.3.16-con-limites
actualizado: 2026-10-29
---
# Estado del repositorio

## Candidato local A01 — recuperación de biblioteca

Solo A01: carga completa validada, respaldo ante datos incompatibles y conservación del rechazado; sin copia válida, guardado bloqueado sin sobrescribir originales. Esquema 1 y otros consumidores de LocalStore conservados. RED16/6 y GREEN22; verificación independiente enfocada22/análisis limpio después de completar un insumo omitido de la copia aislada. Suite final174aprobadas/cero fallidas/una optativa omitida, exit0;36PNG previos conservados. Commit local `0f35994` en `fix/a01-recovery`, revisión nativa aprobada con acuse completado y dos recomendaciones no bloqueantes; no publicación ni prueba física/cortes de energía. Alcance, instrucciones y límites: [[03 Biblioteca y reproduccion]].

## Referencia publicada: 0.3.16

0.3.16-alpha.1 publicada, app0.3.16+25. ReleaseID 428152288; tag/código 9aceaa2db7c9d54c764de79252bd5761895508cd. Android universal/ARM64 y Windows x64 completo32archivos/licencias/guías. Siete adjuntos verificados en borrador y públicamente por tamaño/SHA256, tag al commit correcto y manifiesto descargado idéntico. Catálogo externo b74564aaee444294580ff1aefa7a6e8f337fabcd: diez opciones y34paquetes/variantes comprobados; cliente real selecciona YouTube0.5.3, Explorador0.2.3 y Explorador JS0.1.1, con variantes anteriores preservadas. 163 pruebas aprobadas/una optativa omitida y análisis limpio; pruebas adicionales de metadatos/portadas y respaldo ante503 separadas. APK sin permiso de instalar paquetes, firma compatible. Sin prueba física nueva ni medición de latencia API3 Android; SAF/widgets/ARM64 físicos y escucha prolongada pendientes. [[45 Portadas artistas navegacion y descargas 0.3.16]].

## Antecedente publicado: 0.3.15

0.3.15-alpha.1 publicada, app0.3.15+24. ReleaseID 428029331; tag/código 9dcdeb1f0d842bfc2bb1abe098f961ba378b9e9b. Android universal exacto probado por el usuario, ARM64 y Windows x64 completo (32 archivos/licencias/guías). Siete adjuntos verificados en borrador y públicamente por tamaño/SHA256; tag al commit correcto y manifiesto descargado idéntico. Universal sin REQUEST_INSTALL_PACKAGES aceptado por Play Protect e instalado en emulador conservando lista/fecha original; usuario confirma A34 con actualización sin aviso y Pova 7 con análisis solicitado e instalación normal, sin clasificación dañina. Android usa actualizaciones por web/Archivos y firma de producción con transición compatible. 166 pruebas aprobadas/una optativa omitida y análisis limpio. ARM64 físico/análisis automático específico, otros dispositivos, escucha prolongada y latencia API3 Android pendientes. Catálogo externo conservado, sin nuevos paquetes. [[44 Diagnostico local de instalacion y actualizaciones manuales]].

0.3.15 se conserva como antecedente. La referencia actual0.3.16 y su catálogo se comprobaron en GitHub en esta publicación.

## Alcance 0.3.16

Petición, decisiones, cambios y verificaciones en [[45 Portadas artistas navegacion y descargas 0.3.16]]. Incluye «Explorar» con cinco destinos fijos, descargas de álbum a disco/reintentos, búsqueda e indicador de álbum, agrupación de artistas, imágenes de entidades, candidatos de metadatos/portadas y diagnóstico/caché API 3. Publicado con validación automatizada y límites físicos explícitos.

## Capacidades publicadas y límites

| Área | Estado de referencia |
| --- | --- |
| Biblioteca | Raíz/subcarpetas, caché, escaneo manual/progresivo, búsqueda, favoritos/listas, álbumes/artistas/carpetas y orden. |
| Audio | Cola de selección, controles/volumen, aleatorio/repetición, historial y restauración sin autoplay. Android conserva just_audio/audio_service; Windows usa libmpv. |
| Letras | Incrustadas compatibles y LRC/TXT; sincronización según tiempos disponibles. Letras locales automáticas mediante extensión/caché privada. |
| Descargas | M4A con etiquetas/portada/letras disponibles sin recodificar; álbum completo secuencial. Informe actual de álbum faltante en canciones sueltas reabierto. |
| Extensiones | API 1/2 preservadas; API 3 JS con vistas nativas, HTTP por etapas y audio autorizado. Catálogo externo, permisos y recuperación. |
| YouTube Windows | Reproducción/descarga nativas y confirmación del usuario desde 0.3.10; ya no figura como función sin implementar. |
| Android | Sesión/notificación/controles y widgets; actualizaciones web/Archivos. Instalación universal 0.3.15 informada en A34/Pova 7; no valida otros flujos o esta nueva versión. |
| Cuenta | Sin acceso por sesión ni sincronización bidireccional implementados. Navegación pública y copias importadas sí existen. |

## Pendientes vigentes

- Entrega publicada0.3.16 comprobada: suite163/una omitida, Android universal firmado, Windows normal/ZIP32archivos, metadatos/portada ante503 y capturas Flutter. Resultados y límites en [[45 Portadas artistas navegacion y descargas 0.3.16]]. Publicación verificada en GitHub.
- Prueba física Android: SD/SAF, exportación, widgets/launcher, gestos, controles, ARM64 y escucha prolongada.
- Medir la demora API 3 en Android por etapas y primer audio; caché y diagnóstico local no acreditan mejora física.
- Confirmar con casos del usuario el álbum faltante; cobertura de imágenes/letras no universal.
- Funciones futuras, confianza del SDK, licencia y benchmarks en [[07 Preguntas e investigacion]] y [[05 Rendimiento]].

## Evidencia por versión

[[44 Diagnostico local de instalacion y actualizaciones manuales]] (0.3.15), [[43 Play Protect y firma de Android]] (0.3.14), [[42 Albumes y extensiones con identidad RP 0.3.13]], [[41 Letras dinamicas y reproductor fijo 0.3.12]], [[40 Gestos widgets albumes y descargas 0.3.11]], [[39 Audio Windows M4A OPUS y YouTube]], [[37 Explorador y radio JavaScript]], [[36 Motor JavaScript paralelo]]. Las fases locales y resultados parciales conservados en esas notas no sustituyen su cierre publicado.

Publicación0.3.16 completada; siete adjuntos y catálogo comprobados. [[45 Portadas artistas navegacion y descargas 0.3.16]].
