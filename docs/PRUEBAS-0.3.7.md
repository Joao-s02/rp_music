# Pruebas de RP Music 0.3.7

## Comprobado

114 pruebas de la suite aprobadas y una prueba de red optativa omitida. Análisis del código cambiado sin incidencias. Importación con duplicados, reinicio, borrado de referencias faltantes, contrato y revocación de proveedor; interfaz a 360 px abre álbum e importa copia. Siete casos del paquete Explorador en intérprete; consultas reales por artista/álbum/lista y apertura. Paginación larga pública con 100+100 canciones. Repeticiones no aumentan el total. Firma Android compatible con 0.3.6; paquetes completos verificados al publicar.

## Pruebas pendientes del usuario

1. Instalar APK universal o ARM64 encima sin desinstalar. Windows: extraer todo el ZIP y conservar datos. Comprobar listas, favoritos, raíz, ajustes y extensiones.
2. Mantener YouTube Android 0.4.0 e instalar también YouTube Explorador 0.1.0 desde catálogo. Confirmar que ambas aparecen, elegir Explorador como Fuente y luego volver a la estable.
3. Buscar canciones, artistas, álbumes y listas públicas. Abrir páginas, reproducir y cargar más. Probar listado vacío, privado/no disponible, error de red y reintento; no esperar conexión de cuenta.
4. Abrir una lista larga y cargar todas las páginas antes de importar. Elegir nombre nuevo. Reiniciar y comparar orden/canciones/repeticiones. Editar la copia debe afectar solo RP Music. No esperar audio offline por importar.
5. Probar descarga y etiquetas/letras con cada proveedor en Android. Actualizar biblioteca y reproducir el M4A en la app y otro reproductor. No se reparan automáticamente archivos antiguos.
6. Desactivar/cambiar fuente durante búsqueda o reproducción; deben descartarse respuestas tardías y detenerse el acceso no autorizado.
7. SD/SAF, permisos revocados, widget, notificación, escucha larga y actualizaciones conservando datos en equipos físicos. Windows local y bandeja; YouTube Windows sigue fuera de las capacidades confirmadas.

Las pruebas públicas de red no equivalen a ensayo físico Android ni validación de todas las canciones, regiones o servicios. Informa versión/dispositivo/pasos al detectar fallos.
