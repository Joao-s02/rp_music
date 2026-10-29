---
tipo: requisitos-implementacion-y-verificacion
estado: desarrollo-local-con-verificacion-parcial
actualizado: 2026-10-29
---
# Portadas artistas navegacion y descargas 0.3.16

## Requisitos confirmados

El usuario acepta trabajar latencia API 3, comprobaciones Android y coherencia documental. Añade: portadas de mejor calidad desde metadatos, corregir álbum de canciones sueltas, optimizar navegación con muchas extensiones, descarga de álbum sin errores por tamaño, lupa/búsqueda plegable dentro de álbum, animación de pista actual, artistas separados por «y»/«&» y sin duplicados por mayúsculas, fotos públicas de artistas/portadas de sus álbumes en Explorador.

Decisiones posteriores explícitas: **un acceso Explorar** reúne fuentes/pantallas visuales conservando cinco destinos principales; **descarga a archivo temporal con progreso y reintento de fallidas**, manteniendo la app abierta. No se pide persistencia tras cerrar ni servicio en segundo plano.

Casos reales que el usuario confirma como regresión: La Incondicional / Luis Miguel y Las Noches / Junior H. Antes se descargaban con álbum; ahora falla al descargar sueltas, mientras desde un álbum funciona. No se atribuye todavía a una variante o dispositivo concretos.

## Implementación local

App 0.3.16+25, sin publicar. Navegación Biblioteca/Favoritos/Listas/Explorar/Ajustes. Explorar enumera pantallas/fuentes y permite administrar extensiones; instalar todas no añade botones a la barra. Álbum local entra con búsqueda plegada; escribir filtra dentro del mismo álbum sin abandonarlo. Indicador reutiliza NowPlayingBars, con estado de reproducción/pausa y movimiento reducido.

Artistas se separan por coma, « y » y « & »; agrupación por nombre sin distinguir mayúsculas y con espacios normalizados. Mantiene una grafía visible encontrada; no reescribe etiquetas. No intenta resolver alias/homónimos ni identificar automáticamente grupos cuyo nombre usa esas conjunciones.

Las entidades de fuente muestran artwork ya validado contra dominios de la extensión: foto circular para artista y portada para álbum; alternativa si falta/falla. No confundirlo con nueva prueba de retratos offline.

Descarga de álbum: audio por fragmentos a temporal privado, hasta512MiB/canción, sin reunir el payload completo en memoria. Etiquetador MP4 lee cabeceras acotadas, valida posiciones fragmentadas y transmite los bloques de audio intactos. Android SAF copia desde archivo privado mediante canal nativo; Windows usa temporal y renombrado. Progreso por canción y bytes; reintento solo de índices fallidos con numeración original/carpeta conservadas. No sobrescribe terminadas. Cierre de app no conserva cola; requiere espacio para temporales. Exportación individual conserva todavía su ruta acotada a64MiB.

Lógica/paquetes específicos exclusivamente en el checkout Git independiente rp-music-extensions, ubicado en dist/extensions-repository. build_0316.py genera candidatos en previews/0.3.16: YouTube Android/Windows0.5.3, Explorador Android/Windows0.2.3 y Explorador JS0.1.1. Catálogo público intacto. El anfitrión prioriza portadas devueltas por metadatos compatibles, alternativas autorizadas y una portada compartida en el lote. Consulta de hasta25 grabaciones, Single/EP oficiales permitidos, portada1200 de edición/grupo y conservación ante fallo posterior. Solicitar1200 no garantiza disponibilidad/calidad para toda edición.

API3: medida de motor/registro, red y acción en diagnóstico de sesión sin registrar consultas, respuestas, cookies ni URLs. Caché optativa cacheSeconds1–60, máximo8 respuestas/2MiB, por pantalla/extensión/revisión de permisos; solo status200 sin cookies, sin persistencia. Candidato JS marca navegación pública, no resolución de audio. No elimina recuperación ni permisos. Android sigue pendiente de medición instrumentada.

## Comprobaciones y límites

-163 pruebas Flutter aprobadas, una optativa de red omitida; suite completa con biblioteca QuickJS Release disponible en PATH. Fallos previos de preparación (DLL ausente, reactivación tras permisos y espera infinita de animación) corregidos; no se suman repeticiones como casos nuevos.
-Analizador Dart sin incidencias en lib y nueva prueba; revisión final completa pendiente tras terminar cambios.
-Cuatro paquetes reales compilados/ejecutados con dart_eval: álbum desconocido/conocido, Single/EP, orden estable, coincidencia/duración, LRC y portada1200 conservados; los tests específicos viven en el repositorio de extensiones.
-Prueba de archivo plano, fragmentado y reparación de inicialización final: resultado a disco idéntico byte a byte al escritor previo; originales intactos. Archivo65MiB mantiene SHA256 del payload tras etiquetar por flujo.
-Consultas públicas nuevas: La Incondicional identifica Busca Una Mujer/pista5 y55 líneas temporizadas; Las Noches identifica $AD BOYZ 4 LIFE II/pista7 y23 líneas. Son consultas, no nuevas reproducciones físicas ni exportación comprobada.
-Ensayo completo posterior de enriquecimiento de La Incondicional falló: MusicBrainz503 y sin portada. Demuestra dependencia real de disponibilidad; investigación de respaldo de origen en curso. No ocultar este resultado ni declarar resuelta la regresión física.
-Arranque ADB del entorno restringido falló; Android físico/SAF/widgets/latencia/escucha prolongada no comprobados. Sin APK/ZIP0.3.16 final al redactar esta etapa.
-La revisión automática de permisos falló dos veces por capacidad del servicio, después se recuperó y permitió pruebas. No fue un rechazo por peligrosidad.

