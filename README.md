# RP Music

Reproductor Flutter para Android y Windows, ampliable mediante extensiones. Biblioteca local sin cuenta ni conexión; actualizaciones y consultas en línea opcionales.

**Versión publicada: 0.3.19-alpha.1**, aplicación **0.3.19+28**. [Descargar Android universal, ARM64 y Windows](https://github.com/Joao-s02/rp_music/releases/tag/v0.3.19-alpha.1).

[Guía vigente](docs/USO.md) · [Pruebas](docs/PRUEBAS-0.3.19.md) · [Cambios](docs/CAMBIOS-0.3.19.md) · [Documentación](docs/README.md)

## Novedades de 0.3.19

Esta versión incluye regreso desde listas, recorte cuadrado de portadas y un menú para añadir una canción a varias listas, crear una lista o consultar sus detalles. En Canciones, la barra inferior se recoge al avanzar y reaparece al volver hacia arriba. El minirreproductor sigue accesible. El botón para actualizar la biblioteca está junto a la búsqueda. Las miniaturas recientes se reutilizan al volver a recorrer la lista.

Letras usa la portada difuminada cuando está disponible y distingue voces numeradas con alineación alterna. Canciones y álbumes descargados desde extensiones comparten un destino configurable en Ajustes. Android 14 o posterior incorpora el selector de salida del sistema. Google Cast sigue pendiente. Android espera a que termine una carga antes de iniciar la última pista seleccionada en una secuencia de cambios rápidos.

## Funciones disponibles

Biblioteca local por carpetas, álbumes y artistas; búsqueda, favoritos, listas y carátulas; cola de reproducción, aleatorio/repetición y restauración sin iniciar audio. Letras incrustadas y LRC/TXT; sincronización por línea y por palabra cuando el archivo aporta esos tiempos. Reproductor adaptable, controles multimedia y widgets Android. Windows utiliza libmpv y tiene evidencia nativa de M4A/OPUS y YouTube desde 0.3.10.

Las extensiones API 2/Dart y API 3/JavaScript se instalan por separado desde el catálogo de [rp-music-extensions](https://github.com/Joao-s02/rp-music-extensions), con permisos explícitos. YouTube/Explorador permiten búsqueda, navegación pública, importación como copias locales y descargas según la variante. Radio y Letras locales son opciones independientes. Las letras automáticas de música local usan caché privada; no reescriben los archivos del usuario. Sin cuenta/sincronización online implementada ni soporte web.

## Instalación y actualización

Usa la [release 0.3.19-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.3.19-alpha.1). En Android, descarga el APK apropiado e instálalo desde Archivos **sin desinstalar** la versión anterior para conservar tus datos. En Windows, extrae el ZIP completo, incluidas DLL y licencias. Consulta la [guía de instalación y uso](docs/USO-0.3.19.md).

## Verificación

Android universal y ARM64 firmados y Windows x64 compilado. La suite completa aprobó 185 pruebas y omitió 1. Queda pendiente probar la actualización, las salidas de audio y Play Protect en Android físico. [Pruebas y límites](docs/PRUEBAS-0.3.19.md) · [Historial de versiones](docs/releases/README.md).

## Desarrollar y colaborar

```sh
flutter pub get
flutter run -d windows
# Android: consultar flutter devices y usar el ID disponible
flutter run -d ID_DEL_DISPOSITIVO
```

[Compilación](docs/COMPILACION.md). No ejecutar tests/builds Flutter concurrentes ni distribuir sondas de integración. Herramientas verificadas durante este desarrollo: Flutter 3.47.6/Dart 3.13.5; comprobar entorno antes de compilar.

Consulta [AGENTS.md](AGENTS.md) y el [índice de documentación](docs/README.md). La licencia del proyecto está pendiente de elección.

## Tráiler

[![RP Music — Tu música. Tus reglas. Ver el tráiler en YouTube](design/youtube/rp-music-miniatura.jpg)](https://youtu.be/lobwRKtXv-M)

▶ **[Ver el tráiler de RP Music en YouTube](https://youtu.be/lobwRKtXv-M)**
