---
tipo: requisitos-y-estado
estado: vigente
actualizado: 2026-10-27
---
# Biblioteca y reproduccion

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

Notificaciones/borrado: [[20 Pruebas 0.2.4 y mejoras 0.2.5]]. Escritura/widget/orden: [[21 Pruebas 0.2.5 y mejoras 0.2.6]]. Listas automáticas/carátulas: [[23 Extensiones programables - primer prototipo]]. Álbum/metadato de fuente: [[28 Pruebas 0.3.1 y mejoras 0.3.2]]. Reproductor/historial/artistas: [[29 Pruebas 0.3.2 y mejoras 0.3.3]].

El usuario probó controles/fuente en versiones anteriores. Audio nativo 0.3.3 se verificó en primer plano; retesteo físico y pantalla apagada prolongada de esa versión pendientes. [[10 Estado del repositorio]], [[05 Rendimiento]].

## Preparación local posterior a 0.3.3

[[32 Pruebas 0.3.3 y mejoras 0.3.4]] incorpora controles fijos adaptables y primera implementación LRC/TXT persistente por canción; no publicada. Letras sincronizadas dejan de ser solo visión en el código local, con límites/verificaciones en esa nota. Edición de etiquetas/gapless/fundido siguen pendientes.

Actualización 0.3.5: [[33 Metadatos de descargas YouTube]] incorpora lectura de letras incrustadas en la base (incluido SYLT en milisegundos), búsqueda automática al seleccionar canción con proveedor autorizado y caché privada. Letras recuperadas para archivos existentes no modifican la música, por decisión expresa. Descargas nuevas M4A admiten etiquetas y letras incrustadas sin recodificar; contratos/proveedores externos separados. La entrega 0.3.4 del párrafo anterior se publicó posteriormente; 0.3.5 se publicó posteriormente; confirmación en nota 33.
