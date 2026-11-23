# Auditoría del código actual de RP Music

**Conclusión:** el proyecto tiene una separación funcional reconocible y protecciones útiles, pero necesita reforzar recuperación de datos, cancelación de operaciones, coherencia del estado y límites de integración. Hay responsabilidades entrelazadas y lógica duplicada con consecuencias concretas; no hay evidencia suficiente para calificar todo el proyecto como «código espagueti» ni para recomendar una reescritura.

**Verificación final:** análisis sin incidencias y repetición autorizada de la suite con **165 aprobadas, cero fallidas y una optativa omitida**. El bloqueo de carga QuickJS se resolvió usando las DLL existentes con PATH temporal, sin modificar código. La primera ejecución fallida se conserva en la sección 5; los doce hallazgos no se consideran corregidos por obtener una suite verde.

## 1. Alcance, referencia y cómo leer este informe

- **Fecha:** 2026-10-30.
- **Base Git:** `fc4b0e9`, rama `main`.
- **Código auditado:** árbol de trabajo local, aplicación `0.3.17+26`, incluidos cambios sin commit y archivos nuevos de integración multimedia. No equivale exclusivamente al commit base ni a la release publicada `0.3.16`.
- **Solicitud:** auditar el código, señalar debilidades y optimizaciones, proponer mejoras y definir mínimos de aceptación. **No se autorizaron ni realizaron correcciones de código.**
- **Método:** inventario, dos revisiones de fuente por áreas, contraste directo de los flujos relevantes y comprobaciones automatizadas existentes. Se inventariaron 66 archivos Dart en `lib/` y 32 archivos `*_test.dart` en `test/`; esas cantidades no significan lectura exhaustiva ni cobertura del 100 %.
- **Áreas examinadas:** estado/biblioteca, persistencia, reproducción, interfaz, letras, extensiones, fuentes/red/descargas, actualizador y puentes de plataforma. Se priorizaron los límites de datos, permisos y operaciones asíncronas.
- **Fuera de alcance:** código del repositorio independiente de extensiones o RP Edits, auditoría exhaustiva de dependencias/CVE, secretos/firma, binarios y prueba manual o instrumental en dispositivos.

Las rutas de evidencia son relativas a la raíz de `rp_music`. Los números de línea corresponden a este árbol de trabajo y pueden desplazarse al editarlo. Los ejemplos de fallo son escenarios deducidos del código: **no se presentan como reproducciones dinámicas realizadas**, salvo que se indique expresamente.

### Prioridad y certeza

| Etiqueta | Significado |
| --- | --- |
| **P1** | Resolver o acotar antes de ampliar la superficie afectada: recuperación de datos o frontera de seguridad. No implica explotación demostrada. |
| **P2** | Defecto funcional o riesgo operacional que conviene corregir en las próximas unidades de trabajo. |
| **P3** | Deuda de mantenibilidad, rendimiento o calidad de pruebas; intervenir de forma incremental. |
| **Confirmado por inspección** | El flujo o la estructura están presentes en el código; no implica reproducción en teléfono. |
| **Condicional** | La consecuencia requiere un intercalado, proveedor o condición externa todavía no reproducidos. |

Los mínimos de aceptación siguientes son **propuestas para trabajos futuros**, no funciones implementadas, requisitos ya aprobados ni resultados de esta auditoría.

## 2. Resumen de hallazgos

| ID | Prioridad | Debilidad | Certeza |
| --- | --- | --- | --- |
| A01 | P1 | Recuperación sintáctica, pero no semántica, de la biblioteca | Confirmado por inspección |
| A02 | P1 | Validación de servidor público desvinculada de la conexión real | Condicional: DNS y comportamiento del motor |
| A03 | P2 | Cancelación Android no cubre la copia final de una descarga | Confirmado por inspección; prueba SAF pendiente |
| A04 | P2 | Quitar una pista puede competir con su selección pendiente | Condicional: intercalado asíncrono |
| A05 | P2 | Resolver una fuente obsoleta bloquea operaciones siguientes | Confirmado por inspección; duración dependiente del resolvedor |
| A06 | P2 | Fallar la persistencia no comunica fracaso al llamador | Confirmado por inspección |
| A07 | P2 | Dos rutas de descarga discrepan al validar respuestas 206 | Condicional: respuesta HTTP inconsistente |
| A08 | P2 | Copias para herramientas multimedia sin cuota agregada/rollback completo | Confirmado por inspección |
| A09 | P2 | Un solo ejecutor Android mezcla trabajos largos y consultas cortas | Confirmado estructuralmente; latencia no medida |
| A10 | P2 | Reproducir una lista puede ignorar el orden visible | Confirmado por inspección |
| A11 | P3 | Estado amplio, reconstrucciones y cálculos derivados repetidos | Confirmado estructuralmente; coste no medido |
| A12 | P3 | Pruebas visuales escriben capturas en carpetas del proyecto | Confirmado por inspección y ejecución de la suite |

