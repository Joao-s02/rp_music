# Extensiones programables — API 2 / SDK experimental 0.1

Motor publicado desde 0.3.0; fuentes/navegación genéricas desde 0.3.2+11, ampliadas en 0.3.3+12. [Índice de documentación](README.md). La API 1 declarativa continúa funcionando. No se incluyen extensiones instaladas en la app.

## Instalar y probar

Abre Extensiones → Explorar repositorio e introduce https://github.com/Joao-s02/rp-music-extensions ; consulta el catálogo y elige **Biblioteca viva**. También puedes importar su archivo .rpmx. Revisa sus permisos, marca los que aceptes y pulsa Aceptar y activar. Biblioteca mostrará la pantalla aportada por el paquete. Abre Filtros combinados, cambia artista/álbum/carpeta/duración/favoritos y usa Reproducir resultados, Guardar lista o Crear lista automática. La búsqueda de la cabecera se incorpora al filtro.

En Listas, abre la lista y pulsa Cambiar carátula: puedes elegir una imagen propia (hasta 8 MB, normalizada a PNG de 512×512 en datos privados de la app) o el mosaico automático de hasta cuatro canciones. Las listas automáticas se recalculan cuando cambia el catálogo o los favoritos. Si desactivas su extensión, mantienen definición, carátula y última composición; no siguen ejecutándose y se identifican como inactivas.

Instala **Pulso nocturno** y acepta por separado su nivel avanzado. Puede estar activo junto a Biblioteca viva. Cambia la vista ampliada a controles antes de carátula y aporta una política de aleatorio que prefiere otro artista. La reproducción sigue pasando por el motor/servicio existente; notificación y widget se conservan.

En Quién controla cada función puedes elegir Biblioteca, Reproductor ampliado y Aleatorio. Activar otra extensión no sustituye silenciosamente un propietario ya elegido. Cada lista automática tiene su propio proveedor de reglas, por lo que varias extensiones pueden mantener sus propias listas sin un propietario global de todas ellas.

**Volver a la base · modo seguro** desactiva programas sin borrar música, listas ni carátulas. Tres fallos desde la última activación desactivan el programa problemático. Si el registro indica que una extensión quedó ejecutándose al cerrarse el proceso, el siguiente inicio la deja desactivada para revisión.

## Archivo instalable

Un `.rpmx` es un archivo JSON UTF-8 de hasta 128 KB que contiene metadatos y código fuente; no es un ZIP ni una ruta hacia código externo. Se importa desde Extensiones → Importar extensión. Compila dentro de la app sin recompilar ni reinstalar el reproductor. El formato no tiene firma de autor: usar los ejemplos o código de confianza mientras el sistema sea experimental.

Campos:

| Campo | Contrato |
| --- | --- |
| apiVersion | 2 |
| id | Minúsculas, números, puntos/guiones; hasta 100 caracteres. |
| name / description | Hasta 80 / 500 bytes UTF-8. |
| version | Tres números, por ejemplo 0.1.0. |
| level | standard (predeterminado) o advanced. |
| permissions | Capacidades requeridas, aceptadas explícitamente. |
| capabilities | library, player, shuffle y/o lists. |
| source | Código Dart de hasta 64 KB UTF-8. |

Sustituir player/shuffle requiere level=advanced y behavior.override además de los permisos de reproducción. El nivel avanzado no concede acceso general al sistema. Una actualización de paquete exige importación y revisión explícita; si no compila se conserva la versión anterior. No hay actualización silenciosa. El catálogo remoto permite elegir cada descarga. Máximo inicial de 16 programas instalados.

## Permisos disponibles

- `library.read`: metadatos de biblioteca y estado de favoritos; IDs opacos, sin rutas de archivos.
- `playback.control`: reproducir/seleccionar mediante controles del anfitrión.
- `playlists.manage`: guardar resultados y mantener listas de la app. No modifica ni borra archivos musicales.
- `storage.private`: recibir y devolver preferencias JSON propias de hasta 64 KB.
- `behavior.override`: reemplazar las funciones avanzadas declaradas y elegidas por el usuario.

