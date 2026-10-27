---
tipo: pendientes-y-resoluciones
estado: vigente
actualizado: 2026-10-26
---
# Preguntas e investigacion

## Pendientes abiertos

| Tema | Qué falta |
| --- | --- |
| Ecualizador | Próxima extensión deseada: requisitos, puntos de integración audio/DSP, compatibilidad y pruebas. No implementado ni añadido al núcleo. |
| Fuente en línea | Windows, cuentas, listas/favoritos/historial online, artistas/álbumes completos, redes/regiones y escucha larga. |
| SDK/confianza | Memoria/aislamiento, autoría/firmas, colaboración, componentes visuales amplios y métricas atribuibles. |
| Audio avanzado | Gapless/fundido, cola editable, letras locales/sincronizadas y edición de metadatos con protección de sobrescritura. |
| Plataformas/equipos | Retesteo físico actual, gestos/tres botones, SD/SAF, launcher/widget, actualización entre releases conservando datos y controles multimedia Windows. |
| Rendimiento | Biblioteca/equipos reproducibles y presupuestos. [[05 Rendimiento]]. |
| Producto futuro | Escaneo automático/observador, agrupación de compilaciones/etiquetas incompletas y personalización adicional. |
| Distribución | Licencia del proyecto pendiente. Play Store y condiciones vigentes de servicios requieren investigación específica. Catálogo revisado obligatorio no aprobado. |

Consultar documentación primaria vigente al realizar una investigación nueva; registrar fecha, fuente, conclusión y límites. Esta consolidación revisa notas/código y evidencia existentes, no realiza una nueva revisión de políticas externas.

## Resuelto para la implementación actual

| Pregunta anterior | Resolución |
| --- | --- |
| ¿Reconstruir alfa? | Autorizado/ejecutado preservando Git/bóveda. [[11 Reconstruccion - primera base]]. |
| ¿Motor/persistencia/runtime sin elegir? | Elección técnica provisional implementada: just_audio/audio_service, JSON y dart_eval/API 2. [[31 Arquitectura vigente]]. |
| ¿Android o Windows primero? | App para ambos. Fuente inicial prioriza Android por aceptación posterior; Windows de esa fuente pendiente. [[04 Extensiones]]. |
| ¿Identidad/tema/fuentes? | A confirmado y tema/fuentes integrados; álbum/reproductor rediseñados. [[15 Identidad visual e icono]]. |
| ¿Catálogo/instalación? | Archivo y repositorio GitHub, permisos y actualización explícita. [[04 Extensiones]]. |
| ¿Varias activas/conflictos/recuperación? | Aceptados e implementados con propietarios por función, base y fallos; límites del SDK conservados. |
| ¿Restaurar con autoplay? | Implementación restaura local sin iniciar audio; no atribuirlo como respuesta original del usuario. [[03 Biblioteca y reproduccion]]. |
| ¿Caché/escaneo? | Manual/progresivo; muestra caché al abrir. Puede cambiar su política futura, no falta elegir cómo funciona hoy. |
| ¿Notificaciones ausentes? | Usuario confirmó controles visibles en 0.2.4. Informes negativos anteriores son antecedentes. [[20 Pruebas 0.2.4 y mejoras 0.2.5]]. |
| ¿Actualizador solo propuesto? | Aprobado/implementado, ventana/descarga posteriores en 0.2.6. [[17 Actualizaciones opcionales desde la app]], [[21 Pruebas 0.2.5 y mejoras 0.2.6]]. |
| ¿Sin fuente implementada? | Búsqueda/audio Android publicados, vía experimental aceptada. Cliente específico migrado al paquete en 0.3.2. No repetir entrevista ni reintroducirlo al núcleo. [[24 YouTube Music - definicion e investigacion]], [[28 Pruebas 0.3.1 y mejoras 0.3.2]]. |
| ¿Primera release pendiente? | Ya publicada y sucedida por otras. Referencia actual en [[10 Estado del repositorio]]. |

## Continuar investigando

Elegir lo relacionado con la tarea y preguntar solo lo que la evidencia no resuelva. Diferenciar requisito, decisión técnica provisional, observación y propuesta. Tablas/etapas anteriores conservadas en versiones, [[09 Registro de cambios]] y [[30 Archivo de navegacion y estado]].

## Solicitud posterior a prueba 0.3.3

[[32 Pruebas 0.3.3 y mejoras 0.3.4]]: iniciar letras sincronizadas y descargas YouTube pasa a implementación local. Spotify solicitado explícitamente sin cuenta/vía no oficial: vista previa pública comprobada, canciones completas y búsqueda anónima por nombre sin resolver; no pedir credenciales para este alcance. Verificar reproducción nativa Windows y exportación/selector en ambas plataformas.
