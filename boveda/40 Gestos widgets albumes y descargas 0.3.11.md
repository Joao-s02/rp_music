---
tipo: requisitos-implementacion-y-verificacion
estado: implementado-local-validado-con-pendientes
actualizado: 2026-10-28
---
# Gestos widgets albumes y descargas 0.3.11

## Requisitos confirmados por el usuario

Informe directo de pruebas0.3.10 Android/Windows: YouTube Windows ya reproduce y descarga canciones; M4A/OPUS locales Windows se leen sin errores. Es confirmación del usuario distinta de los ensayos instrumentados de [[39 Audio Windows M4A OPUS y YouTube]]. No atribuir confirmación específica de radio/latencia Android a este mensaje.

Se solicita iniciar nueva versión cumpliendo estrictamente:

1. Conservar YouTube Windows funcional, incluido descargar.
2. Conservar compatibilidad M4A/OPUS Windows.
3. Android: cambiar canción al deslizar horizontalmente.
4. Android: widget menos tosco, redimensionable y más tipos.
5. Interior de listas con portada grande y presentación semejante a álbum local.
6. Mejorar descargas/incrustación de metadatos: dos canciones del mismo álbum no deben acabar en álbumes diferentes; descargar álbum completo. Referencia facilitada: https://github.com/mornyeapp/Mornye .
7. Álbumes de YouTube Explorador con vista semejante al álbum local.
8. Consultar fotos de artistas con internet y conservarlas para verlas sin conexión.

App local0.3.11+20; referencia publicada0.3.10+19. Esta petición inicia desarrollo, no autoriza publicar otra release. Proveedores/fuentes/pruebas/paquetes específicos se mantienen en rp-music-extensions; anfitrión contiene capacidades genéricas. [[04 Extensiones]], [[31 Arquitectura vigente]].

## Diagnóstico y decisiones

Descargas anteriores: letras podían aportar un álbum y MusicBrainz seleccionaba una edición con puntuación mayor aunque no coincidiera con el álbum de la fuente; empate dependía del orden recibido. Además, agrupar álbum por artista de cada pista separa colaboraciones. Se prioriza identidad de la colección/fuente; letras no determinan edición, no adivinar álbum desconocido. Enriquecimiento externo de edición exige coincidencia con el álbum conocido. Lote comparte álbum/artista de álbum/portada y orden; no inventa disco o fecha cuando la colección no los ofrece. No reescribir música del usuario.

Mornye consultado como referencia de flujo/criterios, sin copiar su código: README describe obtener pistas y encolarlas; download_queue_provider_embedding.dart prioriza metadatos de origen antes del backend y valida índices. Implementación propia con transporte/permisos/límites existentes de RP Music.

Gesto en carátula y minirreproductor, izquierda siguiente/derecha anterior, umbral de distancia/velocidad; los deslizadores conservan su gesto. Widgets compacto/horizontal/carátula con reducción de controles según ancho, resize horizontal/vertical y actualización al cambiar opciones. El launcher determina cuadrícula y pasos de tamaño; no se promete tamaño libre en píxeles.

Listas y álbum en línea comparten encabezado adaptable de portada grande. Descarga de álbum reúne todas las páginas antes de iniciar, elige carpeta una vez, procesa una canción cada vez, informa resultados y admite cancelar. Respeta storage.download/revocación, no sobrescribe archivos previos y conserva terminados si alguna pista falla. Selección de carpeta Android vía SAF separada de la raíz de biblioteca. Sin servicio de descargas persistente en segundo plano en esta etapa.

Fotos: consulta mediante fuente compatible con artistArtwork y permiso library.read aceptado; sin enviar biblioteca a extensiones anteriores sin ese consentimiento. Identidad de artista coincidente, dominio autorizado, caché privada en artist_portraits, imagen acotada y lectura offline. Fuentes/consultas YouTube permanecen fuera del núcleo. No garantizar foto para todos los artistas u homónimos; no confundir portada de disco con retrato.

## Verificación y pendientes

Cinco pruebas nuevas dirigidas aprobadas: identidad frente a otra edición, dos archivos etiquetados y agrupados con artista de álbum/numeración, reapertura de caché sin fuente, gesto izquierda/derecha/roce corto y cola con no sobrescritura/fallo parcial/cancelación durante transferencia simulada. Trece pruebas de metadatos/letras/gesto también aprobadas en ensayo anterior; no sumar repeticiones como casos distintos.

Primera regresión antigua esperaba reemplazar título por cualquier metadata: se actualizó para comprobar identidad seleccionada según requisito nuevo, conservando ensayo de escritor aislado/letra. Las pruebas de lote comparaban rutas con separadores distintos en Windows; se corrigió el ensayo, que contaba el archivo previo como nuevo. El intérprete Dart no admite continue en estas fuentes y requiere evitar promoción de tipos ambigua al recorrer listas/mapas; correcciones candidatas en verificación, sin alterar catálogo/paquetes publicados.

