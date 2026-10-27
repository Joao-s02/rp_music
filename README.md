# RP Music

Reproductor local Flutter para Android y Windows, ampliable mediante extensiones. Biblioteca musical sin cuenta ni conexión; actualizaciones y fuentes en línea son opcionales.

**Versión publicada: [0.3.4-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.3.4-alpha.1)**, app 0.3.4+13. Android universal/global, ARM64 y Windows x64, con uso/pruebas/cambios y hashes.

[Guía vigente](docs/USO.md) · [Pruebas 0.3.4](docs/PRUEBAS-0.3.4.md) · [Cambios](docs/CAMBIOS-0.3.4.md) · [Documentación](docs/README.md)

## Novedades de 0.3.4

Controles principales fijos y carátula adaptable; letras LRC/TXT importables y consulta opcional mediante extensión; descarga manual con permiso en fuentes compatibles. Paquetes YouTube Android/Windows separados y Spotify experimental de vistas previas públicas por enlace, sin cuenta. La reproducción nativa de YouTube Windows sigue fallando en las pruebas; su paquete es candidato experimental. Spotify completo y búsqueda por nombre no están resueltos. Alcance y verificaciones: [estado y verificaciones](boveda/32%20Pruebas%200.3.3%20y%20mejoras%200.3.4.md).

## Disponible

- Una raíz con subcarpetas, catálogo persistente, escaneo manual/progresivo, búsqueda y orden guardado.
- Canciones, álbumes, artistas por comas y carpetas; metadatos y carátulas disponibles.
- Audio, cola de selección, volumen/silencio, aleatorio/repetición, anterior/avance histórico y restauración local sin autoplay.
- Favoritos, listas manuales y carátulas propias/mosaico; añadir álbum a lista existente o crear sin duplicar. Automáticas mediante extensión.
- Borrado de archivo con confirmación y permiso de escritura cuando corresponda. Quitar una lista no borra audio.
- Identidad nocturna cian/violeta, tema claro/oscuro, navegación adaptable, álbum y reproductor expandido renovados.
- Android: sesión/notificación/carátula/controles y widget. Windows: reproducción local, volumen y bandeja/salida según preferencia.
- Actualizador opcional con canales, descarga/verificación e instalador Android; Windows descarga ZIP para extracción manual. Diagnóstico multimedia desde Ajustes.
- API 1 declarativa y API 2 experimental con permisos, recuperación, catálogo por repositorio y fuentes mediante contratos genéricos.

Reconocer MP3/FLAC/M4A/MP4/WAV/OPUS no garantiza todos los códecs en todos los equipos; MP4 se trata como audio. La etiqueta original de artista se conserva, aunque se muestre en varios grupos.

## Instalar y actualizar

Descargar desde la release. Android: instalar encima de la anterior sin desinstalar para conservar datos; firma actual de desarrollo. Windows: extraer ZIP completo y abrir rp_music.exe junto con DLL y data. Elegir carpeta de música; en Android conceder lectura y escritura cuando sea necesaria. Actualizar biblioteca incorpora cambios; al abrir se muestra la caché sin un escaneo nuevo automático.

Datos en soporte privado de app: biblioteca/preferencias y sesión en v2, programas en v3, con respaldo JSON. No se migran datos de la antigua alfa 0.1. No borrar esas carpetas al actualizar. [Guía completa](docs/USO-0.3.4.md).

## Extensiones

[Repositorio de extensiones](https://github.com/Joao-s02/rp-music-extensions): **Extensiones → Explorar repositorio → Consultar → elegir paquete/actualización → revisar permisos**. También importar archivo .rpmx. No vienen instaladas ni dentro del APK/ZIP ni adjuntas a releases de la app.

Para 0.3.4: YouTube Android 0.3.0 con letras/descarga, Spotify · vistas previas 0.1.0 por enlace público, Biblioteca viva 0.1.1 y Pulso nocturno 0.1.0. El catálogo conserva variantes para clientes anteriores. YouTube Windows es candidato manual con fallos nativos conocidos, fuera del catálogo recomendado; Spotify sin cuenta no ofrece canciones completas ni búsqueda por nombre. Cuentas/listas/favoritos/historial online siguen pendientes.

Código específico, paquetes, recursos y pruebas de extensiones se desarrollan solo en ese repositorio. El principal contiene reproductor/motor/SDK/capacidades genéricas. Prototipos heredados de biblioteca/reproductor en examples y pruebas siguen como deuda de migración, no lugar para nuevas extensiones. [Contrato API 2](docs/EXTENSIONES-API-2.md).

## Verificación y pendientes

0.3.4: suite completa de **97 pruebas aprobadas** y análisis sin incidencias. Reproductor verificado sin desplazamiento de controles en cuatro tamaños; letras en pantalla con avance/retroceso/seek y cambio de canción. Windows normal release compilado. Empaquetado Android y verificaciones finales de publicación en la [nota de versión](boveda/32%20Pruebas%200.3.3%20y%20mejoras%200.3.4.md).

Fuente YouTube Windows no supera la prueba nativa. Spotify solo vista previa pública; no hay nueva reproducción nativa aprobada de esos paquetes. Guardado real con selector, nuevos paquetes Android/Spotify, escucha física y segundo plano prolongado requieren retesteo. No convertir pruebas de bytes en pruebas de reproducción.

Edición de etiquetas/cola editable/gapless/fundido, ecualizador como extensión, aislamiento fuerte/firmas/métricas del SDK y validaciones de tienda siguen pendientes. Sin soporte web en esta entrega. Código público; licencia del proyecto aún sin elegir (licencias de terceros conservadas).

## Desarrollar y colaborar

```sh
flutter pub get
flutter run -d windows
# Android: consultar flutter devices y usar su ID
flutter run -d ID_DEL_DISPOSITIVO
```

Configuración y comandos de verificación/build: [COMPILACION](docs/COMPILACION.md). No ejecutar pruebas y builds Flutter concurrentes ni distribuir sondas de integración. Herramientas registradas durante reconstrucción: Flutter 3.47.6/Dart 3.13.5; consultar entorno antes de nuevas compilaciones.

Leer AGENTS.md y [entrada a la bóveda](boveda/00%20Inicio.md). [Estado actual](boveda/10%20Estado%20del%20repositorio.md), [arquitectura vigente](boveda/31%20Arquitectura%20vigente.md) y [registro histórico](boveda/09%20Registro%20de%20cambios.md) tienen funciones distintas. El documento del alfa arquitectura-reproductor-flutter.md no es la arquitectura vigente. Guías anteriores desde [docs](docs/README.md).

Revisar README y notas afectadas en cada actualización. Publicar requiere autorización y [política de releases](boveda/27%20Publicacion%20de%20releases%20-%20contenido%20obligatorio.md): tres binarios, USO/PRUEBAS/CAMBIOS y SHA256SUMS; excepciones expresas. Documentar no concede autorización automática para push/publicación.

## Tráiler

[![RP Music — Tu música. Tus reglas. Ver el tráiler en YouTube](design/youtube/rp-music-miniatura.jpg)](https://youtu.be/lobwRKtXv-M)

▶ **[Ver el tráiler de RP Music en YouTube](https://youtu.be/lobwRKtXv-M)**
