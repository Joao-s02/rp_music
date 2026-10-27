# Pruebas de RP Music 0.3.5

## Ya verificado

- Suite: 106 aprobadas. Prueba de red optativa omitida por defecto y ejecutada aparte con resultado aprobado. Análisis sin incidencias.
- Etiquetas M4A: título/artista/álbum/artista de álbum/fecha/pista/disco/letras, portada, conservación de posiciones/bytes de audio y manejo de mdat hasta EOF.
- SYLT a LRC, prioridad de incrustadas, caché privada y negativa, revocación antes de guardar, búsqueda sin abrir Letras y protección de importación manual ante respuesta tardía. Regresión del fallo de captura del registro en el isolate del escritor.
- Intérprete real de paquetes: normalización, búsqueda alternativa y rechazo de artista/versión/duración incorrectos. Cinco comprobaciones específicas externas, no parte del conteo de 106.
- YouTube real → letras sincronizadas: Las Noches / Junior H (227 s), BAILE INoLVIDABLE / Bad Bunny (368 s), La Incondicional / Luis Miguel (258 s). No se guarda contenido lírico como fixture.
- Enriquecimiento completo con paquete real y audio sintético de 4 s: letra, portada de 72531 bytes y álbum incrustados, original intacto; temporales eliminados. No equivale a escuchar físicamente esas canciones.
- ffprobe/ffmpeg: etiquetas y decodificación correctas; Windows nativo: lectura de letras y reproducción con avance, conservando hash del original.
- App normal universal y Windows compilados, versión 0.3.5+14. Publicación también incluye ARM64 de la misma versión, firmas/ABI e integridad comprobados antes de publicar. No se distribuyen ejecutables de integración ni paquetes de extensión dentro de APK/ZIP.

## Pruebas pendientes para el usuario

1. Instalar Android encima de la anterior sin desinstalar; Windows extraer todo. Verificar conservación de biblioteca, listas, favoritos, ajustes y extensiones.
2. Seleccionar canciones locales con letras incrustadas, incluso sin conexión ni extensiones. Abrir Letras y comprobar texto; en LRC/SYLT compatible probar avance, retroceso y tocar línea. Cambiar pista: no mezclar letras. Probar MP3/M4A/FLAC/Ogg/Opus y reportar formato/variante concretos.
3. Instalar Letras locales 0.1.0 y aceptar permisos. Seleccionar canción sin letra: debe consultar automáticamente y guardar solo en la app. Repetir sin red y verificar recuperación. Comparar archivo musical original: no debe cambiar. Desactivar proveedor impide nuevas búsquedas y conserva copias. Probar reintento de nube tras ausencia/error.
4. Importar LRC/TXT manualmente. Una búsqueda pendiente no debe reemplazar la letra importada. Cancelar selector debe conservar la anterior.
5. Actualizar YouTube Android 0.4.0 desde catálogo y revisar permisos. Probar los tres ejemplos y versiones de estudio/directo/remix; comprobar coincidencia y sincronización. Una versión distinta debe descartarse.
6. Descargar nueva canción: elegir destino, abrir con otro reproductor y verificar etiquetas, portada y letras disponibles. Actualizar biblioteca si está en la raíz. Cancelar selector, revocar permiso y cortar conexión; comprobar aviso de datos parciales y que no se modifiquen archivos locales existentes. Guardado SAF real y escritura con selector siguen pendientes en dispositivo.
7. Probar notificación/widget, pantalla apagada, segundo plano y escucha prolongada en Android físico. En Windows probar controles multimedia y biblioteca local. No declarar funcional YouTube Windows por devolver búsqueda/bytes.
8. Confirmar Spotify ausente del catálogo; las instalaciones previas se eliminan manualmente si se desea. Verificar actualización entre releases conservando datos.

Registrar plataforma/versión, formato, canción, pasos y resultado. Los servicios comunitarios pueden faltar o fallar: no convertir un ensayo positivo en cobertura universal.
