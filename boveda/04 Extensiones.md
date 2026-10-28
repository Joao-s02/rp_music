---
tipo: requisitos-y-contratos
estado: vigente-con-limites-experimentales
actualizado: 2026-10-28
---
# Extensiones

Usuario exige resolver YouTube Windows sin migrar API2. Variantes Windows independientes sencillas/Explorador y Radio0.1.1 en verificación local con app0.3.10; paquetes Android y catálogo publicado preservados. Pruebas de reproducción nativa, no solo URL/bytes, en [[39 Audio Windows M4A OPUS y YouTube]]. Sin publicación nueva autorizada.

2026-10-28: usuario confirma funcionamiento de Explorador musical/Radio en Android y señala latencia API3 de3–6s en búsquedas/apertura de contenido/secciones. No migrar YouTube API2 con esta experiencia; medir/optimizar antes de reconsiderarlo. No se atribuye la diferencia al lenguaje sin comparación controlada. [[38 Latencia de extensiones API 3]].

2026-10-28: desarrollo local autorizado de Explorador musical/Radio por internet en JavaScript, HTTP por etapas y audio remoto. Paquetes solo en rp-music-extensions; motor genérico en app 0.3.9+18. No publicados ni migración de YouTube Dart. [[37 Explorador y radio JavaScript]].

## Visión y alcance confirmado

Añadir funciones y personalizar pantallas sin recompilar la app. Se aceptaron varias activas, permisos separados, niveles normal/avanzado, elección de conflictos, recuperación, instalación por archivo y catálogo por repositorio. Actualizaciones con aceptación, no silenciosas.

Biblioteca viva: filtros combinados, acciones, listas manuales/automáticas, carátulas propias/mosaico. Nivel avanzado deseado: reemplazar reproductor, modificar aleatorio y reglas de listas. No equivale a acceso irrestricto ni a reorganizar código compilado de la base.

## Separación obligatoria de repositorios

**Toda nueva extensión se desarrolla/publica exclusivamente en https://github.com/Joao-s02/rp-music-extensions . Nunca en https://github.com/Joao-s02/rp_music .**

- Extensiones: fuentes/lógica específicas, parsers/clientes de servicios, paquetes .rpmx, recursos, documentación, pruebas particulares y catálogo.
- App: reproductor, SDK/motor, permisos/instalación, capacidades HTTP/UI genéricas y fixtures sintéticos mínimos del motor.
- No añadir extensiones nuevas como ejemplos/fixtures del principal, assets del APK/ZIP ni adjuntos de sus releases. Enlazar catálogo y compatibilidad.
- La lógica de fuente migró fuera de la app en 0.3.2. Material heredado de Biblioteca viva/Pulso en ejemplos/pruebas del principal sigue como deuda de migración; actualizar extensiones solo en su repositorio. No afirmar separación total ni borrar historia publicada.

## Implementación actual

API 1 declarativa conservada. API 2 ejecuta Dart mediante dart_eval y devuelve JSON a componentes Flutter del anfitrión, como elección técnica provisional. Máximo 16 programas instalados; permisos, propietario para biblioteca/reproductor/aleatorio/fuente, retorno a base y desactivación por fallos repetidos. Las reglas automáticas conservan su proveedor por lista, no un único propietario global de todas las listas. Listas/datos conservados para recuperación; reglas automáticas inactivas al desactivar proveedor.

Permisos: library.read, playback.control, playlists.manage, storage.private, behavior.override, network.http, navigation.add y storage.download (0.3.4). network.youtube se reconoce solo como antecedente que requiere actualizar paquete. Nivel avanzado no concede IO, procesos ni código nativo.

El programa filtra, decide siguiente pista y selecciona presentaciones definidas por contrato. La fuente elegida/autorizada declara icono/etiqueta, busca y resuelve audio por HTTP acotado. No hay widgets Flutter arbitrarios, edición del código compilado, colaboración general entre paquetes ni cuota dura de memoria. Métricas actuales: tiempo de llamada/fallos; no RAM/CPU/batería atribuida.

Formato y límites: [API 2](../docs/EXTENSIONES-API-2.md). Componentes/flujos: [[31 Arquitectura vigente]].

## Paquetes del catálogo para 0.3.5

