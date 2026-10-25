# RP Music

Base reconstruida en Flutter para Android y Windows. Aplicación local, sin cuenta. La versión preliminar 0.2.2 añade notificaciones, volumen y bandeja; todavía no implementa toda la visión del proyecto. Consulta [qué volver a probar](docs/PRUEBAS-0.2.2.md).

## Descargar y usar

Los binarios se distribuyen en [Releases de GitHub](https://github.com/Joao-s02/rp_music/releases). Consulta la [guía de uso](docs/USO.md) para instalar el APK, abrir el paquete portable Windows e importar el ejemplo de personalización.

## Disponible en esta base

- Una carpeta raíz con subcarpetas; escaneo manual progresivo y caché de metadatos fuera de la interfaz.
- Canciones, álbumes, artistas, carpetas y búsqueda.
- Reproducción, pausa, posición, anterior/siguiente, aleatorio y repetición de una canción.
- Cola de la selección actual, favoritos y listas persistentes con eliminación de entradas y contador de disponibles/ausentes.
- Restauración de canción, cola y posición sin iniciar reproducción automáticamente.
- Volumen de la aplicación y silenciar, con nivel guardado.
- Windows: cerrar a bandeja o salir completamente según preferencia; menú para abrir, reproducir/pausar y salir.
- Android: permiso de notificaciones en el primer ingreso, estado/ajustes y propagación de cambios reproducir/pausar al servicio multimedia.
- Metadatos para organizar la biblioteca y carátula de la canción activa.
- Tema claro/oscuro y navegación adaptable en español.
- Integración de servicio multimedia Android preparada mediante audio_service.
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

Los datos nuevos se guardan en el directorio de soporte de la aplicación, dentro de `v2`, con un respaldo del guardado anterior. Se conservan los datos de 0.2.0; no se migran los de la antigua alfa 0.1. El escaneo nunca modifica los archivos musicales. La sesión se guarda por separado en `session.json`, también con respaldo.

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

Las pruebas verifican biblioteca, guardados, progreso/caché, cambios de raíz, listas, extensiones, restauración, carreras al cambiar pistas, teclado y navegación móvil/escritorio. La prueba nativa Windows con WAV silenciosos generados se ejecuta con `flutter test integration_test/windows_playback_test.dart -d windows`. Ejecutarla antes de compilar paquetes de distribución, sin otras compilaciones nativas en paralelo. No comprueba todos los formatos ni reproduce necesariamente el crash de la PC del usuario.

## Pendiente

Letras, edición de etiquetas, cola editable, fundidos, gapless, controles multimedia del sistema Windows, carátulas en la biblioteca, mediciones de rendimiento y recursos por extensión, runtime programable, permisos de dos niveles, catálogo e integraciones con servicios. Falta confirmar notificaciones en teléfonos reales y diagnosticar el rechazo de APK en Tecno Android 16. Web no está soportada por este incremento.

## Contexto para colaborar

Leer `AGENTS.md` y abrir `boveda` en Obsidian. La bóveda registra requisitos, decisiones técnicas provisionales, verificaciones y pendientes. El documento `arquitectura-reproductor-flutter.md` es histórico. La distribución se documenta en la nota de release de la bóveda.
