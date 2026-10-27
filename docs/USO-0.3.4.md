# RP Music 0.3.4 — instalación y uso

Release experimental: https://github.com/Joao-s02/rp_music/releases/tag/v0.3.4-alpha.1

## Instalar y actualizar

Android universal: RP-Music-0.3.4-android.apk. ARM64: RP-Music-0.3.4-android-arm64.apk para dispositivos de 64 bits compatibles. Instalar encima de la anterior con la misma firma; no desinstalar para conservar datos. Firma actual de desarrollo. Windows: extraer RP-Music-0.3.4-windows-x64.zip completo y abrir rp_music.exe junto con DLL y data. No ejecutar desde dentro del ZIP.

Seleccionar raíz musical, conceder los permisos necesarios y usar Actualizar biblioteca para nuevos archivos. Biblioteca/sesión y programas se guardan en soporte privado de app (v2/v3); no borrar esas carpetas. Letras importadas/consultadas se guardan en lyrics, sin alterar el audio. No se migran datos de la antigua alfa 0.1.

## Reproductor y letras

Abrir la carátula/título del control pequeño. Los controles principales permanecen visibles. Letras → Importar permite LRC sincronizado o TXT, en UTF-8, hasta 256 KiB. Tocar una línea LRC salta al tiempo indicado. En fuentes compatibles, el botón de nube consulta letras enviando los metadatos al proveedor de la extensión. No todas las canciones o grabaciones tienen letra compatible.

## Extensiones y descargas

Extensiones → Explorar repositorio → https://github.com/Joao-s02/rp-music-extensions → Consultar → descargar/actualizar → revisar permisos. No vienen instaladas ni dentro de estos paquetes. Con varias fuentes, Usar esta fuente elige cuál reproduce.

YouTube Android 0.3.0 añade letras y descarga manual. Aceptar storage.download si se desea exportar; pulsar Descargar junto al resultado, esperar recepción y elegir destino. Máximo 64 MiB/3 minutos; no es descarga en segundo plano ni conversión de formatos. Actualizar biblioteca si se guardó en su raíz. La exportación con selector requiere retesteo en dispositivo.

Spotify · vistas previas 0.1.0 sirve para enlaces públicos de canción y solo fragmentos disponibles sin cuenta. No busca por nombre ni reproduce canciones completas. Letras sin sincronizar con el fragmento. YouTube Windows es candidato manual con fallos nativos conocidos y no figura en el catálogo recomendado.

Ver CAMBIOS-0.3.4.md para límites y PRUEBAS-0.3.4.md para pasos pendientes. Los hashes de los adjuntos están en SHA256SUMS.txt.
