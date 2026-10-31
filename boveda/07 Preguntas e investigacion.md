---
tipo: pendientes-y-resoluciones
estado: vigente
actualizado: 2026-10-29
---
# Preguntas e investigacion

## Pendientes abiertos

| Tema | Qué falta |
| --- | --- |
| RP Edits | Candidato Android firmado comprobado en A34/Android16 (nueve pruebas físicas y apertura/exportación real desde Letras). Otros equipos/versiones, usos largos, vídeos fuera de30fps y port/lanzador Windows pendientes; sin release publicada. [[46 Extension de letras para edits]]. |
| Ecualizador | Próxima extensión deseada: requisitos, puntos de integración audio/DSP, compatibilidad y pruebas. No implementado ni añadido al núcleo. |
| Fuente en línea | Cuentas/sincronización, redes/regiones y escucha larga. Windows y navegación pública de artistas/álbumes ya entregados; regresión actual de álbum en canciones sueltas y calidad de portadas en [[45 Portadas artistas navegacion y descargas 0.3.16]]. |
| SDK/confianza | Memoria/aislamiento, autoría/firmas, colaboración, componentes visuales amplios y métricas atribuibles. |
| Audio avanzado | Gapless/fundido, cola editable y edición de metadatos con protección de sobrescritura. LRC/TXT por línea ya implementado en 0.3.4. Enriquecimiento de descargas en [[33 Metadatos de descargas YouTube]]. |
| Plataformas/equipos | Retesteo físico actual, gestos/tres botones, SD/SAF, launcher/widget, actualización entre releases conservando datos y controles multimedia Windows. |
| Rendimiento | Biblioteca/equipos reproducibles y presupuestos. [[05 Rendimiento]]. |
| Producto futuro | Escaneo automático/observador, agrupación de compilaciones/etiquetas incompletas y personalización adicional. |
| Distribución | Licencia del proyecto pendiente. Distribución oficial solo en GitHub; Play Store cancelada el 2026-10-27. Condiciones de servicios externos requieren investigación específica. Catálogo revisado obligatorio no aprobado. |

Consultar documentación primaria vigente al realizar una investigación nueva; registrar fecha, fuente, conclusión y límites. Esta consolidación revisa notas/código y evidencia existentes, no realiza una nueva revisión de políticas externas.

## Resuelto para la implementación actual

| Pregunta anterior | Resolución |
| --- | --- |
| ¿Reconstruir alfa? | Autorizado/ejecutado preservando Git/bóveda. [[11 Reconstruccion - primera base]]. |
| ¿Motor/persistencia/runtime sin elegir? | Elección técnica provisional implementada: just_audio/audio_service, JSON y dart_eval/API 2. [[31 Arquitectura vigente]]. |
| ¿Android o Windows primero? | App para ambos. Fuente inicial priorizó Android; audio/descarga Windows comprobados desde0.3.10. [[04 Extensiones]]. |
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

Prioridad confirmada 2026-10-27 publicada en 0.3.5: lectura de letras incrustadas en la base; letras/metadatos automáticos en nuevas descargas M4A; buscador normalizado con alternativa; extensión de letras locales con caché privada sin editar música. Alcance/verificaciones y validación física todavía pendiente en [[33 Metadatos de descargas YouTube]]. La publicación no equivale a cobertura de toda canción ni a editor general de etiquetas.

Elegir lo relacionado con la tarea y preguntar solo lo que la evidencia no resuelva. Diferenciar requisito, decisión técnica provisional, observación y propuesta. Tablas/etapas anteriores conservadas en versiones, [[09 Registro de cambios]] y [[30 Archivo de navegacion y estado]].

## Solicitud posterior a prueba 0.3.3

[[32 Pruebas 0.3.3 y mejoras 0.3.4]] conserva la implementación y publicación. El 2026-10-27 el usuario confirma reproducción YouTube Android satisfactoria y cancela Spotify tras comprobar fragmentos de unos 30 segundos: canciones completas/búsqueda Spotify dejan de ser pendientes activos. Retirada del catálogo ejecutada en 0.3.5; antecedente conservado en la nota 33. Nueva prioridad: [[33 Metadatos de descargas YouTube]]. Exportación real/selector y Windows siguen pendientes; el informe de reproducción no verifica esos flujos.

