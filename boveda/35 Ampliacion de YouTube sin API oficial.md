---
tipo: investigacion-y-alcance
estado: publicada-con-validacion-fisica-pendiente
actualizado: 2026-10-28
---
# Ampliacion de YouTube sin API oficial

## Decisión confirmada

El usuario detiene la integración oficial y solicita explorar ampliación de la extensión existente. Se abandona la preparación Google Cloud/OAuth oficial; no se implementó ese acceso. Se mantiene el deseo de cuenta y sincronización bidireccional, sujeto a viabilidad no oficial. Listas importadas siguen siendo copias locales independientes. Antecedente en [[07 Preguntas e investigacion]] y contratos en [[04 Extensiones]].

## Investigación y alternativas

Consulta primaria 2026-10-28: ytmusicapi documenta navegación de artistas/álbumes y listas, biblioteca de cuenta, valoraciones e historial usando endpoints internos. Autenticación de navegador reutiliza cabeceras de sesión, sin cliente Cloud. Es evidencia de una implementación externa, no una integración probada en RP Music ni garantía de cumplimiento de condiciones. No copiar Python dentro de dart_eval ni introducir servidor obligatorio: adaptar operaciones específicas a Dart en rp-music-extensions.

- https://github.com/sigma67/ytmusicapi/blob/main/ytmusicapi/mixins/browsing.py
- https://ytmusicapi.readthedocs.io/en/stable/reference/playlists.html
- https://ytmusicapi.readthedocs.io/en/stable/reference/library.html
- https://ytmusicapi.readthedocs.io/en/stable/setup/browser.html

## Fases propuestas, no implementadas

1. Navegación pública: búsqueda por tipo; páginas de artista, álbum y lista; paginación y cola de colección. No requiere cuenta.
2. Importación independiente: persistir referencias y metadatos remotos, conservar orden/repeticiones y marcar no disponibles. No descargar audio al importar.
3. Conexión experimental por sesión: validar adquisición de sesión en Android/Windows antes de prometer botón de login. Entrada manual local posible para prototipo; no pedir cookies/tokens en chat. Sesión en almacén protegido del anfitrión, acceso por permisos/dominios; no estado JSON de la extensión ni repositorio. Cliente específico y firma de peticiones pertenecen al repo externo; puente genérico no debe abrir Authorization arbitrariamente.
4. Cuenta y sincronización: leer primero biblioteca/Me gusta/listas/historial; luego escribir acciones verificadas y pendientes sin conexión. Separar cambios locales de estado remoto, conflictos y cuenta activa. No retransmitir historial importado como nuevas escuchas. Historial documentado no garantiza réplica exacta de fechas ni borrados bidireccionales; ensayar por operación. Copias importadas no participan en sincronización remota.

## Hallazgos del código y límites

ExtensionHttpTransport permite GET/POST acotados y rechaza Authorization. No hay login ni almacén de secretos de cuenta. ExtensionSourceService interpreta solo pistas en búsqueda, no entidades/páginas. LibraryController conserva remoteTracks en memoria (hasta 2000), insuficiente para importar colecciones duraderas. Se necesitan contratos/UI/persistencia genéricos además de modificar la extensión. No alterar descargas/reproducción actuales por investigar; tampoco afirmar que evitar la API oficial elimina las condiciones del servicio o las roturas de endpoints internos.

## Verificación de esta investigación

Lectura de código y documentación primaria; sin login real, modificación de cuenta, pruebas de red autenticadas, cambios de código o paquetes nuevos. Versión publicada permanece 0.3.6. Próximo paso: prototipo de navegación pública y validación local de sesión, sin prometer conexión completa.

## Implementación local por copia — 2026-10-28

Usuario autoriza comenzar manteniendo dos opciones para proteger lo existente. Nueva identidad rp.youtube-explorer / YouTube Explorador 0.1.0, minAppVersion 0.3.7, copia de rp.youtube-music 0.4.0; original preservado SHA256 7caf7c3a08f5f7d1f3daf48d5ee384b71be8d087840859d8563686017ff88d2d. BASELINE.json y build_explorer.py del repo externo comprueban identidad/hash; catálogo y paquetes estables sin cambios. Variantes coexistentes, propietario de Fuente elegido explícitamente; desactivar Explorador y elegir estable permite volver.

