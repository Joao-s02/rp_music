# Pruebas de RP Music 0.3.3

## Reproductor Android y Windows

1. Actualizar sin desinstalar y comprobar biblioteca, listas, carátulas y favoritos conservados. Abrir el reproductor desde el control pequeño.
2. Revisar carátula grande, título largo en una línea, artista/álbum, favorito local y nombre real de fuente. Probar tema claro/oscuro, orientación, ventana y texto grande.
3. Probar pausa/play, progreso, volumen y porcentaje. Abrir Detalles (metadatos reales) y Cola, seleccionar otra pista y cerrar. Comprobar área de gestos/tres botones al final del scroll.
4. Activar aleatorio, escuchar A→C→B y pulsar Anterior después de varios segundos: debe volver a C y luego A. Siguiente debe recorrer C y B antes de otro sorteo. Repetir con controles multimedia del sistema. Cerrar y recuperar la cola local; Anterior debe mantener el recorrido disponible.
5. Cambiar la cola/eliminar una pista y comprobar que no reaparece en el historial. Probar reproducción en segundo plano y pantalla apagada varios minutos.

## Biblioteca

1. Crear una lista Viaje con una canción. Abrir un álbum → botón Añadir álbum a una lista → Viaje. Debe conservar la canción previa y añadir las del álbum sin duplicarlas. Repetir la operación.
2. Desde ese selector elegir Crear nueva lista. Si no hay listas manuales debe pedir directamente nombre; cancelar conserva todo. Las listas automáticas no deben aparecer como editables.
3. Usar canción con artista Uno, Dos. En Artistas deben aparecer Uno y Dos; la canción debe estar en ambos grupos. Probar espacios alrededor de comas y artistas repetidos. La etiqueta original sigue igual en detalles/archivo.

## Extensiones Android

1. Actualizar desde el catálogo o importar el paquete de fuente 0.2.1 compatible con anfitrión 0.3.3. Verificar el icono YT de contorno integrado al tema y su estado seleccionado. Buscar/reproducir y verificar nombre del servicio y controles.
2. En Extensiones, la fuente elegida con navegación no debe mostrar otro botón Abrir. Mantiene permisos, elección de dueño y desinstalación. Desactivar debe retirar el destino y detener su audio.
3. Si se usa Biblioteca viva, actualizar a 0.1.1 y filtrar por el segundo artista de una canción colaborativa; guardar lista automática y comprobar resultados. Versiones anteriores del catálogo se conservan para apps anteriores.

## Alcance

Suite inicial completa de 86 pruebas aprobada, más una regresión nueva sobre el filtro guardado, incluida en 11 comprobaciones finales seleccionadas aprobadas. Recorrido nativo Android aprobado con búsqueda, audio real, pausa/seek, anterior/avance y revocación, en primer plano. APK normal instalado/abierto; ARM64 y firma verificados. Windows compilado e iniciado; ZIP completo verificado. Resultados y hashes finales en boveda/29 Pruebas 0.3.2 y mejoras 0.3.3.md. Retesteo físico y escucha larga pendientes. Windows recibe UI/biblioteca/reproducción local; no se promete fuente inicial Windows.
