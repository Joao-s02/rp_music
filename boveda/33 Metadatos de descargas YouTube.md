---
tipo: requisitos-implementacion-y-verificacion
estado: publicado-con-limites-experimentales
actualizado: 2026-10-27
---
# Metadatos de descargas YouTube

## Decisiones confirmadas

- Distribución oficial de RP Music solo en GitHub; Play Store cancelada. Licencia concreta aún sin elegir. [[02 Vision y decisiones]].
- Spotify cancelado tras comprobar fragmentos de unos 30 segundos. No continuar audio completo/búsqueda. Se conserva su historia y paquetes publicados; la retirada del catálogo es local hasta que se autorice publicar.
- Usuario confirma reproducción satisfactoria YouTube Android.
- Base: reconocer letras ya incrustadas en canciones locales sin red ni extensión, manteniendo importación LRC/TXT.
- Nuevas descargas YouTube: completar metadatos y portada automáticamente e incrustar letras disponibles. Sin editar masivamente etiquetas de archivos existentes.
- Extensión separada para buscar automáticamente letras faltantes de canciones locales. Usuario confirma guardar resultados exclusivamente dentro de la app, sin modificar música.
- Corregir buscador de letras YouTube: falló en todos los temas inicialmente probados por el usuario. Casos aportados: Las Noches / Junior H, BAILE INoLVIDABLE / Bad Bunny y La Incondicional / Luis Miguel.

## Antecedente y causa observada

En 0.3.4 SourceDownload guardaba bytes sin escribir etiquetas ni portada. LyricsView solo leía su copia privada, nunca las etiquetas del audio. El paquete YouTube consultaba una coincidencia exacta LRCLIB con título/artista sin normalizar; concatenaba información de columnas en el artista y terminaba ante ausencia de resultados. No se atribuye toda ausencia al servicio ni se promete cobertura universal.

## Implementación local 0.3.5+14

### Base y caché

MusicFiles/EmbeddedLyrics leen letras mediante el lector existente en un isolate. MP3 USLT, FLAC/Vorbis, Ogg/Opus y M4A usan capacidades de la dependencia, con cobertura por formato que debe comprobarse. Se añade SYLT ID3v2.3/v2.4 con marcas en milisegundos; formatos temporales MPEG y SYLT comprimido/cifrado no se declaran soportados.

Android abre el documento SAF solo para lectura y crea una copia temporal privada acotada a 256 MiB/30 s; se elimina tras leer. Las copias interrumpidas se limpian después de una hora al iniciar otra lectura. No se solicita escritura sobre música. Límite de texto: 256 KiB. En Windows se lee la ruta directamente sin copia completa.

LyricsController sigue la canción seleccionada: incrustadas, copia privada y búsqueda mediante proveedor autorizado. La búsqueda automática se inicia al seleccionar/reproducir, incluso sin abrir Letras; no es un barrido masivo de toda la biblioteca. Copias por ID y huella tamaño/modificación para resultados online; importación manual conservada. Ausencia de coincidencias: caché 24 h; error: pausa 5 min; botón de nube permite reintento explícito. Memoria acotada a 64 letras y 256 comprobaciones. Resultados tardíos tras revocación/cambio de proveedor se descartan; una importación manual no debe ser sustituida por búsqueda pendiente.

### Contratos genéricos del anfitrión

Capacidad lyrics y permiso lyrics.cache con library.read/network.http y dominios/plataformas declarados. Proveedor elegido separado de source, sin apropiarse del audio. Solo recibe metadatos necesarios de la canción; no rutas de archivo ni permisos para modificar originales. source/metadata permite hasta ocho etapas; conserva resultados parciales ante fallo de red y reintenta una vez HTTP 429/503. source/lyrics conserva cuatro etapas. Espera declarada por petición hasta 2 s permite respetar límites de proveedor. Dominios máximos: doce.

DownloadEnrichment toma datos del paquete y obtiene portada JPEG/PNG con máximo 5 MiB, 25 s y tres redirecciones, validando cada destino contra dominios consentidos. DownloadTags añade etiquetas MP4/M4A (título, artista, álbum, artista de álbum, fecha, pista/disco, género y letras cuando disponibles). Conserva los bytes de audio y sus posiciones; no recodifica. Si no se puede etiquetar, guarda audio original con aviso. No promete convertir WebM/otros formatos ni aumentar calidad. Selector conserva elección manual del destino.

### Repositorio de extensiones

Checkout independiente existente: dist/extensions-repository, ignorado por Git del principal y con remoto rp-music-extensions. Toda lógica/proveedor, pruebas y paquetes particulares se mantienen en ese repositorio; no son assets de producción.

Candidatos locales: YouTube Android 0.4.0 y Letras locales 0.1.0, minAppVersion 0.3.5. Fuente compartida normaliza título/canal, busca por campos y alternativa textual en LRCLIB, valida título/artista/duración/tipo de versión y prefiere sincronizadas. Para descargas consulta MusicBrainz, elige una edición oficial coherente, obtiene fecha/pista/disco/créditos y solicita portada Cover Art Archive. Campos ausentes quedan ausentes, con aviso de datos parciales. Complemento local solo busca letras. No usa Spotify ni requiere cuenta personal de esos servicios.

