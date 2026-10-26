# RP Music — guía de uso

Versión preliminar **0.2.5-alpha.1** para Android y Windows. Reproductor de música local, sin cuenta ni conexión a internet obligatoria. Todavía no es una versión estable. Véase también [qué volver a probar](PRUEBAS-0.2.5.md).

## Qué descargar

- **Android:** `RP-Music-0.2.5-android.apk` (universal) o `RP-Music-0.2.5-android-arm64.apk` (más pequeño, ARM64).
- **Windows x64:** `RP-Music-0.2.5-windows-x64.zip`.
- **Ejemplo de personalización:** `descubrir.json`, también incluido dentro del ZIP de Windows.

Paquetes de la [release v0.2.5-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.2.5-alpha.1). La copia local se conserva en `dist/0.2.5`. Actualiza sobre la versión anterior para conservar tus datos.

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
- En móvil, pulsa título/carátula del minirreproductor para abrir la vista completa; incluye volumen, posición y cola.
- En **Listas**, la papelera de la fila o del detalle permite eliminar una lista con confirmación, sin borrar archivos.
- En **Listas**, crea una lista. Después usa el menú de una canción en la biblioteca para añadirla.
- Dentro de una lista, **Quitar de la lista** retira esa entrada sin borrar el archivo. Los contadores distinguen disponibles y ausentes; **Quitar** permite limpiar las referencias no disponibles. Si las conservas, reaparecen al volver a la carpeta que las contiene.
- Los tres puntos de cada canción incluyen **Eliminar del dispositivo**, con confirmación de borrado permanente. Se retira también de favoritos, listas y cola. Para borrar en Android puede ser necesario volver a elegir la carpeta y conceder escritura; si falla, se conservan las referencias.
- Los títulos largos de la vista ampliada se desplazan en una línea. La vista ocupa toda el área de la app, tanto en Android como en Windows.
- En **Ajustes**, cambia entre tema oscuro y claro o elige otra carpeta.

Al añadir, eliminar o cambiar archivos dentro de tu carpeta, pulsa **Actualizar biblioteca**. El escaneo es manual y progresivo: primero aparecen los archivos y después se completa su información. Las actualizaciones reutilizan archivos sin cambios. La biblioteca guardada se muestra al volver a abrir sin esperar un escaneo nuevo. Si falla el acceso a una nueva carpeta, se conserva el catálogo anterior.

Se reconocen archivos MP3, FLAC, M4A, MP4, WAV y OPUS. La reproducción real depende del códec y de las capacidades del sistema. MP4 se utiliza como audio, no como vídeo. Los metadatos se leen para organizar la biblioteca; el escaneo no modifica los archivos musicales. Eliminar del dispositivo sí borra el archivo tras confirmar.

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

Pendientes: letras, edición de etiquetas, edición de cola, controles multimedia del sistema Windows, fundidos, gapless, métricas y runtime programable de extensiones. En Windows, cerrar mantiene reproducción en bandeja por defecto; se cambia en Ajustes. Para cerrar completamente, usa Salir en el icono de bandeja.

La versión actual tiene 46 pruebas automatizadas aprobadas y comprobación multimedia nativa debug/release en emulador Android API 37. La comparación release reprodujo la ausencia de controles cuando se eliminaban sus iconos y confirmó la notificación al conservarlos. Windows release 0.2.5+7 compilado y prueba nativa aprobada: cambios repetidos, volumen, bandeja y borrado real de una pista cargada con archivos sintéticos. Consulta la guía de pruebas de 0.2.5 para el alcance de validación. El cierre con los archivos originales de Windows y la nueva carátula/borrado SAF en Galaxy A34/Poco X6 aún necesitan repetirse en dispositivos. No se han medido todavía RAM, batería o latencias.

## Reportar un problema

Crear un [issue en GitHub](https://github.com/Joao-s02/rp_music/issues) con versión de la app, sistema/dispositivo, pasos para reproducir, resultado esperado y resultado observado. Si es un fallo de audio, indicar formato y códec si se conocen. Evitar compartir credenciales o archivos musicales privados.

## Notificaciones, diagnóstico y actualizaciones en 0.2.5

Se conservan los iconos multimedia que el optimizador eliminaba del APK y se actualiza la sesión con cola, índice y duración real. **Ajustes → Diagnóstico multimedia** permite comprobar notificación, sesión, canal y errores mientras suena una canción. El permiso concedido no demuestra por sí solo que el servicio haya publicado sus controles.

El volumen y silencio se conservan. En móvil están en el reproductor completo; en Windows, en la franja inferior. Consulta el [plan de pruebas 0.2.5](PRUEBAS-0.2.5.md) para el retesteo de Galaxy/Poco. El problema de instalación Tecno anterior sigue sin confirmación física.


El buscador está contraído a la lupa de Biblioteca. Púlsala para abrirlo y mantener el teclado enfocado. El diagnóstico permite copiar texto, exportar e importar logs locales.

Las actualizaciones se consultan opcionalmente en segundo plano como máximo una vez al día. Se pueden desactivar desde Ajustes; hay consulta manual y canal de pruebas. Android descarga únicamente al aceptar y verifica integridad y firma antes de abrir su instalador. Puede pedir autorización para instalar desde RP Music. Windows abre la página de descarga. La primera versión con esta función debe instalarse manualmente y futuras publicaciones deben mantener un código de versión superior y certificado compatible.

Pausar mantiene el servicio preparado sin el wake lock de CPU; Detener en el reproductor ampliado libera el servicio. Consultar el plan de pruebas para los límites físicos pendientes.

La sesión multimedia Android incorpora la carátula incrustada disponible y cinco iconos simples. Su presentación final depende de Android y el fabricante. Las acciones de Ajustes están agrupadas en tarjetas con botones e iconos.
