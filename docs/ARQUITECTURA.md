# Arquitectura de RP Music

## Candidato local 0.4.0

El arranque conecta biblioteca local, audio, actualizador, letras offline y ThemeLibrary. Se retiran SDK, runtimes y fuentes de extensiones. ThemeLibrary persiste la apariencia aparte de la biblioteca y obtiene paquetes desde un catálogo HTTPS configurable o importación local. [Formato de temas](TEMAS.md).

El mapa siguiente conserva el antecedente previo a esta reforma.

RP Music es un reproductor **local-first** en Flutter/Dart para Android y Windows. El núcleo funciona sin cuentas ni servicios online obligatorios; las integraciones externas se incorporan mediante capacidades genéricas, extensiones autorizadas o aplicaciones complementarias.

Este mapa describe responsabilidades existentes, no propone una reescritura ni afirma una Clean Architecture estricta. La [nota arquitectónica de la bóveda](../boveda/31%20Arquitectura%20vigente.md) conserva su evolución. La versión publicada, el candidato local y las verificaciones se consultan en el [estado del repositorio](../boveda/10%20Estado%20del%20repositorio.md).

## Vocabulario básico

| Término | Significado en este proyecto |
| --- | --- |
| Local-first | La música local funciona sin depender de una cuenta o servicio online. |
| Anfitrión / host | RP Music: recibe contratos de extensiones y decide qué operaciones permite. |
| Runtime | Motor que ejecuta programas Dart o JavaScript bajo las restricciones disponibles. |
| Backend de audio | Implementación que conecta el reproductor con el motor de una plataforma. |
| SAF | Storage Access Framework: acceso a documentos/carpetas mediante permisos y selectores de Android. |

## Mapa de componentes

| Área | Entradas principales | Responsabilidad |
| --- | --- | --- |
| Composición | [`lib/main.dart`](../lib/main.dart) | Inicializar servicios, conectar plataforma y restaurar sin autoplay. |
| Presentación | [`lib/app/music_app.dart`](../lib/app/music_app.dart), vistas de álbum/reproductor/letras | Navegación Material adaptable, presentación y coordinación de acciones. |
| Biblioteca | [`LibraryController`](../lib/app/library_controller.dart) | Estado `ChangeNotifier`, catálogo, favoritos, listas y preferencias. |
| Dominio | [`Track`](../lib/domain/track.dart), [`Lyrics`](../lib/domain/lyrics.dart), orden y manifiestos | Identidades, metadatos y contratos de datos. |
| Archivos/persistencia | [`MusicFiles`](../lib/data/music_files.dart), [`LibraryScanner`](../lib/data/library_scanner.dart), [`LocalStore`](../lib/data/local_store.dart) | Selección/escaneo, adaptación de IO y JSON privado con escrituras serializadas. |
| Reproducción | [`MusicHandler`](../lib/playback/music_handler.dart), [`native_audio_player.dart`](../lib/playback/native_audio_player.dart) | Cola, selección, estado multimedia, sesión y backend de plataforma. |
| Extensiones | [`lib/extensions`](../lib/extensions) | Paquetes, catálogo, permisos, propietarios de capacidades, ejecución y contratos de UI. |
| Fuentes/descargas | [`lib/sources`](../lib/sources) | Resolución genérica, broker de audio, transferencias y enriquecimiento/exportación. |
| Letras | [`LyricsController`](../lib/lyrics/lyrics_controller.dart), lectura/etiquetado en `lib/data` | Material local, caché privada y proveedor autorizado. |
| Plataforma | [`lib/platform`](../lib/platform), [`Android`](../android/app/src/main/kotlin/com/example/rp_music), [`Windows`](../windows/runner) | Canales, widgets, ciclo de vida y handoff a complementos. |
| Actualización | [`lib/updates`](../lib/updates) | Consulta de versiones/canales y flujo según capacidades reales de instalación. |

`lib/app` tiene responsabilidades amplias y existe deuda de separación. Esta tabla identifica responsabilidades, no garantiza desacoplamiento completo; ver los [hallazgos de auditoría](AUDITORIA-CODIGO-ACTUAL.md).

## Flujo local

```text
Carpeta elegida → MusicFiles / LibraryScanner → LibraryController
                                                  ↕
                                              LocalStore
                                                  ↓
Interfaz → selección/cola → MusicHandler → backend de audio
```

1. El arranque carga el catálogo guardado, no fuerza un escaneo nuevo.
2. Elegir raíz o actualizar inicia descubrimiento/lectura progresivos con caché. Ante fallo del escaneo se conserva la copia estable anterior.
3. Seleccionar una pista define la cola y solicita la carga al motor.
4. Las generaciones descartan varios resultados obsoletos; no eliminan todas las carreras ni cancelan necesariamente el trabajo subyacente. A04/A05 de la auditoría siguen abiertos.
5. Restaurar sesión filtra pistas locales disponibles y no inicia reproducción.

