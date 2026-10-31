# Cambios de RP Music 0.3.18

Aplicación 0.3.18+27, canal alfa.

- Exploración de fuentes: mayor separación y relleno entre canciones, artistas y álbumes. Buscador, filtros y cabecera se desplazan junto con los resultados; lista construida bajo demanda y teclado plegable al arrastrar.
- Atrás del teléfono cierra el detalle del álbum local. En fuentes, Atrás recorre álbum → artista → resultados previos sin repetir consultas.
- Búsqueda reciente de fuentes Dart y pantallas JavaScript conservada al cambiar de sección: texto, resultados, colección y desplazamiento. Solo durante esta sesión, con hasta ocho pantallas y caducidad de 30 minutos desde que se guardan; no se escribe historial en disco. Cambiar permisos, proveedor o paquete invalida la caché. No se reproduce audio por restaurar una pantalla.
- Escaneo Android: descubrimiento por lotes sin esperar a terminar toda la raíz; etiquetas válidas visibles desde el descubrimiento; lectura de metadatos únicamente para archivos nuevos/modificados, con dos trabajadores. Los resultados de metadatos se entregan cuando están listos y las actualizaciones agrupan hasta 128 archivos o 160 ms. Windows comparte el progreso de descubrimiento por lotes.
- Incluye A01 ya corregido: recuperación de biblioteca validada, respaldo sano conservado y bloqueo de guardado si ninguna copia es válida. No cambia el esquema ni reescribe canciones.
- Conserva el acceso opcional desde Letras a RP Edits Android, implementado en el candidato previo 0.3.17. RP Edits se instala por separado; su motor y paquetes no se incluyen en RP Music.

## Límites

No se modifican proveedores ni paquetes de extensiones; YouTube API2/Dart se mantiene. A02 y los demás hallazgos no se dan por resueltos. No se ha medido el tiempo de escaneo de esta versión en un Android físico: las pruebas sintéticas de 500/900 pistas comprueban integridad, caché y progreso, no segundos de mejora en teléfonos. Sin validación física nueva de Play Protect, SAF/SD, widgets o ARM64. No se instala ni desinstala ninguna app durante esta entrega.
