# RP Music 0.3.6 — instalación y uso

Release preliminar: https://github.com/Joao-s02/rp_music/releases/tag/v0.3.6-alpha.1

## Instalar y actualizar

Android universal: RP-Music-0.3.6-android.apk. ARM64: RP-Music-0.3.6-android-arm64.apk para dispositivos compatibles de 64 bits. Instalar encima de la versión anterior, sin desinstalar para conservar datos. Firma actual de desarrollo, compatible con 0.3.5. Windows: extraer RP-Music-0.3.6-windows-x64.zip completo y abrir rp_music.exe junto con DLL y data. No ejecutar desde dentro del ZIP.

Elegir raíz musical y conceder lectura; Actualizar biblioteca incorpora archivos nuevos. Se conserva biblioteca/sesión/configuración y extensiones en soporte privado v2/v3. No borrar esas carpetas. No se migran datos de la antigua alfa 0.1. Base musical sin cuenta/conexión; consultas y actualizaciones son opcionales.

## Letras locales

Al seleccionar una canción se leen las letras incrustadas, sin extensión ni conexión. Abrir Letras desde el reproductor. LRC se sincroniza por línea y permite tocar una línea para avanzar; texto plano se muestra sin sincronización. Se mantiene importar LRC/TXT UTF-8 hasta 256 KiB.

Para buscar las que falten: Extensiones → Explorar repositorio → https://github.com/Joao-s02/rp-music-extensions → Consultar → instalar Letras locales 0.1.0 y aceptar permisos. En Letras de canciones locales elegir ese proveedor si hay conflicto. La consulta comienza al seleccionar una canción sin letras incrustadas/copia privada; no es un escaneo masivo de toda la biblioteca.

Resultados guardados exclusivamente dentro de RP Music, sin modificar archivos musicales locales. Se pueden leer después sin conexión. Ausencia de coincidencias: espera 24 h; error: 5 min. El botón de nube permite reintento manual. Desactivar la extensión impide nuevas consultas y conserva la caché. Los metadatos de la canción se envían al proveedor autorizado al consultar.

## YouTube y nuevas descargas

Actualizar YouTube Android a 0.4.0 desde el catálogo y revisar los dominios/permisos. Requiere app 0.3.5 o posterior. La búsqueda de letras normaliza título/artista, usa búsqueda alternativa y verifica versión/duración. Se prefieren sincronizadas cuando existen.

Descargar desde un resultado con permiso storage.download: se recibe audio (hasta 64 MiB/3 min), se consultan metadatos y se incorporan los datos encontrados, portada y letras al nuevo M4A antes del selector. No se recodifica ni aumenta la calidad del audio. Elegir destino; Actualizar biblioteca si está dentro de la raíz. Las consultas de metadatos añaden tiempo y dependen de la red. No es una descarga en segundo plano.

La información externa puede faltar. Un aviso indica datos parciales o archivo guardado sin etiquetas cuando no es compatible. No se inventan álbumes, fechas ni letras. Guardar canciones locales existentes no forma parte de este proceso. El selector y los archivos personales requieren retesteo en Android físico.

## Extensiones y límites

YouTube Android 0.4.0, Letras locales 0.1.0, Biblioteca viva 0.1.1 y Pulso nocturno 0.1.0 en https://github.com/Joao-s02/rp-music-extensions. No vienen instaladas ni dentro del APK/ZIP ni como adjuntos de esta release. Variantes para apps anteriores conservadas. Spotify cancelado y retirado del catálogo; paquetes históricos conservados. Si ya estaba instalado puede eliminarse desde Extensiones. YouTube Windows continúa como candidato manual con fallos nativos conocidos, fuera del catálogo recomendado.

Android lee documentos mediante copia temporal privada de hasta 256 MiB/30 s, eliminada tras la lectura. SYLT admite marcas en milisegundos sin compresión/cifrado; otras variantes requieren comprobación. Ningún proveedor garantiza letras o edición correctas para toda canción. Windows reproduce música local; no se declara resuelto YouTube Windows.

Distribución oficial exclusivamente por GitHub; Play Store descartada. Código público, licencia concreta pendiente de elección; licencias de terceros conservadas. Ver PRUEBAS-0.3.6.md y CAMBIOS-0.3.6.md. SHA256SUMS.txt cubre todos los demás adjuntos.

## Corrección de M4A fragmentados en 0.3.6

0.3.5 podía desplazar la inicialización de un MP4 fragmentado al final al añadir etiquetas. El resultado conservaba el audio pero algunos lectores no podían abrirlo correctamente. 0.3.6 conserva la inicialización antes de los fragmentos y valida sus posiciones relativas; una variante no soportada conserva el audio original con aviso.

Este arreglo está en la app: las extensiones compatibles siguen siendo YouTube Android 0.4.0 y Letras locales 0.1.0. Actualizar la app no reescribe canciones ya descargadas. Para un archivo afectado, usar una copia reparada o descargarlo de nuevo después de actualizar. No basta cambiar .mp3 por .m4a para reparar su estructura. La herramienta genérica de reparación del código fuente crea una copia nueva y nunca sobrescribe originales.

La validación física Android del arreglo sigue pendiente. No se incluyen canciones del usuario ni archivos musicales privados en estos paquetes.