Catálogo local conserva variantes anteriores y omite Spotify; no se ha cambiado catálogo remoto ni borrado paquetes históricos. Constructor de candidatos y regenerador del catálogo preservan esta decisión.

## Evidencia obtenida

- Pruebas nuevas de etiquetas, SYLT, prioridad de incrustadas, persistencia privada, caché negativa y revocación aprobadas en la suite; nuevas regresiones de inicio automático e importación manual añadidas para cierre final.
- Suite completa intermedia: 103 aprobadas. Primera ejecución falló en cuatro pruebas del actualizador porque la versión futura simulada coincidía con 0.3.5; se movió el fixture a 9.0.0, sin modificar el comportamiento del actualizador. Repetición completa aprobada.
- Intérprete real: cinco comprobaciones iniciales de paquetes, normalización, alternativa y rechazo de artista/versión/duración incorrectos aprobadas. Se corrigieron incompatibilidades de dart_eval con aritmética/nullable/promociones observadas al ejecutar, no solo al analizar.
- Consulta real: letras encontradas para los tres casos del usuario. Las Noches y BAILE INoLVIDABLE obtuvieron también una edición con campos de álbum y URL de portada; La Incondicional obtuvo letra/datos básicos, con ampliación de selección de ediciones posterior. MusicBrainz devolvió intermitentemente 503 y un timeout; no se presenta como disponibilidad garantizada.
- Audio sintético de 4 s etiquetado: lector de la app y ffprobe reconocen etiquetas/letras; duración 4 s y decodificación ffmpeg aprobadas. Prueba nativa Windows aprobada: lectura de letra y reproducción con avance, conservando hash del original.

## Fuentes consultadas — 2026-10-27

- https://lrclib.net/docs — búsqueda por campos/texto; comportamiento contrastado con respuestas reales.
- https://musicbrainz.org/doc/MusicBrainz_API y https://musicbrainz.org/doc/MusicBrainz_API/Search — grabaciones/ediciones y créditos.
- https://musicbrainz.org/doc/MusicBrainz_API/Rate_Limiting — identificación del cliente y espera entre consultas.
- https://musicbrainz.org/doc/Cover_Art_Archive/API — portada de edición, con redirecciones sujetas a dominios.
- https://acoustid.org/webservice — huella acústica investigada inicialmente; NO incorporada, ni necesaria para el primer flujo.

## Límites y cierre pendiente

Validación física con los archivos incrustados del usuario y selector SAF todavía pendiente; adb no detectó dispositivo. No se afirma compatibilidad con todas las variantes de etiquetas, regiones o canciones. Música local no modificada. No commit, push ni publicación autorizados en este trabajo. [[03 Biblioteca y reproduccion]], [[04 Extensiones]], [[10 Estado del repositorio]], [[31 Arquitectura vigente]].

## Verificación posterior del flujo completo

Los tres casos del usuario pasaron también usando los resultados reales de búsqueda YouTube y sus duraciones: LAS NOCHES/Junior H 227 s, BAILE INoLVIDABLE/Bad Bunny 368 s y La Incondicional/Luis Miguel 258 s. Los tres obtuvieron letras sincronizadas (1180, 2852 y 1753 caracteres antes del trim). No se guardó su contenido como fixture en el repositorio.

Prueba optativa download_metadata_live_test con paquete externo real y audio sintético: encontró letras (1179 caracteres tras trim), portada JPEG de 72531 bytes y álbum de la edición para Las Noches, sin aviso de datos parciales. La copia final contiene letras/portada y conserva duración de 4 s; original con hash idéntico. El texto musical y la copia se mantuvieron en directorio temporal eliminado al terminar.

Esa prueba detectó un fallo real que las comprobaciones del escritor aislado no mostraban: la clausura enviada al isolate capturaba el registro de extensiones, impidiendo etiquetar. Se separó el ámbito para transferir únicamente bytes/datos y se añadió regresión offline con registro deliberadamente no transferible. Se conserva el primer fallo como evidencia; el flujo completo posterior pasó. No atribuir este recorrido HTTP a escucha física de música ni a selector Android.

## Cierre local

Suite final: **106 aprobadas**, una prueba de red optativa omitida por defecto y ejecutada aparte con resultado aprobado. No se suman repeticiones como casos nuevos. Análisis final de lib/test/integration_test/tools: **sin incidencias**. Enlaces Obsidian y diff --check de ambos repositorios correctos. Capturas históricas restauradas tras la última suite, sin cambios gráficos ajenos pendientes por estas pruebas.

