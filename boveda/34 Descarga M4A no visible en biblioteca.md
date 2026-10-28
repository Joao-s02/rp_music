---
tipo: investigacion-de-incidencia
estado: correccion-publicada-con-validacion-fisica-pendiente
actualizado: 2026-10-27
---
# Descarga M4A no visible en biblioteca

## Informe del usuario

Tras publicar 0.3.5, el usuario informa que una canción descargada desde la extensión existe y se reproduce en otro reproductor, pero no aparece en RP Music. Esto confirma su observación de descarga/reproducción externa; no identifica todavía la causa ni acredita las etiquetas/selector de todos los archivos.

## Comprobaciones realizadas

- LibraryScanner.kt incluye m4a/mp4 en el filtro Android y enumera la raíz SAF y sus subcarpetas; no busca todo el almacenamiento.
- library_scanner.dart incluye .m4a/.mp4 y conserva un archivo descubierto aunque falle lectura de metadatos. Android también conserva la entrada si falla readTags. Un fallo de etiquetas por sí solo no demuestra por qué desaparecería.
- SourceDownload propone nombre con .m4a para audio MP4. El selector permite elegir destino y no actualiza automáticamente la biblioteca. ExtensionSourceView aconseja actualizar solo en el mensaje predeterminado; el aviso de datos parciales puede sustituir ese recordatorio.
- Sonda sobre el escáner real de escritorio: tag-input.m4a y tag-output.m4a del audio sintético se descubren como M4A y duración 4000 ms; skipped=0. No reproduce el caso Android del usuario ni valida su archivo concreto.

## Confirmación posterior del usuario

El usuario confirma que guardó en la carpeta correcta, pulsó Actualizar biblioteca y volvió a elegir la carpeta; el archivo sigue ausente. Nombre informado: La incondicional.m4a. No repetir ubicación/reescaneo como solución pendiente ni afirmar que se trata de un error de uso.

## Investigación inicial (antes de recibir archivos)

La extensión del nombre informado coincide con el filtro permitido. Se revisó también la lista visible: una extensión propietaria de library puede sustituirla; Biblioteca viva conserva filtros de artista/álbum/carpeta/duración/favoritos. Los filtros pueden ocultar una canción aunque el escáner la haya descubierto; no se ha confirmado que estén activos en este dispositivo. La interfaz permite elegir Biblioteca → Aplicación base independientemente de la fuente YouTube. La búsqueda de texto también limita la lista.

Para distinguir descubrimiento de filtrado, comprobar vista de biblioteca base con búsqueda vacía. Si continúa ausente, inspeccionar el archivo original descargado y/o el resultado del escaneo Android. Falta el archivo concreto: los M4A sintéticos de escritorio no reproducen su caso y no prueban la enumeración SAF del dispositivo. No se identifica todavía una causa raíz ni se anuncia corrección.

Sin cambios de código, compilación nueva, commit, push o publicación. Estado funcional y antecedente de descargas en [[33 Metadatos de descargas YouTube]], alcance de biblioteca en [[03 Biblioteca y reproduccion]].

## Archivos aportados y diagnóstico comprobado

El usuario envía Ven y besame.m4a y La incondicional.mp3, tras pasar por Drive. La captura muestra ambos nombres terminados en .m4a antes de descargarlos. No se ha comprobado el mecanismo de renombrado de Drive ni se atribuye una conversión de audio a ese servicio.

Inspección por contenido: Ven y besame es MP4/M4A AAC válido (3332068 bytes, 205.714263 s). La incondicional tiene firma ftyp/dash, no audio MP3, pese al sufijo .mp3 (4249722 bytes). ffprobe falla con trun track id unknown, no tfhd was found / error reading header. Presenta ftyp, free de 644 bytes en el lugar de la inicialización anterior, sidx, 26 pares moof/mdat y moov al final (87030 bytes). Coincide con el diseño de DownloadTags de 0.3.5: sustituía moov por free y lo añadía al final para mantener offsets. Esa técnica funciona para el MP4 plano ensayado pero rompe inicialización de este MP4 fragmentado.

Se confirma fallo propio de etiquetado y un archivo incompatible como consecuencia; no se ha observado directamente cómo lo omite la biblioteca Android del usuario. La hipótesis de filtros no se convierte en causa. Las pruebas sintéticas anteriores eran MP4 plano y no cubrían fragmentación real.

## Corrección local 0.3.6+15

DownloadTags distingue archivos con moof. En fragmentados mantiene moov antes de sidx/moof y valida direccionamiento relativo: tfhd default-base-is-moof sin base absoluta y primer trun con data-offset-present. Conserva bytes de los fragmentos e índices relativos; rechaza desplazamientos absolutos/tablas no vacías/índices aleatorios no soportados para que el flujo guarde original con aviso. La ruta de MP4 plano conserva su comportamiento previo. No requiere cambios de proveedor en rp-music-extensions.

