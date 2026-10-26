# YouTube Music — definición e investigación inicial

Fecha: 2026-10-26. Estado actual: primera integración Android implementada localmente en 0.3.1+10, validada con límites; los resultados fallidos iniciales se conservan como antecedente.

El usuario confirmó que el catálogo descarga, instala y solicita permisos correctamente en su prueba. Solicita estado Instalada para paquetes presentes y comenzar una extensión YouTube Music con preguntas para precisar alcance. Antecedente confirmado: buscar/explorar catálogo y reproducir dentro de RP Music, ver [[04 Extensiones]].

Preguntas enviadas: funciones imprescindibles y prioridad de búsqueda/reproducción/listas; ubicación de reproducción y necesidad de pantalla apagada/segundo plano; cuenta opcional o inicial, lectura o modificación de datos y prioridad Android/Windows. Pendiente de respuestas, no atribuir elecciones.

Investigación inicial: la documentación de YouTube Data API describe acceso a datos con proyecto/credenciales y OAuth para datos privados; esto no garantiza acceso equivalente a la biblioteca específica de YouTube Music. Las políticas oficiales restringen separar audio, descargas y reproductor no visible/segundo plano. No se ha elegido proveedor oficial/no oficial ni se promete streaming con el motor local. Fuentes consultadas: https://developers.google.com/youtube/data/getting-started y https://developers.google.com/youtube/terms/developer-policies-guide . Revisar capacidades concretas tras respuestas.

El SDK actual no expone red ni fuentes musicales remotas: la implementación real requerirá ampliar contratos/permisos del anfitrión. No instalar un paquete vacío con apariencia de conexión funcional. Autenticación y credenciales no se guardarán en la bóveda.

Relaciones: [[23 Extensiones programables - primer prototipo]], [[07 Preguntas e investigacion]], [[09 Registro de cambios]].


## Respuestas confirmadas — 2026-10-26

- Prioridad máxima: reproducción de canciones de YouTube Music dentro de RP Music.
- Solo audio, sin reproductor de vídeo visible; requiere segundo plano y pantalla apagada.
- Android y Windows desde la primera entrega.
- Primera versión sin iniciar sesión. Listas, favoritos e historial guardados localmente en RP Music.
- También desea búsqueda de canciones/artistas/álbumes, exploración y eventual importación de listas. Sin cuenta no se promete consultar datos privados/favoritos de Google; las listas públicas y los datos locales se deben distinguir.

## Viabilidad y decisión pendiente

Las políticas de los servicios API de YouTube no permiten el modo de reproducción solicitado; no presentar el reproductor oficial como solución equivalente. Se consultó la documentación primaria de youtube_explode_dart: permite consultar metadatos y resolver streams mediante solicitudes no oficiales; algunas rutas requieren un solver JS. Esto describe capacidades del proyecto externo, no una prueba de reproducción en RP Music ni compatibilidad Android/Windows verificada. ytmusicapi documenta búsquedas/lecturas públicas sin autenticación, pero es Python y no resuelve por sí solo la reproducción Flutter.

Fuentes: https://github.com/Hexer10/youtube_explode_dart ; https://ytmusicapi.readthedocs.io/en/stable/reference/api/ytmusicapi.html ; https://developers.google.com/youtube/terms/developer-policies . No se añadieron dependencias ni puentes de red a las extensiones todavía.

Se preguntó si prefiere investigar/desarrollar una integración no oficial experimental o conservar solo vías oficiales. Motivo: diferencia material de compatibilidad con el servicio y mantenimiento, no exigencia de AGENTS ni aprobación de publicación. Pendiente de respuesta; no cambiar sus requisitos de audio por abrir una web/vídeo como sustituto.

Propuesta de orden: comprobar primero reproducción real sin cuenta en Android/Windows (incluido pasar a segundo plano), luego ampliar el SDK de fuentes/red y añadir navegación/listas/historial. Esta secuencia evita presentar una pantalla conectada a metadatos como si ya pudiera reproducir. Ninguna reproducción remota está comprobada aún.


## Vía experimental aceptada

El usuario aceptó explícitamente investigar/desarrollar la integración no oficial, empezando por verificar reproducción real en Android y Windows antes de completar búsqueda/listas/historial. Esto autoriza el trabajo de la extensión, no una publicación de la app ni credenciales de cuentas.

