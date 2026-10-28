# Pruebas de RP Music 0.3.6

## Ya verificado

- Suite completa: 110 aprobadas, una prueba de red optativa omitida. Análisis del escritor, herramienta y nuevas pruebas sin incidencias. No se suman repeticiones.
- Cuatro regresiones nuevas con estructuras sintéticas: moov antes del índice/fragmentos; reparación de moov final emitido por 0.3.5; rechazo de posiciones absolutas; rechazo de índice aleatorio no soportado.
- Archivo real afectado: antes ffprobe fallaba al interpretar pistas; después de reparar copia detecta AAC/portada y decodifica todo el audio, duración 257.026667 s. Conserva 26 mdat, 26 moof y un sidx byte a byte; original intacto. Escáner de escritorio descubre título La incondicional y 257026 ms, sin omisiones. No se incluye ese archivo privado en las pruebas ni en la release.
- M4A fragmentado sintético de 4 s: etiquetado, letras, identificación y decodificación externa aprobados. MP4 plano y regresiones anteriores siguen pasando.
- Se mantienen como antecedentes los ensayos nativos Windows y los tres casos de letras/red de 0.3.5; no se presentan como pruebas nuevas de 0.3.6.

## Pruebas del usuario pendientes

1. Instalar Android encima de 0.3.5 sin desinstalar. Windows: extraer todo el ZIP. Comprobar datos/listas/ajustes conservados.
2. Usar el mismo paquete YouTube Android 0.4.0. Descargar una canción nueva en la raíz musical, actualizar biblioteca y verificar que aparece, reproduce y muestra etiquetas/carátula/letras disponibles.
3. Probar La incondicional y otros temas; abrir el archivo en otro reproductor. Probar copia reparada de una descarga anterior. El arreglo de la app no modifica automáticamente las canciones ya guardadas.
4. Probar tanto M4A plano como fragmentado, pausar, avanzar/retroceder y cambiar pista. Conservar el archivo original al informar errores. No cambiar una extensión esperando convertir o reparar audio.
5. Cancelar selector, interrumpir red, revocar permiso de descarga y probar proveedor desactivado. Cuando no puede etiquetarse, el aviso debe explicar que conserva el audio original.
6. Comprobar letras incrustadas offline y Letras locales para canciones sin letra, con caché privada. Verificar que los archivos locales originales no cambian.
7. Probar SAF/SD, notificación/widget y escucha prolongada en Android físico. No declarar resuelto YouTube Windows por estas comprobaciones de archivos.

La identificación y decodificación en escritorio no acreditan visibilidad/lectura en el teléfono del usuario. Registrar sistema/versión, carpeta, archivo y resultado.
