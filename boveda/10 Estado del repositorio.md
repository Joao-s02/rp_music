---
tipo: estado-actual
estado: publicado-con-limites-experimentales
actualizado: 2026-10-27
---
# Estado del repositorio

## Referencia publicada

**0.3.6-alpha.1**, aplicación **0.3.6+15**, Android universal/ARM64 y Windows x64. [Release pública](https://github.com/Joao-s02/rp_music/releases/tag/v0.3.6-alpha.1).

- Tag/código: d0d894257e52f89f3c6edc80359bc737bf9bbf51.
- Extensiones: d0a007ef5bbc4f8fb22ed340c57fa7ddab2f5ee4 de rp-music-extensions. Código/paquetes específicos exclusivamente allí; commits documentales posteriores no cambian binarios.
- Siete adjuntos públicos verificados por tamaño/SHA-256: dos APK, ZIP Windows completo, USO, PRUEBAS, CAMBIOS y SHA256SUMS. Manifiesto descargado sin autenticación idéntico al local; tag confirmado al commit esperado.
- Evidencia de corrección/publicación en [[34 Descarga M4A no visible en biblioteca]]. Funciones y entrega anterior en [[33 Metadatos de descargas YouTube]]; navegación histórica en [[30 Archivo de navegacion y estado]].

## Capacidades actuales

| Área | Estado |
| --- | --- |
| Biblioteca local | Raíz/subcarpetas, caché, escaneo manual/progresivo, búsqueda, álbumes/artistas/carpetas y orden. |
| Audio | Cola de selección, controles/volumen, aleatorio/repetición, anterior/avance histórico y restauración sin autoplay. |
| Listas/archivos | Manuales/favoritos/carátulas/añadir álbumes; automáticas por extensión; borrado confirmado y metadatos de lectura. |
| Reproductor | Carátula/espacios adaptables y controles principales fijos; disposición de extensión por contrato. |
| Letras base | Lee incrustadas en formatos compatibles; SYLT en milisegundos añadido; importación LRC/TXT y sincronización por línea/seek. Límites concretos en nota 33. |
| Letras automáticas | Extensión autorizada busca al seleccionar canción sin incrustadas/caché. Resultados privados, sin modificar música local. No es barrido masivo. |
| Descargas | Nuevas M4A compatibles con etiquetas, portada y letras disponibles sin recodificar. Selector, permiso storage.download y audio hasta 64 MiB/3 min. Datos parciales/errores con aviso. |
| Android | Sesión/notificación/carátula/controles, permisos y widget. Lectura SAF con copia temporal privada acotada; retesteo físico actual pendiente. |
| Windows | Audio local, volumen y bandeja/salida. YouTube Windows no supera pruebas nativas previas; no declararlo funcional. |
| Actualizaciones | Consulta opcional/manual/diaria, canales y descarga/verificación. Android usa instalador; Windows extrae ZIP manualmente. |
| Extensiones | API 1/2 experimental, permisos, recuperación, catálogo y destinos múltiples. Proveedor lyrics independiente de source. |

Contratos en [[04 Extensiones]], comportamiento en [[03 Biblioteca y reproduccion]], módulos en [[31 Arquitectura vigente]].

## Extensiones para esta versión

Catálogo público: YouTube Android 0.4.0, Letras locales 0.1.0, Biblioteca viva 0.1.1 y Pulso nocturno 0.1.0. Los dos nuevos paquetes requieren app 0.3.5 y revisar permisos/dominios. Variantes anteriores conservadas. Spotify cancelado/retirado del catálogo; archivos históricos no borrados y una instalación previa no se elimina automáticamente.

YouTube Windows 0.3.0 sigue como candidato manual fuera del catálogo recomendado, con fallos nativos conocidos. Ninguna extensión viene dentro del APK/ZIP ni adjunta a la release de la app.

## Verificaciones registradas

- Suite 110 aprobadas, análisis de los cambios sin incidencias. Prueba de red optativa omitida; resultado positivo de 0.3.5 como antecedente, no prueba nueva.
- Antecedente 0.3.5: tres casos del usuario desde resultados reales YouTube/duración real obtuvieron letras sincronizadas. Prueba completa con paquete real incrustó letras/portada/álbum en audio sintético, con original intacto.
- Antecedente 0.3.5: lector y reproducción nativa Windows de M4A etiquetado aprobados; ffprobe/ffmpeg comprobaron etiquetas/duración/decodificación.
- APK universal/ARM64 normales, versión/código 0.3.6/15, firma v2/certificado compatible y ABIs correctos. Sin dispositivo conectado para instalación/escucha física de esta versión.
- Windows normal 0.3.6+15 recompilado tras las pruebas; ZIP de 22 archivos íntegro con guías, sin paquetes de extensión ni sonda.
- Publicación: borrador verificado antes de publicar, API pública/adjuntos/tag y manifiesto descargado confirmados después. Artefactos finales en dist/0.3.6-release.

## Pendientes y límites activos

Fallo posterior confirmado en 0.3.5: etiquetar MP4/M4A fragmentado desplaza la inicialización al final y produce archivos incompatibles. Corrección publicada 0.3.6+15 y copia del archivo aportado reparada, decodificada y encontrada por escáner de escritorio. 110 pruebas aprobadas y análisis limpio de cambios. Usuario confirma el 2026-10-27 que todo funciona muy bien; incidencia M4A cerrada según ese informe. [[34 Descarga M4A no visible en biblioteca]].

Prueba física Android con archivos personales, selector SAF/exportación real, permisos, SD/launcher/widget y escucha prolongada; actualización entre releases conservando datos; cobertura de formatos/redes/regiones. Letras/metadatos pueden faltar o corresponder a versiones distintas; servicios con 503/timeouts observados. No se promete toda canción ni etiqueta.

YouTube Windows funcional; cuentas/listas/favoritos/historial online; edición general de etiquetas, cola editable, gapless/fundido, ecualizador como extensión; aislamiento/métricas/firmas del SDK y licencia concreta. Spotify y Play Store dejan de ser objetivos. Distribución oficial exclusivamente GitHub. [[07 Preguntas e investigacion]]. Publicaciones futuras requieren autorización y [[27 Publicacion de releases - contenido obligatorio]].

0.3.6 corrige moov al final en M4A fragmentados: inicialización previa y offsets relativos validados, sin recodificar. Copia del archivo aportado y fixture fragmentado decodificados por ffmpeg; escáner de escritorio encuentra la copia. No se reescriben archivos existentes al actualizar. Confirmación posterior del usuario: buen funcionamiento de 0.3.6; incidencia M4A cerrada según su informe, sin atribuir pruebas específicas adicionales. [[34 Descarga M4A no visible en biblioteca]].

Trabajo local 0.3.7+16: variante YouTube Explorador 0.1.0 con ID independiente, sin alterar YouTube Android 0.4.0 ni catálogo. Navegación pública e importación persistente implementadas localmente; cuenta/sincronización pendientes. Contratos y evidencia en [[35 Ampliacion de YouTube sin API oficial]]. No publicado.
