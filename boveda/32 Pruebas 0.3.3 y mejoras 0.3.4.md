---
tipo: seguimiento
estado: publicada-con-limites-experimentales
actualizado: 2026-10-27
---
# Pruebas 0.3.3 y mejoras 0.3.4

## Requisitos confirmados

Prueba del usuario: el reproductor ampliado exige desplazar para cambiar canción. Solicita adaptar carátula/controles al espacio, iniciar letras sincronizadas, separar la fuente YouTube de Windows/Android, añadir extensión Spotify con acceso propio y letras, y descargar audio desde YouTube. Aclara que Spotify debe investigarse por vía no oficial sin cuenta; no solicitar Client ID. No autoriza publicar ni enviar cambios.

## Implementación local, todavía sin publicar

App en preparación 0.3.4+13. El reproductor recibe el alto real de la ruta, deja controles principales fuera del desplazamiento, reduce carátula/espacios y adapta también el contenedor del reproductor aportado por extensión. La información secundaria puede desplazarse en ventanas muy bajas; anterior/pausa/siguiente permanecen visibles. No se limita la escala de texto del usuario.

Letras: parser LRC con marcas múltiples, fracciones, offset en milisegundos y búsqueda por posición; pantalla con resaltado, seguimiento automático y salto al tocar línea. Importa LRC/TXT mediante selector, conserva una copia propia por ID de canción (SHA-256) en soporte/lyrics; no modifica el archivo musical. TXT carece de sincronización. Límites de 256 KiB; no se implementa sincronización palabra por palabra ni extracción de letras incrustadas. Cambiar canción descarta resultados tardíos y carga su propia letra guardada.

Consulta opcional de letras mediante operación genérica source/lyrics y botón de nube. Proveedor LRCLIB exclusivamente dentro de los paquetes externos; envía título/artista/duración al pulsar el botón. No se añade un cliente de servicio específico al núcleo. Puede no haber letra o las marcas comunitarias pueden diferir de la grabación; no se inventan tiempos.

Descarga: permiso nuevo storage.download, acción por resultado, resolución reciente de URL y selector de destino. Exportación acotada a 64 MiB/3 minutos, HTTPS/dominios aceptados, sin redirecciones y comprobación de permiso/paquete durante transporte. Se recibe el archivo completo antes del selector. Consumo de memoria proporcional al límite; no es un gestor de descargas persistente/en segundo plano, no hace conversión ni inserción automática en biblioteca. Si se guarda dentro de la raíz elegida, actualizar biblioteca.

Navegación: accesos de todas las fuentes activas/autorizadas compatibles; se mantiene una fuente elegida para reproducción. Abrir otra no cambia dueño silenciosamente: ofrece Usar esta fuente. Textos descriptivos/búsqueda declarados por cada paquete y acento de su cabecera integrado en el tema.

## Extensiones exclusivamente en su repositorio

Checkout separado dist/extensions-repository, ignorado por el principal, conserva paquetes publicados. Previews/0.3.4: youtube-music-android.rpmx y youtube-music-windows.rpmx 0.3.0, con IDs/plataformas separados y lógica compartida; descarga con nuevo consentimiento y letras LRCLIB. No confundir habilitar Windows en un manifiesto con reproducción nativa verificada. spotify-preview.rpmx 0.1.0 compatible con ambas plataformas utiliza datos públicos del embed, sin cuenta, y reproduce solo audioPreview cuando existe. No aporta búsqueda por nombre, catálogo completo, sesión ni canciones completas. Esto satisface parcialmente el requisito Spotify; audio completo sin cuenta sigue sin vía comprobada. Letras completas TXT, sin sincronizar con el fragmento cuyo desplazamiento original se desconoce. No deriva audio de otro proveedor simulando Spotify.

No se actualiza el catálogo público ni se adjuntan estos paquetes a una release. Importación manual con app local 0.3.4. Spotify/LRCLIB y las rutas públicas pueden cambiar; no se declara estabilidad universal.