Compilaciones finales de entrada normal tras la corrección del isolate: Android universal release aprobado (118.1 s), Windows x64 release aprobado (90.1 s), versión **0.3.5+14**. APK: código 14, ABIs arm64-v8a/armeabi-v7a/x86_64, firma v2 válida y certificado compatible con 0.3.4 (eba2769ed11d359c8f89f6991bc6867c7766f6f46a4295bc5386e7d41ce7d38d). No hay dispositivo Android conectado; compilar no equivale a instalar/probar físicamente. Registros de plugins normales sin integration_test.

Archivos locales en dist/0.3.5-local: APK universal, ZIP Windows completo con guía y SHA256SUMS. Extensiones únicamente en previews/0.3.5 del checkout independiente rp-music-extensions. No se añadieron paquetes al APK/ZIP. No se generó nueva variante ARM64 separada ni se presenta como publicación completa. Referencia pública sigue siendo 0.3.4; instalación/importación y pruebas físicas quedan pendientes.

## Publicación autorizada — 2026-10-27

El usuario pide publicar la nueva release. Esta autorización sustituye el límite local de las fases anteriores. Se prepara v0.3.5-alpha.1 / app 0.3.5+14: universal, ARM64, Windows, USO, PRUEBAS, CAMBIOS y SHA256SUMS. ARM64 normal compilado (155.5 s), código 14, versión 0.3.5, solo arm64-v8a, firma v2 y certificado compatible comprobados. Universal conserva los bytes verificados del cierre local. ZIP Windows normal reempaquetado con tres guías vigentes: 22 archivos íntegros, sin paquetes de extensión ni sonda. Candidatos/catálogo se publican solo en rp-music-extensions; Spotify fuera del catálogo, variantes anteriores conservadas.

Siete adjuntos preparados en dist/0.3.5-release; hashes calculados tras cerrar guías. Borrador y publicación se confirmarán por API y comparación de tamaños/SHA-256 antes de declarar disponible. Sin cambios de código funcional posteriores a las 106 pruebas/análisis y verificaciones del cierre local. La autorización de publicar no convierte el selector/archivos personales ni Android físico en pruebas realizadas.

### Adjuntos definitivos

| Archivo | Bytes | SHA-256 |
| --- | ---: | --- |
| CAMBIOS-0.3.5.md | 2367 | c908a9d66d7246ee4f0df8ee07c033dcffd6eb4d8220511a40a5026034e6cc37 |
| PRUEBAS-0.3.5.md | 3822 | 5f9575ae6a7d27c2c9c64fb6f805f863336895d4d389d96d8476cb8ad6353693 |
| RP-Music-0.3.5-android-arm64.apk | 25149041 | 41151fa73de35db8ac46c38d17b5adda001235db3d4aa6349de900779b73ae36 |
| RP-Music-0.3.5-android.apk | 68920356 | eb7b3eba376bf53c60773d69f46d0557dbc7827494137e81fa02e7d3ed842b6c |
| RP-Music-0.3.5-windows-x64.zip | 15601180 | 671621dc5d98307a88b38df2c23dab55566e276d9a3effd7fbbdc2a848797eba |
| SHA256SUMS.txt | 534 | b719bccd3e8380d2515f76b63d84192a17b4866fe26617e48a817774a0cbb1be |
| USO.md | 4172 | d02c57bd5d04a7c1fd4d43b38b8dcf61bde2b43da749dbf19cb3736e9164f62e |

Extensiones publicadas antes de la app: commit d0a007ef5bbc4f8fb22ed340c57fa7ddab2f5ee4 en rp-music-extensions. Consulta real del catálogo público desde ProgramCatalog 0.3.5 verificó SHA-256/metadatos de Biblioteca viva 0.1.1, Pulso nocturno 0.1.0, YouTube Android 0.4.0 y Letras locales 0.1.0. Spotify no está en el catálogo, paquetes históricos intactos. La app se prepara como borrador a continuación; no confundir esta publicación de extensiones con la release de la app.

## Publicación confirmada — v0.3.5-alpha.1

2026-10-27: publicada como prerelease en https://github.com/Joao-s02/rp_music/releases/tag/v0.3.5-alpha.1. Release ID 425965469, app 0.3.5+14, tag/código a7c9e11bcaf90c2fe0868d395a2d3d132169d4bf. Extensiones publicadas exclusivamente en rp-music-extensions (código d0a007ef5bbc4f8fb22ed340c57fa7ddab2f5ee4).

Antes de publicar: borrador autenticado con siete adjuntos uploaded y tamaños/digests SHA-256 iguales a los locales; target_commitish exacto. Después: API pública sin autenticación confirma prerelease visible con los siete adjuntos; tag apunta al código esperado y SHA256SUMS descargado públicamente coincide byte a byte. Archivos definitivos son los de la tabla anterior. Commits documentales posteriores confirman la publicación y no cambian los binarios del tag.

No cambian los límites al publicar: sin prueba física Android con archivos/selector del usuario ni garantía de letras/metadatos completos o estabilidad de servicios; YouTube Windows conserva fallos conocidos. Ya no es entrega solo local. README, entrada de documentación y estado vigente actualizados, conservando fases históricas.
