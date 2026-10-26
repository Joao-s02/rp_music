# RP Music 0.3.2-alpha.1 — cambios

Aplicación 0.3.2+11, Android y Windows. Release: https://github.com/Joao-s02/rp_music/releases/tag/v0.3.2-alpha.1 .

- Nuevo detalle de álbum inspirado en la referencia: carátula, título/artista, datos disponibles, reproducir/aleatorio y guardar álbum como lista. Pestañas de pistas y cola en curso, fila activa destacada y acciones por canción.
- El buscador de fuentes respeta el área de navegación del sistema; el teclado deja espacio para escribir.
- El reproductor ampliado muestra el nombre del servicio de la pista remota. Los archivos conservan Audio local.
- Permiso para aportar un acceso a la navegación desde el manifiesto de la extensión, con icono, etiqueta y color; respeta activación y fuente elegida.
- Transporte HTTP genérico acotado en el SDK y lógica específica de servicios trasladada al repositorio separado de extensiones. Catálogo con selección de variantes compatibles con la versión de la app.

## Actualizar la extensión de fuente

El paquete inicial debe actualizarse a 0.2.0, compatible con RP Music 0.3.2 Android, y requiere aceptar sus nuevos permisos. Se entrega desde el repositorio de extensiones, por separado. La edición 0.1.0 sigue destinada a RP Music 0.3.1. Biblioteca/reproductor programables anteriores conservan su contrato.

## Límites

Fuente inicial priorizada en Android. Windows incluye las mejoras locales/visuales y el motor genérico; no se promete reproducción de esta fuente en Windows. Listas, favoritos, historial y cuentas de fuentes en línea siguen pendientes. La reproducción depende del servicio y la disponibilidad del contenido. No se inventan datos de calidad ni metadatos ausentes. Motor de extensiones experimental sin aislamiento duro de memoria.