Prueba inicial aislada con youtube_explode_dart 3.1.0 (última publicada consultada): vídeo público de demostración Blender aqz-KE-bpKQ. Metadatos y manifiesto de audio disponibles. La lectura del stream con el cliente de biblioteca agotó 20 s sin primer chunk. Petición directa HTTP Range al stream MP4 de androidSdkless respondió 206 con 8191 bytes. Rutas androidVr e ios fallaron respectivamente como no reproducible y 403. No generalizar estos fallos a todos los clientes/contenidos/redes ni confundir recepción de bytes con reproducción.

Se crea tools/youtube_audio_probe.dart, entrada separada de prueba con AudioService/just_audio y sin bibliotecas reales del usuario. youtube_explode_dart se incorpora provisionalmente solo como dependencia de desarrollo; sus dependencias incluyen archive/html y xml baja de 7.1.0 a 6.6.1. La app normal todavía no usa esta fuente. No distribuir las salidas de esta sonda como RP Music normal; reconstruir lib/main.dart antes de empaquetar de nuevo. Los dist locales previamente entregados se conservan.


## Resultados intermedios de las sondas

Sonda Android AOT/API 37: con adaptador tools/youtube_range_source.dart se abrió AAC 140 y se verificaron posición >3 s, pausa y seek a >10 s. Tras HOME y KEYCODE_SLEEP (power Dozing), la sonda siguió informando playing=true y posiciones posteriores; se observó una regresión de posición al final, por lo que no se afirma continuidad impecable/estable. Es emulador, no prueba física ni catálogo completo.

Windows nativo rechazó tanto URL directa (AAC 139/140) como lectura por rangos concurrentes. Contadores verificaron primeros bytes recibidos y un 403 posterior; renovar el manifiesto una vez no corrigió este caso. No se atribuye solo al códec: el transporte rechaza algunas peticiones. Android directo también produjo 403.

Investigación adicional: Range 0-65535 devuelve MP4 válido (ftyp/dash); cuatro rangos consecutivos de 256 KB respondieron 206 y 262144 bytes cada uno. Un rango completo y lectores concurrentes fallaron. Se prueba tools/youtube_buffer_source.dart: descarga compartida y secuencial por bloques, búfer RAM máximo 16 MB, sin archivo permanente; aún no es una API estable ni un permiso de red para extensiones. Pruebas de bytes concurrentes/límite de RAM aprobadas. Falta completar sonda nativa con esta variante.

Android permite HTTP solo para localhost/127.0.0.1, requerido por el proxy local de just_audio; conexiones externas siguen sin cleartext. Esto no expone red a los programas. No se añadieron servicios externos ni servidor propio.


## Cierre de la primera investigación — resultado parcial

La sonda Windows con búfer secuencial recibió 1048576 bytes antes de 403; `ok=false`, dos lecturas nativas. Variante previa con renovación del manifiesto también falló. No se demostró reproducción estable en Windows. No elegir aún estos transportes como arquitectura final ni empaquetar un .rpmx que prometa funcionar en ambas plataformas.

Comprobado: Android emulador AOT pudo cargar/reproducir/pausar/seek mediante rangos y continuó informando reproducción tras HOME/SLEEP; hubo regresión posterior de posición, estabilidad pendiente. Windows sigue fallando; fuente/contenido único de demostración, sin prueba física ni catálogo musical amplio. No hay búsqueda YouTube Music implementada, playlists remotas, favoritos/historial remoto o permisos de red expuestos al SDK. El siguiente paso técnico pendiente es encontrar un transporte/cliente que mantenga reproducción estable en ambas plataformas y repetir el ensayo; el usuario ya autorizó la vía no oficial, no necesita repetirse esa pregunta.

Artefactos de sondas permanecen en build, NO son la app normal. No se publicaron en GitHub ni sustituyeron archivos entregados en dist/0.3.0-catalogo. Antes de empaquetar otra aplicación normal reconstruir lib/main.dart con `flutter build windows --release` y `flutter build apk --release` completos; los registros integration_test pueden quedar de pruebas si se usa --no-pub. Los intentos de sonda Android con --no-pub fallaron por registro residual; el build completo corrigió ese problema.

Pruebas: suite completa final 73 aprobadas, incluyendo comparación de versiones instalada/remota, transporte por rangos, renovación simulada ante 403, búfer secuencial compartido y límites RAM. Una aserción inicial del búfer esperaba descarga completa antes de que sus lectores hubieran terminado el último tramo; se corrigió solicitando el tramo final, sin ocultar errores reales de transporte. Pruebas unitarias no implican éxito de YouTube: son validaciones locales del adaptador.

