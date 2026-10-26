# RP Music

Reproductor de música local construido en Flutter para Android y Windows. Escucha tus archivos sin conexión y sin cuentas, con biblioteca, favoritos y listas de reproducción.

**Versión: [0.2.5-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.2.5-alpha.1)** (aplicación `0.2.5+7`). Sigue en desarrollo: las funciones disponibles y los pendientes se detallan a continuación. Consulta la [guía de pruebas de 0.2.5](docs/PRUEBAS-0.2.5.md).

## Novedades de 0.2.5

- Reproductor ampliado a pantalla completa y títulos largos en una línea con desplazamiento horizontal; respeta reducir animaciones.
- Carátula incrustada de la pista en la sesión multimedia Android e iconos simples. La apariencia final depende de Android y del fabricante; pendiente comprobarla en teléfono físico.
- Ajustes divididos en secciones, con botones e iconos para las acciones.
- Eliminar del dispositivo desde los tres puntos de cada canción, con confirmación. Borra el archivo y limpia sus referencias solo si tiene éxito. En Android puede ser necesario volver a elegir la carpeta para otorgar escritura; no todos los proveedores permiten borrar.

Versión `0.2.5+7` para Android y Windows: análisis estático limpio y 46 pruebas aprobadas. Windows recibe reproductor ampliado, título animado, Ajustes agrupados y eliminación confirmada de archivos. Las notificaciones multimedia del sistema se aplican a Android. Los paquetes de 0.2.4 se conservan. Consulta la [guía de pruebas de 0.2.5](docs/PRUEBAS-0.2.5.md). Ver [seguimiento de pruebas](boveda/20%20Pruebas%200.2.4%20y%20mejoras%200.2.5.md).

## Tráiler

