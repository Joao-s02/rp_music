# Arquitectura técnica y plan de implementación

> Documento histórico: sus propuestas no son la especificación vigente. La entrevista posterior se consolida en [la bóveda de contexto](boveda/00%20Inicio.md). Consultarla antes de usar esta arquitectura; paquetes, alcance web y planificación de extensiones deben reevaluarse.

## Reproductor musical Flutter local-first para Windows, Android y web

La arquitectura recomendada es una aplicación Flutter modular, con un único coordinador de reproducción, biblioteca incremental y persistencia compartida mediante Drift. Windows y Android reproducen archivos mediante capacidades nativas; web usa archivos autorizados por el usuario y declara explícitamente sus límites.

La conversación recuperada contiene las solicitudes originales, pero las respuestas anteriores aparecen como referencias sin contenido accesible. Este documento completa los componentes solicitados sin atribuir detalles a esas respuestas.

## 1. Decisiones y alcance del MVP

“Extremadamente optimizado” debe convertirse en presupuestos medibles. No conviene empezar con un motor de audio propio, un sistema de plugins o una arquitectura distribuida.

| Área | Decisión |
|---|---|
| Arquitectura | Monolito modular con puertos y adaptadores |
| UI | Flutter, diseño adaptable y listas virtualizadas |
| Estado | Riverpod, con suscripciones pequeñas y selectivas |
| Audio | `just_audio`, detrás de un contrato propio |
| Windows | Backend adicional de `just_audio`, elegido mediante prueba comparativa |
| Android | `audio_service` y `audio_session` |
| Datos | Drift + SQLite nativo; Drift + SQLite WASM en web |
| Archivos web | Handles cuando existan; selección temporal como alternativa universal |
| Trabajo pesado | Isolate nativo / workers web |
| Personalización | Tokens visuales y preferencias declarativas |
| Nube | Fuera del MVP |