Herramienta genérica repair_fragmented_m4a reconstruye solo una copia nueva, conserva etiquetas y nunca sobreescribe entrada/salida existente. Copia para el usuario en dist/repair-m4a, excluida de Git. No se incorpora música ni letras del usuario como fixtures ni a publicaciones.

## Verificaciones

- Copia reparada del archivo real: ffprobe reconoce AAC y portada MJPEG, duración 257.026667 s; decodificación completa ffmpeg sin error. Mismo tamaño de archivo; 26 bloques mdat, 26 moof y un sidx idénticos por SHA-256, sin recodificar.
- Escáner real de escritorio: descubre la copia como M4A con título La incondicional, duración 257026 ms y skipped=0.
- Fuente original SHA-256 1dcf3359c21fb561c05a206889b5d92120304abe4a378e6173b2bc3385658e03. Copia reparada SHA-256 4d4ac53f7f3d102dd8f899e2d00d3c2d3757693bc647553819119135ea765ffd. Originales no modificados.
- M4A fragmentado sintético de 4 s generado sin música privada, etiquetado con la corrección: ffprobe reconoce etiquetas/letras y 4.023220 s; decodificación ffmpeg correcta. El lector de metadatos actual devuelve duración 0 para ese caso sintético, límite separado que no impide descubrirlo.
- Suite completa: 110 aprobadas y una prueba de red optativa omitida, no ejecutada nuevamente. Cuatro regresiones nuevas: inicialización previa, reparación del diseño 0.3.5, rechazo de offsets absolutos y rechazo de índice aleatorio no soportado. Análisis de código/herramienta/pruebas sin incidencias.

Documentación primaria contrastada el 2026-10-27: https://w3c.github.io/mse-byte-stream-format-isobmff/ (inicialización y direccionamiento relativo) y https://ffmpeg.org/ffmpeg-formats.html (default_base_moof/skip_trailer para fixture sintético).

Compilación Android local en curso; no nueva publicación ni autorización implícita para publicarla. Falta probar copia reparada y app corregida en Android del usuario. La versión pública 0.3.5 conserva el fallo para nuevas descargas fragmentadas; copia reparada no equivale a actualizar la app instalada.

Cierre de compilación local: APK normal universal 0.3.6+15 compilado en release (160.1 s), copia en dist/0.3.6-local/RP-Music-0.3.6-local-android.apk. No se genera una release pública ni se modifica la 0.3.5 publicada. Se entrega APK local y canción reparada para comprobar en Android; no hay prueba física de esta corrección. Originales conservados y archivos musicales fuera de Git.

## Publicación autorizada — 2026-10-27

El usuario aclara que pide una nueva release con las versiones corregidas. Se prepara v0.3.6-alpha.1 / app 0.3.6+15, con universal, ARM64, Windows, guías y hashes. El intento de petición de issue se corrigió antes de actuar; no se crea issue. Extensiones sin cambios: el arreglo está en la app. No se distribuyen la canción reparada ni archivos privados. Confirmación de borrador y API pública pendiente hasta terminar.

Preparación de publicación: ARM64 normal release aprobado (129.7 s), código 15/versionName 0.3.6, solo arm64-v8a; universal contiene arm64-v8a/armeabi-v7a/x86_64. Ambas firmas v2 válidas con certificado compatible con 0.3.5. Windows normal release 0.3.6+15 compilado (114.1 s), ProductVersion comprobado tras terminar. Se prepara ZIP completo con guías vigentes, sin entrada de integración ni música/extensiones. Documentos en docs/USO-0.3.6.md, PRUEBAS/CAMBIOS/RELEASE-0.3.6.md; siete adjuntos y hashes en dist/0.3.6-release. Confirmación pública aún pendiente en esta fase.

## Publicación confirmada — v0.3.6-alpha.1

2026-10-27: release preliminar pública https://github.com/Joao-s02/rp_music/releases/tag/v0.3.6-alpha.1. App 0.3.6+15, tag/código d0d894257e52f89f3c6edc80359bc737bf9bbf51, release ID 426240606. Siete adjuntos definitivos: universal, ARM64, Windows, USO, PRUEBAS, CAMBIOS y hashes.

Borrador autenticado verificado antes de publicar por tamaños/digests SHA-256 y target_commitish. Después, API pública sin autenticación confirmó prerelease visible, siete adjuntos con mismos tamaños/hashes, tag al commit esperado y SHA256SUMS descargado idéntico al local. Commits documentales posteriores confirman publicación y no cambian binarios del tag.

No se incluyen música privada ni la copia reparada en Git/release. Extensiones compatibles sin cambios. La publicación no acredita prueba física Android ni reparación automática de archivos anteriores; no se modificaron adjuntos de 0.3.5.