[![RP Music — Tu música. Tus reglas. Ver el tráiler en YouTube](design/youtube/rp-music-miniatura.jpg)](https://youtu.be/lobwRKtXv-M)

▶ **[Ver el tráiler de RP Music en YouTube](https://youtu.be/lobwRKtXv-M)**

## Descargar y usar

Los binarios se distribuyen en [Releases de GitHub](https://github.com/Joao-s02/rp_music/releases). Consulta la [guía de uso](docs/USO.md) para instalar el APK, abrir el paquete portable Windows e importar el ejemplo de personalización.

- **Android:** APK ARM64 o universal. Para actualizar una instalación anterior, instala encima sin desinstalar para conservar los datos. La firma sigue siendo de desarrollo.
- **Windows x64:** extrae el ZIP completo y abre `rp_music.exe` conservando sus DLL y la carpeta de datos.
- **Primera instalación de 0.2.4:** descarga manualmente desde Releases; 0.2.3 todavía no incluía el actualizador.

## Novedades de 0.2.4

- Búsqueda móvil desde la lupa, con foco estable al abrir el teclado, y nueva presentación de biblioteca vacía.
- Correcciones del servicio de audio Android durante pausas y cambios de pista; Detener libera el servicio y la notificación. El retesteo prolongado en teléfonos físicos sigue pendiente.
- Diagnóstico multimedia con copia de texto, exportación e importación de logs locales.
- Consulta opcional de actualizaciones, automática como máximo una vez al día o manual desde Ajustes. Puede desactivarse y permite elegir si incluir versiones de prueba.
- En Android, descarga con progreso/cancelación y validación de integridad, paquete, versión y firma antes de abrir el instalador del sistema. La instalación requiere tu confirmación. En Windows se ofrece el enlace de descarga.

La interfaz renovada de 0.2.3, con la identidad nocturna cian/violeta, fuentes locales y adaptación a móvil/escritorio, también está incluida. Consultar actualizaciones requiere internet; reproducir tu biblioteca local sigue funcionando sin conexión.

## Disponible en esta base

- Una carpeta raíz con subcarpetas; escaneo manual progresivo y caché de metadatos fuera de la interfaz.
- Canciones, álbumes, artistas, carpetas y búsqueda.
- Reproducción, pausa, posición, anterior/siguiente, aleatorio y repetición de una canción.
- Cola de la selección actual, favoritos y listas persistentes con eliminación de entradas o listas completas y contador de disponibles/ausentes. Eliminar una lista no borra los archivos musicales.
- Restauración de canción, cola y posición sin iniciar reproducción automáticamente.
- Volumen de la aplicación y silenciar, con nivel guardado.
- Windows: cerrar a bandeja o salir completamente según preferencia; menú para abrir, reproducir/pausar y salir.
- Android: permiso de notificaciones en el primer ingreso, estado/ajustes y propagación de cambios reproducir/pausar al servicio multimedia.
- Metadatos para organizar la biblioteca y carátula de la canción activa.
- Tema claro/oscuro y navegación adaptable en español.
- Servicio multimedia Android con controles de notificación y reproducción en segundo plano, sujeto a permisos y restricciones del dispositivo; consulta los límites de validación más abajo.
- Diagnóstico multimedia y actualizaciones opcionales desde Ajustes.
- Importación de extensiones declarativas JSON, selección de presentación y retorno a la base.

El reconocimiento de archivos MP3, FLAC, M4A, MP4, WAV y OPUS no garantiza que todo códec sea reproducible en todos los dispositivos. MP4 se trata como fuente de audio.

## Ejecutar

Herramientas verificadas: Flutter 3.47.6 y Dart 3.13.5.

```sh
flutter pub get
flutter run -d windows
# O con un dispositivo Android conectado:
flutter devices
flutter run -d ID_DEL_DISPOSITIVO
```

En la aplicación, elegir una carpeta de música. En Android se usa el selector del sistema y se conserva el permiso de lectura. En Windows se usa una ruta local. Los cambios de archivos se incorporan con Actualizar. Al volver a abrir se muestra el catálogo guardado sin escanear automáticamente.

Los datos nuevos se guardan en el directorio de soporte de la aplicación, dentro de `v2`, con un respaldo del guardado anterior. Se conservan los datos de 0.2.0; no se migran los de la antigua alfa 0.1. El escaneo nunca modifica los archivos musicales. Eliminar del dispositivo borra un archivo únicamente tras confirmarlo. La sesión se guarda por separado en `session.json`, también con respaldo.

## Probar la extensión de ejemplo

1. En Extensiones, pulsar Importar extensión.
2. Elegir `examples/extensions/descubrir.json` (copiarlo al dispositivo si se prueba Android).
3. Pulsar Descubrir mi música para activarla.
4. Volver a Biblioteca: aparecerán tarjetas, un acento lavanda y la acción Sorpréndeme.
5. Seleccionar Interfaz base o desinstalar para volver al aspecto inicial.

No hace falta recompilar ni reiniciar para esta prueba. Reimportar un archivo con el mismo identificador reemplaza explícitamente la versión anterior. No hay actualización automática ni catálogo remoto.

Esta prueba ejecuta acciones predefinidas por la aplicación. **No ejecuta programas de terceros ni constituye todavía el SDK completo de extensiones.** Consultar `examples/extensions/README.md`.

## Comprobar

```sh
flutter analyze
flutter test
flutter build apk --debug
flutter build windows --debug
```

Windows requiere Visual Studio con herramientas C++ y soporte para enlaces de complementos. Lo habitual es habilitar el modo de desarrollador. En esta máquina se pudo compilar con junctions locales dentro de `windows/flutter/ephemeral/.plugin_symlinks`; estos archivos temporales no se versionan. Se usa `just_audio_windows_plus 0.5.5`, con C++20, en reemplazo del backend anterior.

Las pruebas verifican biblioteca, guardados, progreso/caché, cambios de raíz, listas, extensiones, restauración, carreras al cambiar pistas, teclado y navegación móvil/escritorio. La prueba nativa Windows con WAV silenciosos generados (incluye borrado real de una pista cargada) se ejecuta con `flutter test integration_test/windows_playback_test.dart -d windows`. Ejecutarla antes de compilar paquetes de distribución, sin otras compilaciones nativas en paralelo. No comprueba todos los formatos ni reproduce necesariamente el crash de la PC del usuario.

Para 0.2.5 se aprobaron 46 pruebas automatizadas, el análisis estático y la prueba nativa Windows de reproducción, volumen, bandeja y borrado. APK universal/ARM64 y Windows release compilados; firma compatible, recursos multimedia y alineación de APK comprobados. Como antecedente, en 0.2.4: En emulador Android API 37 se verificaron cambios automáticos en segundo plano, pausa/reanudación y liberación al detener; también se probaron el foco del buscador y las validaciones nativas del actualizador. El alcance y las pruebas físicas pendientes están en la [guía de 0.2.4](docs/PRUEBAS-0.2.4.md).

## Pendiente

Letras, edición de etiquetas, cola editable, fundidos, gapless, controles multimedia del sistema Windows, carátulas en la biblioteca, mediciones de rendimiento y recursos por extensión, runtime programable, permisos de dos niveles, catálogo e integraciones con servicios. Web no está soportada por este incremento.

Falta repetir reproducción prolongada con pantalla apagada y controles en Galaxy A34 Android 16/Poco X6, completar una actualización entre dos releases públicas desde el instalador y comprobar los datos conservados. Siguen pendientes el rechazo de instalación en Tecno Android 16 y la confirmación del comportamiento de cierre en Windows por el usuario. Las pruebas en emulador no sustituyen estas verificaciones.

## Contexto para colaborar

Leer `AGENTS.md` y abrir `boveda` en Obsidian. La bóveda registra requisitos, decisiones técnicas provisionales, verificaciones y pendientes. El documento `arquitectura-reproductor-flutter.md` es histórico. La distribución se documenta en la nota de release de la bóveda.

En cada actualización del proyecto se debe revisar y actualizar este README: versión, novedades, instalación, funciones disponibles, comprobaciones y pendientes. Debe distinguir lo implementado de lo propuesto y mantenerse alineado con la bóveda. Esto no autoriza por sí solo publicar o enviar cambios a GitHub.
