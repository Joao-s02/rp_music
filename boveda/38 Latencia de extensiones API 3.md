---
tipo: diagnostico-y-propuesta
estado: pendiente-de-medicion-android
actualizado: 2026-10-28
---
# Latencia de extensiones API 3

Informe posterior Windows: radio tarda~30s y M4A/OPUS no reproducen, mientras MP3/FLAC/MP4 sí. Corrección de audio y variante Radio0.1.1 de una sola consulta en [[39 Audio Windows M4A OPUS y YouTube]]. No se presenta como solución general de la latencia Android ni como migración de YouTube.

## Informe y prioridad del usuario

Tras probar0.3.9, el usuario confirma que las dos nuevas extensiones funcionan en Android, pero percibe3–6s en acciones API3 frente a API2. Aclaración posterior: ocurre al buscar, abrir una canción/emisora o pasar entre secciones del explorador; no informó demora de3–6s al abrir una pantalla vacía. Modelo del equipo, red, caché y distribución por operación no indicados. Es evidencia de uso informada, no cronometraje instrumentado.

El usuario no considera viable migrar YouTube a JavaScript con esa experiencia. Mantener YouTube API2 y conservar API3 como alternativa mientras se mide/optimiza. Los paquetes nuevos JS son opciones independientes; no se ha decidido migración automática. [[04 Extensiones]], [[37 Explorador y radio JavaScript]].

## Inspección actual

- Abrir inicialmente Explorador musical/Radio devuelve árbol/estado sin petición de red. Buscar/abrir entidades sí usa HTTP por etapas. Cambiar de categoría de búsqueda consulta otra vez. Las páginas de ocho resultados ya cargados se resuelven localmente.
- Atrás en Explorador recuerda identidad/título, pero vuelve a consultar al servidor; no conserva la página anterior completa en caché.
- Seleccionar canción YouTube obtiene preparación y después resolución AAC antes de entregar audio al backend.
- Seleccionar radio renueva por UUID, espera registro de clic y después validación inicial de stream/redirecciones antes de la apertura del backend. Hay varias esperas consecutivas; no se ha medido cuál domina en Android.
- ExtensionHttpTransport crea/cierra un HttpClient por petición, sin reutilización de conexiones entre etapas. También lo usa API2: no acredita por sí solo la diferencia entre motores.
- Cada invocación crea isolate/contexto QuickJS y guarda dos veces el registro completo. Es trabajo adicional observado, no causa demostrada de los3–6s. No retirar recuperación/permisos/límites para ocultarlo.

## Medición diagnóstica disponible

Prueba particular externa tests/screen_open_benchmark_test.dart, salida SCREEN-OPEN-WINDOWS-JIT.json, con ocho paquetes reales instalados en registro temporal. Flutter-test JIT Windows, QuickJS nativo Release disponible en PATH. Seis aperturas sin red por paquete, primera separada y promedio de cinco posteriores. No mide dibujo Flutter, búsquedas, respuesta real ni tiempo de primer audio; estado inicial sin resultados voluminosos. No es benchmark Android/release ni comparación contra API2.

| Pantalla | Primera apertura | Promedio siguientes | Guardados dentro del promedio | Ejecución JS directa media |
| --- | --- | --- | --- | --- |
| Laboratorio JS | 121.1ms | 19.2ms | 13.8ms | 2.3ms |
| Explorador musical | 17.8ms | 16.3ms | 11.9ms | 2.7ms |
| Radio por internet | 16.2ms | 18.6ms | 13.5ms | 2.7ms |

Dos escrituras por invocación, registro87–88KB en este caso. Una prueba diagnóstica aprobada; no se suma a las138 de la release ni demuestra mejora aplicada. El resultado orienta a medir red/etapas y experiencia completa en Android; no prueba que Android tenga esos tiempos ni que toda ejecución JS cueste3ms.

## Siguiente trabajo propuesto, sin implementar

1. Medir en Android por acción: motor, transporte/etapa, procesamiento/dibujo y primer audio. Comparar API2/API3 con misma consulta/red/caché. Separar canción, emisora y navegación; no prometer una cifra universal.
2. Caché temporal acotada de consultas/páginas con caducidad y actualización explícita. Atrás/páginas visitadas deberían reutilizar contenido ya obtenido; invalidar al cambiar contexto/permisos. No guardar URLs firmadas como audio persistente.
3. Evaluar reutilización de conexiones HTTP manteniendo límites/dominios, revocación y cierre correcto; reducir esperas secuenciales de radio, sin eliminar comprobaciones de stream público.
4. Conservar contenido previo mientras carga y distinguir carga/error; esto mejora experiencia, no implica que el servidor responda antes.

Solo tras medir mejora real reconsiderar migración de YouTube. No se modifica motor/app/paquetes/versiones/publicaciones en este diagnóstico. README y notas actualizados localmente; sin push.
