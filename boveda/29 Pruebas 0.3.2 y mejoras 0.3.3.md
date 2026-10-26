---
tipo: seguimiento
estado: implementada-local-con-verificaciones-y-pendientes
actualizado: 2026-10-26
---
# Pruebas 0.3.2 y mejoras 0.3.3

## Requisitos confirmados

El usuario entrega referencia visual de Ahora suena y pide adaptarla sin ecualizador: queda reservado para la próxima extensión, no se implementa ahora. Solicita además: añadir canciones del álbum a lista existente o crear una si falta; icono de fuente acorde al tema; Anterior debe volver a la canción previamente escuchada y aleatorio solo influir en Siguiente; separar artistas por comas; retirar el botón textual de abrir la fuente de su tarjeta cuando ya aporta navegación.

No solicita publicar otra release en esta tarea. La versión pública continúa en [[28 Pruebas 0.3.1 y mejoras 0.3.2]]. Trabajo local siguiente: 0.3.3+12 / 0.3.3-alpha.1.

## Implementación local

- Reproductor expandido con carátula grande redondeada, título en una línea con desplazamiento y movimiento reducido, artista/álbum, favorito local, chips de detalles/cola, progreso y tiempos, volumen con porcentaje, controles centrales grandes y tarjeta inferior de fuente/cola. Respeta área segura y scroll, tema claro/oscuro y disposición controlsFirst de extensiones existentes. Los detalles se basan en formato de archivo, duración, tamaño y metadatos conocidos. No se añaden datos ficticios de bits/kHz/DAC/salida ni controles decorativos de letras, temporizador o cambio de salida que todavía no tienen implementación. Ecualizador ausente por instrucción expresa.
- Botón del álbum abre listas manuales existentes y Crear nueva lista; si no hay ninguna elegible pide directamente nombre. Añadido por lote conserva canciones previas, carátula y metadatos, evita duplicados y no modifica listas automáticas ni archivos musicales.
- Historial de navegación de hasta 300 pistas anteriores, con avance al regresar. Anterior recorre selecciones cargadas correctamente, sin sortear canciones ni reiniciar la actual tras tres segundos. Al volver hacia delante se recupera el recorrido visitado antes de otro sorteo. Cambiar cola reinicia historial; eliminar pista limpia sus referencias. Sesión local conserva anterior/avance; pistas ausentes se descartan al restaurar.
- Track.artists deriva artistas de la etiqueta original: separa comas con/sin espacios, recorta blancos y deduplica nombres sin distinguir mayúsculas dentro de la misma canción. No divide por slash/feat/& ni reescribe el archivo/etiqueta original. Vista Artistas incluye la pista en cada grupo correspondiente y los filtros del motor reciben artists además de artist por compatibilidad. No requiere reescanear una biblioteca cacheada para aplicar la separación.
- Nuevo icono genérico playOutline en el contrato de navegación; utiliza IconTheme (color/tamaño del destino), para coherencia al seleccionar/no seleccionar. Paquete específico de fuente actualizado en su repositorio, no en la app. Tarjeta del gestor oculta Abrir fuente cuando la fuente elegida ya declara navegación; mantiene elección de dueño y administración/permisos.

## Extensiones separadas

Desarrollo exclusivamente en checkout dist/extensions-repository (repositorio Git separado e ignorado por el principal), según [[04 Extensiones]]. Variantes locales para anfitrión 0.3.3: fuente 0.2.1 con icono playOutline en previews/0.3.3/youtube-music.rpmx y Biblioteca viva 0.1.1 con filtro por artista individual en previews/0.3.3/biblioteca-viva.rpmx. Mantener versiones anteriores del catálogo para clientes 0.3.1/0.3.2; los nuevos contratos no se anuncian como compatibles con esos anfitriones. Requiere importar los paquetes nuevos para probar sus cambios mientras no se publique catálogo.

Biblioteca viva modificada solo en su repositorio; los ejemplos heredados del principal no se actualizan ni se copian de vuelta. Fixture del filtro por segundo artista se ejecutó por ProgramRuntime: devuelve la canción colaborativa esperada. Paquete/cliente de fuente conserva búsqueda/resolución; esta variante solo cambia el manifiesto visual y compatibilidad mínima.