`just_audio` necesita una implementación adicional en Windows y sus capacidades varían por plataforma; no se debe inferir paridad por compartir API. [Documentación de just_audio](https://pub.dev/packages/just_audio).

### Incluido en el MVP

- Importar archivos y fuentes locales.
- Biblioteca por canciones, álbumes y artistas.
- Buscar, ordenar, favoritos y playlists.
- Reproducir, pausar, buscar posición, siguiente/anterior.
- Cola editable, repetición y aleatorio.
- Restaurar cola y posición, sin reproducir automáticamente al iniciar.
- Carátulas y metadatos básicos.
- Android: reproducción con pantalla apagada y controles del sistema.
- Windows: controles multimedia y funcionamiento minimizado.
- Web: reproducción local, persistencia del catálogo y reconexión de archivos.
- Tema claro/oscuro, color, densidad y atajos dentro de la aplicación.

Posterior al MVP: ecualizador multiplataforma, crossfade, normalización de volumen, visualizadores, edición de etiquetas originales, letras sincronizadas, sincronización entre dispositivos y extensiones ejecutables.

Gapless será una capacidad opcional comprobada por backend, no un requisito universal, especialmente en web.

## 2. Módulos y dirección de dependencias

```text
UI Flutter
    ↓
Controladores de aplicación
    ↓
Dominio y contratos
    ↑
Adaptadores de audio, archivos, datos e integración del sistema
```

El dominio no importa Flutter, Drift, `dart:io` ni paquetes de reproducción.

| Módulo | Responsabilidad |
|---|---|
| `playback` | Estado, comandos, reproducción y recuperación |
| `queue` | Orden lógico, aleatorio, repetición y navegación |
| `library` | Fuentes, indexación, disponibilidad y consultas |
| `metadata` | Etiquetas, duración y carátulas |
| `playlists` | Listas, favoritos y exportación |
| `settings` | Preferencias y personalización |
| `platform_media` | MediaSession, SMTC y controles web |
| `storage` | Base de datos, migraciones y cachés |
| `diagnostics` | Métricas locales y reporte exportable |

No es necesario crear un paquete independiente por módulo. Para el MVP bastan carpetas con límites comprobados en revisión.

### Árbol propuesto

```text
lib/
  main.dart
  bootstrap/
    composition_root.dart
    platform_bindings.dart
  app/
    app.dart
    navigation.dart
    theme/
  core/
    errors/
    ids/
    diagnostics/
    cancellation/
  features/
    playback/
      domain/
        audio_engine.dart
        playback_snapshot.dart
        playable_source.dart
        playback_failure.dart
      application/
        playback_coordinator.dart
        playback_controller.dart
      infrastructure/
        just_audio_engine.dart
      presentation/
    queue/
      domain/
      application/
        queue_controller.dart
      presentation/
    library/
      domain/
        library_repository.dart
        source_provider.dart
        source_resolver.dart
      application/
        library_controller.dart
        scan_scheduler.dart
        incremental_indexer.dart
      infrastructure/
        drift_library_repository.dart
      presentation/
    metadata/
      domain/
        metadata_reader.dart
      infrastructure/
    playlists/
    settings/
  infrastructure/
    database/
      app_database.dart
      tables/
      daos/
      migrations/
      connection_native.dart
      connection_web.dart
    files/
      windows/
      android/
      web/
    media_controls/
      android_audio_handler.dart
      windows_smtc_bridge.dart
      web_media_session_bridge.dart
    cache/
android/
windows/
web/
  sqlite3.wasm
  drift_worker.dart.js
  manifest.json
  # service worker generado o mantenido y probado explícitamente
test/
  unit/
  database/
  contracts/
  widgets/
integration_test/
benchmark/
  fixtures/
  scenarios/
```

Los imports condicionales seleccionan implementaciones. Un widget no pregunta directamente por `Platform.isWindows`.

## 3. Contratos de audio

El contrato debe expresar capacidades y estados reales, sin copiar toda la API del paquete.

```dart
abstract interface class AudioEngine {
  AudioCapabilities get capabilities;
  Stream<PlaybackSnapshot> get snapshots;

  Future<void> load(PlayableSource source, Duration position);
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> setVolume(double volume);
  Future<void> stop();
  Future<void> dispose();
}

abstract interface class SourceResolver {
  Future<SourceLease> resolve(TrackLocation location);
}

abstract interface class SourceLease {
  PlayableSource get source;
  Future<void> release();
}
```

`PlayableSource` es una unión tipada:

- Archivo nativo autorizado.
- URI Android `content://`.
- URL `blob:` web.
- Archivo administrado por la aplicación.

El dominio conserva un identificador de ubicación; el resolvedor obtiene la fuente concreta al reproducir.

`SourceLease` controla recursos temporales: URL de objeto, descriptor o copia temporal. Se libera cuando el motor deja de utilizarla, no simplemente cuando cambia la selección visual.

### Estado de reproducción

```text
PlaybackSnapshot
  sessionId
  sourceGeneration
  trackId
  processing: idle | loading | ready | buffering | completed | failed
  playIntent: bool
  position
  duration: nullable
  volume
  failure: nullable
```

Separar intención de reproducción y estado de procesamiento evita mostrar “sonando” durante carga o buffering. Este modelo coincide con la distinción que documenta `just_audio`. [Modelo de estado](https://pub.dev/packages/just_audio#the-state-model).

### Reglas del coordinador

`PlaybackCoordinator` es el único propietario del motor:

1. Recibe comandos desde UI y controles del sistema.
2. Resuelve ubicaciones y permisos.
3. Serializa cambios de pista.
4. Descarta resultados de cargas anteriores mediante una generación.
5. Actualiza cola, sesión persistida y controles externos.
6. Normaliza errores.

No bloquear la cola de comandos esperando a que termine `play()`. En algunos backends ese futuro puede permanecer pendiente durante la reproducción. Pausa y siguiente deben seguir disponibles.

Los seek consecutivos se agrupan conservando el último. Cambiar de pista invalida resoluciones pendientes.

Errores tipados:

```text
permissionDenied
sourceMissing
sourceDisconnected
unsupportedFormat
corruptMedia
storageUnavailable
backendFailure
userActivationRequired
```

Un archivo defectuoso no debe provocar un bucle infinito de saltos. Tras tres errores consecutivos, detener y ofrecer recuperación.

### Cola

- Cada entrada tiene `entryId`, aunque una canción aparezca varias veces.
- Orden original y orden aleatorio son explícitos.
- Persistir semilla, revisión y entrada actual.
- La cola lógica puede contener miles de IDs.
- El backend recibe una ventana pequeña cuando sea necesario.
- Si se exige gapless, esa ventana debe prepararse como secuencia nativa; cargar pistas individualmente no garantiza continuidad.

## 4. Adaptadores por plataforma

### Android

Audio: `just_audio` + `audio_service`; `audio_session` gestiona foco e interrupciones.

`AppAudioHandler` traduce controles externos al mismo coordinador. Publica pista, estado y acciones habilitadas. No mantiene una segunda cola independiente.

La configuración debe cubrir servicio foreground de reproducción, permisos correspondientes al SDK objetivo, notificación y ciclo de vida. No añadir además un servicio Media3 propio mientras `audio_service` sea propietario de esa integración. Si se sustituye, debe sustituirse de forma completa. [audio_service](https://pub.dev/packages/audio_service), [reproducción en segundo plano de Android](https://developer.android.com/media/media3/session/background-playback).

Biblioteca:

- MediaStore para audio compartido.
- SAF para archivos o carpetas seleccionados.
- Persistir permisos de URI cuando el proveedor lo permita.
- Usar `content://`; no convertirlo en una supuesta ruta física.
- Resolver pérdida de permiso, tarjeta retirada y proveedor desaparecido.
- Pedir permisos según versión de Android y flujo elegido; evitar acceso general al almacenamiento.

Interrupciones:

- Pérdida permanente de foco: pausar.
- Interrupción temporal: seguir política de sesión.
- Auriculares desconectados: pausar.
- Reanudar únicamente si existía intención de reproducir y la interrupción permite hacerlo.
- No prometer reproducción después de un cierre forzado.

### Windows

Probar primero un backend basado en capacidades de Windows y compararlo con `just_audio_media_kit`:

| Alternativa | Ventaja esperada | Riesgo |
|---|---|---|
| `just_audio_windows` | Menor dependencia de decodificadores distribuidos | Códecs y comportamiento del sistema |
| `just_audio_media_kit` | Mayor cobertura de formatos | Tamaño, binarios y licencias |

La selección se cierra en el primer hito con medidas de memoria, formatos, seek y distribución. No incorporar ambos en producción sin una necesidad comprobada. [Opciones de Windows](https://pub.dev/packages/just_audio#Windows), [adaptador media_kit](https://pub.dev/packages/just_audio_media_kit).

Para SMTC, usar un plugin mantenido o un puente pequeño C++/WinRT asociado a la ventana. Todos sus eventos llaman al coordinador. Publicar metadatos y habilitar únicamente acciones válidas. [SMTC de Microsoft](https://learn.microsoft.com/en-us/windows/apps/develop/media-playback/system-media-transport-controls).

- Minimizar mantiene el audio.
- Cerrar termina la aplicación por defecto.
- “Cerrar a bandeja” queda como preferencia posterior.
- Watchers de carpetas generan candidatos a revisión; no sustituyen la reconciliación.
- Resolver Unicode, rutas largas, archivos bloqueados y unidades desconectadas.
- Evitar seguir enlaces o junctions recursivamente por defecto.

### Web

La experiencia web tiene tres modalidades:

| Modalidad | Persistencia del acceso | Uso |
|---|---|---|
| Archivos seleccionados | Habitualmente temporal | Compatibilidad básica |
| Handles persistidos | Condicionada a API y permisos | Chromium cuando esté disponible |
| Copia administrada en OPFS | Sujeta a almacenamiento del origen | Importación offline opcional |

Los handles pueden almacenarse en IndexedDB, pero conservarlos no garantiza que el permiso siga concedido. OPFS contiene archivos privados del origen, no referencias automáticas a las carpetas originales. [File System API](https://developer.mozilla.org/en-US/docs/Web/API/File_System_API), [OPFS](https://developer.mozilla.org/en-US/docs/Web/API/File_System_API/Origin_private_file_system).

Flujo del MVP:

1. Usuario selecciona archivos.
2. Se indexan metadatos sin subir el audio.
3. Se crean URLs `blob:` únicamente para pistas necesarias.
4. Al recargar, se intenta resolver el handle.
5. Si no existe acceso, la canción aparece como “requiere reconectar”.
6. Una nueva selección permite vincular archivos mediante candidatos y confirmación ante ambigüedad.

No almacenar URLs `blob:` como ubicaciones persistentes. Tampoco cargar todos los archivos mediante `readAsBytes()`.

La copia permanente de audio será opcional y posterior al flujo básico: consultar cuota, mostrar espacio requerido y manejar fallos. `persist()` reduce riesgo de desalojo si se concede; no equivale a una copia de seguridad. [Cuotas y desalojo](https://developer.mozilla.org/en-US/docs/Web/API/Storage_API/Storage_quotas_and_eviction_criteria).

Añadir:

- Activación inicial por gesto del usuario.
- Media Session web mediante detección de capacidades.
- Una pestaña propietaria de reproducción, con coordinación entre pestañas.
- Si no puede garantizarse exclusión, exigir cierre de la pestaña anterior.
- PWA con shell y recursos esenciales disponibles offline.
- No prometer continuidad con navegador cerrado o suspensión del sistema.

## 5. Drift, SQLite e IndexedDB

Recomendación: compartir esquema y consultas con Drift en las tres plataformas.

- Android/Windows: SQLite en ejecución de base de datos fuera del isolate de UI.
- Web: SQLite WASM en worker, con almacenamiento seleccionado por Drift.
- IndexedDB adicional: handles de archivos y datos web que no encajan en SQL.

Drift puede utilizar OPFS y recurrir a IndexedDB según capacidades. Deben desplegarse WASM y worker compatibles, servir el MIME correcto y comprobar el modo efectivo de persistencia. [Configuración web de Drift](https://drift.simonbinder.eu/platforms/web/).

No mantener simultáneamente un catálogo SQL nativo y otro catálogo NoSQL web: duplicaría consultas, migraciones y pruebas.

### Esquema lógico

Todos los tiempos se almacenan como enteros UTC; duraciones como milisegundos. Los IDs internos son independientes de rutas.

| Tabla | Campos principales |
|---|---|
| `library_sources` | `id`, `kind`, `locator`, `status`, `last_successful_scan`, `scan_generation` |
| `tracks` | `id`, `title`, `album_id?`, `duration_ms?`, `track_no?`, `disc_no?`, `year?`, `artwork_id?` |
| `artists` | `id`, `name`, `sort_name` |
| `track_artists` | `track_id`, `artist_id`, `role`, `position` |
| `albums` | `id`, `title`, `album_artist?`, `year?`, `grouping_key` |
| `track_locations` | `id`, `track_id`, `source_id`, `locator_key`, `size`, `modified_at?`, `provider_version?`, `fingerprint?`, `availability`, `last_seen_generation` |
| `playlists` | `id`, `name`, `created_at`, `updated_at` |
| `playlist_entries` | `id`, `playlist_id`, `track_id`, `position` |
| `track_user_state` | `track_id`, `favorite`, `play_count`, `last_played_at?` |
| `queue_entries` | `entry_id`, `track_id`, `position`, `shuffle_position` |
| `playback_session` | `id`, `queue_revision`, `current_entry_id?`, `position_ms`, `repeat_mode`, `shuffle_seed?` |
| `artworks` | `id`, `content_hash`, `cache_key`, `width`, `height`, `byte_size` |
| `settings` | `key`, `value_json`, `schema_version` |
| `scan_runs` | `id`, `source_id`, `generation`, `status`, `cursor?`, `counters_json` |

Índices:

- Único por `(source_id, locator_key)`.
- Ordenación por `(title_sort, id)`; añadir `title_sort` al esquema físico como clave normalizada de ordenación.
- Ubicaciones por `(source_id, last_seen_generation)`.
- Playlist por `(playlist_id, position)`.
- Relaciones de artistas en ambos sentidos.

Activar claves foráneas. Playlist y cola usan entradas independientes para admitir duplicados.

La identidad de álbum no se deduce únicamente del título. Una huella parcial sirve para encontrar candidatos, no para fusionar archivos automáticamente.

### Búsqueda y consultas

- Páginas iniciales de 100 registros, ajustables por medición.
- Paginación por cursor con desempate estable.
- Consultas que devuelven únicamente columnas necesarias.
- Búsqueda con debounce aproximado de 200 ms.
- FTS5 solo después de verificar soporte en los binarios nativos y WASM elegidos.
- Si se usa FTS, mantener sincronización y reconstrucción comprobables.
- No observar la biblioteca completa para actualizar una fila.

### Migraciones y recuperación

- Versiones de esquema explícitas.
- Pruebas desde cada versión publicada.
- Migraciones SQL transaccionales cuando corresponda.
- Copia consistente antes de migraciones destructivas.
- Preferencias y playlists exportables en JSON versionado.
- Las cachés se regeneran; los datos del usuario no.
- En web, migrar SQL y el almacén de handles de forma idempotente: no existe una transacción conjunta entre ambos.

## 6. Biblioteca incremental

```text
Enumerar fuente
  → detectar candidatos
  → comparar cambios
  → extraer metadatos necesarios
  → escribir por lotes
  → publicar progreso
  → reconciliar ausencias
```

### Algoritmo

1. Crear generación de escaneo por fuente.
2. Enumerar sin cargar el listado completo en memoria.
3. Comparar tamaño, fecha y versión del proveedor cuando existan.
4. Para archivos sin cambios, actualizar presencia sin releer etiquetas.
5. Para nuevos o modificados, extraer metadatos con concurrencia limitada.
6. Escribir lotes iniciales de 100–300 registros.
7. Reducir actividad si la reproducción o UI superan sus presupuestos.
8. Marcar ausencias solamente después de completar correctamente la enumeración.
9. Si la fuente está desconectada, marcar la fuente; conservar canciones y playlists.

Un escaneo cancelado, permiso denegado o fallo parcial no debe convertir toda la biblioteca en archivos eliminados.

### Estrategia de recursos

- Un coordinador de escaneo por fuente.
- Concurrencia inicial: 1–2 tareas de metadatos.
- Cola de trabajo acotada y cancelable.
- Lecturas por rangos cuando formato y API lo permitan.
- Carátulas grandes se procesan con límites de bytes y dimensiones.
- Miniaturas pequeñas para listas y una resolución mayor para reproducción.
- Caché LRU en disco y memoria, ambas con presupuesto.
- Descartar resultados de metadatos si el archivo cambió durante el análisis.

Windows usa watchers con debounce y reescaneos de reconciliación. Android usa cambios de MediaStore cuando estén disponibles, más reconciliación. Web reenumera al abrir o por acción del usuario; no promete vigilancia continua de carpetas.

## 7. Controladores y personalización

| Controlador | Función |
|---|---|
| `PlaybackController` | Proyección de estado para UI y comandos |
| `QueueController` | Edición y persistencia de cola |
| `LibraryController` | Filtros, páginas y selección |
| `ScanController` | Progreso, cancelación y reintentos |
| `PlaylistController` | CRUD y orden |
| `SettingsController` | Validación y persistencia |
| `PlatformMediaBridge` | Traducción de eventos del sistema |

El servicio de reproducción vive durante la sesión de aplicación. Navegar entre pantallas no lo recrea.

La posición actualiza solamente la barra y el tiempo. No reconstruye listas, carátulas o la pantalla completa. En segundo plano no se mantiene un temporizador visual innecesario.

Personalización MVP:

- Claro, oscuro y sistema.
- Color de acento.
- Densidad.
- Tamaño de texto compatible con accesibilidad.
- Columnas visibles en escritorio.
- Reducción de movimiento.
- Atajos configurables dentro de la app.

Guardar preferencias mediante un esquema validado. Los temas importados contienen datos, sin scripts ni expresiones ejecutables.

## 8. Seguridad y privacidad

- Audio local sin subida ni analítica por defecto.
- Acceso de solo lectura a archivos originales en el MVP.
- Eliminar de biblioteca no elimina del dispositivo.
- SQL parametrizado.
- Validar JSON importado, tamaños, cantidades y versiones.
- Tratar etiquetas y carátulas como entradas no confiables.
- Límites de lectura, memoria y tiempo; aislamiento adicional para parsers nativos que no puedan cancelarse.
- No ejecutar rutas ni comandos derivados de etiquetas.
- Redactar rutas, nombres privados y URI en diagnósticos exportados.
- No solicitar permisos de red o almacenamiento más amplios de lo necesario.
- HTTPS y política CSP compatible con Flutter, workers y `blob:` en web.
- Sin scripts externos innecesarios.
- Revisar licencias y avisos de binarios de audio.
- Exportaciones web sin handles reutilizables ni promesas de trasladar permisos entre dispositivos.

SQLite no está cifrado por defecto. Para el MVP se acepta almacenamiento protegido por el sistema operativo; cifrado específico requiere un modelo de amenaza y evaluación posterior.

## 9. Métricas y criterios de rendimiento

Estos números son objetivos iniciales, sujetos a validación en el primer hito.

Medir builds release/profile, con equipo, sistema, navegador, códec, caché y tamaño de biblioteca registrados.

Referencias iniciales: Android de gama media con 4 GB de RAM, Windows con SSD y 8 GB, y Chrome/Edge en ese Windows.

| Métrica | Objetivo inicial |
|---|---|
| Biblioteca ya indexada visible | p95 ≤ 1,5 s nativo; ≤ 3 s web con shell cacheado |
| Play → primer audio, archivo accesible | p95 ≤ 500 ms nativo; ≤ 800 ms web |
| Búsqueda, 10.000 canciones | p95 ≤ 100 ms de consulta, sin contar debounce |
| Scroll a 60 Hz | p95 de UI y raster por debajo de 16,7 ms |
| Memoria estable con biblioteca de 10.000 | Android ≤ 180 MB; Windows ≤ 220 MB como presupuesto inicial |
| CPU reproduciendo MP3, sin escaneo | Media ≤ 3 % del total del equipo de referencia |
| Escaneo sin cambios, SSD, 10.000 archivos | ≤ 15 s; cero relecturas de etiquetas |
| Sesión prolongada | 2 h sin fallos de reproducción atribuibles a la app |
| Fugas | Sin crecimiento sostenido tras 200 cambios de pista |

En web medir memoria por separado con las herramientas del navegador; no compararla directamente con RSS nativo.

La latencia del motor no demuestra por sí sola “primer audio”: validar con captura o loopback en una muestra de pruebas.

Instrumentación local:

- Inicio, consultas, scans y cargas.
- Profundidad de colas y tareas.
- Tamaño y aciertos de caché.
- Errores por backend.
- Frames lentos.
- Memoria y CPU en benchmarks.

No hacer escrituras por cada avance de posición. Guardar cada 10–15 segundos y en pausa/cambio, aceptando una pérdida máxima documentada ante terminación abrupta.

## 10. Pruebas

### Unitarias

- Aleatorio, repetición y duplicados.
- Cargas concurrentes y eventos obsoletos.
- Seek durante carga y siguiente durante reproducción.
- Restauración sin autoplay.
- Reconciliación tras escaneo parcial.
- Límites y recuperación de caché.

### Base de datos

- Migraciones reales.
- Integridad referencial.
- Playlists y cola.
- Búsqueda y paginación estable.
- Recuperación después de cierre inesperado.

### Contratos por adaptador

- Carga, pausa, seek, fin y liberación.
- Archivo ausente, corrupto o sin permiso.
- Duración desconocida.
- Cambio de pista sin recursos retenidos.

### Integración

- Android: pantalla apagada, foco, Bluetooth, auriculares, notificación y permisos revocados.
- Windows: SMTC, minimización, rutas Unicode, unidad retirada y suspensión.
- Web: recarga, reconexión, cuota agotada, dos pestañas, offline y actualización de PWA.

### Corpus de audio

MP3 CBR/VBR, AAC/M4A, FLAC, WAV y Ogg como candidatos, además de archivos corruptos y carátulas grandes. Publicar una matriz de formatos efectivamente comprobados por plataforma; la extensión no garantiza compatibilidad.

Las pruebas automatizadas con motor falso verifican lógica. Las pruebas de audio real requieren dispositivos y salida comprobable.

## 11. Dependencias y riesgos

| Dependencia | Uso | Riesgo / decisión |
|---|---|---|
| Flutter/Dart | UI y aplicación | Fijar versión y actualizar por ciclos |
| Riverpod | Estado e inyección | Evitar reconstrucciones amplias |
| `just_audio` | Audio común | Diferencias entre backends |
| `audio_service` | Android background y controles | Configuración y restricciones del sistema |
| `audio_session` | Foco/interrupciones | Validación física obligatoria |
| Backend Windows | Decodificación | Elegir por evidencia |
| Drift + sqlite3 | Catálogo | Migraciones y binarios compatibles |
| `drift_dev` + `build_runner` | Generación | Comprobar archivos generados |
| `package:web` | APIs del navegador | Detección de capacidades |
| Selector de archivos | Interacción básica | No asumir soporte de carpetas o permisos durables |
| Parser de metadatos | Tags y carátulas | Probar rangos, límites y plataformas |
| Puente SMTC | Windows | Mantenimiento nativo pequeño |

No fijar versiones numéricas hasta completar la prueba de compatibilidad. Después: versión Flutter registrada, `pubspec.lock` versionado y actualización revisada. No usar restricciones `any`.

Riesgos bloqueantes del primer hito:

1. URI SAF reproducible sin copiar archivos grandes.
2. SMTC con el backend Windows elegido.
3. Handles web después de recargar.
4. Parser de etiquetas sin cargar el archivo completo.
5. Persistencia Drift web en el hosting real.
6. Memoria y tamaño final del backend Windows.

## 12. CI/CD

### Cada PR

- Formato y análisis estático.
- Unitarias, contratos y migraciones.
- Generación de código sin cambios pendientes.
- Builds Android, Windows y web.
- Smoke web con selección de archivos.
- Auditoría de dependencias y licencias.

### Pruebas periódicas

- Benchmarks comparables.
- Corpus completo de formatos.
- Dispositivos Android físicos.
- Windows con controles del sistema.
- Chrome/Edge para capacidades avanzadas y Firefox para el flujo básico.

### Publicación

- Android: AAB firmado y canal interno antes de producción.
- Windows: MSIX firmado cuando corresponda, más paquete de prueba.
- Web: despliegue previo, pruebas offline y promoción.
- Secretos de firma fuera del repositorio.
- Artefactos versionados, hashes, símbolos y avisos de licencia.
- WASM/worker y shell se actualizan coordinadamente.
- Probar rollback frente a cambios de esquema: volver al ejecutable anterior puede ser incompatible con una base migrada.

## 13. Hitos del MVP

Estimación orientativa: 8–10 semanas para dos desarrolladores con apoyo parcial de QA, ajustada después del primer hito.

| Hito | Entrega | Criterio de salida |
|---|---|---|
| H0 · Semana 1 | Pruebas técnicas en tres plataformas | Audio local, persistencia y controles críticos comprobados |
| H1 · Semana 2 | Núcleo y contratos | Cola, estado y recuperación con pruebas |
| H2 · Semanas 3–4 | Catálogo incremental | 10.000 pistas, búsqueda y escaneos seguros |
| H3 · Semanas 5–6 | Integración de plataforma | Android background, Windows SMTC y reconexión web |
| H4 · Semana 7 | Personalización y accesibilidad | Preferencias persistentes y navegación por teclado |
| H5 · Semanas 8–10 | Optimización y distribución | Presupuestos, pruebas prolongadas y paquetes candidatos |

### Aceptación final

El MVP se acepta cuando:

- Funciona sin cuenta ni servidor.
- Reproduce formatos publicados en su matriz comprobada.
- Biblioteca, playlists y preferencias sobreviven al reinicio.
- Un escaneo incompleto no elimina referencias.
- Archivos inaccesibles se distinguen de archivos eliminados.
- Android reproduce con pantalla apagada y responde a controles externos.
- Windows responde a SMTC mientras está minimizado.
- Web explica y resuelve la reconexión de archivos.
- La PWA abre offline después de su instalación/cache inicial.
- No modifica archivos originales ni realiza subidas de audio.
- Cumple los presupuestos acordados en equipos de referencia.
- Migraciones, recuperación y distribución están verificadas.

La primera implementación debe ser una porción vertical: seleccionar un archivo, persistir su referencia, reproducirlo, pausarlo desde el sistema y restaurarlo después de reiniciar. Resolver esa cadena en las tres plataformas permite confirmar las decisiones más costosas antes de construir toda la biblioteca y la personalización.