## Evidencia y límites

Pruebas de ruta real: controles alcanzables sin scroll en 320×568, 360×640, 800×360 y 1280×720. Parser LRC: fracciones, marcas múltiples/offset, retroceso/seek, texto plano, segundos inválidos y tamaño máximo. Paquetes ejecutados en ProgramRuntime: Spotify devuelve un resultado y 65536 bytes HTTP 206 de vista previa; YouTube Windows devuelve 20 resultados y 65536 bytes AAC. Operación lyrics/start devuelve petición LRCLIB válida. Dos consultas reales LRCLIB devolvieron letras planas y sincronizadas (solo existencia, sin guardar contenido de esas canciones en repositorio).

Primer ensayo falló por incompatibilidad de split('?') de dart_eval en el parser Spotify; corregido con indexOf/substring y repetición aprobada. Primera compilación de pruebas señaló una variable de selección fuera de alcance; corregida. Primera prueba pequeña intentaba tocar antes de recibir el estado multimedia; se corrigió la espera de UI y los cuatro tamaños aprobaron. No contar esos intentos como verificaciones funcionales aprobadas.

Suite completa, análisis final, prueba de letras en pantalla y reproducción nativa de Windows pendientes al redactar; registrar resultados finales antes de cerrar. Descarga/selector Android, escucha física, accesibilidad extrema y redes/regiones requieren validación adicional. No se ha creado una nueva release pública.

Fuentes consultadas: https://lrclib.net/docs , https://developer.spotify.com/documentation/web-playback-sdk/tutorials/getting-started , reproductor público https://open.spotify.com/embed/track/4uLU6hMCjMI75M1A2tKUQC . Oficial Spotify requiere cuenta para reproducción completa vía SDK; evidencia pública observada solo da vista previa. No concluir de ello que se hayan probado todas las vías no oficiales.

Relacionadas: [[03 Biblioteca y reproduccion]], [[04 Extensiones]], [[10 Estado del repositorio]], [[31 Arquitectura vigente]].

### Investigación nativa Windows

Primer ensayo: no inicia reproducción. Segundo con proxy HTTP de just_audio: también falla, por lo que se retira el cambio especulativo de proxy. Tercer ensayo: resolución y carga nativa directa aprobadas, pero playing=true con posición 0 al volver al recorrido normal; no se considera audio verificado. Se prueba recepción completa en búfer privado Windows (mismos límites 64 MiB/3 min del transporte, sin exportar a biblioteca), antes de entregar un archivo local al motor. Hasta cuatro archivos temporales por sesión, limpieza de archivos anteriores y al cerrar MusicHandler; fallo/liberación de manejadores se trata explícitamente. Cierre abrupto puede dejar temporales del sistema. No afirmar que esta solución funciona antes del ensayo final. Android conserva reproducción directa.

Recepción completa por rango estándar: verificador genérico del paquete Windows recibe 5983881 bytes de audio, con tiempo total de recepción acotado a 60 s. Se añade Range: bytes=0- al transporte compartido, validando 206 como archivo completo por Content-Range, sin aceptar fragmentos truncados como descargas completas. Ensayo nativo anterior sin esta petición interrumpido por tardanza; no se atribuye aprobación.

La primera suite completa detectó cinco pruebas del actualizador cuyos datos de «versión futura» usaban ya 0.3.4; se actualiza el fixture común a 0.3.5, sin cambiar lógica del actualizador. La primera prueba de letras usaba un canal de directorio incorrecto para Windows; se añade inyección del directorio de almacenamiento y se repite. Estas correcciones de infraestructura no prueban por sí solas las funciones.

El ensayo posterior con rango y dos búsquedas tampoco aprobó el avance nativo. Se retira del código el experimento de búfer de reproducción y su callback de limpieza: no demostró resolver el fallo y añadía latencia/almacenamiento. El transporte completo acotado queda exclusivamente para la descarga solicitada. Windows conserva el broker directo previo; su paquete separado es candidato experimental sin reproducción nativa aprobada y no se publica en catálogo. No se declara este requisito terminado. Las menciones anteriores al búfer describen una investigación descartada, no la implementación final.