**Orden recomendado:** recuperación de datos y frontera de red → coherencia/cancelación → integridad y almacenamiento → refactorizaciones y rendimiento. Las prioridades no prueban que todos los escenarios ocurran en el uso habitual.

## 3. Hallazgos y mínimos de aceptación

### A01 — La recuperación puede aceptar una biblioteca inválida y degradar su respaldo

**Evidencia:** [LocalStore](../lib/data/local_store.dart), líneas 17–29 y 33–45; [LibraryController](../lib/app/library_controller.dart), líneas 153–200.

`LocalStore.load()` devuelve el primer JSON que pueda decodificar como mapa. No comprueba el esquema ni la validez de sus campos. `LibraryController.initialize()` asigna estado progresivamente y hace conversiones que pueden fallar después de haber cambiado campos anteriores. En ese caso no solicita el respaldo. Un esquema desconocido tampoco provoca ese fallback. Al guardar después, la rotación puede reemplazar un respaldo bueno por el principal defectuoso.

**Escenario:** un principal JSON válido contiene `favorites: 42`, una pista mal formada o un esquema no admitido; existe un respaldo correcto. La carga no recupera ese respaldo y puede dejar estado parcial o vacío. Cambiar una preferencia puede consolidar ese estado incompleto.

**Lo que ya está bien:** escrituras serializadas, archivo temporal con `flush`, respaldo y recuperación de corrupción sintáctica. No se afirma que toda persistencia esté desprotegida.

**Propuesta:** decodificar y validar una instantánea completa antes de publicarla; aplicar fallback semántico, no solo sintáctico; preservar una copia válida y conservar el archivo rechazado para diagnóstico sin datos privados en logs.

**Aceptación mínima:**
- Principal truncado, tipo incorrecto en un campo, pista inválida y esquema desconocido se prueban como casos separados.
- Con respaldo válido, cargar produce la instantánea completa de ese respaldo, sin mezclar campos del principal.
- Guardar y reiniciar después conserva al menos una copia válida y recupera los mismos favoritos/listas.
- Sin copia válida, no se sobrescriben silenciosamente los archivos rechazados y se informa recuperación necesaria.

### A02 — Comprobar DNS antes de abrir una URL no fija el destino efectivo

**Evidencia:** [JavascriptScreenService](../lib/extensions/javascript_screen_service.dart), líneas 237–275; [ExtensionSourceBroker](../lib/sources/extension_source_broker.dart), líneas 19–22.

`resolvePublicStream()` resuelve el dominio y verifica que las direcciones sean públicas. Luego `HttpClient.getUrl()` establece una conexión independiente y, finalmente, el reproductor vuelve a abrir la URI devuelta. La dirección comprobada no queda fijada a esas conexiones.

**Riesgo condicional:** un dominio controlable cambia de respuesta entre validación y conexión —DNS rebinding— o el motor utiliza otro destino en su apertura posterior. Alcanzar un destino privado mediante HTTPS depende además de superar TLS para el hostname o del comportamiento concreto del motor. La comprobación preliminar no constituye una barrera SSRF completa. No se realizó una explotación ni se demostró acceso a red privada en esta auditoría.

**Protecciones existentes:** HTTPS, filtros de direcciones y nombres no públicos, comprobaciones de autorización y redirecciones iniciales. El problema es la separación entre validación y uso, no la ausencia total de validación.