Host local 0.3.7+16 añade opt-in sourceConfig.browse y contrato genérico de entidades/páginas/continuación. La UI admite filtros, apertura de artista/álbum/lista, reproducción y carga de páginas. Importación manual de álbum/lista tras cargar todas las páginas crea copia independiente: conserva orden/repeticiones y metadatos/IDs remotos tras reinicio, sin descargar audio ni guardar URL firmada. Cache transitoria no expulsa canciones guardadas en listas/favoritos. No se modifican letras ni archivos locales. Referencias remotas requieren proveedor autorizado para audio; no son reproducción offline.

Proveedor específico y pruebas en rp-music-extensions: fuentes youtube_explorer_base/browse, envoltorio generado youtube_explorer.dart y previews/explorer-0.1.0/youtube-explorer.rpmx. Se reutilizan resolución/descarga/metadatos heredados. No se implementaron login, almacén de sesión ni sincronización bidireccional; siguen siguientes fases. No se promete discografía exhaustiva por artista ni contenido privado/no disponible por región.

Pruebas: suite inicial 113 aprobadas/una red optativa omitida; posteriormente nueva prueba de interfaz a 360 px y verificaciones finales registradas al cierre. Siete comprobaciones del paquete real en dart_eval; consultas públicas de Luis Miguel y apertura de artista/álbum/lista aprobadas. Paginación pública larga comprobada: primera página 100 pistas, continuación 95. Se detectó y corrigió el uso de continuación de recomendaciones en lugar de canciones; ahora se limita al shelf de colección. Hallazgos del intérprete: no admite continue ni if-element en mapas; lecturas de claves ausentes requieren guardas y lectura de texto usa la ruta columnText ya compatible. Pruebas nativas Android de esta variante pendientes; no hay login de cuenta ni cambios remotos. Sin push, catálogo ni release pública nueva.

## Cierre de verificación local

Suite final: 114 aprobadas y una prueba optativa de red omitida, sin sumar repeticiones. Análisis del código cambiado y pruebas sin incidencias. Prueba de interfaz a 360 px aprobada. APK universal normal release final compilado (95.8 s), código 16/versionName 0.3.7; firma v2 con certificado compatible con 0.3.6. SHA256 APK ed4d8be5797b722dad0e317b8db443dc858414c0368991cbd1fb662403b46983; paquete Explorador 75f155625bc759ac48bd7aae97d6570937eac06139886b204a7a3b38cf137348. Capturas históricas regeneradas por suite restauradas byte a byte desde HEAD; imágenes ajenas sin tocar. Binario local y PROBAR en dist/0.3.7-local; paquete exclusivamente en repo externo. No prueba física Android ni publicación. Una repetición del sondeo de listas largas no encontró candidatos paginados entre los primeros cinco resultados dinámicos; se distingue disponibilidad del caso de prueba de fallo de parseo. Evidencia previa 100+95 conservada.

Último sondeo paginado aprobado: lista pública larga de 100 pistas en primera página + 100 en continuación con el paquete definitivo; ID público del caso guardado en tests/explorer-live-list.json del repositorio externo. Siete comprobaciones sintéticas del paquete aprobadas.

2026-10-28: usuario autoriza publicar nueva release 0.3.7. Se preparan tres binarios, guías y hashes; Explorador como entrada separada en repositorio de extensiones, estable intacta. Confirmación remota pendiente hasta terminar.

Preparación 0.3.7: ARM64 release normal compilado en 122.4 s. Extensiones publicadas en 3cb1181, catálogo comprobado por el cliente real: cinco opciones verificadas por SHA/metadatos, Explorador 0.1.0 y estable 0.4.0 separadas. Catálogo previo preservado íntegro. Confirmación de app pública pendiente.

## Publicación confirmada

Binarios normales: ARM64 122.4 s, Windows 98.5 s; ProductVersion 0.3.7+16 confirmado y ZIP de 22 archivos íntegro. APKs código16/versionName0.3.7 y firma v2 compatibles. 2026-10-28: release pública https://github.com/Joao-s02/rp_music/releases/tag/v0.3.7-alpha.1, app 0.3.7+16, tag/código df3c1ec6c184218778a01b96c63b1cc5f812ddbf, release ID 426269933. Siete adjuntos uploaded verificados por tamaño/SHA256 en borrador y API pública; tag al commit esperado y manifiesto descargado idéntico al local. Commit de extensiones 3cb1181eeaa8a8c303a5cf50a5bcdece077412be, catálogo/Explorador/estable comprobados remotamente; cinco entradas verificadas con cliente real. Commits documentales posteriores no cambian binarios del tag. Cuenta y sincronización siguen pendientes, Explorador Android sin prueba física nueva; no se modificaron releases anteriores.
