---
tipo: correccion-y-verificacion
estado: publicado-con-verificacion-y-limites
actualizado: 2026-10-28
---
# Audio Windows M4A OPUS y YouTube

## Informe confirmado

Tras0.3.9, el usuario informa fallos de audio local/YouTube JS Windows y radio con carga aproximada30s. Aclaraciones: **M4A y OPUS fallan; FLAC, MP4 y MP3 sí funcionan**. No registrar fallo general de toda reproducción ni suponer MP3 averiado. Android reproduce sus canciones con normalidad. Exige resolver también YouTube Windows ahora, manteniendo API2; no migrar sus extensiones a JavaScript. Latencia Android3–6s en operaciones API3 sigue como asunto separado en [[38 Latencia de extensiones API 3]].

Autorización de corrección, no de nueva publicación. App local0.3.10+19; referencia publicada0.3.9+18 conservada. [[03 Biblioteca y reproduccion]], [[04 Extensiones]], [[31 Arquitectura vigente]].

## Diagnóstico reproducido

Se inspeccionaron archivos accesibles de la biblioteca de esta instalación, sin modificar originales ni registrar rutas/títulos privados en bóveda. Cinco M4A son AAC44100Hz/estéreo en MP4 fragmentado; varios contienen portada MJPEG. ffprobe los reconoce. Una entrada histórica con extensión.mp3 contiene un MP4 mal formado; no representa una prueba de MP3 válido y se conserva sin modificar.

Motor previo WinRT/just_audio_windows_plus0.5.5: M4A reales no avanzan; algunos emiten error nativo y otros quedan detenidos sin error claro. Copia byte a byte con nombre sencillo tampoco reproduce; dos copias de diagnóstico con el mismo AAC reempaquetado (plano y fragmentado sin pista de portada) sí avanzan. Por tanto no se atribuye todo fallo a fragmentación ni se presume audio original corrupto. Mensaje de app ocultaba causa y sugería siempre comprobar formato.

## Corrección local

Solo Windows pasa a just_audio_media_kit2.1.0/media_kit1.2.6 + media_kit_libs_windows_audio1.0.9, con libmpv audio dinámico. Factory nativa central, inicialización única y protocolos acotados a archivos/HTTP de audio. Android conserva just_audio nativo y parches audio_service; no se toca su configuración del servicio. Dependencias/registros de plugins regenerados. Junctions locales resuelven enlaces de compilación sin cambiar Modo desarrollador/configuración de Windows.

MusicHandler conserva código de error de audio y tiempos de resolución/carga en diagnóstico; URLs se redactan. El aviso de carga no culpa automáticamente al archivo. Se escucha el error asíncrono para soltar una carga cuyo backend no complete su Future; Windows añade límite30s. Nueva selección/parada/cierre interrumpen esa espera sin autoplay tardío. Pruebas de fallo/recuperación y controles finales en cierre.

Licencias de wrappers/nativo y referencias del binario en third_party/windows_audio. No se modifica DLL ni caché de paquetes. Binario upstream2023-09-24(652a1dd); cadenas internas FFmpeg identifican LGPL3+, compilación --disable-gpl/--disable-nonfree/--enable-version3. Se conservan textos LGPL3/GPL3/LGPL2.1 y MIT/Unlicense correspondientes; la licencia MIT del wrapper no se presenta como licencia única de la DLL. No hay música del usuario en distribuciones.

## Extensiones externas candidatas

En rp-music-extensions/previews/0.3.10, fuera de APK/ZIP y sin cambiar catálogo público:

- YouTube Windows0.4.1, rp.youtube-music-windows, minApp0.3.10: código Dart exacto de YouTube Android0.4.0, manifiesto Windows independiente. Paquete Android previo intacto.
- YouTube Explorador Windows0.1.0, rp.youtube-explorer-windows, minApp0.3.10: código Dart exacto de Explorador0.1.0, identidad Windows independiente. Navegación pública por API2 y propietario Fuente explícito.
- Radio por internet0.1.1, mismo ID que0.1.0/minApp0.3.9: consulta /json/url/UUID renueva enlace y registra clic a la vez. Elimina una consulta secuencial, valida UUID/HTTPS/audio directo y mantiene comprobación pública del stream en anfitrión. No elimina seguridad para acelerar. Paquete0.1.0 publicado preservado; fuente nueva radio_internet_011.js.