| Paquete | Versión | Alcance |
| --- | --- | --- |
| YouTube Android | 0.4.0 | Búsqueda de letras corregida y metadatos/portada/letras para nuevas descargas. Retesteo físico/selector pendiente. |
| Letras locales | 0.1.0 | Búsqueda automática al seleccionar canción sin letra; caché privada, sin modificar música. |
| Biblioteca viva | 0.1.1 | Artistas colaboradores, filtros/acciones/listas automáticas. |
| Pulso nocturno | 0.1.0 | Disposición del reproductor y política de aleatorio por contrato avanzado. |

YouTube Windows 0.3.0 es candidato manual fuera del catálogo recomendado: sus pruebas nativas fallaron. No presentarlo como funcional. YouTube Android 0.4.0 y Letras locales 0.1.0 requieren app 0.3.5 y consentimiento de permisos.

Catálogo fija revisión Git, comprueba SHA-256 y muestra Descargar/Instalada/Actualizar. Conserva fuente 0.1.0 para app 0.3.1, 0.2.0 para 0.3.2 y 0.2.1 para 0.3.3; Biblioteca viva 0.1.0 para anteriores y 0.1.1 para 0.3.3+. Fuente 0.3.0 conservada para app 0.3.4. Spotify ya no se ofrece en el catálogo; su paquete histórico se conserva. Hash no acredita autoría; no hay firma/catálogo auditado obligatorio implementado.

## Integraciones y siguiente investigación

Vía no oficial experimental y prioridad Android aceptadas para primera fuente: solo audio, sin vídeo visible ni cuenta. Búsqueda/reproducción publicadas, no solo investigadas. Prueba física positiva de 0.3.1 y segundo plano se conservan como antecedentes en [[24 YouTube Music - definicion e investigacion]]. Ahora la fuente reside en su paquete, con transporte genérico del anfitrión.

Pendientes: Windows de esa fuente, cuentas, listas/favoritos/historial online, artistas/álbumes completos, ecualizador, interoperabilidad y aislamiento más fuerte. Ecualizador es próxima extensión deseada, sin especificación ni DSP implementados. Spotify cancelado por el usuario el 2026-10-27; su paquete publicado es antecedente y se retiró del catálogo con 0.3.5. Play Store cancelada; las condiciones de servicios externos requieren investigación específica vigente.

El 2026-10-27 el usuario confirma reproducción satisfactoria de YouTube Android y solicita priorizar metadatos completos en descargas, mediante otro servicio o complemento si hace falta. Requisito implementado/publicado para 0.3.5; decisiones y evidencia en [[33 Metadatos de descargas YouTube]].

Alcance posterior confirmado: enriquecer automáticamente nuevas descargas YouTube con letras incrustadas y corregir búsqueda de letras que falla en las canciones probadas por el usuario. Extensión aparte para buscar automáticamente letras faltantes en biblioteca local. Reconocer letras ya incrustadas corresponde a la base. Decisión posterior confirmada: solo caché privada, sin modificar archivos locales. [[33 Metadatos de descargas YouTube]].

Entrega 0.3.5: el usuario elige **solo caché privada**, sin editar música local. Nueva capacidad lyrics/permiso lyrics.cache y proveedor independiente de source. Candidatos externos YouTube Android 0.4.0 y Letras locales 0.1.0, minAppVersion 0.3.5. Catálogo publicado sin Spotify; paquetes históricos conservados. Evidencia y límites en [[33 Metadatos de descargas YouTube]].

Antecedentes: [[22 Extensiones - alcance del primer sistema]], [[23 Extensiones programables - primer prototipo]], [[28 Pruebas 0.3.1 y mejoras 0.3.2]], [[29 Pruebas 0.3.2 y mejoras 0.3.3]].

## Entrega 0.3.4

[[32 Pruebas 0.3.3 y mejoras 0.3.4]]: variantes YouTube separadas Android/Windows y Spotify de vistas previas públicas sin cuenta, exclusivamente en el repositorio externo. Android y Spotify vista previa están publicados en catálogo; Windows es candidato manual. No equivalen a Spotify completo. Núcleo añade storage.download, operación genérica de letras y múltiples accesos de fuente con elección explícita de propietario. Publicación de app 0.3.4 y hashes externos confirmados en la nota; variantes anteriores conservadas.

## Publicación 0.3.5 confirmada

