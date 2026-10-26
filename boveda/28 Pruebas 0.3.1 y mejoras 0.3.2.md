---
tipo: seguimiento
estado: implementada-local-con-limites
actualizado: 2026-10-26
---
# Pruebas 0.3.1 y mejoras 0.3.2

## Confirmado por el usuario

- Detalle de álbum más parecido a la captura Stitch: tarjeta con carátula, título/artista, información real, reproducir/aleatorio, pistas y cola, fila activa destacada.
- Barra del sistema sobrepone al control pequeño al buscar en la extensión: corregir áreas seguras.
- El reproductor ampliado debe mostrar el nombre de la extensión/servicio en lugar de Audio local cuando corresponde.
- La extensión de fuente debe poder añadir un botón YT a la navegación, definido desde su paquete.
- Segundo plano y pantalla apagada funcionan en 0.3.1 según su prueba; preservar.

No se ha pedido publicar 0.3.2. La release pública sigue siendo [[26 Release 0.3.1]]. Reglas de distribución futura en [[27 Publicacion de releases - contenido obligatorio]].

## Implementación local

0.3.2+11 / 0.3.2-alpha.1. Detalle de álbum con carátula real, formato conocido por extensión del archivo, duración conocida, acciones reproducir/aleatorio/guardar como lista, pestañas de pistas/cola real, favorito y menú del archivo. No se inventan año, género, profundidad de bits ni tasa de bits que el modelo no conoce. Adapta tamaños a móvil/escritorio con acciones que pueden ocupar dos filas en pantallas pequeñas.

Pantalla de fuente independiente dentro de SafeArea; al integrarla en inicio usa el área segura y minirreproductor global de inicio. El teclado oculta el control y la introducción larga para conservar espacio. Los metadatos de la canción incluyen nombre de fuente y carátula; el reproductor conserva Audio local para archivos.

Contrato genérico sourceConfig/navigation.add: la fuente elegida, habilitada y autorizada aporta un acceso con etiqueta, icono y color del manifiesto. Desactivar o revocar permisos retira el acceso y devuelve a la biblioteca si estaba seleccionada. No admite widgets Flutter arbitrarios ni varios dueños simultáneos de source.

## Separación de repositorios

Para cumplir [[04 Extensiones]], se retira del principal el cliente/parser/pantalla específicos, dependencia youtube_explode_dart, paquete, ejemplos y pruebas específicos de la fuente. Se conservan como antecedente en legacy/host-0.3.1 del checkout separado rp-music-extensions (dist/extensions-repository, ignorado por el Git de la app). Biblioteca viva/Pulso nocturno heredados aún requieren migración: no se afirma separación completa de todo el material previo.

La app ejecuta flujos HTTP genéricos acotados declarados por el paquete: HTTPS/dominios, GET/POST, sin redirección, cuatro rondas, límites de tamaño/plazo, verificación antes/después de cada etapa. El intérprete sigue sin IO ni paquetes nativos. Cookies anónimas solo en memoria durante el flujo; no se guardan URLs firmadas ni respuestas del proveedor. Errores de fuente se redactan antes de registrar.

La extensión 0.2.0 para Android y anfitrión 0.3.2 se desarrolla exclusivamente en el repositorio de extensiones (sources/youtube_music.dart y previews/0.3.2/youtube-music.rpmx). Contiene navegación y toda la lógica del servicio. La variante base del catálogo sigue siendo 0.1.0 para anfitrión 0.3.1; variants/versions ofrece el paquete nuevo a 0.3.2. Actualización exige consentimiento de nuevos permisos. El paquete 0.1.0 no funciona en el anfitrión nuevo hasta actualizarlo, explicado en el gestor; programas anteriores de biblioteca/reproductor conservan contrato.

## Verificaciones y límites

Comprobado: programa externo ejecutado por ProgramRuntime real: 20 resultados de búsqueda y HTTP 206 con 65536 bytes de audio. La resolución requiere bootstrap anónimo; sin ese contexto se observó LOGIN_REQUIRED. No se eluden requisitos de cuenta. Las pruebas sintéticas del proveedor están en su repositorio; el principal usa una fuente ficticia example.com para probar el SDK.

Suite completa inicial posterior a cambios: 75 pruebas aprobadas, sustituyendo pruebas de proveedor movidas por comprobaciones genéricas. Incluye metadatos/carátula de fuente, permisos/retirada durante respuesta, dominios y compatibilidad de catálogo, UI segura y álbum a 360/1280. Capturas con fuentes reales inspeccionadas en design/verification/album-0.3.2-*.png. Validación nativa, análisis final y artefactos se registrarán después de completar su ejecución; no atribuirlos por esta nota.

Pendientes heredados de fuente: Windows, listas/favoritos/historial, artistas/álbumes completos, cuentas, diversas redes/regiones y pruebas largas. SDK experimental sin aislamiento duro de memoria. Referencia previa en [[24 YouTube Music - definicion e investigacion]].


### Verificación nativa completada