Incidencia M4A: fallo de contenedor de 0.3.5 confirmado con archivo aportado y corregido/publicado en 0.3.6. Usuario confirma el buen funcionamiento de 0.3.6 y se cierra la incidencia M4A según su informe; pruebas específicas de otros flujos siguen abiertas. [[34 Descarga M4A no visible en biblioteca]].

## Ampliación de YouTube — definición iniciada 2026-10-27

El usuario solicita profundizar el punto de artistas/álbumes y cuentas/listas/favoritos/historial para implementarlo. Revisión de código: fuente actual busca canciones, sin navegación de entidades ni conexión de cuentas. Se propone búsqueda por tipo, páginas de artista/álbum/lista pública con paginación y reproducción de colección. Favoritos/historial locales y listas importadas deben distinguirse de datos sincronizados. Elección de conexión Google y comportamiento de importación consultada al usuario, pendiente de respuesta; ninguna opción asumida como requisito confirmado. Lógica específica permanece en repositorio de extensiones; anfitrión aporta contratos/UI genéricos. No implementado en esta revisión. Referencias primarias consultadas: https://github.com/sigma67/ytmusicapi/blob/main/ytmusicapi/mixins/browsing.py y https://ytmusicapi.readthedocs.io/en/stable/setup/browser.html .

## Alcance confirmado de cuenta e importación — 2026-10-27

El usuario elige conectar Google y sincronizar cambios en ambos sentidos. Importar listas crea copias locales independientes: sus ediciones no se propagan a la lista de origen. Las vistas de cuenta/listas remotas se distinguirán de dichas copias. No se presume que favoritos de archivos locales equivalgan a valoraciones de vídeos sin una identidad remota comprobada. Alcance deseado no equivale a viabilidad verificada de historial/biblioteca Music.

El usuario no tiene proyecto Google Cloud ni cliente OAuth y solicita guía. Se inicia por crear proyecto, activar YouTube Data API v3 y configurar consentimiento externo en pruebas con su usuario. Tipo de cliente y conexión definitiva aún por validar para Android/Windows y capacidades Music; no usar flujo TV como sustituto automático de cliente móvil. API oficial soporta listas y valoraciones de vídeos; no se ha acreditado sincronización completa de biblioteca/historial Music. Documentación consultada: https://developers.google.com/youtube/data/guides/auth/installed-apps , https://developers.google.com/youtube/data/reference/rest/v3/playlists/list , https://developers.google.com/youtube/data/reference/rest/v3/videos/rate y https://ytmusicapi.readthedocs.io/en/stable/setup/oauth.html . Credenciales y sesiones fuera de Git/bóveda. Sin código de autenticación ni sincronización implementado todavía.

2026-10-28: el usuario detiene la API oficial y la preparación Google Cloud; explorar ampliación no oficial de la extensión existente. Deseo de sincronización bidireccional y copias importadas independientes conservado, viabilidad pendiente. Investigación, fases propuestas y límites en [[35 Ampliacion de YouTube sin API oficial]]. No implementado.

Primera fase publicada en 0.3.7: Explorador independiente, navegación pública e importación persistente. Siguiente pendiente: acceso por sesión y sincronización bidireccional; no API oficial ni Google Cloud. [[35 Ampliacion de YouTube sin API oficial]].

2026-10-28: usuario solicita mayor autonomía visual de extensiones y autoriza prototipo JavaScript conservando Dart/YouTube. Árbol componible, pantallas/eventos propios en verificación local; no equivale todavía a HTML/CSS libre, Node.js ni motor completo. [[36 Motor JavaScript paralelo]].

Primera API 3 visual publicada en 0.3.8, Dart preservado. Sigue pendiente ampliar componentes/servicios y validar Android; no equivale a SDK ilimitado ni a migración YouTube. [[36 Motor JavaScript paralelo]].

API3 HTTP por etapas/audio remoto y dos extensiones publicadas en 0.3.9; no siguen como propuestas. Pendientes Android físico, escucha prolongada, audio YouTube Windows, cuentas/sincronización y aislamiento/firmas. [[37 Explorador y radio JavaScript]].

## Desarrollo0.3.16 — 2026-10-29

Requisitos, elecciones de navegación/descarga, regresión confirmada con La Incondicional/Las Noches, cambios locales y evidencia en [[45 Portadas artistas navegacion y descargas 0.3.16]]. No cerrar latencia Android ni regresión física por una consulta de escritorio.