Pendientes al redactar: validación final de candidatos con intérprete/red, suite completa, análisis, vistas pequeñas/texto ampliado, compilaciones Android/Windows y comprobación nativa de widgets/SAF. Sin Android físico conectado. Mantener latencia API3 Android como pendiente separado en [[38 Latencia de extensiones API 3]].


## Cierre local comprobado

Suite final conjunta:147 aprobadas, una de red optativa omitida; análisis sin incidencias. Pruebas dirigidas de escáner/migración:18 aprobadas (incluyen repeticiones de cinco casos nuevos, no sumar). Vista de listas360/1280 revisada visualmente y tests con texto1.6 aprobados. Imágenes previas restauradas byte a byte, sin incorporar los cuatro PNG ajenos sin seguimiento.

Cuatro paquetes API2 finales compilan/ejecutan con dart_eval y pasan rechazo de edición distinta, álbum desconocido sin adivinar, álbum bloqueado no alterado por letras, desempate estable, campos opcionales ausentes y retrato coincidente. Fotos públicas comprobadas para las cuatro variantes. Las listas/mapas del intérprete requirieron lectura compatible; un acceso a syncedLyrics/instrumental ausentes se corrigió explícitamente. No se modificaron paquetes ni catálogo publicados.

Prueba nativa final Windows aprobada: álbum público My Dear Melancholy, seis canciones descargadas y leídas desde archivo con mismo álbum/artista de álbum, numeración1–6/total6 y portadas incrustadas idénticas porSHA256. Foto de The Weeknd descargada, normalizada y recuperada con instancia nueva sin fuente. Informe anónimo dist/0.3.11-album-export.json; audio temporal eliminado al terminar. No interpretar leer etiquetas como nueva prueba de reproducción de todos los códecs; motor Windows permanece conservado y su confirmación del usuario corresponde a0.3.10.

Ensayos previos: encabezado real contenía texto anidado que causaba error de tipo; se corrigió sin elevar límites del motor. Timeout de red inicial y ensayo parcial de tres pistas conservados como antecedente. El harness nativo se ajustó a runAsync como los demás ensayos de integración, incluye un reintento explícito de transporte y terminó aprobado. No se garantiza disponibilidad universal; la app muestra motivo por pista fallida, conserva terminadas y no llama completo a un lote parcial.

Android universal normal final113.2s, versión0.3.11/código20, firma v2/certificado compatible previo, tresABI, sin integration_test/libmpv/rpmx. Widgets compilados con tres receptores, redimensionado horizontal/vertical y mínimos110×48dp. Antes solo había mínimos250×120dp sin minResize; no atribuir al XML la política concreta del launcher. Windows normal final91.8s, ProductVersion/FileVersion0.3.11+20. ZIP31 archivos íntegros con licencias/guías y sin WinRT/rpmx. Recompilados después de integración; ninguna sonda se entrega como aplicación.

Entrega local dist/0.3.11-local, guías docs/PROBAR-0.3.11.md y docs/RESULTADOS-0.3.11.md. Permanece pendiente prueba física Android del launcher/tamaño/controles, SAF y escucha prolongada. Fotos dependen de coincidencias de fuente/permisos y caché64MiB; la cola requiere app abierta. Caché de etiquetas antigua se relee en próxima actualización manual, sin modificar música. Latencia API3 Android sigue separada. Sin nuevos commits/push/tag/release.


## Integridad final de la entrega local

ZIP31 archivos y APK universal firmados comprobados; hashes definitivos:

```text
1cfe46f44abb16934d81aea645308b771d539e48e92a7f72b96ed74b1ca503f6  RP-Music-0.3.11-local-android.apk
9d68757b3550841780dcfa085e3d387d539139882c5c347b57d6091a0d2c8233  RP-Music-0.3.11-local-windows-x64.zip
```

Imágenes previas comparadas byte a byte con respaldo; paquetes candidatos externos comparados con su manifiesto SHA256. Catálogo público/paquetes anteriores sin cambios; sin push ni publicación.


## Publicación0.3.11 autorizada — 2026-10-28

El usuario solicita «sube la nueva release». Se completa ARM64, guías públicas, catálogo con cuatro actualizacionesAPI2 y siete adjuntos. Se verificarán borrador/tamaños/SHA256/tag antes de publicar y acceso público después. Se conserva alcance y pendientes de [[40 Gestos widgets albumes y descargas 0.3.11]].


## Entrega pública preparada

ARM64 normal141.0s, versión0.3.11/código20, solo arm64-v8a y firma v2/certificado previo compatible. Universal conserva bytes normales ya verificados. ZIP público32 archivos íntegros, todas las DLL/data/licencias y tres guías, sin WinRT/rpmx. Siete adjuntos finales en dist/0.3.11-release. Catálogo externo publicado en 2dfeaf16985ba7299e9592261a83cf52ee8d4ea5: diez opciones con cliente real y veinte paquetes/variantes de revisión fija byte a byte/SHA256/metadatos correctos. No confundir esta publicación con prueba física Android.