## Evidencia nativa inicial

1. Doce variantes locales con motor nuevo: cinco M4A originales intactos, dos remux de diagnóstico, MP3/WAV/OPUS/FLAC sintéticos y MP4 de control. Todas avanzan~1.6–2s y reproducen, sin error en canales de reproducción. Primera M4A236ms de carga; restantes controles28–40ms en este ensayo. No garantía para cualquier archivo/códec/equipo.
2. YouTube API2 Windows sencillo y Explorador: búsqueda20 resultados, dos canciones reales, progreso, pausa, seek10s, siguiente/anterior y parada por desactivación aprobados. Tiempo hasta cargar y acumular2s de audio:3908ms/3623ms; no confundir con latencia pura de inicio. Informes anónimos en dist/windows-sources-mediakit.json.
3. Explorador JS0.1.0 original: búsqueda/entidades/100+100 y reproducción real de La Incondicional aprobadas. Acción de resolución1571ms y total4285ms incluyendo2s de avance. No es solo URL recibida.
4. Radio candidata0.1.1: consulta de selección796ms y total7161ms incluyendo2086ms de audio; inicio aproximado5s para Radio Swiss Pop AAC192, pausa/reanudación/parada aprobados. No se ensayó necesariamente la misma emisora/red del informe30s ni se promete ese tiempo universal.

Los componentes nativos emitieron advertencias no fatales de propiedad osc/caché de archivo y una de TLS durante cierre de stream; no se ocultan como ausencia absoluta de logs, aunque los canales de error de reproducción quedaron vacíos en casos aprobados. Caché/páginas y rendimiento Android general no se declaran resueltos por cambiar backend Windows.

Suite completa, prueba de rechazo de archivo inválido/recuperación, bandeja/cierre y binarios normales definitivos pendientes al redactar. No publicar ni hacer push sin nueva autorización. Validación física Android pendiente.

Fuentes primarias: https://pub.dev/packages/just_audio_media_kit , https://pub.dev/packages/media_kit_libs_windows_audio , https://github.com/media-kit/libmpv-win32-audio-build , https://docs.radio-browser.info/ (station click counter devuelve URL actual). Código de paquetes instalado inspeccionado además de documentación.

## Cierre local comprobado

Suite conjunta final: **142 aprobadas** (132 app + diez externas), una red optativa omitida. Análisis final lib/test/integration_test/tools y pruebas particulares nuevas sin incidencias. No sumar ensayos dirigidos/repeticiones a esa cifra. Capturas históricas y tres imágenes previas sin seguimiento restauradas desde respaldo, sin incorporar cambios gráficos ajenos.

Cinco casos nativos distintos aprobados, por separado de suite: formatos (doce variantes), archivo inválido→M4A válido, dos fuentes API2 en un caso, pantallas JS/red/audio y controles/bandeja Windows. La primera aserción sobre error de archivo inválido fue prematura: el backend notifica después de completar carga; se esperó notificación asíncrona y pasó la recuperación. Se conserva error/código y no queda bloqueada la siguiente pista. Caso simulado de Future nativo que no completa también cubierto por regresión unitaria; parada/cambio/cierre interrumpen carga nativa.

Con código final: API2 Windows sencillo/Explorador buscaron20 resultados y reprodujeron con pausa/seek/siguiente/anterior/revocación. Búsquedas1050/766ms; totales3820/3498ms incluyen2s de reproducción. Explorador JS original reprodujo audio real (resolución1610ms, total4318ms con2s de avance) y continuaciones100+100. Radio0.1.1: selección952ms; total6952ms con2080ms de avance (~5s hasta inicio), pausa/reanudación/revocación aprobadas. Resultados de esa red/estación, no garantía universal ni prueba de Android.

