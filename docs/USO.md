# RP Music — guía de uso

Versión preliminar de correcciones **0.2.2-alpha.1** para Android y Windows. Reproductor de música local, sin cuenta ni conexión a internet obligatoria. Todavía no es una versión estable. Véase también [qué volver a probar](PRUEBAS-0.2.2.md).

## Qué descargar

- **Android:** `RP-Music-0.2.2-android.apk`.
- **Windows x64:** `RP-Music-0.2.2-windows-x64.zip`.
- **Ejemplo de personalización:** `descubrir.json`, también incluido dentro del ZIP de Windows.

Los paquetes corregidos se distribuyen mediante la [release 0.2.2-alpha.1 de GitHub](https://github.com/Joao-s02/rp_music/releases/tag/v0.2.2-alpha.1). Los archivos automáticos «Source code» son para desarrollar; no son instaladores. La copia local de los adjuntos se prepara en `dist/0.2.2`.

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
- Dentro de una lista, **Quitar de la lista** retira esa entrada sin borrar el archivo. Los contadores distinguen disponibles y ausentes; **Quitar** permite limpiar las referencias no disponibles. Si las conservas, reaparecen al volver a la carpeta que las contiene.
- En **Ajustes**, cambia entre tema oscuro y claro o elige otra carpeta.

Al añadir, eliminar o cambiar archivos dentro de tu carpeta, pulsa **Actualizar biblioteca**. El escaneo es manual y progresivo: primero aparecen los archivos y después se completa su información. Las actualizaciones reutilizan archivos sin cambios. La biblioteca guardada se muestra al volver a abrir sin esperar un escaneo nuevo. Si falla el acceso a una nueva carpeta, se conserva el catálogo anterior.

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

La canción, cola y posición se guardan por separado y se restauran en pausa al abrir. Durante reproducción se guarda aproximadamente cada cinco segundos; pausar o pasar a segundo plano también guarda. Un cierre forzado puede perder los últimos segundos desde el checkpoint anterior. Al abrir el teclado se ocultan temporalmente los controles inferiores para dar espacio a la búsqueda.

Pendientes: letras, edición de etiquetas, edición de cola, controles multimedia del sistema Windows, fundidos, gapless, carátulas en toda la biblioteca, métricas y runtime programable de extensiones. En Windows, cerrar mantiene reproducción en bandeja por defecto; se cambia en Ajustes. Para cerrar completamente, usa Salir en el icono de bandeja.

El usuario comprobó buena fluidez en tres celulares y reportó los problemas que motivan esta compilación. Se aprobaron 25 pruebas automatizadas y una prueba nativa Windows con WAV generados. La mejora de escaneo en esos celulares, el cierre con los archivos originales de Windows, segundo plano y pantalla de bloqueo aún necesitan repetirse en dispositivos. No se han medido todavía RAM, batería o latencias.

## Reportar un problema

Crear un [issue en GitHub](https://github.com/Joao-s02/rp_music/issues) con versión de la app, sistema/dispositivo, pasos para reproducir, resultado esperado y resultado observado. Si es un fallo de audio, indicar formato y códec si se conocen. Evitar compartir credenciales o archivos musicales privados.

## Notificaciones y volumen en 0.2.2

Android solicita el permiso de notificaciones al ingresar por primera vez en esta versión. Puedes gestionarlo desde Ajustes. El volumen y silencio están en la barra inferior y se conserva el nivel elegido. Consulta el plan de pruebas 0.2.2 para bandeja, cierre completo y diagnóstico Tecno.
