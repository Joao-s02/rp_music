# RP Music 0.3.9 — instalación y uso

Release preliminar: https://github.com/Joao-s02/rp_music/releases/tag/v0.3.9-alpha.1

## Instalar y actualizar

Android universal: RP-Music-0.3.9-android.apk. ARM64: RP-Music-0.3.9-android-arm64.apk para dispositivos compatibles de 64 bits. Instalar encima de la versión anterior, sin desinstalar para conservar datos. Firma actual de desarrollo, compatible con 0.3.8. Windows: extraer RP-Music-0.3.9-windows-x64.zip completo y abrir rp_music.exe junto con DLL y data. No ejecutar desde dentro del ZIP.

Elegir raíz musical y conceder lectura; Actualizar biblioteca incorpora archivos nuevos. Se conserva biblioteca/sesión/configuración y extensiones en soporte privado v2/v3. No borrar esas carpetas. No se migran datos de la antigua alfa 0.1. Base musical sin cuenta/conexión; consultas y actualizaciones son opcionales.

## Letras locales

Al seleccionar una canción se leen las letras incrustadas, sin extensión ni conexión. Abrir Letras desde el reproductor. LRC se sincroniza por línea y permite tocar una línea para avanzar; texto plano se muestra sin sincronización. Se mantiene importar LRC/TXT UTF-8 hasta 256 KiB.

Para buscar las que falten: Extensiones → Explorar repositorio → https://github.com/Joao-s02/rp-music-extensions → Consultar → instalar Letras locales 0.1.0 y aceptar permisos. En Letras de canciones locales elegir ese proveedor si hay conflicto. La consulta comienza al seleccionar una canción sin letras incrustadas/copia privada; no es un escaneo masivo de toda la biblioteca.

Resultados guardados exclusivamente dentro de RP Music, sin modificar archivos musicales locales. Se pueden leer después sin conexión. Ausencia de coincidencias: espera 24 h; error: 5 min. El botón de nube permite reintento manual. Desactivar la extensión impide nuevas consultas y conserva la caché. Los metadatos de la canción se envían al proveedor autorizado al consultar.

## YouTube y nuevas descargas

Actualizar YouTube Android a 0.4.0 desde el catálogo y revisar los dominios/permisos. Requiere app 0.3.5 o posterior. La búsqueda de letras normaliza título/artista, usa búsqueda alternativa y verifica versión/duración. Se prefieren sincronizadas cuando existen.

Descargar desde un resultado con permiso storage.download: se recibe audio (hasta 64 MiB/3 min), se consultan metadatos y se incorporan los datos encontrados, portada y letras al nuevo M4A antes del selector. No se recodifica ni aumenta la calidad del audio. Elegir destino; Actualizar biblioteca si está dentro de la raíz. Las consultas de metadatos añaden tiempo y dependen de la red. No es una descarga en segundo plano.

La información externa puede faltar. Un aviso indica datos parciales o archivo guardado sin etiquetas cuando no es compatible. No se inventan álbumes, fechas ni letras. Guardar canciones locales existentes no forma parte de este proceso. El selector y los archivos personales requieren retesteo en Android físico.

## Extensiones y límites

YouTube Android 0.4.0, Letras locales 0.1.0, Biblioteca viva 0.1.1 y Pulso nocturno 0.1.0 en https://github.com/Joao-s02/rp-music-extensions. No vienen instaladas ni dentro del APK/ZIP ni como adjuntos de esta release. Variantes para apps anteriores conservadas. Spotify cancelado y retirado del catálogo; paquetes históricos conservados. Si ya estaba instalado puede eliminarse desde Extensiones. YouTube Windows continúa como candidato manual con fallos nativos conocidos, fuera del catálogo recomendado.

Android lee documentos mediante copia temporal privada de hasta 256 MiB/30 s, eliminada tras la lectura. SYLT admite marcas en milisegundos sin compresión/cifrado; otras variantes requieren comprobación. Ningún proveedor garantiza letras o edición correctas para toda canción. Windows reproduce música local; no se declara resuelto YouTube Windows.

Distribución oficial exclusivamente por GitHub; Play Store descartada. Código público, licencia concreta pendiente de elección; licencias de terceros conservadas. Ver PRUEBAS-0.3.9.md y CAMBIOS-0.3.9.md. SHA256SUMS.txt cubre todos los demás adjuntos.

## Corrección M4A heredada de 0.3.6

0.3.5 podía desplazar la inicialización de un MP4 fragmentado al final al añadir etiquetas. El resultado conservaba el audio pero algunos lectores no podían abrirlo correctamente. Desde 0.3.6 se conserva la inicialización antes de los fragmentos y valida sus posiciones relativas; una variante no soportada conserva el audio original con aviso.

Este arreglo está en la app: las extensiones compatibles siguen siendo YouTube Android 0.4.0 y Letras locales 0.1.0. Actualizar la app no reescribe canciones ya descargadas. Para un archivo afectado, usar una copia reparada o descargarlo de nuevo después de actualizar. No basta cambiar .mp3 por .m4a para reparar su estructura. La herramienta genérica de reparación del código fuente crea una copia nueva y nunca sobrescribe originales.

