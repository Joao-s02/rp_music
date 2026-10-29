---
tipo: estado-actual
estado: publicado-con-limites-experimentales
actualizado: 2026-10-28
---
# Estado del repositorio

0.3.11-alpha.1 publicada, app0.3.11+20. Android universal/ARM64 y Windows x64 completo con licencias/guías/hashes. ReleaseID 427162160; tag/código 34211ad4760368c1c76808fff67deb1a7579c441. Siete adjuntos verificados por tamaño/SHA256/target en borrador y públicamente, tag al commit correcto y manifiesto descargado idéntico. Extensiones 2dfeaf16985ba7299e9592261a83cf52ee8d4ea5: diez opciones verificadas con cliente real y veinte paquetes/variantes de revisión fija byte a byte. YouTube Android/Windows0.5.0 y Explorador Android/Windows0.2.0, minApp0.3.11; API2 y variantes anteriores conservadas.147 pruebas aprobadas/una optativa omitida, análisis limpio; seis canciones de álbum real con etiquetas/portada/numeración iguales y foto recuperada offline comprobadas. Android físico (widgets/launcher/SAF), escucha prolongada y latencia API3 Android pendientes. [[40 Gestos widgets albumes y descargas 0.3.11]].

0.3.10-alpha.1 publicada, app0.3.10+19. Android universal/ARM64 y Windows x64 completo con licencias, guías y hashes. ReleaseID 426832656; tag/código 5587b0e07dad13014e8f534854df5d80dd8f1036. Siete adjuntos verificados por tamaño/SHA256/target en borrador y públicamente; tag al commit correcto y manifiesto público idéntico. Catálogo externo 8733caa272a7d8609e9884bff2d12ba42aace43e, diez opciones descargadas con cliente real/SHA256/metadatos válidos. 142 pruebas/una optativa omitida, análisis limpio y cinco casos nativos Windows. YouTube API2/JS con audio real y M4A/OPUS comprobados; fuentes Android conservadas. Android físico, escucha prolongada y latencia API3 Android pendientes. [[39 Audio Windows M4A OPUS y YouTube]].

Informe posterior0.3.9: usuario confirma nuevas extensiones funcionales en Android, con latencia percibida3–6s al consultar/abrir contenido API3. No es fallo de apertura vacía confirmado ni benchmark instrumentado. YouTube API2 se conserva; [[38 Latencia de extensiones API 3]].

0.3.9 publicada: HTTP/audio remoto JS y Explorador musical/Radio por internet independientes. Verificación y límites en [[37 Explorador y radio JavaScript]].

2026-10-28: el usuario confirma que 0.3.8 fue un éxito y que las extensiones JavaScript funcionan correctamente. Dispositivo, plataforma y recorrido no especificados; confirmación de uso sin nueva prueba instrumentada. Propuesta posterior en [[36 Motor JavaScript paralelo]].

## Referencia publicada

0.3.11-alpha.1 publicada, app0.3.11+20. Android universal/ARM64 y Windows x64 completo con licencias/guías/hashes. ReleaseID 427162160; tag/código 34211ad4760368c1c76808fff67deb1a7579c441. Siete adjuntos verificados por tamaño/SHA256/target en borrador y públicamente, tag al commit correcto y manifiesto descargado idéntico. Extensiones 2dfeaf16985ba7299e9592261a83cf52ee8d4ea5: diez opciones verificadas con cliente real y veinte paquetes/variantes de revisión fija byte a byte. YouTube Android/Windows0.5.0 y Explorador Android/Windows0.2.0, minApp0.3.11; API2 y variantes anteriores conservadas.147 pruebas aprobadas/una optativa omitida, análisis limpio; seis canciones de álbum real con etiquetas/portada/numeración iguales y foto recuperada offline comprobadas. Android físico (widgets/launcher/SAF), escucha prolongada y latencia API3 Android pendientes. [[40 Gestos widgets albumes y descargas 0.3.11]].