## Verificación final del código local

Suite completa final: **97 pruebas aprobadas**. Análisis Flutter final: **sin incidencias**. Cinco pruebas seleccionadas de letras/pantallas de fuente aprobadas antes de repetir suite; son parte de los 97, no casos adicionales. La prueba de letras drena las lecturas reales de archivo dentro del reloj de pruebas; confirma caché por canción, resaltado con avance/retroceso, tocar línea para seek y cambio de pista sin letra obsoleta. Se evitó duplicar el título de fuente fuera del modo embebido.

Capturas player-0.3.4-360.png y player-0.3.4-1280.png inspeccionadas con fuentes e iconos reales. Fixtures sin carátula física. Controles principales visibles; en ventanas extremas se permite desplazamiento de información secundaria. Las pruebas heredadas regeneraron capturas 0.3.3; se restauraron sus bytes previos para conservar la evidencia histórica. Solo las capturas nuevas 0.3.4 corresponden al cambio actual.

**Pendientes que impiden declarar los cinco puntos completos:** audio nativo YouTube Windows (ensayos fallidos); Spotify completo y búsqueda por nombre sin cuenta (solo vista previa por enlace comprobada); reproducción nativa de nuevos paquetes Android/Spotify, guardado real con selector/permiso en Android y Windows y escucha física. No se promete que letras comunitarias coincidan con todas las versiones/grabaciones.

Descarga usa únicamente almacenamiento solicitado por selector y permiso separado; se retiró todo búfer automático del broker. Fuentes/paquetes y hashes en tests/RESULTADOS-0.3.4.md del repositorio de extensiones. El catálogo publicado se conserva. Se recompila la entrada normal Windows después de las sondas; resultado de esa compilación se añade al terminar.

Compilación normal Windows **release aprobada** (85.6 s), entrada lib/main.dart, sin defines de sonda. ProductVersion comprobado **0.3.4+13**; registro de plugins sin integration_test. No equivale a prueba de fuente Windows ni se distribuye el ejecutable debug de integración. No se compilaron APK nuevos en este trabajo; no hay nueva publicación, commits ni pushes.

## Publicación autorizada — 2026-10-27

El usuario solicita generar paquetes nuevos y publicar la release 0.3.4. Esta instrucción reemplaza la ausencia de autorización de la etapa anterior. Se preparan Android universal/ARM64 y Windows x64, USO/PRUEBAS/CAMBIOS y SHA256SUMS; extensiones únicamente en su repositorio. Catálogo ofrece YouTube Android 0.3.0 y Spotify · vistas previas 0.1.0 a anfitriones 0.3.4; conserva variantes anteriores. Windows remoto continúa como candidato manual fuera del catálogo recomendado, con el fallo nativo explícito en su manifiesto. No se cambia su estado a funcional por publicar la app. Verificación de binarios, commits y enlace público pendientes hasta terminar.

### Paquetes externos publicados y Windows empaquetado

Extensiones enviadas a rp-music-extensions, commit 833044a: catálogo conserva 0.3.1/0.3.2/0.3.3 y selecciona Android 0.3.0 / Spotify 0.1.0 para 0.3.4. Verificación pública: JSON del catálogo idéntico tras normalizar saltos de línea de Git; tres paquetes nuevos comparados byte a byte y por SHA-256 (Android 8939 bytes, Windows candidato 9035, Spotify 4720). Primer intento de igualdad binaria del catálogo falló por CRLF/LF; no era diferencia de JSON ni de paquetes, cuyas extensiones .rpmx tienen atributo -text.

ZIP Windows normal preparado: 20 archivos, dependencias/data presentes, testzip aprobado, sin .rpmx ni integration_test; versión EXE 0.3.4+13. Proceso normal iniciado oculto y activo tras 5 s; cerrado solo ese proceso de comprobación. No se atribuye escucha ni fuente Windows a esta prueba de arranque.