## Persistencia y datos remotos

El almacenamiento principal es JSON en el soporte privado de la aplicación, no una base relacional:

| Ubicación | Contenido principal |
| --- | --- |
| `v2/library.json` | Raíz/catálogo, favoritos, listas, preferencias y metadatos remotos referenciados por favoritos/listas cuando corresponde. |
| `v2/session.json` | IDs de cola, pista/posición, aleatorio/repetición e historial. |
| `v2/updates.json` | Estado y preferencias del actualizador. |
| `v2/playlist_covers` | Imágenes propias de listas. |
| `v3/extensions.json` | Registro de programas, permisos, datos privados y recuperación. |

`v2`/`v3` son nombres de carpetas: no equivalen automáticamente al campo `schema` de cada archivo. Las URL firmadas/temporales no se deben tratar como identidad estable. Guardar metadatos remotos o IDs no garantiza restaurar una fuente online completa.

El candidato local A01 añade validación completa de la biblioteca antes de publicarla y recuperación desde respaldo ante datos o esquema inválidos. Al guardar tras recuperar, conserva el archivo rechazado como `.rejected` (con sufijo numérico si ya existe) sin reemplazar el respaldo válido por él. Sin copia válida, bloquea el guardado para preservar los originales. Los otros consumidores de `LocalStore` mantienen su carga genérica. Evidencia y límites: [Biblioteca y reproducción](../boveda/03%20Biblioteca%20y%20reproduccion.md). A06 sigue fuera de esta corrección; esto no garantiza transacciones ni tolerancia universal a cortes de energía.

## Audio y diferencias de plataforma

- **Android:** `just_audio`, `audio_session` y `audio_service`, servicio multimedia y canales nativos. La copia local de `audio_service` tiene [dos ajustes documentados](../third_party/audio_service/RP-MUSIC-PATCH.md); no sustituirla sin revisar y repetir sus pruebas.
- **Windows:** backend `media_kit`/libmpv seleccionado por la fábrica de audio. La distribución necesita sus componentes nativos y licencias, no solo el EXE.
- El diagnóstico, los codecs probados y el comportamiento de controles del sistema tienen evidencia específica por versión. No deducir DSP, DAC, gapless o compatibilidad universal de la elección del motor.

## Extensiones: el anfitrión conserva el control

Conviven API 1 declarativa, API 2 Dart/`dart_eval` y API 3 JavaScript/QuickJS. `ProgramController` administra habilitación, permisos, propietarios y recuperación; los runtimes ejecutan contratos acotados. El anfitrión interpreta árboles/datos permitidos: no son widgets Flutter arbitrarios, Node, HTML libre ni acceso al código compilado.

```text
Paquete autorizado → runtime/contrato → capacidades del anfitrión
                              ├─ biblioteca/listas
                              ├─ pantalla nativa permitida
                              └─ HTTP/resolución → broker → MusicHandler
```

Permisos, límites y revisiones ayudan a contener fallos, pero los isolates no son aislamiento de proceso ni cuota dura de RAM. Un hash comprueba bytes, no autoría. La validación preliminar de un servidor público no asegura por sí sola la conexión efectiva; A02 sigue abierto.

Contratos: [API 2](EXTENSIONES-API-2.md), [API 3](EXTENSIONES-API-3.md), [red/audio API 3](EXTENSIONES-API-3-RED.md).

## Fronteras entre repositorios

| Repositorio | Le corresponde | No incorporar aquí |
| --- | --- | --- |
| `rp_music` | Reproductor, SDK, permisos, IO/red/UI genéricos y fixtures sintéticos del motor. | Clientes/parsers específicos nuevos de un proveedor ni el motor del editor. |
| `rp-music-extensions` | Proveedores, paquetes `.rpmx`, catálogo, recursos y pruebas específicas. | Sus paquetes dentro del APK/ZIP o releases de RP Music. |
| `rp_edits` | Editor y motor audiovisual independientes. | Su implementación dentro del reproductor o del catálogo `.rpmx`. |

Existe material heredado de prototipos en ejemplos/pruebas del principal; la separación es una regla para el trabajo actual, no una afirmación de que nunca hubo deuda histórica. Consultar la [decisión mantenida](../boveda/04%20Extensiones.md).

## Complementos multimedia y evolución pendiente

El candidato local usa `MediaToolRequest`/`MediaToolPlatform` y el puente Android para abrir aplicaciones compatibles con firma coincidente y acceso de lectura acotado. RP Edits se instala por separado; el editor Windows no está implementado. La caché de preparación, su limpieza y la planificación nativa tienen límites auditados —A08/A09—; no prometer cuota total o borrado automático exacto a las 24 horas.

La cuenta/sincronización, edición general de etiquetas, cola editable, gapless/fundido y ecualizador no se deducen de este mapa: siguen como trabajo futuro. Cada cambio debe contrastar código, contratos y pruebas, y mantener separados hechos, propuestas y evidencia.