La modificación de archivos musicales, procesos, canales de plataforma y código nativo **no están expuestos**. Desde 0.3.2 hay HTTP acotado para fuentes con consentimiento explícito. Un paquete que pida un permiso desconocido se rechaza; no se muestra un permiso sin efecto. Incorporarlos requiere contratos nuevos, pruebas y consentimiento separado.

## Función Dart

La entrada es `String run(String request)`. Recibe y devuelve JSON. Solo se permiten imports de dart:core, dart:convert y dart:math, comprobados mediante AST antes de compilar; no se conceden puentes de recursos sensibles al intérprete.

Usar tipos genéricos explícitos: `Map<String, dynamic>` y `List<dynamic>`. El intérprete no implementa todo Dart. Los ejemplos usan conversiones y operaciones comprobadas; un código válido en Dart puede necesitar adaptación a dart_eval.

Entrada de library/lists: `event`, `tracks` y `filters`. Desde 0.3.3, cada pista añade artists (nombres individuales por coma), conservando artist original. Cada canción incluye id, title, artist, album, folder relativa, durationMs, size, modifiedMs y favorite. Los IDs son SHA-256 opacos y se resuelven solo dentro de la selección autorizada; devolver IDs ajenos o duplicados se rechaza. No usar los IDs como rutas.

Salida de library/lists: objeto con `ids`. Library también requiere title (hasta 120 caracteres) y admite description (hasta 500), layout=list/cards. Una salida `state` opcional persiste datos propios solo con storage.private.

Entrada de shuffle: tracks de la cola, current (ID opaco), seed. Salida: `next` con un ID válido de esa cola. Si el programa falla, está ocupado o devuelve una selección inválida, se conserva el aleatorio base. El resultado tardío se ignora si el usuario ya cambió de pista.

Entrada de player: título/artista/álbum actuales y estado de reproducción. Salida: title y layout=artworkFirst/controlsFirst. Estos son los primeros componentes admitidos; **no es todavía un catálogo de widgets arbitrarios ni permite reescribir el código compilado**. Añadir más componentes es una evolución del contrato. No se entregó aún la libertad visual completa de la visión del proyecto.

## Preparar un paquete propio

Desarrolla la fuente en el repositorio de extensiones y regenera su envoltorio allí; el empaquetador genérico del anfitrión acepta una ruta externa:

```powershell
python tools/empaquetar_extension.py RUTA_DEL_REPOSITORIO_DE_EXTENSIONES/biblioteca-viva.rpmx
```

El empaquetador genérico espera la fuente en la misma carpeta que el envoltorio, usando guiones bajos (`biblioteca_viva.dart`); para la estructura sources/packages/previews del repositorio de extensiones seguir su procedimiento y verificar coherencia fuente/paquete. No copiar esas fuentes al principal. Editar la fuente sin regenerar el paquete no cambia el archivo instalable. Los archivos generados se comprueban contra su fuente normalizando saltos de línea Windows/Linux.

## Límites comprobables y pendientes

Compilación y ejecución ocurren en isolates externos a la interfaz. Compilar tiene un límite de 12 segundos; cada ejecución, 2 segundos; superar el plazo mata el isolate. Entrada JSON hasta 4 MB, respuesta hasta 512 KB UTF-8, estado propio hasta 64 KB, bytecode hasta 4 MB por programa y caché LRU de ocho versiones. Se serializan las llamadas del anfitrión para limitar trabajo concurrente; la política de audio conserva una alternativa base cuando el motor está ocupado.

Estos límites acotan entradas/salidas y tiempo, **no son una cuota dura de memoria ni aislamiento de proceso/OS**. No se presenta como ejecución segura de código deliberadamente hostil ni como SDK completo listo para un catálogo abierto. Falta fortalecer esa frontera, ampliar autenticación/APIs de red y colaboración, contratos visuales más amplios y mediciones de RAM/batería/latencia. La pantalla muestra duración de la llamada y fallos; no inventa atribución de RAM o CPU por extensión.

