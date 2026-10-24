# RP Music

Primera base reconstruida en Flutter para Android y Windows. Aplicación local, sin cuenta. La versión 0.2.0 es un incremento de desarrollo, no la implementación completa de la visión del proyecto.

## Descargar y usar

Los binarios se distribuyen en [Releases de GitHub](https://github.com/Joao-s02/rp_music/releases). Consulta la [guía de uso](docs/USO.md) para instalar el APK, abrir el paquete portable Windows e importar el ejemplo de personalización.

## Disponible en esta base

- Una carpeta raíz con subcarpetas; escaneo manual fuera de la interfaz.
- Canciones, álbumes, artistas, carpetas y búsqueda.
- Reproducción, pausa, posición, anterior/siguiente, aleatorio y repetición de una canción.
- Cola de la selección actual, favoritos y listas persistentes.
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

Los datos nuevos se guardan en el directorio de soporte de la aplicación, dentro de `v2`, con un respaldo del guardado anterior. No se migran los datos del alfa. El escaneo nunca modifica los archivos musicales.

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

Windows requiere Visual Studio con herramientas C++ y soporte para enlaces de complementos. Lo habitual es habilitar el modo de desarrollador. En esta máquina se pudo compilar con junctions locales dentro de `windows/flutter/ephemeral/.plugin_symlinks`; estos archivos temporales no se versionan. Hay una definición de compatibilidad de Visual Studio 2026 limitada a `just_audio_windows` en CMake; el backend debe reevaluarse antes de una versión estable.

Las pruebas verifican biblioteca, guardados, cancelación/fallo de cambio de raíz, listas, extensiones, carreras al cambiar pistas y navegación a 360 y 1280 píxeles. Compilar no verifica reproducción física, pantalla de bloqueo ni compatibilidad real de todos los formatos.

## Pendiente

Letras, edición de etiquetas, restauración de cola/posición, cola editable, fundidos, gapless, bandeja y controles del sistema Windows, carátulas en la biblioteca, mediciones de rendimiento y recursos por extensión, runtime programable, permisos de dos niveles, catálogo e integraciones con servicios. Web no está soportada por este incremento.

## Contexto para colaborar

Leer `AGENTS.md` y abrir `boveda` en Obsidian. La bóveda registra requisitos, decisiones técnicas provisionales, verificaciones y pendientes. El documento `arquitectura-reproductor-flutter.md` es histórico. La distribución se documenta en la nota de release de la bóveda.
