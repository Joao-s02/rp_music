# RP Music0.3.16+25 — desarrollo local

La referencia publicada continúa siendo0.3.15. Este desarrollo no autoriza publicación ni actualización del catálogo externo.

## Cambios y cómo probarlos

1. Instala varias fuentes y pantallas visuales. La navegación conserva Biblioteca/Favoritos/Listas/Explorar/Ajustes. En Explorar abre cada fuente; Administrar extensiones permite instalar/actualizar/revisar permisos.
2. Abre un álbum local: búsqueda inicialmente plegada. Pulsa la lupa, filtra por canción y comprueba que permaneces en ese álbum. Cerrar búsqueda recupera todas sus pistas.
3. Reproduce una canción del álbum. Su indicador se anima; pausar detiene el movimiento. Respeta movimiento reducido y el tamaño de texto.
4. Artistas: prueba etiquetas como «Ana y Luis», «Ana & Luis», «ANA» y «ana». Cada colaboración comparte las canciones y las mayúsculas no crean otro grupo. Los archivos originales no se editan. Los nombres de grupos que contienen esas conjunciones pueden requerir una futura excepción manual.
5. YouTube Explorador: busca artistas y abre uno. Sus resultados muestran foto pública y portadas de álbum disponibles; si faltan, se conserva un icono. La disponibilidad depende del servicio.
6. Descarga La Incondicional/Luis Miguel y Las Noches/Junior H desde resultados sueltos con los candidatos0.3.16. Comprueba álbum y portada dentro del archivo exportado, no solo en la pantalla. No se reparan automáticamente descargas anteriores.
7. Descarga un álbum completo. Mantén la app abierta. Comprueba progreso por canción/bytes; al fallar una pista, Reintentar fallidas descarga solo esa pista con su numeración original y la misma carpeta. Archivos terminados se conservan. Audio hasta512MiB por canción; necesita espacio para temporales y salida. Las descargas individuales conservan por ahora el límite64MiB.
8. Explorador JS candidato0.1.1: abre contenido y vuelve a la página anterior. Su caché pública dura hasta60s y desaparece al cerrar la pantalla o cambiar permisos. Los tiempos de motor/red/acción aparecen en el diagnóstico de sesión. Sigue pendiente medir la demora real Android y primer audio.

Los paquetes de YouTube y Explorador se instalan por separado desde los candidatos en el repositorio independiente de extensiones. El catálogo publicado todavía ofrece las versiones anteriores. No hace falta instalar todas las variantes Android/Windows; elegir la compatible con la plataforma.

## Verificación registrada

- Suite Flutter:163 aprobadas, una optativa de red omitida, sin fallos en la ejecución final registrada.
- Escritor a archivo: MP4 plano/fragmentado/inicialización final coinciden byte a byte con la salida del escritor previo. Prueba65MiB conserva SHA256 del payload. No se recodifica.
- Consultas de metadatos públicas recuperan los dos álbumes. Enriquecimiento/incrustación con copia de audio sintético: Las Noches obtiene $AD BOYZ 4 LIFE II y portada1200×1200; La Incondicional obtiene Busca Una Mujer y portada1000×1000 incluso con fallo503 en una consulta posterior. No son pruebas físicas ni audios descargados/reproducidos de ambas canciones.
- Primer intento completo de La Incondicional:503 y ausencia de portada, conservado como fallo real previo.
- Respaldo de origen final comprobado con MusicBrainz simulado503: álbum Busca Una Mujer y portada1200×1200. Cuatro paquetes Dart finales pasan sus pruebas; cinco candidatos externos tienen hashes comprobados. Android universal firmado y Windows completo compilados.

## Pendientes

Android físico: actualización conservando datos, ARM64, SAF/SD/exportación, widgets/launcher, escucha prolongada y latencia API3. No hay garantía universal de álbum/foto/letra para todas las canciones. Publicación requiere otra autorización.

Contexto detallado: [nota45 de la bóveda](../boveda/45%20Portadas%20artistas%20navegacion%20y%20descargas%200.3.16.md).