**Propuesta:** diseñar un transporte que conecte únicamente con direcciones comprobadas conservando hostname/SNI; estudiar un proxy controlado para el motor nativo. Si se conserva la arquitectura actual, describir honestamente esta frontera como validación preliminar y evaluar su riesgo; cambiar el texto no equivale a cerrar el riesgo técnico.

**Aceptación mínima para considerar resuelto el riesgo:**
- Ensayo determinista con resolución pública→privada verifica el destino real de la conexión, no solo la función de clasificación de IP.
- Cero conexiones a destinos privados durante resolución, reintentos, redirecciones y apertura del audio.
- La reproducción de un servidor público permitido sigue funcionando con validación TLS activa.
- Si no puede garantizarse ese contrato, documentar el riesgo residual y obtener una decisión explícita sobre la capacidad afectada antes de presentarla como frontera segura.

### A03 — Cancelar durante la escritura SAF todavía puede guardar otra canción

**Evidencia:** [AlbumDownload](../lib/sources/album_download.dart), líneas 159–180, 213–214 y 298–300; [MainActivity](../android/app/src/main/kotlin/com/example/rp_music/MainActivity.kt), líneas 179–203.

La cancelación se revisa antes de llamar a `writeDownload`, pero la copia Android usa `copyTo` sin token de cancelación. Al regresar se incrementa el contador de guardadas. El mensaje «La petición en curso terminará sin guardar otra canción» promete más de lo que asegura esa fase.

**Escenario:** pulsar Cancelar mientras se escribe en una SD/proveedor SAF lento. La copia puede terminar y quedar exportada. Retirar autorización de la extensión en esa ventana tampoco interrumpe el commit.

**Propuesta:** trabajos identificables, cancelación cooperativa nativa y una comprobación final antes de confirmar. Borrar el documento creado si la operación se cancela; si el proveedor impide rollback, informar ese resultado real. Mantener la protección ya existente de limpieza ante excepciones.

**Aceptación mínima:**
- Con proveedor SAF controlado, cancelar al 50 % deja cero documentos nuevos y no incrementa `saved`.
- Repetir retirando autorización durante la copia.
- Los archivos anteriores permanecen idénticos; un fallo de limpieza se hace visible, no se oculta como cancelación limpia.
- El mensaje mostrado coincide con las garantías efectivamente implementadas.

### A04 — Selección y eliminación no comparten una única identidad de pista vigente

**Evidencia:** [MusicHandler](../lib/playback/music_handler.dart), líneas 230–251 y 351–377.

`select()` actualiza `tracks/index`, espera `player.pause()` y recién después publica `mediaItem`. `removeTrack()` utiliza ese `mediaItem`, que puede seguir describiendo la selección anterior, para decidir si debe detener e invalidar la carga.

**Intercalado de riesgo:** A publicada → seleccionar B con pausa pendiente → eliminar B → la eliminación considera que la actual es A y no invalida la selección capturada de B. B puede continuar hacia la carga aunque ya no esté en la cola.

**Propuesta:** representar explícitamente selección solicitada y pista cargada; invalidar cualquier operación que dependa de un ID eliminado y reconciliar cola/índice/estado multimedia en la misma transición.

**Aceptación mínima:** con un reproductor falso cuya pausa se pueda bloquear, seleccionar B, eliminar B y liberar la pausa. B no debe cargarse ni reproducirse; índice, cola y `mediaItem` deben ser coherentes. Repetir eliminando otra pista para conservar el comportamiento previo.

### A05 — Descartar un resultado obsoleto no evita que bloquee la cola

**Evidencia:** [MusicHandler](../lib/playback/music_handler.dart), líneas 240–269, 277–292 y 581–600.

Las selecciones se serializan mediante `_operations`. La espera de `onlineSourceLoader` no compite con una señal de cancelación; la interrupción actual cubre la carga posterior del motor. Por eso una resolución vieja puede seguir retrasando una selección local nueva. El cierre también puede esperar esa operación.

**Límite de la conclusión:** las capas externas pueden imponer plazos; no se afirma espera infinita en todos los proveedores. El defecto es que la nueva selección hereda una espera que ya no necesita.