Android: preparación normal Flutter release seguida de ensamblado Gradle offline por espera de comprobaciones de red, conforme a la guía de compilación. No se cambió el código ni dependencias para resolver esa espera. No hay emulador/dispositivo conectado para instalar/abrir APK en esta ejecución. Verificaciones de versión, firma, ABI y hash se registran al terminar.

### Binarios definitivos y preparación del borrador

Android universal aprobado tras preparación Flutter y Gradle offline (6 min 37 s); variante ARM64 del mismo release normal aprobada (1 min 57 s). Versiones/códigos 0.3.4/13, firmas válidas y certificado SHA-256 compatible con 0.3.3: eba2769ed11d359c8f89f6991bc6867c7766f6f46a4295bc5386e7d41ce7d38d. ABI universal arm64-v8a/armeabi-v7a/x86_64 y ARM64 solo arm64-v8a. Sin paquetes .rpmx dentro de APK/ZIP y registro de plugins sin integration_test. No hubo dispositivo para prueba de instalación/arranque Android.

Siete adjuntos definitivos preparados en dist/0.3.4-release; SHA256SUMS cubre los otros seis adjuntos. PRUEBAS incorpora el alcance real de verificación. El borrador se verifica por tamaño/digest antes de publicarse; enlace público todavía pendiente en esta etapa.

| Archivo | Bytes | SHA-256 |
| --- | ---: | --- |
| RP-Music-0.3.4-android.apk | 68502972 | 13178c574eea2699e298f21218d5b9f36449269113f897831b5b8e600d49afd6 |
| RP-Music-0.3.4-android-arm64.apk | 25370633 | 36d790e8621c0e9471a8084c05ab3471d44730ec5699613f88d3108dfd5f6985 |
| RP-Music-0.3.4-windows-x64.zip | 15655914 | b0dc65d6ac99643d8eb1fd61edd5c63642af0973e8a198ce14cc6566a45dce07 |
| USO.md | 2420 | 9b4772b3e4d8b9c34602da12139d61d16899e05857219d7088c2eef0999795be |
| PRUEBAS-0.3.4.md | 3725 | a969d484dbc168f67f2c59fc03585d02348b896dea587f9257759e1153055e5b |
| CAMBIOS-0.3.4.md | 2625 | c2a830bcb125eb795eb0dbdac7a36547185bd0aad327454a324ff7f589ad0ac2 |
| SHA256SUMS.txt | 528 | b9de4c681ff08f5e3ddc0baea25ac45a62ffecc27670993470062b8dc3a3ea4c |

## Publicación confirmada — v0.3.4-alpha.1

2026-10-27: publicada como prerelease en https://github.com/Joao-s02/rp_music/releases/tag/v0.3.4-alpha.1 . Aplicación 0.3.4+13, tag/código d873ae3ada998fcefc89b4a5f98cd298f9db6204. Extensiones publicadas exclusivamente en rp-music-extensions, commit 833044ab11a2d03a4fd82134822246fc52149aed.

Antes de publicar se verificó el borrador por ID de release (el endpoint por tag aún devuelve 404 en esa etapa): siete archivos, tamaños/digests SHA-256 idénticos a los locales y revisión de código correcta. Después de publicar: API pública sin autenticación confirmó prerelease visible, siete adjuntos, tamaños/digests correctos y tag al commit esperado. SHA256SUMS descargado públicamente idéntico byte a byte al local. Los archivos públicos son los de la tabla definitiva anterior.

No se modifican los límites por publicar: YouTube Windows sigue fallando en reproducción nativa y permanece como candidato manual fuera del catálogo; Spotify solo fragmentos por enlace sin cuenta y letras planas. No hubo instalación/arranque Android ni prueba nueva de exportación por selector o escucha física. La prueba de arranque Windows no acredita audio remoto. Commits documentales posteriores confirman publicación y no cambian los binarios del tag.