## Verificación y pendientes

Pruebas iniciales del historial real/restauración, añadido por lote, grupos de artistas y flujos de listas aprobadas. Reproductor a 360/1280 con texto ampliado en revisión. Se corrigieron durante pruebas una superficie de Material de la cola y el porcentaje que envolvía en dos líneas; las pruebas de interfaz se repiten después de los ajustes. Resultados finales de suite, análisis, nativo y artefactos se anotarán al completarse, no se atribuyen por esta nota.

Pendientes de la visión previa: letras locales/sincronizadas, temporizador y selección de salida no se implementan por referencia visual; investigación específica futura. Ecualizador reservado a extensión. Límites de fuente/SDK previos se conservan (Android prioritario, sin cuentas/listas/favoritos/historial online, sin cuota dura de memoria). Prueba física de nueva UI y navegación pendiente del usuario.


### Verificación automatizada completada

Suite completa: 86 pruebas aprobadas. Incluye historia aleatoria anterior/avance/restauración/eliminación y nueva cola, artistas individuales sin reescribir etiqueta, añadido por lote sin duplicados ni edición de automáticas, flujo real de lista existente/primera lista, fuente sin botón Abrir duplicado e icono temático, nueva UI a 360/1280 con texto ampliado, detalles y apertura real de cola. Análisis final sin incidencias. Se repitieron dos pruebas de captura visual tras corregir el momento de captura antes de abrir hojas modales; no son dos casos nuevos adicionales a los 86.

Primera prueba de audio real Android: búsqueda/carga con playing=true, pero a los cinco segundos posición 0.93 s frente al umbral >2 s esperado. No se acredita esa ejecución como aprobada; se investiga carga inicial/red del emulador y se repite la navegación con comprobaciones de progreso acotadas. La lógica HTTP/resolución del servicio no se modificó en esta tarea. Resultado nativo final pendiente hasta terminar.


### Audio real Android

Segundo recorrido nativo aprobado en emulador API 37 con paquete externo 0.2.1: búsqueda, dos canciones, pausa/seek, Anterior hacia primera pista, avance histórico hacia segunda, metadato de fuente y revocación que impide reanudar. Observación de 30 s de posición monotónica en segunda pista, playing=true; RP_SOURCE_PROBE_OK, duración total 96 s. Este recorrido se ejecutó en primer plano: no se envió HOME/SLEEP durante su ventana de observación y no se atribuye una nueva comprobación 0.3.3 con pantalla apagada. Antecedentes 0.3.2 y confirmación física del usuario permanecen vigentes; retesteo físico actual pendiente.

Se acotan las esperas de la prueba por progreso/playing (hasta 25 s) para evitar confundir carga de red con audio detenido; no cambia el transporte ni se considera aprobado si no avanza. En el recorrido aprobado el inicio/seek aún usaban las esperas fijas previas y cumplieron sus umbrales; se aplica después la misma espera acotada ya ejercitada en los tres saltos a esos dos pasos para futuros ensayos. No se atribuye un tercer recorrido ejecutado por esa edición de infraestructura.


Capturas finales player-0.3.3-360.png y player-0.3.3-1280.png inspeccionadas con fuentes reales y escala 1.2. Se captura toda la superficie Material, pues capturar solo su descendiente omite pintura delegada a antecesores y producía imágenes parciales; no era ausencia de controles en la app. Proporciones, espacio de controles, porcentaje en una línea y tarjeta de cola comprobados. Son fixtures sintéticos sin carátula, no capturas de una biblioteca física del usuario.


### Compatibilidad de filtros guardados

Revisión final: al reemplazar opciones de artistas por nombres individuales, un filtro antiguo guardado con etiqueta combinada podía seguir activo mientras el selector enseñaba Todos. Se conserva como opción visible el valor guardado aunque ya no aparezca entre las nuevas opciones; así no se altera silenciosamente su criterio ni se oculta un filtro. Las nuevas opciones siguen siendo artistas individuales. Prueba genérica de migración añadida y 11 comprobaciones seleccionadas aprobadas (incluye casos ya contados, una regresión nueva; no sumar 86+11 como casos distintos). Se recompilan todos los instaladores finales con esa corrección; las primeras compilaciones de preparación se consideran sustituidas y no son las que se entregan. Historial/audio no cambiaron por este ajuste de selector.