El usuario confirmó buen funcionamiento del arreglo M4A en 0.3.6; la variante Explorador requiere su propia prueba física. No se incluyen canciones del usuario ni archivos musicales privados en estos paquetes.

## YouTube Explorador — nueva opción independiente

Desde Extensiones → Explorar repositorio, consultar https://github.com/Joao-s02/rp-music-extensions e instalar YouTube Explorador 0.1.0. Requiere app 0.3.7+. YouTube Android 0.4.0 estable permanece disponible; las dos pueden instalarse. Seleccionar Usar esta fuente en Explorador para probarla; volver a elegir YouTube Android para regresar a la estable.

Usar filtros Canciones, Artistas, Álbumes o Listas. Abrir una página y reproducir una canción o la colección. Cargar más obtiene la siguiente página; las listas públicas también admiten enlace HTTPS en la búsqueda. Una vez cargadas todas las páginas de un álbum/lista, Importar copia crea una lista local con nombre nuevo, orden y repeticiones conservados. No modifica YouTube ni descarga el audio automáticamente. Referencias/metadatos se conservan al reiniciar; reproducir requiere conexión y el proveedor seleccionado/autorizado. Guardar una lista no equivale a tenerla disponible offline.

No incluye inicio de sesión, contenido privado ni sincronización de cuenta. No garantiza discografía completa ni toda región o respuesta del servicio. Explorador reproduce en Android; publicar Windows de la app no habilita YouTube Windows. La variante todavía requiere prueba física del usuario.

## Laboratorio JS y motor paralelo

Instalar Laboratorio JS 0.1.0 desde el catálogo de https://github.com/Joao-s02/rp-music-extensions . Requiere RP Music 0.3.9 y aceptar navegación, estado privado, lectura de metadatos y reproducción. Pulsar Abrir pantalla en su tarjeta o abrir su acceso de navegación. No elegirla como Fuente: las pantallas JavaScript son independientes.

Probar las tres páginas de la demo: guardar saludo con un apodo; abrir panel y sumar/restar contador; buscar/reproducir canciones locales. Cerrar y abrir para comprobar persistencia. La extensión ve hasta 500 pistas autorizadas y muestra hasta ocho coincidencias, con IDs opacos sin rutas de archivos. Desactivarla impide nuevas acciones; conserva sus datos para recuperación.

API 1 y API 2/Dart permanecen disponibles sin convertir paquetes. YouTube Android 0.4.0 y Explorador 0.1.0 conservan sus bytes y su motor. API 3 usa QuickJS y componentes nativos combinables: la extensión define árboles visuales, eventos y navegación interna. No es Node.js, npm, HTML/CSS libre ni SDK ilimitado. Desde 0.3.9 API 3 ofrece HTTP por etapas y audio remoto autorizados. Cuentas, sincronización y DSP siguen pendientes. Los límites del intérprete no equivalen a aislamiento del sistema operativo.

La demo funciona sin cuenta ni consultas externas, usa el motor de audio base con permisos y solo guarda su estado dentro de RP Music. Ningún paquete de extensión viene dentro del APK/ZIP. Ver PRUEBAS-0.3.9.md: la prueba física Android de este motor sigue pendiente.

## Explorador musical y Radio por internet — JavaScript

Desde Extensiones → Explorar repositorio, consultar https://github.com/Joao-s02/rp-music-extensions e instalar Explorador musical 0.1.0 y Radio por internet 0.1.0. Requieren app 0.3.9. Revisar permisos; Radio añade audio HTTPS de servidores públicos con dominios variables. Abrir Explorar JS/Radio JS en la navegación. No elegirlas como propietario de Fuente: conviven con YouTube Dart.

Explorador: buscar canciones/artistas/álbumes/listas, abrir resultados, Atrás, páginas y continuación. Admite enlaces de listas públicas. Escuchar solicita audio AAC. Sin cuenta, sincronización, descargas ni importación desde esta pantalla JS; la variante Dart conserva sus funciones anteriores. Navegación y resolución reales comprobadas; no se declara resuelto audio nativo YouTube Windows.

Radio: buscar por nombre/país/etiqueta, explorar populares y guardar hasta 30 favoritas privadas, sujeto a espacio. Solo emisoras HTTPS MP3/AAC, sin HLS/listas remotas. Renovación por UUID antes de escuchar. Algunas emisoras pueden fallar/no aparecer por esos filtros. Una radio AAC se comprobó con reproducción nativa Windows, pausa/reanudación y parada al desactivar; no garantiza todas las emisoras/redes. Favoritas se consultan sin conexión; reproducir requiere red.

Cancelar descarta respuestas tardías y detiene una carga de audio pendiente. Desactivar detiene el audio correspondiente; conserva datos propios. Ni cuenta ni secretos se requieren. Android físico y escucha prolongada pendientes. Las dos extensiones se distribuyen exclusivamente desde el repositorio de extensiones, fuera del APK/ZIP y adjuntos de la app.
