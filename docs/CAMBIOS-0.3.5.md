# Cambios de RP Music 0.3.5

Aplicación 0.3.5+14 · release preliminar 0.3.5-alpha.1.

- La base reconoce letras incrustadas de canciones locales y mantiene importación LRC/TXT. SYLT ID3v2.3/v2.4 en milisegundos añadido.
- Nuevo contrato genérico lyrics y permiso lyrics.cache para buscar letras automáticamente al seleccionar canciones sin letra. Resultados privados de la app; música local existente intacta. Caché, reintento y descarte de resultados tras revocación/cambio de proveedor.
- Nuevas descargas compatibles M4A incorporan etiquetas, portada y letras disponibles, sin recodificar. Portadas acotadas y dominios verificados; avisos ante información parcial o contenedor no compatible.
- Extensión YouTube Android 0.4.0 corrige artista/duración y normaliza la búsqueda de letras, con alternativa y validación de versión/duración. Enriquece metadatos con MusicBrainz y portada de Cover Art Archive. Letras locales 0.1.0 busca mediante LRCLIB.
- Spotify cancelado y retirado del catálogo; historia y variantes anteriores conservadas. Distribución oficial solo por GitHub, sin Play Store.

## Verificación y límites

106 pruebas aprobadas y análisis sin incidencias. Prueba de red optativa aprobada por separado; no se suman repeticiones. Tres casos del usuario obtuvieron letras sincronizadas desde búsqueda real YouTube: Las Noches / Junior H, BAILE INoLVIDABLE / Bad Bunny y La Incondicional / Luis Miguel. Flujo completo con paquete real incrustó letras, portada y álbum en una copia de audio sintético, conservando original/duración. Lectura y reproducción nativa Windows de M4A etiquetado aprobadas; ffprobe/ffmpeg confirmaron etiquetas y decodificación.

Sin dispositivo Android conectado para instalar/probar la versión: archivos personales con letras, selector SAF, permisos y escucha física prolongada requieren retesteo. No garantiza todos los formatos, variantes de etiquetas, canciones o redes. MusicBrainz mostró 503/timeout intermitentes; se conservan datos parciales. YouTube Windows sigue con fallos nativos conocidos. Edición general de etiquetas, cola editable, gapless/fundido y ecualizador como extensión continúan pendientes. Licencia del proyecto aún sin elegir.

Las extensiones se instalan por separado desde rp-music-extensions; no forman parte de los binarios o adjuntos de la app.