**Propuesta:** cancelar la resolución por generación o desacoplar su espera de las operaciones nuevas, descartando resultados tardíos sin permitir efectos laterales.

**Aceptación mínima:** con resolvedor A sin completar, seleccionar B local y cerrar deben poder finalizar sin liberar A. Completar A después no modifica cola, selección ni estado del reproductor y no inicia audio. Deben conservarse las comprobaciones de autorización existentes.

### A06 — Una operación puede mostrar éxito aunque el guardado haya fallado

**Evidencia:** [LibraryController](../lib/app/library_controller.dart), líneas 204–233 y 399–416; [MusicApp](../lib/app/music_app.dart), líneas 749–764.

`persist()` captura el fallo de `store.save()` y completa normalmente. Sus llamadores no pueden distinguir «cambiado en memoria» de «guardado». Por ejemplo, añadir un álbum puede mostrar «Álbum añadido a la lista» pese al fallo de almacenamiento.

**Protección existente:** hay mensaje de error de guardado. El problema es que coexiste con un contrato de éxito ambiguo y el cambio puede desaparecer al reiniciar.

**Propuesta:** resultado explícito de persistencia o error tipado, estado de cambios pendientes y reintento. No hace falta imponer rollback de toda edición en memoria.

**Aceptación mínima:** store falso que falla: no se muestra éxito de persistencia, se identifica el cambio pendiente y no se oculta el error. Tras un reintento exitoso y reinicio, se recupera exactamente la última edición, sin duplicados.

### A07 — La descarga individual puede aceptar una respuesta 206 incompleta

**Evidencia:** [SourceAudioTransfer](../lib/sources/source_audio_transfer.dart), líneas 55–70, 107–109, 153–163 y 184–189; [SourceDownload](../lib/sources/source_download.dart), línea 17.

`receiveFile()` usa el total de `Content-Range` como longitud esperada. `receive()` verifica la coherencia declarada del rango, pero al terminar compara los bytes solo contra `Content-Length`, si existe. La descarga individual utiliza esta segunda ruta.

**Escenario condicional:** respuesta 206 con `Content-Range: bytes 0-999/1000` y 500 bytes reales, declarados mediante `Content-Length: 500` o enviados sin longitud. La ruta a disco rechaza la discrepancia; la ruta en memoria puede aceptarla si el transporte termina normalmente.

**Propuesta:** compartir una validación de estado/rango/longitud y, progresivamente, el transporte. Los límites actuales de 64 MiB para canciones individuales y 512 MiB para álbumes son restricciones documentadas, no defectos descubiertos aquí.

**Aceptación mínima:** matriz HTTP sintética común para ambas rutas: 200/206 válidos y rango total incompatible con bytes recibidos, con/sin `Content-Length`. Las respuestas incoherentes producen error y cero exportaciones; las válidas conservan audio y metadatos. No aumentar límites silenciosamente para unificar código.

### A08 — La preparación para el editor puede acumular copias privadas

**Evidencia:** [MediaToolsBridge](../android/app/src/main/kotlin/com/example/rp_music/MediaToolsBridge.kt), líneas 26–65.

Se admiten hasta 2 GiB por archivo copiado desde una ruta local; las URI `content://` se transfieren sin copiar ni comprobar aquí su tamaño. La limpieza por antigüedad de las copias se ejecuta al abrir otra solicitud; no hay cuota total propia. Si falla una etapa después de copiar el audio —validación de letras, creación de proyecto o lanzamiento— no se elimina todo lo creado para esa solicitud.

**Impacto:** aperturas repetidas o fallos pueden consumir almacenamiento y retener música/letras más tiempo del necesario. Android puede recuperar caché, pero eso no sustituye una política determinista de la aplicación.

**Propuesta:** directorio por solicitud, rollback completo antes del lanzamiento, cuota agregada y retención explícita compatible con la lectura del complemento. No borrar activos que un proyecto abierto todavía necesita.

**Aceptación mínima:**
- Definir una cuota agregada `Q` y publicarla; diez aperturas y diez fallos consecutivos nunca superan `Q`. Si no cabe otra solicitud, rechazarla antes de copiar.
- Cualquier fallo previo al lanzamiento deja cero archivos de esa solicitud.
- La limpieza no elimina los activos de una solicitud vigente durante su plazo documentado.
- Probar almacenamiento insuficiente y reinicio; no exponer rutas privadas ni ampliar los permisos de lectura existentes.

