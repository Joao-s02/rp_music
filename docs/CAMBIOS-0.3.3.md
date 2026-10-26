# RP Music 0.3.3-alpha.1 — cambios

App 0.3.3+12. Release: https://github.com/Joao-s02/rp_music/releases/tag/v0.3.3-alpha.1 .

- Reproductor expandido renovado según referencia: carátula grande, título en una línea, favorito, metadatos reales, progreso, volumen con porcentaje, controles principales y tarjeta de fuente/cola. Detalles y cola con sus acciones reales; se conserva la disposición de extensiones de reproductor.
- Botón de álbum para añadir canciones a una lista manual existente o crear una nueva. Conserva contenido y carátula, evita duplicados; listas automáticas no se editan por este botón.
- Anterior vuelve por el historial real, incluso con aleatorio, y deja de reiniciar la pista por llevar más de tres segundos. Siguiente recupera el recorrido visitado antes de sortear otra canción. Historial local restaurable, acotado a 300 pistas.
- Artistas separados por comas con/sin espacios aparecen individualmente. No se modifican archivos ni etiquetas originales; también se aplica a la biblioteca cacheada.
- Icono de contorno integrado al tema mediante paquete de fuente 0.2.1 para RP Music 0.3.3. Se retira el acceso Abrir duplicado en la tarjeta de la fuente activa con navegación propia.

Ecualizador reservado expresamente a una extensión futura. La referencia visual no añade funciones de letras, temporizador ni selección de salida; no se muestran datos ficticios de bits/kHz/DAC. Fuente inicial sigue priorizando Android; soporte Windows de esa fuente y listas/favoritos/historial online siguen pendientes.

Extensiones separadas: importar paquete de fuente 0.2.1 para el nuevo icono; si se usa Biblioteca viva, importar su 0.1.1 para filtros de artistas colaboradores. Los paquetes están en el repositorio de extensiones, fuera del APK/ZIP y de los adjuntos de la app. Versiones anteriores se conservan para anfitriones anteriores.