Binarios normales tras las sondas: Windows release50.9s, ProductVersion/FileVersion0.3.10+19; ZIP íntegro30 archivos con libmpv/QuickJS/licencias/guía, sin antiguo plugin WinRT ni rpmx. APK universal release91.2s, versión0.3.10/código19, firma v2/certificado SHA256 eba2769ed11d359c8f89f6991bc6867c7766f6f46a4295bc5386e7d41ce7d38d compatible, tres ABI. APK sin libmpv/DLL Windows ni rpmx; motor móvil no sustituido. No se probó instalación física Android ni se generó ARM64 separado para esta entrega local.

Entrega en dist/0.3.10-local y guía docs/PROBAR-WINDOWS-0.3.10.md. Hashes:

```text
144e60fcf58fbd4146ed2988dbcfe0d6d35c46fc0d79f00756dfe0160cc7e9c1  RP-Music-0.3.10-local-android.apk
479d2111ecb1aba67092c97d46d78bcc53c86ad7199912b70ab6a820b92d8888  RP-Music-0.3.10-local-windows-x64.zip
```

YouTube API2 Windows y Radio0.1.1 externos, regenerables mediante build_windows_0310.py; catálogo/paquetes publicados anteriores intactos. Sin commits nuevos, push ni publicación. Falta prueba del usuario con mismos M4A/OPUS/emisora/red y escucha prolongada, además de Android físico. Windows YouTube ya tiene evidencia nativa local positiva; no mantenerlo como fallo universal sin distinguir la release pública anterior y esta corrección.


## Publicación 0.3.10 autorizada — 2026-10-28

El usuario solicita «sube la nueva release». Se prepara entrega completa universal/ARM64/Windows, guías y hashes, catálogo externo con diez opciones y Radio0.1.1 como actualización compatible. Se verificarán borrador/adjuntos antes de publicar y acceso público después. Evidencia nativa y pendientes de [[39 Audio Windows M4A OPUS y YouTube]] se conservan.


## Entrega completa preparada

ARM64 normal compilado y verificado: versión0.3.10/código19, solo arm64-v8a y firma v2 con certificado previo. Universal conserva bytes normales comprobados. ZIP público32 archivos, todas las DLL/data/licencias y tres guías, comparado byte a byte con compilación normal; sin WinRT ni rpmx. Siete adjuntos en dist/0.3.10-release y SHA256SUMS final. Catálogo publicado en 8733caa272a7d8609e9884bff2d12ba42aace43e: diez opciones descargadas por el cliente real con SHA256/metadatos correctos, incluida Radio0.1.1 y ambas fuentes Windows. No equivale a Android físico.


## Publicación confirmada — 2026-10-28

0.3.10-alpha.1 publicada, app0.3.10+19. Android universal/ARM64 y Windows x64 completo con licencias, guías y hashes. ReleaseID 426832656; tag/código 5587b0e07dad13014e8f534854df5d80dd8f1036. Siete adjuntos verificados por tamaño/SHA256/target en borrador y públicamente; tag al commit correcto y manifiesto público idéntico. Catálogo externo 8733caa272a7d8609e9884bff2d12ba42aace43e, diez opciones descargadas con cliente real/SHA256/metadatos válidos. 142 pruebas/una optativa omitida, análisis limpio y cinco casos nativos Windows. YouTube API2/JS con audio real y M4A/OPUS comprobados; fuentes Android conservadas. Android físico, escucha prolongada y latencia API3 Android pendientes. [[39 Audio Windows M4A OPUS y YouTube]].

https://github.com/Joao-s02/rp_music/releases/tag/v0.3.10-alpha.1


## Confirmación posterior del usuario

El usuario prueba0.3.10 Android/Windows y confirma explícitamente: YouTube Windows reproduce sonido y descarga canciones; lectura M4A y OPUS Windows sin errores. Es evidencia directa de uso, independiente de las pruebas instrumentadas anteriores. La nueva solicitud de gestos/widgets/listas/álbumes/metadatos/fotos se mantiene en [[40 Gestos widgets albumes y descargas 0.3.11]]. No atribuir mejora de latencia API3 Android a esta confirmación.