### A09 — Un ejecutor compartido genera bloqueo entre funciones independientes

**Evidencia:** [MainActivity](../android/app/src/main/kotlin/com/example/rp_music/MainActivity.kt), líneas 23–30, 117–126 y 179–248; [MediaToolsBridge](../android/app/src/main/kotlin/com/example/rp_music/MediaToolsBridge.kt), líneas 26–42.

Escaneo, escrituras SAF, portadas, operaciones del actualizador y preparación para el editor comparten `newSingleThreadExecutor()`. Eso protege el hilo UI, pero una copia o proveedor documental bloqueado retrasa tareas no relacionadas. Comprobar el plazo después de `read()` no interrumpe una lectura bloqueada.

**Propuesta:** separar trabajos largos y consultas breves con concurrencia acotada; añadir cancelación, límites y ownership por ciclo de vida. No reemplazar el ejecutor por un pool ilimitado.

**Aceptación mínima:** bloquear una copia mediante un doble de IO no impide completar una consulta independiente. Objetivo inicial propuesto: respuesta de consultas cortas <1 s en el ensayo controlado. Cancelar debe liberar el trabajo; recrear la Activity no entrega callbacks al propietario destruido ni duplica resultados. Medir luego en Android físico antes de prometer ese umbral al usuario.

### A10 — El botón de reproducción y las filas usan órdenes diferentes

**Evidencia:** [MusicApp](../lib/app/music_app.dart), líneas 1008–1024 y 1136–1168; [LibraryController](../lib/app/library_controller.dart), líneas 419–425.

Las filas pasan por `library.ordered()`, pero el botón de cabecera construye la cola directamente con `playlistTracks()`, que sigue los IDs guardados. Una lista almacenada `[Z, A]` puede mostrar `[A, Z]` y empezar por Z al pulsar «Reproducir».

**Propuesta:** calcular una colección efectiva y reutilizarla en cabecera, filas y cola. Si se quiere orden manual distinto del orden visible, convertirlo en una decisión explícita de interfaz, no en una diferencia accidental.

**Aceptación mínima:** pruebas de widget con inserción opuesta al orden visible, ascendente y descendente: botón, primera fila y cola coinciden. Aleatorio no altera accidentalmente la política posterior de reproducción normal.

### A11 — Hay responsabilidades entrelazadas y trabajo derivado repetido

**Evidencia:** [MusicApp](../lib/app/music_app.dart), líneas 39–68, 1008, 1136–1150 y 1222; [LibraryController](../lib/app/library_controller.dart), líneas 419–428.

`music_app.dart` tiene 2.075 líneas, pero el hallazgo no se basa solo en su tamaño. Reúne navegación, presentación de biblioteca/listas, diálogos y coordinación de acciones. `MusicApp` escucha el controlador completo para reconstruir `MaterialApp`. Por otro lado, `playlistTracks()` reconstruye un índice del catálogo en cada llamada y algunas vistas solicitan varias veces la misma lista para contenido, duración, conteos y ausencias. Las filas vuelven a ordenarse al reconstruirlas.

**Consecuencia comprobable:** cálculos repetidos y alcance amplio de notificaciones. **Consecuencia no medida:** no se ha demostrado un número concreto de frames perdidos ni una latencia en teléfono.

**Propuesta:** extraer pantallas por responsabilidad, reducir suscripciones al estado necesario y mantener índice/derivados por revisión de catálogo. Empezar por listas; no introducir otra librería de estado ni reescribir toda la arquitectura sin una necesidad demostrada.

**Aceptación mínima:**
- Fixture de 10.000 pistas/100 listas: un índice por revisión del catálogo y una resolución por lista en cada reconstrucción relevante, no una por etiqueta visible.
- Un evento de extensión que no cambie catálogo ni orden no vuelve a filtrar/ordenar la biblioteca.
- Pruebas existentes de navegación, selección, tema, listas y persistencia conservadas.
- Comparación antes/después en el mismo equipo y perfil; informar p50/p95, memoria y reconstrucciones. No declarar optimización solo porque se movió código de archivo.

