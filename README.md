# RP Music

Reproductor Flutter para Android y Windows, ampliable mediante extensiones. Biblioteca local sin cuenta ni conexión; actualizaciones y consultas en línea opcionales.

**Versión publicada: 0.3.16-alpha.1**, aplicación **0.3.16+25**. [Descargar Android universal, ARM64 y Windows](https://github.com/Joao-s02/rp_music/releases/tag/v0.3.16-alpha.1).

[Guía vigente](docs/USO.md) · [Pruebas](docs/PRUEBAS-0.3.16.md) · [Cambios](docs/CAMBIOS-0.3.16.md) · [Documentación](docs/README.md)

## Novedades 0.3.16+25

Publicados Android universal/ARM64 firmados y Windows completo, con siete adjuntos verificados. [Uso](docs/USO-0.3.16.md) · [Pruebas y límites](docs/PRUEBAS-0.3.16.md).

Cambios:

- Navegación con cinco destinos fijos. **Explorar** reúne fuentes y pantallas de extensiones; desde ahí se administran paquetes y permisos.
- Álbum local: búsqueda plegada al entrar, lupa para abrirla y filtro dentro del álbum; indicador animado de la pista actual con pausa y movimiento reducido.
- Artistas locales: separadores coma, « y » y « & »; agrupación sin duplicados por mayúsculas o espacios repetidos. Las etiquetas de los archivos permanecen intactas.
- Explorador de fuentes: presenta las fotos y portadas públicas que la extensión devuelve, con alternativa si faltan.
- Descarga de álbum a archivo temporal, progreso por canción, límite de 512 MiB por canción y reintento exclusivo de fallidas. Requiere mantener la app abierta. Las canciones sueltas conservan por ahora la ruta de exportación de 64 MiB.
- Actualizaciones externas YouTube 0.5.3 / Explorador 0.2.3: incluyen respaldo del vídeo exacto, Single/EP oficiales, consulta ampliada y portada de la edición/grupo identificado hasta 1200px. Se prioriza la imagen de metadatos y se conserva una alternativa si no está disponible. No se garantiza álbum o imagen para toda canción.
- API 3: tiempos de motor/red/acción en el diagnóstico de sesión y caché pública optativa de hasta 60 segundos, acotada e invalidada al cambiar permisos. Explorador JS 0.1.1; sin afirmar mejora medida en Android.

[Alcance y verificación 0.3.16](docs/PROBAR-0.3.16.md). Las extensiones se actualizan por separado desde su catálogo; las variantes anteriores permanecen disponibles.

## Antecedente 0.3.15 — instalación Android

Android retira el permiso para iniciar instalaciones. La app consulta versiones y abre la descarga oficial; el usuario instala el APK desde Archivos. Firma de producción con transición compatible, datos y funciones musicales conservados. **Actualizar desde Archivos sin desinstalar**, especialmente desde 0.3.13.

Play Protect bloqueó el control y aceptó el universal corregido en emulador. El usuario confirma dos dispositivos: A34 actualizado sin aviso de Play Protect y Pova 7 instalado normalmente tras solicitar análisis, sin clasificación dañina. No garantiza el resultado en todos los equipos; ARM64 físico y análisis específico pendientes. 166 pruebas aprobadas/una optativa omitida y análisis limpio. [Uso](docs/USO-0.3.15.md) · [Resultados](boveda/44%20Diagnostico%20local%20de%20instalacion%20y%20actualizaciones%20manuales.md). Android universal/ARM64 y Windows publicados con siete adjuntos verificados. Catálogo de extensiones conservado.

## Funciones disponibles

Biblioteca local por carpetas, álbumes y artistas; búsqueda, favoritos, listas y carátulas; cola de reproducción, aleatorio/repetición y restauración sin iniciar audio. Letras incrustadas y LRC/TXT; sincronización por línea y por palabra cuando el archivo aporta esos tiempos. Reproductor adaptable, controles multimedia y widgets Android. Windows utiliza libmpv y tiene evidencia nativa de M4A/OPUS y YouTube desde 0.3.10.

Las extensiones API 2/Dart y API 3/JavaScript se instalan por separado desde el catálogo de [rp-music-extensions](https://github.com/Joao-s02/rp-music-extensions), con permisos explícitos. YouTube/Explorador permiten búsqueda, navegación pública, importación como copias locales y descargas según la variante. Radio y Letras locales son opciones independientes. Las letras automáticas de música local usan caché privada; no reescriben los archivos del usuario. Sin cuenta/sincronización online implementada ni soporte web.

## Instalación y actualización

Usa la [release 0.3.16](https://github.com/Joao-s02/rp_music/releases/tag/v0.3.16-alpha.1). Android: descarga el APK apropiado e instala desde Archivos **sin desinstalar** para conservar datos. Windows: extrae el ZIP completo, incluidas DLL, datos y licencias; no copies solo el EXE. Consulta [instalación y uso](docs/USO-0.3.16.md) y [firma Android](docs/ANDROID-SIGNING.md).

## Verificación y pendientes

La referencia publicada 0.3.15 registra 166 pruebas aprobadas, una optativa omitida y análisis limpio. Sus resultados no son una prueba de 0.3.16. 0.3.16:163 pruebas aprobadas/una omitida y análisis limpio; metadatos/portadas y respaldo ante503 comprobados. [Comprobaciones y límites actuales](docs/PRUEBAS-0.3.16.md).

Pendientes físicos: SD/SAF, exportación a almacenamiento elegido, widgets/launcher, ARM64, escucha prolongada y medición Android de la demora API 3. Álbumes, imágenes y letras dependen de cobertura y disponibilidad de servicios externos. El informe del usuario de que algunas canciones siguen sin álbum reabre ese caso en esta versión.

Edición general de etiquetas, cola editable, gapless/fundido, ecualizador como extensión, cuenta/sincronización e aislamiento/firmas/métricas del SDK permanecen pendientes. Licencia concreta del proyecto por elegir; licencias de terceros conservadas.

Historial: [0.3.13](docs/CAMBIOS-0.3.13.md), [0.3.12](docs/CAMBIOS-0.3.12.md), [0.3.11](docs/CAMBIOS-0.3.11.md), [audio Windows 0.3.10](boveda/39%20Audio%20Windows%20M4A%20OPUS%20y%20YouTube.md), [API 3](docs/EXTENSIONES-API-3.md). El [registro de la bóveda](boveda/09%20Registro%20de%20cambios.md) conserva las decisiones y comprobaciones anteriores.

## Desarrollar y colaborar

```sh
flutter pub get
flutter run -d windows
# Android: consultar flutter devices y usar el ID disponible
flutter run -d ID_DEL_DISPOSITIVO
```

[Compilación](docs/COMPILACION.md). No ejecutar tests/builds Flutter concurrentes ni distribuir sondas de integración. Herramientas verificadas durante este desarrollo: Flutter 3.47.6/Dart 3.13.5; comprobar entorno antes de compilar.

Leer AGENTS.md y la [bóveda](boveda/00%20Inicio.md). [Estado actual](boveda/10%20Estado%20del%20repositorio.md), [arquitectura](boveda/31%20Arquitectura%20vigente.md) y [registro](boveda/09%20Registro%20de%20cambios.md). Arquitectura del alfa como antecedente. README/notas se mantienen en cada actualización. [Política de releases](boveda/27%20Publicacion%20de%20releases%20-%20contenido%20obligatorio.md): tres binarios, USO/PRUEBAS/CAMBIOS y hashes; publicar requiere autorización.

## Tráiler

[![RP Music — Tu música. Tus reglas. Ver el tráiler en YouTube](design/youtube/rp-music-miniatura.jpg)](https://youtu.be/lobwRKtXv-M)

▶ **[Ver el tráiler de RP Music en YouTube](https://youtu.be/lobwRKtXv-M)**


Capturas demostrativas0.3.12 (no Android físico): [Escena de letras](design/verification/lyrics-0.3.12-scene.png) · [Reproductor fijo](design/verification/player-0.3.12-360.png).

Antecedente Android 0.3.12–0.3.14 y comparación que llevó a la actualización manual: [firma e investigación](boveda/43%20Play%20Protect%20y%20firma%20de%20Android.md), [resultado de 0.3.15](boveda/44%20Diagnostico%20local%20de%20instalacion%20y%20actualizaciones%20manuales.md). Los resultados de esas versiones no se atribuyen automáticamente a 0.3.16.
