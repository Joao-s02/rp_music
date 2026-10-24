# RP Music — guía de uso

Versión preliminar **0.2.0-alpha.1** para Android y Windows. Reproductor de música local, sin cuenta ni conexión a internet obligatoria. Todavía no es una versión estable.

## Qué descargar

- **Android:** `RP-Music-0.2.0-alpha.1-android.apk`.
- **Windows x64:** `RP-Music-0.2.0-alpha.1-windows-x64.zip`.
- **Ejemplo de personalización:** `descubrir.json`, también incluido dentro del ZIP de Windows.

Los archivos están en los adjuntos de la [release de GitHub](https://github.com/Joao-s02/rp_music/releases/tag/v0.2.0-alpha.1). Los archivos automáticos «Source code» son para desarrollar; no son instaladores.

## Instalar en Android

1. Descargar el APK en el dispositivo y abrirlo.
2. Si Android lo solicita, permitir que el navegador o gestor de archivos instale esta aplicación.
3. Abrir **RP Music** y pulsar **Seleccionar mi música**.
4. Elegir una carpeta del dispositivo y confirmar el permiso de acceso en el selector de Android.
5. Esperar a que termine la lectura inicial. Se incluyen sus subcarpetas.

El APK está compilado en modo release, pero esta alfa utiliza una firma de desarrollo. No se ha preparado todavía una clave de distribución estable ni publicación en Play Store.

Android puede limitar qué carpetas permite elegir. Selecciona una carpeta de música accesible mediante su selector; no se requiere conceder acceso general a todos los archivos.

## Abrir en Windows

1. Descargar el ZIP y elegir **Extraer todo**.
2. Abrir la carpeta extraída y ejecutar **rp_music.exe**.
3. Mantener el ejecutable junto a los DLL y la carpeta `data` incluidos. No mover solamente el EXE.
4. Pulsar **Elegir carpeta** y seleccionar la carpeta raíz de tu música.

Es una aplicación portable para Windows x64: no incluye un instalador. Si Windows solicita componentes de Visual C++, instalar el redistribuible oficial x64 de Microsoft. No se ha validado todavía en una instalación limpia de Windows.

## Tu biblioteca

- Solo se utiliza **una carpeta raíz** a la vez; sus subcarpetas conservan la organización que les diste.
- Cambia entre **Canciones**, **Álbumes**, **Artistas** y **Carpetas**.
- Usa **Buscar en tu música** para filtrar el catálogo local.
- Pulsa una canción para reproducirla. La cola se forma con la lista desde la que la seleccionaste.
- Usa los controles inferiores para pausar, avanzar, retroceder o mover la posición. También puedes activar aleatorio y repetición de una canción.
- El botón de cola permite ver y seleccionar canciones de la cola actual.
- El corazón agrega o quita un favorito.
- En **Listas**, crea una lista. Después usa el menú de una canción en la biblioteca para añadirla.
- En **Ajustes**, cambia entre tema oscuro y claro o elige otra carpeta.

Al añadir, eliminar o cambiar archivos dentro de tu carpeta, pulsa **Actualizar biblioteca**. En este incremento el escaneo es manual. La biblioteca guardada se muestra al volver a abrir sin esperar un escaneo nuevo. Si falla el acceso a una nueva carpeta, se conserva el catálogo anterior.

Se reconocen archivos MP3, FLAC, M4A, MP4, WAV y OPUS. La reproducción real depende del códec y de las capacidades del sistema. MP4 se utiliza como audio, no como vídeo. Los metadatos se leen para organizar la biblioteca; los archivos musicales no se modifican.

## Instalar la personalización de ejemplo

1. Descargar `descubrir.json` de los adjuntos; en Windows también está dentro del ZIP.
2. Ir a **Extensiones** → **Importar extensión** y elegir ese archivo.
3. Pulsar **Descubrir mi música** para activarla.
4. Volver a **Biblioteca**: aparecen tarjetas, un acento lavanda y **Sorpréndeme**, que elige una canción al azar entre los resultados actuales.
5. Para volver al aspecto original, seleccionar **Interfaz base**. El botón de papelera desinstala el manifiesto.

La elección queda guardada. Reimportar un archivo con el mismo identificador reemplaza explícitamente la versión instalada. No hay actualizaciones automáticas. Para esta prueba no hace falta reiniciar.

Esta extensión es un manifiesto declarativo: utiliza presentaciones y acciones ya incluidas en la app. **Todavía no ejecuta código de terceros ni permite programar pantallas arbitrarias.** No incluye acceso a Spotify, YouTube Music o un ecualizador.

## Datos y límites de esta versión

El catálogo, favoritos, listas, tema y selección de extensión se guardan en el soporte local de la aplicación, en una subcarpeta `v2`, con respaldo del guardado anterior. No se migran datos de la antigua alfa. Desinstalar o borrar los datos de la app puede eliminar esas preferencias.

Pendientes: letras, edición de etiquetas, restauración de cola y posición, edición de cola, bandeja y controles multimedia del sistema Windows, fundidos, gapless, carátulas en toda la biblioteca, métricas y runtime programable de extensiones. Cerrar la ventana de Windows actualmente termina la aplicación.

La integración multimedia Android está compilada, pero reproducción física, segundo plano y pantalla de bloqueo aún necesitan pruebas en dispositivos. No se han medido todavía RAM, batería o latencias. Se aprobaron 13 pruebas automatizadas y el análisis estático; eso no garantiza compatibilidad con todos los dispositivos o formatos.

## Reportar un problema

Crear un [issue en GitHub](https://github.com/Joao-s02/rp_music/issues) con versión de la app, sistema/dispositivo, pasos para reproducir, resultado esperado y resultado observado. Si es un fallo de audio, indicar formato y códec si se conocen. Evitar compartir credenciales o archivos musicales privados.