No hay extensión YouTube Music lista para instalar ni nueva release. Los ejemplos Biblioteca viva/Pulso nocturno y la biblioteca local no usan las dependencias de desarrollo añadidas para esta prueba. El catálogo Instalada/Actualizar sigue siendo un cambio local posterior a los paquetes distribuidos.


## Primera entrega Android — 0.3.1+10 local

El usuario aceptó priorizar Android y una primera prueba de búsqueda/reproducción; Windows, listas/favoritos/historial de la fuente se posponen. Esto modifica la prioridad anterior de ambas plataformas simultáneas. No se publica una release de la app en esta tarea.

### Causa investigada y cambio

El reporte original youtube_explode_dart #386 y el diff de justacalico/fix-386-and-page-parsing indican que androidSdkless deja de servir audio no muxed. Se inspeccionó el diff antes de probar: la alternativa usa cliente VISIONOS, sin cuenta/cookies/solver JS. Se adoptó únicamente esa configuración mediante la API pública YoutubeApiClient de la versión fijada 3.1.0; no se instaló el fork ni se cambió el pub cache. Fuentes: https://github.com/Hexer10/youtube_explode_dart/issues/386 y comparación con commit 292778ec44971789ac6a2f3a7facd3cb47b7a270 del fork.

Prueba HTTP real: manifiesto AAC del vídeo público de demostración y recepción completa de 10271496 bytes. Sonda Android AOT con carga directa HTTPS (sin adaptadores/búfer de las pruebas anteriores): metadatos/carga/play/pause/seek/continuidad=true durante observación de 60 s. Se repitió con HOME/SLEEP y resultado continuous=true. No se generaliza a todos los temas, redes, regiones o teléfonos físicos; no se reprodujeron diez minutos completos aunque se recibieron todos los bytes del audio de demostración.

### Código implementado

- youtube_explode_dart 3.1.0 pasa de dependencia de desarrollo a producción para el adaptador del anfitrión; configuración en lib/sources/youtube_client.dart. No se modifica motor/parches audio_service.
- Nuevo permiso explícito network.youtube y capacidad source. El programa interpretado devuelve contrato provider/query; el anfitrión solo admite youtube-music y operaciones acotadas. No hay acceso a HTTP arbitrario, cookies, rutas, procesos ni puente de paquetes de Dart dentro del intérprete. Es un primer adaptador de fuente, no un SDK genérico de internet.
- Búsqueda real en music.youtube.com mediante WEB_REMIX y filtro de canciones, siguiendo parámetros del código de referencia ytmusicapi. Hasta 30 resultados; entrada 200 caracteres, JSON máximo 2 MB y 25 s totales. Se consultaron parsers/search.py y helpers.py de https://github.com/sigma67/ytmusicapi . No confundir esta búsqueda con un wrapper de resultados generales de vídeos.
- Resolución de audio AAC 140/139 bajo HTTPS googlevideo.com, sin guardar direcciones firmadas. Se renueva la resolución al seleccionar una canción; URLs temporales no se persisten como identidad musical.
- Paquete externo youtube-music.rpmx (id rp.youtube-music, 0.1.0), Android y RP Music 0.3.1+. No viene instalado/embebido en el APK. Instalar solicita acceso a YouTube y reproducción. Gestor permite elegir la fuente y Abrir YouTube Music. Convive con Biblioteca viva/Pulso nocturno.
- Búsqueda/pantalla/control de música mediante componentes nativos del anfitrión; audio usa MusicHandler/AudioService existente, cola, pausa, avance, carátula y controles. IDs estables rpmusic-youtube:extension:video. Las cargas tardías se descartan al cambiar canción; permisos/propietario se comprueban antes/después de resolver y al reproducir/seek. Desactivar/quitar permisos/cambiar propietario detiene esta fuente. Sin acceso remoto al iniciar la app o usar música local.
- Carátulas de la fuente derivadas de un id validado en i.ytimg.com; sin aceptar URLs de imágenes arbitrarias del programa. No se intentan leer metadatos locales de una identidad remota.

### Verificación

Búsqueda real: 20 canciones y primer resultado con respuesta AAC 206/65536 bytes. Prueba nativa del recorrido instalado (integration_test/android_youtube_source_test.dart, depuración en emulador API 37): paquete compilado/importado con permisos, contrato, búsqueda de canciones, reproducción de dos resultados, pausa/seek/cambio de pista, observación monotónica y playing=true durante 45 s, HOME/SLEEP en la parte final, revocación impide reanudar: aprobada. Esta prueba es distinta de la sonda release, no se atribuye un test completo AOT de la app normal por haber pasado depuración.

