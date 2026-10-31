---
tipo: requisitos-y-estado
estado: vigente
actualizado: 2026-10-29
---
# Biblioteca y reproduccion

## Publicado en 0.3.18 — escaneo y navegación

Álbum local intercepta Atrás para cerrar su detalle. Descubrimiento de biblioteca por lotes de 128; Android reutiliza huellas válidas antes de abrir metadatos, omite su trabajo en el ejecutor y entrega los nuevos conforme terminan. Dos lectores, formatos/permisos y conservación ante fallo intactos. A01 se conserva. Evidencia y límites en [[47 Navegacion busquedas y escaneo 0.3.18]].


Informe Windows0.3.9 precisado por usuario: M4A/OPUS fallan; FLAC/MP4/MP3 funcionan. Corrección local0.3.10 cambia solo backend Windows y mejora diagnóstico/recuperación; pruebas nativas reales y límites en [[39 Audio Windows M4A OPUS y YouTube]]. No atribuir el fallo a toda reproducción ni a corrupción general de archivos.

## Candidato local A01 — recuperación validada

Implementación local, no publicada: se valida la instantánea completa antes de aplicar campos; si el principal está truncado, contiene tipos/pistas inválidos o usa un esquema no admitido, se intenta el respaldo. Se conservan esquema 1, campos opcionales y referencias a pistas ausentes. Tras recuperar, guardar conserva el principal rechazado como `.rejected` (sufijo numérico si existe) y mantiene una copia válida.

Si ninguna copia es válida, no se publica estado parcial y se bloquea el guardado, conservando los originales. Aviso: «No se pudo recuperar la biblioteca guardada. El guardado está bloqueado para conservar los archivos originales.» Seleccionar carpeta no desbloquea la persistencia; no se ha añadido reparación automática ni pantalla de recuperación. Los archivos musicales no se reescriben. A06 y los otros hallazgos no forman parte de esta unidad.

Evidencia de esta unidad: RED con 16 aprobadas/6 fallidas; GREEN enfocado con 22 aprobadas y diferencial idéntico de cuatro consumidores genéricos de LocalStore. Verificación independiente enfocada22/exit0 y análisis limpio; primer intento detenido antes de casos por un insumo omitido de la copia, completado bajo autorización expresa. Suite completa del padre:174 aprobadas, cero fallidas y una optativa omitida, exit0; las36capturas previas conservadas byte a byte. Commit local `0f35994` en `fix/a01-recovery`; revisión nativa de esa unidad aprobada y acuse completado (`review-4d60c7ffccd78bac`), con dos recomendaciones no bloqueantes sin corrección abierta. No prueba física ni simulación de corte de energía. Especificación y evidencia: `odd/tasks/a01-recovery.md`; instrucciones sintéticas: [guía vigente](../docs/USO.md). El informe original se conserva como antecedente, no como estado actualizado.

## Requisitos confirmados

Una raíz seleccionada por el usuario con subcarpetas, cientos/miles de canciones y vistas de canciones/álbumes/artistas/carpetas. MP3, FLAC, M4A, MP4, WAV y OPUS solicitados; reconocer un archivo no garantiza cualquier códec en cualquier equipo. MP4 se usa como audio.

Biblioteca, búsqueda, favoritos, listas, carátulas, cola, aleatorio/repetición y controles habituales. Letras LRC/TXT incorporadas en 0.3.4 con sincronización por línea y copia privada; no extracción de letras incrustadas ni sincronización por palabra. Edición de etiquetas con elección archivo/biblioteca, gapless y fundido **siguen pendientes**.

## Implementado en 0.3.3

| Área | Comportamiento actual |
| --- | --- |
| Carga/escaneo | Abre catálogo guardado; Actualizar biblioteca incorpora cambios con escaneo manual/progresivo y caché. No hay observador continuo ni escaneo nuevo automático al abrir. |
| Acceso | SAF/permiso persistente Android, ruta elegida Windows. Un fallo de escaneo conserva la biblioteca estable anterior. |
| Metadatos | Lectura de título/artista/álbum/duración y carátula disponible. Artistas por comas se agrupan individualmente, sin reescribir etiqueta ni reescanear caché. No hay editor. |
| Orden | Título, artista, álbum, duración, modificación, tamaño y archivo, con dirección guardada. |
| Listas | Manuales persistentes, disponibles/ausentes, carátula propia/mosaico; añadir álbum a existente o crear sin duplicar. Automáticas mediante extensión, inactivas al desactivar proveedor. |
| Borrado | Quitar de lista no borra audio. Eliminar archivo confirma y pide escritura de la raíz cuando falta; depende del proveedor SAF. |
| Reproducción | Cola de selección, pausa/posición/volumen/silencio, aleatorio y repetir canción. Anterior usa historial cargado; Siguiente recupera avance visitado antes de sortear. Sin historial, anterior secuencial de la cola. |
| Restauración | Cola/pista/posición/recorrido local disponibles, sin autoplay; descarta ausentes. No equivale a historial/biblioteca online persistente. |
| Interfaz | Álbum con pistas/cola; reproductor expandido con datos reales, carátula y título deslizante. Áreas seguras y reducir movimiento respetados. |
| Android | Sesión/notificación/carátula/controles y widget conectado a la misma reproducción. |
| Windows | Audio local, volumen y cierre a bandeja o salida. Bandeja no prueba por sí sola todos los controles multimedia del sistema. |

## Fuera del núcleo y límites

Fuentes en línea/cuentas son extensiones. Ecualizador y búsqueda de letras faltantes por internet también. Fuente inicial Android: búsqueda/audio; Windows de esa fuente, cuentas y listas/favoritos/historial online pendientes. [[04 Extensiones]].