Android emulador API 37, integration_test/extension_source_test.dart en depuración: paquete externo comprimido suministrado exclusivamente a la prueba; instalación con permisos, búsqueda, dos canciones, pausa/seek, 30 segundos de observación monotónica de la segunda pista, metadato sourceName y revocación que impide reanudar: aprobado (RP_SOURCE_PROBE_OK). HOME/SLEEP enviados durante observación; audio continuó. Duración total de la prueba 73 s; no equivale a escucha continua de 73 s ni a prueba prolongada física/AOT. Se corrigieron límites de infraestructura de prueba: Windows no admite el JSON grande como argumento, y archivo externo inicial recibió denegación de Android; el paquete gzip/base64 de prueba resolvió ambas sin incorporarlo a la app normal.

Análisis final de ese estado: sin incidencias.


Comprobación final adicional: 11 pruebas seleccionadas aprobadas tras añadir navegación de extensión (seis destinos, abre pantalla, un solo minirreproductor, vuelve a cinco destinos al desactivar). Esta comprobación incluye pruebas ya contadas en la suite; no sumar 75+11 como casos distintos.


APK normal universal release compilado con entrada lib/main.dart (sin defines de prueba), 67690900 bytes, versión 0.3.2/código 11, ABI arm64-v8a/armeabi-v7a/x86_64. apksigner válido y mismo certificado SHA-256 que el APK público 0.3.1: eba2769ed11d359c8f89f6991bc6867c7766f6f46a4295bc5386e7d41ce7d38d. Instalado y abierto en emulador, captura de inicio inspeccionada. Sigue siendo firma de desarrollo; no prueba actualización sobre los datos del teléfono físico.


Variante ARM64 release normal: 24755169 bytes, versión 0.3.2/código 11, única ABI arm64-v8a, firma verificada. Inspección de ambos APK: sin paquetes .rpmx ni fuentes de extensiones en assets. Las guías USO/PRUEBAS/CAMBIOS de 0.3.2 se preparan como adjuntos locales separados. Windows y hashes finales pendientes en este punto.


## Cierre local

Compilaciones normales completas de Flutter aprobadas: Android universal, ARM64 y Windows release. Registro de plugins sin integration_test después de recompilar la entrada normal. Windows muestra FileVersion/ProductVersion 0.3.2+11; instancia nueva oculta permaneció activa tras 5 s y se cerró exclusivamente ese proceso de prueba. No se atribuye reproducción nativa de la fuente en Windows ni un recorrido manual completo de escritorio.

ZIP Windows: carpeta Release completa, ejecutable/DLL/data/activos y USO.md; 20 entradas, testzip sin errores, archivos requeridos presentes. Sin paquetes .rpmx dentro de los APK/ZIP. Entrega local dist/0.3.2-local con tres binarios, USO.md, PRUEBAS-0.3.2.md, CAMBIOS-0.3.2.md y SHA256SUMS.txt. Extensión 0.2.0 exclusivamente en el checkout del repositorio de extensiones. No se crearon commits, pushes ni release 0.3.2; el catálogo remoto sigue sirviendo su estado publicado hasta autorizar la publicación de estos cambios. Para probar ahora importar el paquete local actualizado.

| Archivo | Bytes | SHA-256 |
| --- | ---: | --- |
| CAMBIOS-0.3.2.md | 1752 | e59c90ce7bc606daa3b6dbcf675bf11c39dc03c5d0aede791d24bfe09ac18e64 |
| PRUEBAS-0.3.2.md | 2144 | d669c0355b5ace3a5e4d4c7e267f5217c59872b1a5cfdf13e9cfe6d422c93fc0 |
| RP-Music-0.3.2-alpha.1-android-arm64.apk | 24755169 | b68b9d8e7c203e0c92ad92b33ec320f3e441a5821129731b78172ea7132ae95f |
| RP-Music-0.3.2-alpha.1-android.apk | 67690900 | 087a3a0be0158e191d07931055c998f7fa9ff6440e7c660ac084633f11d2d793 |
| RP-Music-0.3.2-alpha.1-windows-x64.zip | 15599492 | 62eeef8e24b2e6858a5bf7cc0581889eb431e567fcc51d2352bef9968e50f85a |
| USO.md | 1332 | 3074154ae0ffa33cd0db964ef841cd4f2a7a7b201b9d17998e720cc2b4009433 |

Pendiente: retesteo físico del usuario, gestos/tres botones, texto ampliado y sesiones largas en distintos teléfonos/redes; Windows requiere recorrido local completo por el usuario. Separación de prototipos de biblioteca/reproductor heredados sigue pendiente. Las capturas de verificación son pruebas sintéticas, no una biblioteca de usuario.


## Publicación autorizada

El usuario solicita publicar la nueva release. Se prepara v0.3.2-alpha.1 con los tres binarios y cuatro adjuntos documentales. Los APK conservan exactamente los bytes probados; se usan nombres con versión core 0.3.2 para compatibilidad con el actualizador. El ZIP conserva los binarios y actualiza únicamente USO.md para la distribución pública. Se publicará primero el paquete 0.2.0 y catálogo compatible en el repositorio de extensiones; no se adjunta ninguna extensión a la release de la app. Confirmación remota pendiente hasta terminar subida y comprobación.