## Fuentes de investigación

2026-10-29: documentación primaria de Cover Art Archive confirma front y miniaturas1200, además de redirecciones/404/503: https://musicbrainz.org/doc/Cover_Art_Archive/API . Campos de búsqueda de grabaciones: https://musicbrainz.org/doc/MusicBrainz_API/Search/RecordingSearch . No usar una letra para imponer una edición del álbum ni inventar datos ausentes.

Estado actual: [[10 Estado del repositorio]]. Contexto previo: [[42 Albumes y extensiones con identidad RP 0.3.13]], [[38 Latencia de extensiones API 3]], [[40 Gestos widgets albumes y descargas 0.3.11]].

## Respaldo de origen y evidencia posterior

Se añade consulta pública de contexto del **vídeo exacto** cuando la descarga suelta no trae álbum. Valida título/artista compatibles y el enlace real de álbum del propio origen; conserva esos datos si MusicBrainz falla. No elige álbum desde la letra ni toma el de otro vídeo de la cola. La primera prueba controlada encontró un límite de promociones dinámicas de dart_eval; los mapas del parser se leen con tipos explícitos. Cuatro paquetes finales pasan la prueba de otro vídeo en la respuesta y conservación de álbum/portada ante MusicBrainz503.

Ensayo completo con una copia de audio sintético: Las Noches / Junior H incrusta $AD BOYZ 4 LIFE II y portada1200×1200/310013bytes, sin aviso parcial. La Incondicional / Luis Miguel incrusta Busca Una Mujer y portada1000×1000/117426bytes, aun con503 en consulta posterior, con aviso de datos parciales. El original permanece intacto. Son imágenes reales del proveedor, no ampliaciones locales ni garantías para todas las ediciones. La consulta anterior que falló no se borra del registro.

Compilación Android universal normal completada318.2s; firma final verificada v2/v3, producción y compatibilidad histórica mediante helper existente, versión0.3.16/código25 y perfil sin instalador. No sustituye prueba Play Protect nueva. ADB autorizado posteriormente funciona y enumera **cero dispositivos**; no hay prueba física nueva.

Referencia primaria de estructura de la cola pública consultada2026-10-29: https://raw.githubusercontent.com/sigma67/ytmusicapi/main/ytmusicapi/parsers/watch.py . Parser propio; no se incorpora ese código al anfitrión.

## Cierre de entrega local

Windows release normal108.9s, ProductVersion/FileVersion0.3.16+25. ZIP completo32archivos (runtime/data, siete licencias/avisos y tres guías) verificado byte a byte contra compilación. APK universal0.3.16/código25/tresABI y perfil manual comprobados. Entrega en dist/0.3.16-local: APK universal, Windows ZIP, USO/PRUEBAS/CAMBIOS y SHA256SUMS. Sin ARM64 separado por ser entrega local, no publicación. Ambos binarios normales; sin paquetes de extensión ni registro integration_test.

Candidatos separados en rp-music-extensions/previews/0.3.16, cinco paquetes con manifiesto comprobado. Las cuatro variantes Dart pasan conservación de datos del vídeo exacto ante503 y selección de álbum/Single/EP; el parser de portada reconoce también yt3.googleusercontent.com/yt3.ggpht.com. Última prueba completa del respaldo utiliza datos reales de YouTube/LRCLIB y simula MusicBrainz503: La Incondicional conserva Busca Una Mujer y portada1200×1200/203551bytes, aviso parcial y original intacto. La falla completa previa se debió también a que el respaldo descartaba el host yt3; se corrigió su lista de imágenes y se mantuvo la validación de dominios del paquete.

Suite completa163 aprobadas/una omitida; pruebas de red adicionales separadas. Repeticiones no se agregan como pruebas únicas. Capturas Flutter360/1280 del álbum revisadas; no son dispositivo Android. Se restauraron capturas históricas y se conservaron los cuatro PNG previos ajenos al trabajo. Sin push, tag, release ni actualización del catálogo. Pendientes físicos y medición Android permanecen.

## Publicación0.3.16 autorizada — 2026-10-29

El usuario solicita «sube la nueva release». Se prepara ARM64 firmado además del universal/Windows normales ya comprobados, cinco actualizaciones de catálogo externo, tres guías y manifiesto. Verificar borrador por tamaño/SHA256/tag y confirmar después por API pública. Las pruebas físicas y latencia Android siguen pendientes; no hay confirmación de uso del usuario de0.3.16.

ARM64 normal final compilado140.9s; versión0.3.16/código25, soloarm64-v8a y firma de producción/transición compatibles verificados. Sin REQUEST_INSTALL_PACKAGES; no equivale a prueba física ni veredicto Play Protect nuevo.

## Comprobación previa de publicación

Tres binarios normales preparados: universal exacto de la entrega local, ARM64 firmado140.9s y Windows0.3.16+25/ZIP32archivos. Siete adjuntos con SHA256: universal, ARM64, Windows, USO, PRUEBAS, CAMBIOS y manifiesto. Catálogo externo publicado enb74564aaee444294580ff1aefa7a6e8f337fabcd: diez opciones y34paquetes/variantes comprobados contra los bytes públicos; cliente real selecciona YouTube0.5.3, Explorador0.2.3 y Explorador JS0.1.1, conservando las variantes anteriores para0.3.15. Publicación de la app pendiente de comprobación del borrador.
