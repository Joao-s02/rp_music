# RP Music

Reproductor de música local construido en Flutter para Android y Windows. Escucha tus archivos sin conexión y sin cuentas, con biblioteca, favoritos y listas de reproducción.

**Versión publicada 0.3.3-alpha.1 para Android y Windows:** [descargas y adjuntos](https://github.com/Joao-s02/rp_music/releases/tag/v0.3.3-alpha.1) · [Guía de uso](docs/USO-0.3.3.md) · [Pruebas](docs/PRUEBAS-0.3.3.md) · [Cambios](docs/CAMBIOS-0.3.3.md).

## Novedades de 0.3.3

- Reproductor expandido inspirado en la nueva referencia: carátula grande, título deslizante, favorito, datos reales, progreso, volumen y controles con cola. El ecualizador queda reservado a una extensión futura.
- Añadir un álbum a una lista existente o crear una nueva, conservando contenido y sin duplicados.
- Anterior recorre el historial de canciones; Siguiente recupera el avance visitado antes de volver al aleatorio. Historial local restaurable.
- Artistas separados por comas aparecen en sus propios grupos, conservando la etiqueta original.
- Acceso de fuente con icono de contorno adaptado al tema; se retira el enlace de apertura duplicado del gestor cuando ya aporta navegación.

Aplicación 0.3.3+12. Distribución conjunta de Android universal/global, Android ARM64 y Windows x64 portable completo, con guías y hashes. Suite completa inicial de 86 pruebas aprobada, regresión adicional del filtro guardado comprobada y análisis sin incidencias. Recorrido nativo Android aprobado (audio real, anterior/avance y revocación, en primer plano); APK normal instalado/abierto, firma compatible y ZIP/arranque Windows verificados. Retesteo físico y escucha larga pendientes.

Actualiza las extensiones desde [su repositorio](https://github.com/Joao-s02/rp-music-extensions) mediante **Extensiones → Explorar repositorio**, o importa sus archivos compatibles: fuente 0.2.1 para el icono integrado al tema y Biblioteca viva 0.1.1 para filtrar artistas colaboradores. Requieren RP Music 0.3.3; el catálogo conserva las versiones para clientes anteriores. Los paquetes se distribuyen exclusivamente en ese repositorio y no se incluyen en APK/ZIP ni en los adjuntos de la app. La fuente inicial sigue priorizando Android; Windows recibe las mejoras locales y visuales. [Resultados y límites](boveda/29%20Pruebas%200.3.2%20y%20mejoras%200.3.3.md).

## Novedades de 0.3.2

- Detalle de álbum renovado: carátula, información disponible, reproducir/aleatorio/guardar lista, pistas y cola con canción activa destacada.
- Corrección del espacio inferior en la búsqueda de fuentes y nombre del servicio en el reproductor ampliado.
- Las extensiones compatibles pueden aportar un acceso a la navegación con icono, etiqueta y color, sujeto a permiso y selección de la fuente.
- La lógica de conexión a servicios se traslada al repositorio de extensiones. La app incorpora un contrato HTTP genérico limitado y compatibilidad de versiones del catálogo.

Distribución: Android universal/global, Android ARM64 y Windows x64 portable completo, acompañados de USO, PRUEBAS, CAMBIOS y SHA-256. La fuente inicial requiere Android y actualizar su paquete a **0.2.0**, aceptando los nuevos permisos. Consulta el [repositorio de extensiones](https://github.com/Joao-s02/rp-music-extensions) desde la app o importa el paquete compatible. Las extensiones se distribuyen por separado; no se incluyen en los instaladores ni en los adjuntos de la app. Windows conserva reproducción local y recibe las mejoras visuales; no se promete reproducción de la fuente inicial en Windows.

Validación: suite completa inicial de 75 pruebas aprobada, comprobación adicional de navegación aprobada, análisis sin incidencias y prueba nativa Android de búsqueda/audio/controles/revocación aprobada, con HOME y pantalla apagada durante observación. APK universal instalado y abierto, firma compatible con 0.3.1, ARM64 verificado y Windows iniciado en una instancia de prueba. Pendientes: retesteo físico, sesiones prolongadas y recorrido manual completo de escritorio. [Resultados y límites](boveda/28%20Pruebas%200.3.1%20y%20mejoras%200.3.2.md).

## Antecedente 0.3.1 · extensiones para música en la nube

RP Music incorpora en Android el primer soporte experimental para **extensiones que añaden fuentes de música en la nube**, con un adaptador inicial para catálogos como YT. La fuente se habilita instalando un paquete compatible y aceptando sus permisos.

- Búsqueda de canciones y reproducción de audio en línea mediante una extensión, sin cuenta en esta primera entrega.
- Cola, pausa, avance, cambio de pista, carátula y reproducción en segundo plano con pantalla apagada, usando los controles de RP Music.
- Permisos separados para acceder al servicio y controlar el audio; desactivar la extensión detiene su reproducción y descarta resultados pendientes.
- Se mantienen Biblioteca viva, Pulso nocturno, listas/carátulas locales, varias extensiones activas y modo seguro. El catálogo indica Descargar, Instalada o Actualizar.

Repositorio: [rp-music-extensions](https://github.com/Joao-s02/rp-music-extensions). **Extensiones → Explorar repositorio → Consultar → elegir un paquete compatible → revisar permisos → abrir su fuente**. También permite importar `.rpmx`. Los paquetes se distribuyen por separado y no se activan al instalar el APK.

Este es un adaptador inicial; otros servicios requieren extensiones y adaptadores compatibles. La biblioteca local conserva su funcionamiento sin conexión. Windows mantiene la 0.3.0 y la nueva capacidad de fuentes en línea está disponible en Android.

**Validación:** el usuario confirmó resultados de búsqueda y audio rápidos, sin bugs ni lag observados durante su prueba, y calificó la velocidad del buscador con 10/10. Es una evaluación de uso, no una medición formal ni una garantía para todos los dispositivos. Se conservan 77 pruebas automatizadas aprobadas, análisis limpio y verificaciones nativas en emulador de reproducción, controles, cambios de pista y revocación de permisos. Se publica el mismo APK validado por el usuario.

**Pendiente:** ajustes de diseño reportados, previstos para la siguiente versión; listas, favoritos e historial de fuentes en línea, navegación completa por artistas/álbumes, cuentas, soporte Windows y sesiones prolongadas con distintas redes. El motor de extensiones sigue siendo experimental, con componentes visuales limitados y sin cuota dura de memoria; usa paquetes de confianza.

[Contrato API 2](docs/EXTENSIONES-API-2.md) · [Ejemplos](examples/extensions/programables/README.md) · [Validaciones y límites de la release](boveda/26%20Release%200.3.1.md).

## Novedades de 0.2.6

- Ventana centrada de actualización con versión actual/nueva, descarga en la app, progreso y Actualizar después. Android abre el instalador tras verificar; Windows descarga/verifica el ZIP y permite mostrarlo para extraer manualmente.
- Al borrar, se solicita escritura para la carpeta actual si falta. Android requiere confirmarla en su selector; no es un interruptor de Ajustes generales. También hay Permitir eliminar archivos en Ajustes de RP Music.
- Widget Android de pantalla de inicio con carátula disponible y controles; Añadir widget desde Ajustes o mediante el selector del launcher. Proveedor y controles de sesión probados en emulador; falta retesteo en el launcher del teléfono.
- Orden por título, artista, álbum, duración, fecha de modificación, tamaño y nombre de archivo, con ascendente/descendente guardado.

Versión `0.2.6+8`, con 52 pruebas aprobadas, análisis estático limpio y pruebas nativas Android/Windows aprobadas. Ver [seguimiento de pruebas](boveda/21%20Pruebas%200.2.5%20y%20mejoras%200.2.6.md). APK universal y ZIP Windows compilados y verificados en `dist/0.2.6`; [guía de pruebas](docs/PRUEBAS-0.2.6.md). En esta release solo se incluyó la API 1 declarativa. El motor API 2 y las listas/carátulas aportadas por programas corresponden al prototipo local 0.3.0 descrito arriba.

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

## Probar el ejemplo declarativo (API 1)

1. En Extensiones, pulsar Importar extensión.
2. Elegir `examples/extensions/descubrir.json` (copiarlo al dispositivo si se prueba Android).
3. Pulsar Descubrir mi música para activarla.
4. Volver a Biblioteca: aparecerán tarjetas, un acento lavanda y la acción Sorpréndeme.
5. Seleccionar Interfaz base o desinstalar para volver al aspecto inicial.

No hace falta recompilar ni reiniciar para esta prueba. Reimportar un archivo con el mismo identificador reemplaza explícitamente la versión anterior. No hay actualización automática; el catálogo remoto corresponde al trabajo local 0.3.x descrito arriba.

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

Letras, edición de etiquetas, cola editable, fundidos, gapless, controles multimedia del sistema Windows, mediciones de rendimiento y recursos por extensión, ampliar el SDK visual/de red, firmas de autor y completar integraciones con servicios. La versión actual incluye un primer runtime, permisos, catálogo y soporte Android para fuentes mediante extensiones; siguen pendientes ampliaciones y validaciones. Web no está soportada por este incremento.

Falta repetir reproducción prolongada con pantalla apagada y controles en Galaxy A34 Android 16/Poco X6, completar una actualización entre dos releases públicas desde el instalador y comprobar los datos conservados. Siguen pendientes el rechazo de instalación en Tecno Android 16 y la confirmación del comportamiento de cierre en Windows por el usuario. Las pruebas en emulador no sustituyen estas verificaciones.

## Contexto para colaborar

Leer `AGENTS.md` y abrir `boveda` en Obsidian. La bóveda registra requisitos, decisiones técnicas provisionales, verificaciones y pendientes. El documento `arquitectura-reproductor-flutter.md` es histórico. La distribución se documenta en la nota de release de la bóveda.

En cada actualización del proyecto se debe revisar y actualizar este README: versión, novedades, instalación, funciones disponibles, comprobaciones y pendientes. Debe distinguir lo implementado de lo propuesto y mantenerse alineado con la bóveda. Esto no autoriza por sí solo publicar o enviar cambios a GitHub.


## Preparar una release

Cada release debe adjuntar Android universal/global, Android ARM64 y Windows, además de `PRUEBAS-<version>.md`, `CAMBIOS-<version>.md`, `USO.md`, `SHA256SUMS.txt` y los archivos auxiliares necesarios. El MD de cambios es independiente del texto de GitHub. Revisar versiones, firmas, contenido y hashes antes de publicar; cualquier excepción a la entrega completa requiere una instrucción explícita del usuario. [Política de publicación](boveda/27%20Publicacion%20de%20releases%20-%20contenido%20obligatorio.md).


## Repositorios de aplicación y extensiones

Las nuevas extensiones —fuentes, paquetes, recursos y pruebas propios— se desarrollan y publican exclusivamente en [rp-music-extensions](https://github.com/Joao-s02/rp-music-extensions). El repositorio de la aplicación contiene el reproductor, motor, SDK, permisos e interfaces genéricas. Los paquetes de extensiones se obtienen desde su catálogo/repositorio; no deben añadirse a releases del repositorio principal. El material de los prototipos y la lógica específica ya presentes en este repositorio están pendientes de separación; este cambio documental no los ha migrado todavía.
