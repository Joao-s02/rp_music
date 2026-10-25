---
tipo: pruebas-y-correcciones
estado: compilado-y-probado-localmente
actualizado: 2026-10-24
---
# Pruebas reales y correcciones 0.2.1

## Informe del usuario sobre 0.2.0-alpha.1

Equipos: Galaxy A34 5G, Tecno Pova 7 4G, Poco X6 y PC descrita por el usuario como Ryzen 5 5800G, 16 GB DDR4. Windows declarado: Windows 11 Pro 26H2; no se ha verificado esa identificación. Formatos del fallo Windows: MP3 y WAV, biblioteca de ocho canciones. En celulares indica entre uno y dos minutos de carga; no se presupone que todos tuviesen exactamente ocho archivos.

Problemas reportados:

1. Indexación más lenta de lo deseado, incluso en bibliotecas pequeñas.
2. Tras cambiar raíz, las listas conservan el contador anterior pero no muestran esas canciones.
3. No se pueden quitar canciones de listas.
4. No se recuerda la canción al volver a abrir.
5. Windows se cierra al cambiar de canción, tanto desde lista como desde siguiente.
6. Teclado Android provoca aviso de desbordamiento inferior de 9,1 píxeles.

Resultados positivos declarados: fluidez general y cambios de pista Android, extensión de ejemplo Android, búsqueda por título/artista, organización de carpetas y reconocimiento de metadatos. La extensión Windows todavía no fue probada por el usuario. No convertir estos resultados en benchmarks numéricos.

## Cambios de implementación

- Versión local `0.2.1+3`; la release pública anterior no se sustituye ni se publica una nueva sin autorización.
- Escaneo progresivo: descubrir rutas antes de leer etiquetas y publicar lotes de información mientras se completa el catálogo.
- Windows utiliza un worker con mensajes de progreso. Android mantiene SAF y usa dos workers de metadatos; intenta reutilizar información ya indexada por MediaStore cuando el documento autorizado se puede convertir, con fallback al lector nativo. No solicita permisos generales de medios.
- Huellas de tamaño/fecha y marca de metadatos completos permiten reutilizar archivos sin cambios. Registros del alfa sin huellas se vuelven a leer. Archivos con errores de metadatos se reintentan.
- Las acciones durante el escaneo guardan el catálogo confirmado, no el preview incompleto; si falla el escaneo se restaura el catálogo anterior.
- Listas: contador de disponibles separado de ausentes; conservar referencias ausentes permite recuperar canciones al volver a una raíz anterior. Botones para quitar una canción o limpiar explícitamente las no disponibles.
- Sesión en `session.json` separado del catálogo: cola, pista, posición, aleatorio y repetición. Guardado al seleccionar, pausar, pasar a segundo plano y cada cinco segundos mientras se reproduce. Las escrituras al mover la posición se agrupan. Al abrir se restaura pausado, sin autoplay. Un cierre forzado puede perder los últimos segundos desde el último checkpoint.
- Android compacto: ocultar reproductor inferior y navegación mientras el teclado está abierto; filtros horizontales y título limitado a una línea. No se oculta el error simplemente recortando el contenido.
- Windows: sustituido `just_audio_windows 0.2.3` por `just_audio_windows_plus 0.5.5`, fijado a esa versión. Se retiró la definición de compatibilidad de coroutine del backend anterior; el nuevo usa C++20.

## Evidencia y límites

- 18 pruebas unitarias/de widgets aprobadas, con cache/progreso, cambios de raíz, listas, restauración y teclado en 360×640 con escala de texto 1,3.
- Análisis estático de código, pruebas y prueba de integración sin problemas.
- Primera prueba nativa con backend anterior: no reprodujo el cierre con los WAV generados; falló al informar duración cero. No hay un diagnóstico confirmado del crash original ni volcado de la PC del usuario.
- Prueba nativa final con backend nuevo: aprobada, sin errores y duración correcta en WAV silenciosos generados. Incluye 36 selecciones/cambios secuenciales entre selección directa, siguiente y anterior, además de 15 solicitudes rápidas coalescidas por el coordinador. No incluye MP3 reales del usuario.
- No se ha medido aún el tiempo corregido de indexación en los tres celulares; no prometer una reducción concreta.
- El primer build Android en paralelo con integración Windows falló por registro generado de `integration_test` incluido durante compilación normal. Se separan las compilaciones para evitar el conflicto de archivos generados.
- Compilaciones release finales Android y Windows completadas. Paquetes en `dist/0.2.1`: `RP-Music-0.2.1-android.apk` (54 203 412 bytes) y `RP-Music-0.2.1-windows-x64.zip` (12 788 737 bytes), guía, plan de retesteo y SHA-256.
- ZIP verificado con EXE, motor Flutter, DLL del backend nuevo, datos y guías; sin DLL del backend anterior ni plugin de integración. Los datos de usuario siguen en `v2` para conservar los de 0.2.0.
- No se publicaron estos cambios en GitHub ni se modificó la release anterior. No se hicieron nuevas pruebas en celulares físicos.

## Fuentes técnicas

- [Backend Windows y cambios publicados](https://pub.dev/packages/just_audio_windows_plus/changelog).
- [API Android MediaStore](https://developer.android.com/reference/android/provider/MediaStore).

Consultadas el 2026-10-24 y contrastadas con fuentes locales. Las afirmaciones del paquete sobre estabilidad no equivalen a garantías para nuestros formatos/dispositivos.

Relaciones: [[03 Biblioteca y reproduccion]], [[04 Extensiones]], [[05 Rendimiento]], [[07 Preguntas e investigacion]], [[10 Estado del repositorio]], [[11 Reconstruccion - primera base]], [[12 Release 0.2.0-alpha.1]], [[09 Registro de cambios]].

## Publicación solicitada

Después de completar las correcciones, el usuario autorizó publicar la nueva release en GitHub. Se prepara `v0.2.1-alpha.1` como preliminar, sin reemplazar la anterior, con fuentes y seis adjuntos: APK, ZIP completo, guía, plan de pruebas, ejemplo y SHA-256. El contenido binario es el ya compilado/probado; se actualizan las guías empaquetadas con los enlaces de distribución. Registrar la confirmación al finalizar.