Importación de letras LRC/TXT implementada en 0.3.4; lectura de letras incrustadas implementada en 0.3.5 con los límites de la nota 33. El 2026-10-27 el usuario confirma que sus canciones contienen letras incrustadas y solicita reconocimiento en la base sin extensiones. Búsqueda automática de letras faltantes para biblioteca local irá en una extensión; enriquecimiento automático con letras incrustadas para nuevas descargas irá integrado con YouTube. Alcance en [[33 Metadatos de descargas YouTube]]. Edición de etiquetas, gapless/fundido y editor completo de cola siguen pendientes. Selección avanzada de salida/DAC y temporizador tampoco se añadieron por la referencia visual. No fabricar año/género/datos de calidad que el modelo no conozca.

## Evidencia y evolución

Incidencia reportada tras 0.3.5: una descarga M4A se reproduce fuera pero no aparece en la biblioteca. Se confirmó archivo fragmentado incompatible por posición de su inicialización en el etiquetador 0.3.5. Corrección local 0.3.6 y copia reparada verificadas; prueba Android todavía pendiente. [[34 Descarga M4A no visible en biblioteca]].

Notificaciones/borrado: [[20 Pruebas 0.2.4 y mejoras 0.2.5]]. Escritura/widget/orden: [[21 Pruebas 0.2.5 y mejoras 0.2.6]]. Listas automáticas/carátulas: [[23 Extensiones programables - primer prototipo]]. Álbum/metadato de fuente: [[28 Pruebas 0.3.1 y mejoras 0.3.2]]. Reproductor/historial/artistas: [[29 Pruebas 0.3.2 y mejoras 0.3.3]].

El usuario probó controles/fuente en versiones anteriores. Audio nativo 0.3.3 se verificó en primer plano; retesteo físico y pantalla apagada prolongada de esa versión pendientes. [[10 Estado del repositorio]], [[05 Rendimiento]].

## Preparación local posterior a 0.3.3

[[32 Pruebas 0.3.3 y mejoras 0.3.4]] incorpora controles fijos adaptables y primera implementación LRC/TXT persistente por canción; no publicada. Letras sincronizadas dejan de ser solo visión en el código local, con límites/verificaciones en esa nota. Edición de etiquetas/gapless/fundido siguen pendientes.

Actualización 0.3.5: [[33 Metadatos de descargas YouTube]] incorpora lectura de letras incrustadas en la base (incluido SYLT en milisegundos), búsqueda automática al seleccionar canción con proveedor autorizado y caché privada. Letras recuperadas para archivos existentes no modifican la música, por decisión expresa. Descargas nuevas M4A admiten etiquetas y letras incrustadas sin recodificar; contratos/proveedores externos separados. La entrega 0.3.4 del párrafo anterior se publicó posteriormente; 0.3.5 se publicó posteriormente; confirmación en nota 33.

Corrección 0.3.6 publicada: el escritor conserva inicialización previa en MP4/M4A fragmentado compatible. No cambia el escáner ni repara automáticamente canciones existentes. Evidencia y prueba física pendiente en [[34 Descarga M4A no visible en biblioteca]].


0.3.10 publicada: motor Windows libmpv, M4A/OPUS y audio YouTube API2/JS comprobados, variantes Windows y Radio0.1.1 en catálogo externo. Evidencia, licencias y límites vigentes en [[39 Audio Windows M4A OPUS y YouTube]]. Android físico/latencia API3 pendientes.


Desarrollo0.3.11: gesto de pistas, widgets adaptables, encabezados de listas/álbum remoto, descarga secuencial con contexto de álbum y retratos privados offline. Track incorpora albumArtist/numeración y versión de lectura2: primera actualización relee caché antigua sin modificar originales. Capacidades genéricas en app; fuentes/selección de metadatos/paquetes en repositorio externo. Evidencia/estado exacto en [[40 Gestos widgets albumes y descargas 0.3.11]].


0.3.11 publicada: gestos, widgets adaptables, colecciones, descarga por álbum y retratos offline; identidad albumArtist/numeración/metadataVersion2 y contrato sourceConfig.artistArtwork/library.read. Verificación y límites actuales en [[40 Gestos widgets albumes y descargas 0.3.11]]. No modifica música existente.


Trabajo local0.3.12+21: letras sincronizadas prioritarias, escena visual con tiempos reales, reproductor fijo/volumen emergente y cola centrada/animada. Fuente/paquetes/pruebas específicas exclusivamente en repositorio de extensiones; catálogo publicado intacto. Contexto, verificaciones y pendientes en [[41 Letras dinamicas y reproductor fijo 0.3.12]]. Referencia pública0.3.11 conservada.

## Cierre 0.3.12 publicado

Letras sincronizadas, vista Escena, reproductor fijo y cola centrada publicados. Resultados, revisión externa y límites vigentes: [[41 Letras dinamicas y reproductor fijo 0.3.12]].

## Desarrollo local 0.3.13

Informe confirmado de letras 0.3.12 y corrección de álbum/identidad visual/consentimiento conjunto: [[42 Albumes y extensiones con identidad RP 0.3.13]]. No publicada.

## Cierre 0.3.13 publicado

Corrección de álbum y datos parciales, interfaz de álbumes/fuentes/extensiones, cola más lenta y consentimiento conjunto publicados. Evidencia y límites vigentes: [[42 Albumes y extensiones con identidad RP 0.3.13]].

## Desarrollo0.3.16

Agrupación de artistas sin distinción de mayúsculas/espacios y separación coma/y/&, búsqueda plegable dentro del álbum e indicador animado de pista; descargas de álbum a disco con reintentos y fotos/portadas de entidades en fuentes. Local, no publicado; límites y evidencia en [[45 Portadas artistas navegacion y descargas 0.3.16]].