## Cierre local y artefactos definitivos

Aplicación normal 0.3.3+12 compilada con entrada lib/main.dart y sin defines de prueba. Android universal y ARM64: versión/código correctos, firma válida y certificado SHA-256 compatible con 0.3.2 (eba2769ed11d359c8f89f6991bc6867c7766f6f46a4295bc5386e7d41ce7d38d). Universal con arm64-v8a/armeabi-v7a/x86_64 y variante ARM64 solo arm64-v8a. Universal final reinstalado y abierto en emulador; la captura inicial de preparación fue inspeccionada, sin pantalla de error (mostraba el permiso normal de notificaciones). No se atribuye actualización física sobre datos del teléfono.

Windows normal release: FileVersion y ProductVersion 0.3.3+12. Instancia nueva oculta inició y continuó activa tras 5 s; se cerró solo el proceso de prueba. ZIP con ejecutable, DLL/data/activos y USO.md: 20 archivos, testzip correcto y archivos necesarios comprobados. Sin registro integration_test residual; no se distribuye ninguna sonda ni paquete .rpmx dentro de los APK/ZIP.

Análisis final posterior a la corrección de filtro guardado: sin incidencias. Se mantienen suite inicial 86 y 11 comprobaciones seleccionadas finales con un caso adicional; no se presentan como 97 casos distintos. Archivos en dist/0.3.3-local, siete adjuntos locales (tres binarios, tres guías y SHA256SUMS). No se crearon commits, pushes ni release de esta versión. Los paquetes de extensiones están solo en el checkout de rp-music-extensions y el catálogo actualizado permanece local.

Sin historial disponible, Anterior conserva el retroceso secuencial de la cola; con historial usa el recorrido real sin aleatorio. Fuente inicial mantiene límites y prioridad Android. Retesteo físico, pantalla apagada prolongada para esta nueva versión y recorrido completo de Windows pendientes del usuario.

| Archivo local definitivo | Bytes | SHA-256 |
| --- | ---: | --- |
| CAMBIOS-0.3.3.md | 1850 | 5d75bdedfdbc72cc151f12638241ff5f7a7e64ef01aea54a13ec56f8fdca46f4 |
| PRUEBAS-0.3.3.md | 2981 | 47c079e49f1f52e31e0632d34efc7f80782a3feab6a389085ae3a28c94f46129 |
| RP-Music-0.3.3-android-arm64.apk | 24821253 | 37cba507700f473bfc4d6a39f369e8913fc5ba206ae94a4c219a6fbfac4e081b |
| RP-Music-0.3.3-android.apk | 67888056 | 3011c98d21ac2d325911cd62788805ce7cb8ee493190b421aeece014e808a863 |
| RP-Music-0.3.3-windows-x64.zip | 15626446 | ac9ea2e869d9ccbc37bda023559d27475fd4d0b597ddd3320a07c63fe53973d8 |
| USO.md | 1300 | a84a3c5c9b52b5c2b613973eb43bd95686bb9c1a4c63c3ef43907749108a7f32 |

Paquetes externos para esta prueba (no adjuntos de app):

- youtube-music 0.2.1, minAppVersion 0.3.3, 7570 bytes, SHA-256 1566ba5db1c30677d7c046f5043b9f4b9bc0b2403081179f18bf2374bdb944e7.
- biblioteca-viva 0.1.1, minAppVersion 0.3.3, 3205 bytes, SHA-256 a22ad5e2cd53c2f20e22c085b34144d88354159ebde1a58427ec7634aabd7a3d.


## Publicación autorizada

El usuario solicita publicar la release 0.3.3 y las actualizaciones de extensiones en su repositorio. Se preparan siete adjuntos (universal/ARM64/Windows, USO/PRUEBAS/CAMBIOS y hashes); los APK conservan bytes probados y el ZIP solo actualiza USO.md respecto a la copia de pruebas. Fuente 0.2.1 y Biblioteca viva 0.1.1 se publican exclusivamente en rp-music-extensions, manteniendo variantes anteriores. Confirmación pública y commits pendientes hasta terminar la publicación y sus verificaciones.