### A12 — Las pruebas de UI generan archivos por defecto, sin aislar su salida

**Evidencia:** [Collections UI test](../test/collections_0311_ui_test.dart), líneas 67–76; [Album/source UI test](../test/album_and_source_ui_test.dart), líneas 100–109; [Visual refresh test](../test/visual_refresh_0313_test.dart), líneas 36–45. Otros tests sí respetan `RP_UI_SNAPSHOTS`.

Hay capturas incondicionales en `design/verification` y `dist/*-preview`. Ejecutar la suite puede modificar artefactos preexistentes o producir archivos nuevos aunque solo se quiera comprobar comportamiento. Generar un PNG no demuestra por sí solo una regresión visual: hace falta una comparación o aserción definida.

**Propuesta:** separar tests funcionales de captura optativa; usar un directorio temporal/configurable para imágenes y golden tests cuando exista una referencia visual aprobada.

**Aceptación mínima:** una ejecución normal no cambia capturas ni distribución; el modo de captura escribe únicamente en su destino configurado. Una comparación visual intencional falla ante un cambio controlado y se actualiza mediante un proceso explícito, no sobrescribiendo la referencia automáticamente.

## 4. Qué conservar: fortalezas observadas

- **Biblioteca:** escaneo separado del trabajo de UI, caché por huella/versión y conservación de catálogo estable ante errores. No conviene sacrificarlo al refactorizar.
- **Reproducción:** generaciones, intención de pausa durante carga, historial y restauración sin autoplay. Los hallazgos A04/A05 son ventanas específicas, no ausencia general de control asíncrono.
- **Letras:** deduplicación y comprobaciones frente a selección/revocación; el núcleo mantiene infraestructura genérica en vez de clientes de proveedores concretos.
- **Extensiones:** permisos explícitos, propietario de capacidades, invalidación y recuperación ante fallos. Los límites de ejecución no equivalen a aislamiento duro de memoria; esa limitación ya está documentada.
- **Actualizador:** comprobaciones de dominio, longitud/SHA-256, limpieza de parciales y validación nativa de identidad/versión/firma. Su existencia no sustituye una auditoría criptográfica completa.
- **Modularidad útil:** dominio, datos, audio, fuentes y plataforma ya están separados. La evolución recomendada es incremental, no una reescritura global.

## 5. Comprobaciones de esta auditoría

Resultados observados en la ejecución inicial y la repetición autorizada posterior, no heredados de la bóveda:

| Comprobación | Resultado | Alcance |
| --- | --- | --- |
| `flutter analyze --no-pub` | **Aprobado**, salida 0: `No issues found!`; 212,1 s | Análisis estático del árbol local |
| Suite: primera ejecución, `flutter test --no-pub --reporter expanded --concurrency=1` | **Fallido**, salida 1: **151 aprobadas, 14 fallidas, 1 omitida**; aproximadamente 94 s | QuickJS no resoluble en el PATH inicial; evidencia histórica conservada |
| Misma suite: repetición autorizada con PATH temporal | **Aprobado**, salida 0: **165 aprobadas, 0 fallidas, 1 omitida**; aproximadamente 93 s de pruebas | QuickJS real cargado desde el build Windows existente; sin activar paquete externo de metadatos |
| Lectura y contraste de fuente | Completados, con cobertura selectiva | Evidencia de los hallazgos A01–A12 |
| Reproducciones dirigidas A01–A11 | No ejecutadas | Los mínimos propuestos son trabajos futuros, no pruebas ya aprobadas |
| Android físico/SAF/lifecycle y puente multimedia | No ejecutados | No se heredan resultados históricos como comprobación nueva |
| Windows nativo/audio/red y compilaciones release | No ejecutados | Sin comprobación nueva de codecs, bandeja o distribución |
| Benchmark, consumo de RAM y pentest/dependencias | No ejecutados | Sin cifras de rendimiento ni garantía de ausencia de vulnerabilidades |