Fuentes del prototipo: [dart_eval](https://pub.dev/packages/dart_eval), [API Runtime](https://pub.dev/documentation/dart_eval/latest/dart_eval/Runtime-class.html). Su uso se eligió como decisión técnica provisional para lógica portable en Dart; no implica soporte de todo Flutter ni de todo Dart.


## Catálogo GitHub y compatibilidad (publicado)

`https://github.com/autor/repositorio` público, con `catalog.json` en la raíz de su rama predeterminada. Ejemplo publicado: https://github.com/Joao-s02/rp-music-extensions . Cada consulta fija el commit y utiliza esa revisión también para descargar.

```json
{"schemaVersion":1,"extensions":[{"id":"autor.ejemplo","name":"Ejemplo","version":"0.1.0","description":"Descripción","path":"packages/ejemplo.rpmx","sha256":"64 caracteres hexadecimales minúsculos"}]}
```

Máximo 100 entradas y 128 KB de índice/paquete. Rutas relativas sin `..`, ni URL externas. id, name, version y description deben coincidir exactamente con el paquete. Hash calculado sobre bytes exactos; usar `*.rpmx -text` en .gitattributes para evitar alteración al publicar. Al actualizar: regenerar paquete, incrementar versión, actualizar índice y hash en el mismo commit. Instalación y actualización requieren elección y revisión de permisos. No se promete autenticidad de autor mediante SHA-256. Los paquetes ya no son assets de producción; los ejemplos locales siguen disponibles para pruebas y desarrollo.


## Antecedente 0.3.1

La fuente inicial network.youtube dependía de un cliente específico del anfitrión. En 0.3.2 se migra al paquete externo y al contrato HTTP genérico siguiente; requiere actualizar la extensión y revisar permisos. El material histórico se conserva en legacy/host-0.3.1 del repositorio de extensiones.

## Fuentes y navegación · RP Music 0.3.2

Las implementaciones y sus pruebas particulares pertenecen al [repositorio de extensiones](https://github.com/Joao-s02/rp-music-extensions). El anfitrión proporciona contratos genéricos; no incorpora parsers de proveedores. Los ejemplos heredados de biblioteca/reproductor del principal siguen pendientes de migración.

El manifiesto admite `minAppVersion`, `sourceConfig` y los permisos `network.http`, `playback.control`, `navigation.add`. `sourceConfig` contiene `name`, `domains` (1–8 dominios HTTPS; comodín `*.dominio` opcional), `platforms` (android/windows) y `navigation` opcional con `label`, `icon` (cloud/music/playBadge/playOutline/headphones), `color` (#RRGGBB). La navegación se muestra para la fuente elegida y autorizada; desaparece al desactivarla. Es un componente visual definido por contrato, no Flutter arbitrario. Se revisan dominios y permisos antes de instalar.

En `event=source`, la entrada contiene `operation=search|resolve`, `stage=start`, `date` UTC YYYYMMDD, `context` y `query` o `id` opaco. El programa puede devolver `{request:{url,method,headers,body},next,context}`. El anfitrión realiza GET/POST HTTPS solo a dominios autorizados, sin seguir redirecciones; vuelve a ejecutar con stage=next y response={status,body,cookies}. No usa sesiones del navegador. Máximo cuatro rondas, contexto 64 KB, cuerpo JSON 64 KB, respuesta HTTP 1.5 MiB y plazo 25 s por petición. Cabeceras sensibles como Authorization/Host se rechazan. La red pertenece a un único flujo en memoria, no se guardan cookies ni URLs firmadas en preferencias. Los errores del intérprete de fuente no registran el contenido recibido.

Resultado de búsqueda: `{tracks:[{id,title,artist,album?,artwork?,durationMs?}]}`, máximo 50. IDs opacos hasta 200 caracteres alfanuméricos/._-; audio y carátula requieren dominios declarados. Resultado de resolve: `{url}` HTTPS temporal. El nombre del servicio se publica en metadatos del reproductor. Cambiar versión, propietario o permisos descarta respuestas pendientes; revocar detiene el audio. Las pistas remotas no son archivos borrables del dispositivo.

El catálogo schemaVersion=1 admite `versions` por entrada con metadatos completos y minAppVersion. 0.3.2 selecciona la variante compatible más nueva; clientes anteriores siguen leyendo la entrada base. El paquete antiguo de fuente network.youtube requiere actualización y no se ejecuta con el nuevo transporte. Los programas de biblioteca/reproductor anteriores conservan sus contratos.

Prueba HTTP independiente: `dart run tools/verify_source_package.dart RUTA_EXTERNA.rpmx CONSULTA`. Prueba Android genérica: integration_test/extension_source_test.dart recibe SOURCE_PACKAGE_GZIP (JSON del paquete externo comprimido con gzip y codificado en base64) y SOURCE_QUERY mediante dart-define-from-file; se evita el límite de línea de comandos de Windows. Es una entrada de pruebas y no se incluye el paquete en la app normal. No introducir código ni fixtures específicos de un proveedor en el principal.


## Novedades publicadas en 0.3.3

playOutline es un icono de contorno que hereda tamaño y color del tema de navegación; requiere minAppVersion 0.3.3. La tarjeta de la fuente activa con acceso propio deja de duplicar Abrir fuente. ProgramSnapshot añade artists (lista de nombres separados por coma, sin duplicados por canción) y conserva artist original para compatibilidad. Las extensiones de filtro deben comparar contra nombres individuales; sus actualizaciones permanecen en el repositorio de extensiones.

## Preparación local 0.3.4 (sin publicar)

- Permiso storage.download permite exportar audio resuelto por una fuente mediante selector, máximo 64 MiB y tres minutos. No habilita acceso a rutas arbitrarias ni escritura desde el programa. Requiere revisión de permisos al importar el nuevo paquete.
- Operación source/lyrics recibe title, artist, album, durationMs y devuelve syncedLyrics (LRC) y/o plainLyrics (texto), hasta 256 KiB. El programa conserva responsabilidad por su proveedor y dominios. Consultas solo al pulsar el botón de nube; letras guardadas por ID de canción.
- sourceConfig admite description (máximo 400 caracteres), searchLabel (máximo 80). Se conservan valores predeterminados de paquetes anteriores.
- navigation.add muestra cada fuente activada/autorizada compatible. Fuente elegida sigue siendo única: abrir otra requiere Usar esta fuente; no altera automáticamente el propietario.
- Paquetes nuevos requieren minAppVersion 0.3.4, exclusivamente en rp-music-extensions. Spotify preview no simula audio completo ni sincronización de fragmentos.

## Contratos de 0.3.5

La sección 0.3.4 anterior conserva su fase de preparación; esa app se publicó posteriormente. Las novedades siguientes requieren minAppVersion 0.3.5 y no están en sus binarios.

- Nueva capacidad `lyrics`, con propietario independiente de `source`. Requiere `library.read`, `network.http`, `lyrics.cache` y `sourceConfig` con nombre, dominios y plataformas; no requiere permiso de reproducción ni navegación. No añadir `navigation` a proveedores que solo tengan `lyrics`.
- El anfitrión entrega `event=lyrics`, `operation=lyrics`, `title`, `artist`, `album`, `durationMs`, y las mismas etapas/contexto/respuestas HTTP del transporte existente. No entrega rutas de archivos locales. Resultado: `syncedLyrics` y/o `plainLyrics`, hasta 256 KiB UTF-8; `instrumental=true` sin texto identifica un instrumental. El texto recuperado se guarda en soporte privado del anfitrión, no en el archivo musical ni en los 64 KiB de estado privado del programa.
- Seleccionar canción inicia lectura incrustada y caché; solo si faltan se consulta el proveedor autorizado. Ausencias se recuerdan 24 h y fallos 5 min. Cambiar permisos/versión/propietario descarta respuestas pendientes antes de persistir. Reintento manual desde Letras. No hay barrido de biblioteca completo.
- `source/metadata` recibe ID opaco remoto, título, artista, álbum y duración. Devuelve `tags` con `title`, `artist`, `album`, `albumArtist`, `date`, `genre`, `trackNumber`, `trackTotal`, `discNumber`, `discTotal` opcionales; también letras, `artwork` HTTPS y `complete` booleano. Máximo ocho etapas; HTTP 429/503 se reintenta una vez. Un fallo de transporte se entrega como `response={status:0,body:""}` para permitir devolver datos parciales. `source/lyrics`, búsqueda y resolución conservan cuatro etapas.
- Peticiones admiten `delayMs` entero 0–2000; se aplica antes de abrir conexión. Cada proveedor debe respetar sus límites. `sourceConfig.domains` admite hasta doce dominios, con las mismas reglas HTTPS y comodines; ampliarlos exige revisión del paquete.
- Portada para descargas: solo JPEG/PNG detectados por bytes, hasta 5 MiB/25 s; hasta tres redirecciones, verificando cada destino. Permisos/versión/propietario se comprueban antes y después de preparar el archivo. No se concede acceso a rutas arbitrarias.
- Etiquetado del nuevo MP4/M4A en memoria: incluye portada y letra, conserva los bytes/posiciones del audio y no recodifica. Otro contenedor o un error de etiquetas conserva el audio original con aviso. No es un editor de originales locales ni garantiza todos los campos.

La implementación específica de cualquier proveedor y sus pruebas permanecen exclusivamente en rp-music-extensions. Guía de uso: [0.3.5](USO-0.3.5.md).

## Exploración de colecciones — candidato local 0.3.7

Opt-in sourceConfig.browse=true, omitido/false para fuentes existentes. source/browse recibe query (hasta 200), kind=song/artist/album/playlist, id remoto opcional y cursor opaco opcional de hasta 16000 caracteres. Devuelve tracks (máximo 200 por página), entities (máximo 100: id, kind=artist/album/playlist, title), title y cursor opcionales; collection opcional identifica la colección abierta. Los IDs tienen las mismas restricciones alfanuméricas que source/search. Se conservan límites HTTP/dominios, propietario y descarte por revocación.

El anfitrión muestra filtros, entidades, páginas y Cargar más. Importar copia está disponible para álbum/lista cuando no hay cursor pendiente; no descarga audio ni crea vínculo de sincronización. Orden y repeticiones se preservan. Persistencia de referencias/metadatos remotos usados por listas/favoritos, sin guardar URLs firmadas. No equivale a conexión de cuenta ni sincronización. La extensión original conserva búsqueda/descarga anteriores; variante experimental y catálogo se gestionan solo en su repositorio.

## Ampliación local 0.3.11: identidad de colección y retratos

`source/browse` admite `artwork` HTTPS y `artist` opcionales en entidades/colección. El anfitrión valida el dominio de imagen y conserva la identidad del encabezado inicial al paginar. Descargar álbum reúne todas las páginas (máximo20 continuaciones/1000 pistas), preserva orden y usa un contexto común de álbum/artista de álbum/portada. El programa no recibe rutas ni escritura; `storage.download` y la selección SAF/carpeta siguen a cargo del anfitrión.

`source/metadata` recibe `albumLocked=true` al descargar desde una colección conocida. Ese álbum no se sustituye por una edición externa ni por el de un resultado de letras. Con álbum desconocido, solo se acepta una edición externa declarada verificada (`tags.albumVerified=true`); se conservan título/artista de la selección. Números/fechas de otra edición se descartan. Proveedores anteriores siguen siendo compatibles, pero requieren actualización para omitir sus búsquedas redundantes. Las letras y los datos que falten conservan los avisos anteriores.

`sourceConfig.artistArtwork=true` declara la consulta opcional de retratos, requiere nueva app0.3.11 y permiso `library.read` aceptado además de fuente/red autorizadas. `source/artistArtwork` recibe únicamente `artist`; devuelve `artist` coincidente y `artwork` HTTPS en dominio autorizado. Las etapas de red siguen el contrato existente. El anfitrión descarga hasta1MiB por foto, limita tiempo, convierte a imagen de256px y guarda caché privada offline de hasta64MiB; coincidencias ausentes se reintentan tras24h. No entrega rutas musicales ni biblioteca completa al proveedor. Desactivar/revocar impide guardar nuevas respuestas; las imágenes ya guardadas se conservan para uso offline.


## Corrección local0.3.12 de selección de letras

Los candidatos separan la identidad de álbum de la selección de letras. Priorizar LRC con marcas válidas entre interpretaciones compatibles (título/artista/versión/duración); consulta alternativa si solo hay texto. Retener candidato de texto dentro del contexto64KiB para no perderlo si la alternativa falla. Duraciones de LRCLIB se leen como int/double, sin split de puntos en dart_eval. El anfitrión valida tiempos de syncedLyrics y conserva mejoras sincronizadas en caché sobre texto incrustado anterior. Sin nuevo permiso, edición de originales ni cambio de apiVersion; versiones/paquetes nuevos se distribuyen solo en repositorio externo.