[Release pública](https://github.com/Joao-s02/rp_music/releases/tag/v0.3.11-alpha.1). Artefactos finales: dist/0.3.11-release. Antecedentes: [[39 Audio Windows M4A OPUS y YouTube]], [[37 Explorador y radio JavaScript]].

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
| Extensiones | API1/2 conservadas y API3/JavaScript: pantallas, HTTP por etapas y audio remoto autorizados. Catálogo/permisos/recuperación; proveedor lyrics independiente. |

Contratos en [[04 Extensiones]], comportamiento en [[03 Biblioteca y reproduccion]], módulos en [[31 Arquitectura vigente]].

## Extensiones para esta versión

Catálogo público: Explorador musical 0.1.0 y Radio por internet 0.1.0 (API3, app 0.3.9+), Laboratorio JS 0.1.0 (API 3, app 0.3.8+), YouTube Explorador 0.1.0 (Android, requiere app 0.3.7), YouTube Android 0.4.0, Letras locales 0.1.0, Biblioteca viva 0.1.1 y Pulso nocturno 0.1.0. Los dos nuevos paquetes requieren app 0.3.5 y revisar permisos/dominios. Variantes anteriores conservadas. Spotify cancelado/retirado del catálogo; archivos históricos no borrados y una instalación previa no se elimina automáticamente.

YouTube Windows 0.3.0 sigue como candidato manual fuera del catálogo recomendado, con fallos nativos conocidos. Ninguna extensión viene dentro del APK/ZIP ni adjunta a la release de la app.

## Verificaciones registradas

- Suite final138 aprobadas (130app+8ext), análisis sin incidencias. Navegación/resolución y lista100+100 públicas; radio AAC nativa Windows/pausa/reanudación/revocación aprobadas. Prueba de red optativa omitida; resultado positivo de 0.3.5 como antecedente, no prueba nueva.
- Antecedente 0.3.5: tres casos del usuario desde resultados reales YouTube/duración real obtuvieron letras sincronizadas. Prueba completa con paquete real incrustó letras/portada/álbum en audio sintético, con original intacto.
- Antecedente 0.3.5: lector y reproducción nativa Windows de M4A etiquetado aprobados; ffprobe/ffmpeg comprobaron etiquetas/duración/decodificación.
- APK universal/ARM64 normales, versión/código0.3.9/18, firma v2/certificado compatible y ABIs correctos. Sin dispositivo conectado para instalación/escucha física de esta versión.
- Windows normal0.3.9+18 recompilado tras las pruebas; ZIP de23 archivos íntegro con guías, sin paquetes de extensión ni sonda.
- Publicación: borrador verificado antes de publicar, API pública/adjuntos/tag y manifiesto descargado confirmados después. Artefactos finales en dist/0.3.9-release.

## Pendientes y límites activos

Fallo posterior confirmado en 0.3.5: etiquetar MP4/M4A fragmentado desplaza la inicialización al final y produce archivos incompatibles. Corrección publicada 0.3.6+15 y copia del archivo aportado reparada, decodificada y encontrada por escáner de escritorio. 110 pruebas aprobadas y análisis limpio de cambios. Usuario confirma el 2026-10-27 que todo funciona muy bien; incidencia M4A cerrada según ese informe. [[34 Descarga M4A no visible en biblioteca]].

Prueba física Android con archivos personales, selector SAF/exportación real, permisos, SD/launcher/widget y escucha prolongada; actualización entre releases conservando datos; cobertura de formatos/redes/regiones. Letras/metadatos pueden faltar o corresponder a versiones distintas; servicios con 503/timeouts observados. No se promete toda canción ni etiqueta.

Más pruebas prolongadas de YouTube Windows; cuentas/listas/favoritos/historial online; edición general de etiquetas, cola editable, gapless/fundido, ecualizador como extensión; aislamiento/métricas/firmas del SDK y licencia concreta. Spotify y Play Store dejan de ser objetivos. Distribución oficial exclusivamente GitHub. [[07 Preguntas e investigacion]]. Publicaciones futuras requieren autorización y [[27 Publicacion de releases - contenido obligatorio]].

0.3.6 corrige moov al final en M4A fragmentados: inicialización previa y offsets relativos validados, sin recodificar. Copia del archivo aportado y fixture fragmentado decodificados por ffmpeg; escáner de escritorio encuentra la copia. No se reescriben archivos existentes al actualizar. Confirmación posterior del usuario: buen funcionamiento de 0.3.6; incidencia M4A cerrada según su informe, sin atribuir pruebas específicas adicionales. [[34 Descarga M4A no visible en biblioteca]].

Trabajo local 0.3.7+16: variante YouTube Explorador 0.1.0 con ID independiente, sin alterar YouTube Android 0.4.0 ni catálogo. Navegación pública e importación persistente implementadas localmente; cuenta/sincronización pendientes. Contratos y evidencia en [[35 Ampliacion de YouTube sin API oficial]]. No publicado.

Entrega 0.3.7 publicada: navegación genérica de fuentes por entidades/páginas, importación persistente de copias independientes y variante Explorador separada de la estable. 114 pruebas aprobadas/una red optativa omitida; análisis limpio, UI 360px e intérprete/red pública aprobados. Cuenta/sincronización y prueba física pendientes. [[35 Ampliacion de YouTube sin API oficial]].

Prototipo local 0.3.8+17: API 3/JavaScript en paralelo a Dart; pantallas por árbol genérico, estado/eventos y reproducción explícita autorizada. Laboratorio JS separado en repositorio de extensiones. Paquetes YouTube sin modificar. No publicado; verificación y límites en [[36 Motor JavaScript paralelo]].

0.3.8 publicada: API 3/JavaScript paralelo, pantalla genérica y Laboratorio JS separado. Suite122 (120app+2ext), análisis limpio; interfaz360px, estado/permisos y compatibilidad de paquetes reales Dart comprobados. Android físico y capacidades ampliadas pendientes. [[36 Motor JavaScript paralelo]].


Cierre local0.3.11+20:147 pruebas/una optativa omitida, análisis limpio, álbum real completo de seis canciones con etiquetas/portada/numeración y foto recuperada offline comprobados. Universal firmado y ZIP Windows normal/licencias/guías/hashes preparados; tres widgets con mínimos110×48dp y resizeMode ambos ejes verificados en APK compilado. Sin publicación nueva; Android físico/SAF/launcher y escucha prolongada pendientes. Detalle en [[40 Gestos widgets albumes y descargas 0.3.11]].


Trabajo local0.3.12+21: letras sincronizadas prioritarias, escena visual con tiempos reales, reproductor fijo/volumen emergente y cola centrada/animada. Fuente/paquetes/pruebas específicas exclusivamente en repositorio de extensiones; catálogo publicado intacto. Contexto, verificaciones y pendientes en [[41 Letras dinamicas y reproductor fijo 0.3.12]]. Referencia pública0.3.11 conservada.