Las comprobaciones Flutter se ejecutaron secuencialmente, sin `pub get`, compilaciones release ni cambios de dependencias. En cada ejecución se preservaron 37 PNG existentes de `design/verification` y `dist/*preview`: la suite modificó seis, cuyo contenido se restauró; no quedaron PNG nuevos en esas carpetas. No se utilizaron canciones del usuario.

### Incidente inicial de validación JavaScript — cerrado en la repetición autorizada

En la primera ejecución, las 14 pruebas fallidas mostraron el mismo impedimento al cargar QuickJS:

```text
FormatException: Invalid argument(s): Failed to load dynamic library 'flutter_qjs_next_plugin.dll': The specified module could not be found.
 (error code: 126)
package:rp_music/extensions/javascript_program_runtime.dart 94:9
```

| Archivo de pruebas | Fallidas | Cobertura impedida |
| --- | --- | --- |
| `test/javascript_extensions_test.dart` | 4 | Ejecución real, interrupción de bucles, coexistencia/restauración e interfaz JS |
| `test/javascript_network_test.dart` | 9 | Pila nativa, continuaciones, cancelación/revocación, dominios y audio JS |
| `test/version_0316_test.dart` | 1 | Caché pública e invalidación por permisos |

El error 126 puede corresponder a la DLL o a una dependencia transitiva que el cargador no encuentra. [COMPILACION.md](COMPILACION.md), línea 86, ya indicaba que las pruebas QuickJS en Windows necesitan las DLL del build Windows en `PATH`. Ese prerrequisito no quedó satisfecho en la invocación inicial. Por ello esa primera ejecución no permitía validar JavaScript ni atribuir los 14 fallos a 14 defectos de la aplicación. En esa etapa no se compiló, modificó `PATH`, sustituyó una DLL ni repitió la suite.

La prueba omitida es la optativa de `test/download_metadata_live_test.dart`: no se proporcionó `METADATA_PACKAGE`. No se presenta como aprobada ni se accedió al repositorio externo para activarla.

### Repetición autorizada y cierre del incidente de entorno

El usuario autorizó preparar el entorno y ejecutar nuevamente la suite. La DLL y su runtime ya existían; una comprobación de carga por nombre (`ctypes.WinDLL`, modo de carga Windows normal) tuvo éxito al anteponer `build/windows/x64/runner/Release` al `PATH` del proceso. La misma preparación temporal se aplicó al proceso hijo de Flutter, sin cambiar el PATH de usuario/sistema, instalar dependencias, reemplazar DLL ni compilar.

- **Comando:** `flutter test --no-pub --reporter expanded --concurrency=1`.
- **Resultado:** `All tests passed!`, salida **0**; **165 aprobadas, cero fallidas, una optativa omitida**.
- **QuickJS:** los 14 casos anteriormente fallidos se ejecutaron y aprobaron, incluidos ejecución real, interrupción de bucles, continuaciones, permisos y caché. No se omitieron ni se cambiaron sus aserciones.
- **DLL usada:** `build/windows/x64/runner/Release/flutter_qjs_next_plugin.dll`.
- **SHA-256:** `326b78efa656ffe867ee6a7392cbac3015b5b3d87e876125e1a6815c2857a2ce`.
- **Integridad:** comparación SHA-256 de 153 archivos antes/después, incluyendo fuentes/pruebas seleccionadas, manifiestos, pubspec/lock y configuración Gradle: cero cambios. Es un control sobre ese conjunto, no sobre todos los archivos del repositorio.
- **Artefactos visuales:** seis PNG modificados por la suite restaurados, sin PNG nuevos retenidos en las carpetas protegidas.
- **Reproducibilidad:** procedimiento de PowerShell con PATH temporal y restauración en [COMPILACION.md](COMPILACION.md), sección «Pruebas QuickJS en Windows: PATH temporal». Esa receta no incluye el mecanismo adicional de protección de capturas usado por el coordinador.

**Estado:** bloqueo de carga QuickJS cerrado para esta ejecución Windows. La preparación del PATH basta para resolver el incidente observado con el conjunto nativo existente; no se identificó por separado cada dependencia transitiva. El análisis estático aprobado corresponde a la ejecución inicial: no se repitió ni se afirma una comprobación adicional. Los doce hallazgos, sus reproducciones dirigidas propuestas y los límites físicos/de rendimiento permanecen sin cambios.

