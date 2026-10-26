# RP Music 0.3.3-alpha.1

Reproductor expandido renovado y correcciones de biblioteca, listas y navegación de extensiones para fuentes de música en la nube.

- Carátula grande, título en una línea, favorito, detalles reales, progreso, volumen con porcentaje y controles con acceso a la cola. El ecualizador queda reservado para una extensión futura.
- Añadir canciones de un álbum a una lista manual existente o crear una nueva, conservando contenido y sin duplicados.
- Anterior recorre el historial de canciones aunque uses aleatorio; Siguiente recupera el avance visitado antes de otro sorteo. Historial local restaurable.
- Artistas separados por comas aparecen en sus propios grupos, sin modificar archivos ni etiquetas. Se conserva visible el filtro guardado al actualizar.
- Acceso de fuente con icono de contorno integrado al tema; se elimina el botón Abrir duplicado cuando ya aporta navegación.

## Descargas

- Android universal/global: RP-Music-0.3.3-android.apk.
- Android ARM64: RP-Music-0.3.3-android-arm64.apk.
- Windows x64: extraer todo RP-Music-0.3.3-windows-x64.zip.
- Guías: USO.md, PRUEBAS-0.3.3.md, CAMBIOS-0.3.3.md y SHA256SUMS.txt.

Android mantiene la firma de distribución de desarrollo: actualizar encima de la versión anterior para conservar datos. Windows necesita ejecutable, DLL y data juntos.

## Extensiones por separado

Actualiza desde Extensiones → Explorar repositorio: [rp-music-extensions](https://github.com/Joao-s02/rp-music-extensions). Fuente 0.2.1 para el icono de contorno y Biblioteca viva 0.1.1 para filtros por artistas colaboradores; requieren RP Music 0.3.3. El catálogo conserva paquetes compatibles con versiones anteriores. Ninguna extensión se incluye en los APK/ZIP ni se adjunta a esta release.

La fuente inicial sigue priorizando Android; Windows recibe biblioteca/reproducción local y mejoras visuales. Cuentas y listas/favoritos/historial online siguen pendientes.

## Validación y límites

Suite inicial completa de 86 pruebas aprobada y regresión adicional del filtro guardado incluida en 11 verificaciones finales seleccionadas, todas aprobadas. Análisis sin incidencias. Recorrido nativo Android con audio real, pausa/seek, anterior/avance y revocación aprobado en primer plano. APK normal instalado/abierto, ARM64 y firma verificados; Windows compilado e iniciado y ZIP completo comprobado.

Retesteo físico, escucha larga y comprobación de pantalla apagada de esta versión pendientes. La referencia visual no añade funciones todavía no implementadas de letras, temporizador o selección de salida. Consulta PRUEBAS para el recorrido recomendado.
