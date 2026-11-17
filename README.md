# RP Music

Reproductor local para Android y Windows. Abre tu biblioteca y escucha música sin cuenta ni conexión.

**Versión 0.4.0**, aplicación **0.4.0+30**. [Descargar Android universal, ARM64 y Windows](https://github.com/Joao-s02/rp_music/releases/tag/v0.4.0).

[Instalación y uso](docs/USO-0.4.0.md) · [Pruebas](docs/PRUEBAS-0.4.0.md) · [Cambios](docs/CAMBIOS-0.4.0.md) · [Documentación](docs/README.md)

## Novedades de 0.4.0

RP Music se centra en la escucha de tu biblioteca local. Temas sustituye Explorar en la navegación y permite importar o descargar colores, fondos e iconos para toda la app. [Catálogo, guía y plantilla de temas](https://github.com/Joao-s02/rp-music-themes).

Se retiran las extensiones, incluidas YouTube, Radio y la búsqueda de letras por internet. Se conservan las letras incrustadas y los LRC/TXT importados. La actualización limpia las letras privadas con marca de origen en línea y convierte las listas automáticas en listas locales editables.

Biblioteca por carpetas, álbumes y artistas, búsqueda, favoritos, listas y portadas. Cola, aleatorio, repetición y restauración sin iniciar audio. Letras sincronizadas según las marcas del archivo, controles multimedia y widgets Android.

## Instalación y actualización

En Android, instala el APK apropiado sobre la app existente para conservar tus datos. En Windows, extrae el ZIP completo, incluidas DLL y licencias. [Guía de uso](docs/USO-0.4.0.md).

## Verificación

120 pruebas automatizadas aprobadas y análisis limpio. Android universal/ARM64 firmados y Windows x64 compilado y empaquetado para distribución. Instalación y actualización reales, Play Protect, audífonos y escucha prolongada pendientes. [Pruebas y límites](docs/PRUEBAS-0.4.0.md).

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
