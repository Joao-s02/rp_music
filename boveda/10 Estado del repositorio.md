---
tipo: estado-actual
estado: publicado-con-pendientes-fisicos
actualizado: 2026-10-26
---
# Estado del repositorio

## Referencia publicada

**0.3.3-alpha.1**, aplicación **0.3.3+12**, Android universal/ARM64 y Windows x64. [Release pública](https://github.com/Joao-s02/rp_music/releases/tag/v0.3.3-alpha.1).

- Tag/código: `610784501ca54409a8857e2d25785dad69164249`.
- Extensiones con esta entrega: commit `641d970b1501ce64eccf601e664a18135a2846be` de rp-music-extensions.
- Commits posteriores registran confirmaciones documentales; no cambian binarios del tag.
- Siete adjuntos verificados públicamente por tamaño/SHA-256: dos APK, ZIP Windows, USO, PRUEBAS, CAMBIOS y SHA256SUMS.

Evidencia, hashes y etapas: [[29 Pruebas 0.3.2 y mejoras 0.3.3]]. Los antiguos estados acumulativos se conservaron en [[30 Archivo de navegacion y estado]].

## Capacidades actuales

| Área | Estado |
| --- | --- |
| Biblioteca local | Raíz/subcarpetas, caché, escaneo manual/progresivo, búsqueda, álbumes/artistas/carpetas y orden. |
| Audio | Cola de selección, controles, volumen, aleatorio/repetición, historial anterior/avance local y restauración sin autoplay. |
| Listas | Manuales, favoritos, carátula propia/mosaico, añadir álbum a existentes/crear; automáticas mediante extensión. |
| Archivos | Borrado confirmado con escritura cuando corresponde. Lectura de metadatos; no editor de etiquetas. |
| Interfaz | Marca A, Inter/Plus Jakarta Sans, temas, navegación adaptable, álbum y reproductor renovados sin ecualizador. |
| Android | Sesión/notificación, carátula/controles, permisos y widget. Límites físicos según cada versión. |
| Windows | Audio local, volumen y bandeja/salida configurables. Fuente inicial no habilitada allí; no dar controles del sistema por validados por la bandeja. |
| Actualizaciones | Consulta opcional/manual o diaria y canales, descarga/verificación; Android solicita instalador y Windows extrae ZIP manualmente. |
| Extensiones | API 1 y API 2 experimental, permisos, propietarios, recuperación, catálogo/compatibilidad y HTTP/UI/navegación acotados. |

Comportamiento en [[03 Biblioteca y reproduccion]], contratos/paquetes en [[04 Extensiones]], módulos en [[31 Arquitectura vigente]].

## Extensiones para esta app

Fuente 0.2.1 (Android), Biblioteca viva 0.1.1 y Pulso nocturno 0.1.0. Exclusivamente en [rp-music-extensions](https://github.com/Joao-s02/rp-music-extensions); ninguna viene instalada ni adjunta a la release. Catálogo con variantes anteriores. Material heredado de biblioteca/reproductor en ejemplos/pruebas del principal pendiente de migración; no desarrollar nuevas extensiones aquí.

## Verificación registrada de 0.3.3

| Comprobación | Resultado y alcance |
| --- | --- |
| Suite completa inicial | 86 pruebas aprobadas. |
| 11 casos finales seleccionados | Aprobados; incluyen una regresión nueva de filtro guardado y casos ya contados. No son 97 casos distintos ni una suite completa nueva de ese tamaño. |
| Análisis final | Sin incidencias. |
| Audio Android | Búsqueda, dos canciones, pausa/seek, anterior/avance y revocación en emulador API 37, en primer plano. Primer intento con espera fija fallido conservado en la nota de versión. |
| Instaladores normales | Universal instalado/abierto; APK con versión/ABI/firma verificados. Windows compilado y arranque de prueba; ZIP íntegro con dependencias. |
| Publicación | Tag, acceso público, siete archivos/hashes y paquetes externos remotos confirmados. |

El usuario validó rapidez/segundo plano de fuentes en versiones anteriores. No convertirlo en prueba física de 0.3.3 ni el ensayo de primer plano en uno nuevo de pantalla apagada.

## Pendientes activos

Retesteo físico/escucha larga, actualización entre releases con datos conservados, validación amplia de formatos/redes/SAF/SD/launcher y Windows. Fuente Windows/cuentas/listas/favoritos/historial online; letras/edición de etiquetas/gapless/fundido/cola editable; ecualizador como extensión; aislamiento/métricas/firmas del SDK y licencia del proyecto. Investigaciones en [[07 Preguntas e investigacion]].

## Mantenimiento

Bóveda: decisiones/evidencia. Código: implementación observada. README y docs: guías de entrada. dist: copias locales de pruebas/distribución, no versiones actuales adicionales. No publicar cambios documentales ni nuevos binarios sin autorización correspondiente.

Actualizar este resumen y la nota temática tras entregas. Dejar preparación, commits y pruebas detalladas en la nota de versión y [[09 Registro de cambios]], sin volver a acumular estados contradictorios aquí.


## Mantenimiento documental posterior a la release

Consolidación local del 2026-10-26 solicitada por el usuario: índice y contexto depurados, decisiones actuales separadas de historia, documentación técnica consolidada en [[31 Arquitectura vigente]] y antecedentes de esta nota preservados en [[30 Archivo de navegacion y estado]]. Solo Markdown; sin cambios de código/binarios, nueva versión ni nueva verificación funcional. La publicación registrada sigue siendo 0.3.3; esta limpieza documental todavía no se ha enviado a GitHub. Registro del trabajo en [[09 Registro de cambios]].

## Preparación local 0.3.4 — 2026-10-27

Código local 0.3.4+13 en desarrollo a partir del test 0.3.3: reproductor con controles fijos, letras LRC/TXT/consulta opcional por extensión, exportación de audio con permiso y fuentes externas separadas. Spotify limitado a vistas previas por enlace público. Evidencia, fallos corregidos y pendientes en [[32 Pruebas 0.3.3 y mejoras 0.3.4]]. No publicado; referencia pública sigue siendo 0.3.3.

Verificación final de preparación 0.3.4: 97 pruebas aprobadas, análisis sin incidencias y compilación normal Windows release 0.3.4+13. Fuente Windows continúa fallando en ensayo nativo; Spotify solo vista previa por enlace. Exportación mediante selector/Android y APK nuevos pendientes. Esta evidencia no cambia la referencia publicada 0.3.3.
