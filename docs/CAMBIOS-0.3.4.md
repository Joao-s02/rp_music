# RP Music 0.3.4-alpha.1 — cambios

Aplicación 0.3.4+13. Android universal, Android ARM64 y Windows x64. Versión experimental.

- Ahora suena adapta carátula y espacios al tamaño disponible. Anterior, pausa/reproducción y siguiente permanecen visibles sin desplazar. La información secundaria puede desplazarse en ventanas muy bajas. Conserva la disposición aportada por extensiones.
- Letras LRC sincronizadas con la posición real, resaltado y seguimiento automático; tocar una línea salta a ese momento. Importa LRC/TXT UTF-8 y guarda una copia por canción, sin modificar el audio. TXT no se sincroniza. Máximo 256 KiB; no hay sincronización por palabra ni extracción de letras incrustadas.
- Las extensiones compatibles pueden consultar letras al pulsar el botón de nube. La consulta envía título/artista/duración al proveedor declarado; puede no haber resultados o no coincidir con esa grabación.
- Descarga manual en fuentes compatibles con permiso separado storage.download, hasta 64 MiB y tres minutos. Recibe el audio antes de abrir el selector de destino; no es gestor en segundo plano ni incorpora automáticamente el archivo a la biblioteca. Si se guarda en la raíz musical, actualizar biblioteca.
- Todas las fuentes autorizadas compatibles pueden aportar acceso de navegación. Cambiar de fuente requiere la acción explícita Usar esta fuente.

## Extensiones separadas y límites

Catálogo: https://github.com/Joao-s02/rp-music-extensions . No vienen dentro del APK/ZIP ni como adjuntos de esta release.

- YouTube Android 0.3.0: nueva variante para anfitrión 0.3.4, letras LRCLIB y descarga con revisión de permisos. Conserva las variantes para apps anteriores.
- Spotify · vistas previas 0.1.0: un paquete para Android/Windows, sin cuenta, mediante enlace público de canción. Solo fragmentos disponibles públicamente; sin búsqueda por nombre ni canciones completas. Letra completa sin sincronización con el fragmento. Prueba de datos/bytes, sin nueva prueba nativa aprobada.
- YouTube Windows 0.3.0: paquete candidato separado para importación manual; queda fuera del catálogo recomendado. Sus pruebas nativas fallaron. La recepción de bytes no acredita reproducción funcional.

97 pruebas automatizadas aprobadas y análisis limpio en la preparación del código. Escucha física, exportación con selector y nuevos paquetes Android/Spotify requieren validación adicional. No se implementan ecualizador, edición de etiquetas, gapless ni fundido. Firma Android actual de desarrollo; instalar encima de la anterior sin desinstalar para conservar datos.