Suite completa: 77 pruebas aprobadas. Incluye parser/IDs/límites, consentimiento, ejecución del paquete, revocación, cargas tardías y descarte de búsqueda tras desactivar. Prueba UI a 360 px; su primera sincronización con el isolate quedó esperando sin bombear el entorno de Flutter test; corregida la sincronización de prueba, sin ocultar un fallo del servicio. Las fuentes/fixtures de integración solo se compilan en la entrada de pruebas. Los builds finales normales se registran al cierre.

### Límites de esta entrega

Solo Android para YouTube. Windows queda pendiente y no se distribuye un nuevo ZIP en esta fase. Búsqueda inicial de canciones (consulta por canción/artista), sin paginación, pantallas de artistas/álbumes, cuentas/importación privada, descarga offline, listas/favoritos/historial de la fuente. Favorito del minireproductor se deshabilita para pistas remotas hasta implementar almacenamiento coherente de estas identidades. Las listas/carátulas locales previas siguen disponibles.

Cola de fuente disponible en sesión; no se recupera una cola remota desde el arranque ni se resuelven links remotos automáticamente al restaurar la biblioteca local. Sin reconexión automática ilimitada: errores se informan y se puede volver a seleccionar. La renovación durante pausas largas/expiración, cobertura del catálogo, batería, RAM, redes lentas y prueba física Galaxy/Poco siguen pendientes. El servicio no oficial puede cambiar.

Las sondas de transporte antiguas se conservan para investigación, no son usadas por la app. El APK normal debe construirse desde lib/main.dart después de integration_test y sondas. Conservar dist anteriores y distinguir compilación local de release pública 0.2.6.


## Artefactos normales y catálogo

APK normal construido desde lib/main.dart, 0.3.1+10 universal ARM32/ARM64/x64, firma igual a la versión anterior, recursos de notificación y alineación ZIP 16 KB verificados. ZIP interno sin paquetes .rpmx/entradas integration_test y sin marcadores de sondas dentro de libapp.so. Archivo local en dist/0.3.1-android-test con paquete externo, USO.md y SHA256SUMS.txt. No se publicó una release ni se envió el incremento de la app a GitHub.

Extensión 0.1.0 publicada en repositorio separado rp-music-extensions, commit ae10a9c; catálogo/fuentes/paquete/documentación actualizados y descarga de los tres paquetes comprobada desde el cliente real (hash/metadatos). El README del catálogo indica Android y RP Music 0.3.1+; hosts anteriores no soportan esta capacidad y requieren nuevo APK. La release pública principal continúa 0.2.6.

85c336c0d4b80cbfed111e4a128f2915927e95ae8674648e159d634657174b70  RP-Music-0.3.1-android.apk
cdbca032bbe43bc75e6639e8e217dfba8dad09005375d27a3f4ae4bae4ebc1d6  youtube-music.rpmx



Cierre verificado: APK final normal instalado en emulador, package com.example.rp_music versionName 0.3.1/versionCode 10, arranque de MainActivity correcto y sin registros de crash. El primer intento de instalación quedó con sesión pendiente y un segundo informó paquete duplicado; se inició en frío el emulador de esta tarea y la instalación normal se completó. No se atribuye ese bloqueo del instalador al código de reproducción ni a teléfonos físicos. Permiso de notificaciones concedido únicamente en emulador para completar el arranque; en teléfonos lo solicita la aplicación.

Compilaciones previas conservadas; no se publica release principal ni ZIP Windows en esta fase. APK normal final de 70362924 bytes. Se cierra el emulador propio al terminar. Siguiente validación: teléfono físico del usuario con consulta del catálogo, aceptación de permisos y reproducción de sus búsquedas. No se requieren contraseñas/cookies para esta entrega.


2026-10-26: usuario valida 0.3.1 (búsqueda/audio rápidos, sin bugs ni lag observados) y autoriza nueva release. Diseño reportado queda para próxima versión. Comunicación pública: soporte de extensiones para fuentes de música en la nube, con adaptador inicial Android; no prometer cualquier proveedor ni ocultar límites. Se publica el mismo APK validado; Windows mantiene 0.3.0. Seguimiento en [[26 Release 0.3.1]].


Publicación vigente confirmada: 0.3.1-alpha.1 Android, con cinco adjuntos y README remoto verificados. Mismo APK validado por el usuario; diseño pendiente para siguiente versión. Windows mantiene 0.3.0. Ver [[26 Release 0.3.1]].