**Interpretación:** ni siquiera una suite verde refutaría escenarios asíncronos, semánticos o nativos que no contiene. No se añadieron tests ni se corrigieron hallazgos en este trabajo documental.

## 6. Plan recomendado de mejora, por unidades verificables

| Unidad propuesta | Hallazgos | Entregable mínimo | Condición de cierre |
| --- | --- | --- | --- |
| U1 — Recuperación de datos | A01, A06 | Instantánea validada, fallback y resultado explícito de persistencia | Matriz de archivos inválidos y fallo/reintento de guardado aprobada, sin perder respaldo válido |
| U2 — Frontera de audio remoto | A02 | Transporte y modelo de amenaza revisados | Prueba del destino efectivo o decisión explícita sobre riesgo residual; no solo filtros de URL |
| U3 — Transiciones de reproducción | A04, A05 | Identidad de operación/selección y cancelación de resolución | Intercalados con dobles bloqueables y cierre sin esperar una resolución obsoleta |
| U4 — Descargas consistentes | A03, A07 | Contrato común de integridad y commit/cancelación | Matriz HTTP más cancelación SAF y contadores correctos |
| U5 — Recursos y puente Android | A08, A09 | Cuota/rollback y planificación acotada de trabajos | Ensayos de fallo, saturación y ciclo de vida; proyecto activo conservado |
| U6 — Interfaz y pruebas | A10–A12 | Orden único, derivados por revisión y capturas optativas | Pruebas de orden, instrumentación del trabajo repetido y suite sin modificar capturas |

Son unidades propuestas, **no una autorización para implementarlas ni una planificación ya comprometida**. Cada cambio de comportamiento debería empezar con su reproducción fallida y terminar con pruebas de la regla nueva y de la conducta previa del código compartido. Evitar combinar correcciones de seguridad/persistencia con rediseños visuales.

## 7. Recomendaciones y mejoras futuras

Estas capacidades no se cuentan como defectos de lo que hoy promete el reproductor:

| Mejora futura | Beneficio | Mínimo propuesto antes de anunciarla |
| --- | --- | --- |
| Modelo común de trabajos cancelables | Menos divergencia entre resolver, descargar, etiquetar y exportar | Estados explícitos, cancelación idempotente, resultado único y limpieza de temporales en error/cierre |
| Presupuestos de caché y temporales | Evitar crecimiento disperso entre letras, portadas y herramientas | Cuota por categoría y total, política de retención, limpieza comprobada sin borrar datos del usuario |
| Diagnóstico por fases y rendimiento | Separar demora de proveedor, motor, IO y dibujo | Medir p50/p95 en un Android físico y Windows declarados, con fixture reproducible y logs sin URLs firmadas ni rutas privadas |
| Confianza e aislamiento de extensiones | Reducir el impacto de programas de terceros | Modelo de amenaza, autenticidad/versionado y revocación; no vender un hash como firma ni un isolate como sandbox de proceso |
| Automatización de calidad en CI | Repetir análisis/pruebas y controlar regresiones | Trabajo secuencial reproducible, resultados publicados sin secretos, capturas optativas y verificación separada por plataforma |
| SDK más fácil de mantener | Reducir conversiones dinámicas y divergencia de contratos | Validadores/contratos versionados, mensajes de error útiles y pruebas de compatibilidad de paquetes admitidos |
| Cola editable, gapless/fundido y ecualizador | Ampliar la experiencia musical | Decisión de producto y soporte probado por backend; ecualizador como extensión según la decisión vigente |
| Cuentas/sincronización y editor Windows | Ampliar integraciones sin debilitar el uso local | Definir privacidad, conflictos, recuperación, límites de plataforma y pruebas; funcionamiento offline preservado |

### Recomendación final

**No reescribir RP Music.** Cerrar primero la recuperación de datos y el riesgo de conexión remota, luego las ventanas de cancelación/selección. Extraer pantallas y servicios solo donde reduzca responsabilidades o trabajo repetido demostrado. Una mejora se considera terminada cuando cumple su aceptación y conserva el comportamiento anterior, no cuando el archivo queda más corto.