App 0.3.5-alpha.1 publicada: https://github.com/Joao-s02/rp_music/releases/tag/v0.3.5-alpha.1. Catálogo público verificado con YouTube Android 0.4.0 y Letras locales 0.1.0 para anfitrión 0.3.5, Biblioteca viva 0.1.1 y Pulso nocturno 0.1.0. Spotify fuera del catálogo, variantes anteriores intactas. Nueva capacidad lyrics/permiso lyrics.cache con library.read/network.http; resultados locales solo en caché privada. El estado público no elimina las validaciones físicas pendientes. [[33 Metadatos de descargas YouTube]].

## Alcance confirmado de cuenta e importación — 2026-10-27

El usuario elige conectar Google y sincronizar cambios en ambos sentidos. Importar listas crea copias locales independientes: sus ediciones no se propagan a la lista de origen. Las vistas de cuenta/listas remotas se distinguirán de dichas copias. No se presume que favoritos de archivos locales equivalgan a valoraciones de vídeos sin una identidad remota comprobada. Alcance deseado no equivale a viabilidad verificada de historial/biblioteca Music.

El usuario no tiene proyecto Google Cloud ni cliente OAuth y solicita guía. Se inicia por crear proyecto, activar YouTube Data API v3 y configurar consentimiento externo en pruebas con su usuario. Tipo de cliente y conexión definitiva aún por validar para Android/Windows y capacidades Music; no usar flujo TV como sustituto automático de cliente móvil. API oficial soporta listas y valoraciones de vídeos; no se ha acreditado sincronización completa de biblioteca/historial Music. Documentación consultada: https://developers.google.com/youtube/data/guides/auth/installed-apps , https://developers.google.com/youtube/data/reference/rest/v3/playlists/list , https://developers.google.com/youtube/data/reference/rest/v3/videos/rate y https://ytmusicapi.readthedocs.io/en/stable/setup/oauth.html . Credenciales y sesiones fuera de Git/bóveda. Sin código de autenticación ni sincronización implementado todavía.

2026-10-28: el usuario detiene la API oficial y la preparación Google Cloud; explorar ampliación no oficial de la extensión existente. Deseo de sincronización bidireccional y copias importadas independientes conservado, viabilidad pendiente. Investigación, fases propuestas y límites en [[35 Ampliacion de YouTube sin API oficial]]. No implementado.

Trabajo local 0.3.7+16: variante YouTube Explorador 0.1.0 con ID independiente, sin alterar YouTube Android 0.4.0 ni catálogo. Navegación pública e importación persistente implementadas localmente; cuenta/sincronización pendientes. Contratos y evidencia en [[35 Ampliacion de YouTube sin API oficial]]. No publicado.

0.3.7 publicada con Explorador 0.1.0 como opción independiente en catálogo. Estable 0.4.0 conserva bytes y sigue disponible; se elige propietario de Fuente. Ninguna se incluye en APK/ZIP. [[35 Ampliacion de YouTube sin API oficial]].

Prototipo local 0.3.8+17: API 3/JavaScript en paralelo a Dart; pantallas por árbol genérico, estado/eventos y reproducción explícita autorizada. Laboratorio JS separado en repositorio de extensiones. Paquetes YouTube sin modificar. No publicado; verificación y límites en [[36 Motor JavaScript paralelo]].

API 3/JavaScript publicada en 0.3.8 en paralelo a Dart: screen independiente con árboles combinables, estado y acciones autorizadas. Laboratorio JS0.1.0 en catálogo como sexta opción; API 2/YouTube sin migrar ni modificar. No Node/HTML libre ni red/cuentas en API 3. [[36 Motor JavaScript paralelo]].

Publicación 0.3.9 confirmada: Explorador musical 0.1.0/Radio por internet 0.1.0 en catálogo como séptima/octava opción, minAppVersion0.3.9. App publicada con API3 HTTP/audio remoto, Dart y paquetes anteriores preservados. Sin cuentas/sincronización, Android físico y audio nativo YouTube Windows pendientes. [[37 Explorador y radio JavaScript]].


0.3.10 publicada: motor Windows libmpv, M4A/OPUS y audio YouTube API2/JS comprobados, variantes Windows y Radio0.1.1 en catálogo externo. Evidencia, licencias y límites vigentes en [[39 Audio Windows M4A OPUS y YouTube]]. Android físico/latencia API3 pendientes.
