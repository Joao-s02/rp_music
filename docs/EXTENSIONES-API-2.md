# Extensiones programables — API 2 / SDK experimental 0.1

Disponible en el trabajo local 0.3.0+9. La release publicada 0.2.6 no contiene este motor. La API 1 (`descubrir.json`) continúa funcionando.

## Probar sin preparar archivos

En la compilación 0.3.0, abre Extensiones y pulsa **Instalar Biblioteca viva**. Revisa sus permisos, marca los que aceptes y pulsa Aceptar y activar. Biblioteca mostrará la pantalla aportada por el paquete. Abre Filtros combinados, cambia artista/álbum/carpeta/duración/favoritos y usa Reproducir resultados, Guardar lista o Crear lista automática. La búsqueda de la cabecera se incorpora al filtro.

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

Sustituir player/shuffle requiere level=advanced y behavior.override además de los permisos de reproducción. El nivel avanzado no concede acceso general al sistema. Una actualización de paquete exige importación y revisión explícita; si no compila se conserva la versión anterior. No hay actualización silenciosa ni catálogo remoto. Máximo inicial de 16 programas instalados.

## Permisos disponibles

- `library.read`: metadatos de biblioteca y estado de favoritos; IDs opacos, sin rutas de archivos.
- `playback.control`: reproducir/seleccionar mediante controles del anfitrión.
- `playlists.manage`: guardar resultados y mantener listas de la app. No modifica ni borra archivos musicales.
- `storage.private`: recibir y devolver preferencias JSON propias de hasta 64 KB.
- `behavior.override`: reemplazar las funciones avanzadas declaradas y elegidas por el usuario.

Internet, modificación de archivos musicales, procesos, canales de plataforma y código nativo **no están expuestos** en este SDK. Un paquete que pida un permiso desconocido se rechaza; no se muestra un permiso sin efecto. Incorporarlos requiere contratos nuevos, pruebas y consentimiento separado.

## Función Dart

La entrada es `String run(String request)`. Recibe y devuelve JSON. Solo se permiten imports de dart:core, dart:convert y dart:math, comprobados mediante AST antes de compilar; no se conceden puentes de recursos sensibles al intérprete.

Usar tipos genéricos explícitos: `Map<String, dynamic>` y `List<dynamic>`. El intérprete no implementa todo Dart. Los ejemplos usan conversiones y operaciones comprobadas; un código válido en Dart puede necesitar adaptación a dart_eval.

Entrada de library/lists: `event`, `tracks` y `filters`. Cada canción incluye id, title, artist, album, folder relativa, durationMs, size, modifiedMs y favorite. Los IDs son SHA-256 opacos y se resuelven solo dentro de la selección autorizada; devolver IDs ajenos o duplicados se rechaza. No usar los IDs como rutas.

Salida de library/lists: objeto con `ids`. Library también requiere title (hasta 120 caracteres) y admite description (hasta 500), layout=list/cards. Una salida `state` opcional persiste datos propios solo con storage.private.

Entrada de shuffle: tracks de la cola, current (ID opaco), seed. Salida: `next` con un ID válido de esa cola. Si el programa falla, está ocupado o devuelve una selección inválida, se conserva el aleatorio base. El resultado tardío se ignora si el usuario ya cambió de pista.

Entrada de player: título/artista/álbum actuales y estado de reproducción. Salida: title y layout=artworkFirst/controlsFirst. Estos son los primeros componentes admitidos; **no es todavía un catálogo de widgets arbitrarios ni permite reescribir el código compilado**. Añadir más componentes es una evolución del contrato. No se entregó aún la libertad visual completa de la visión del proyecto.

## Preparar un paquete propio

Edita el `.dart` del ejemplo y regenera su envoltorio:

```powershell
python tools/empaquetar_extension.py examples/extensions/programables/biblioteca-viva.rpmx
```

El archivo de fuente correspondiente usa guiones bajos (`biblioteca_viva.dart`). Editar la fuente sin regenerar el paquete no cambia el archivo instalable. Los archivos generados se comprueban contra su fuente normalizando saltos de línea Windows/Linux.

## Límites comprobables y pendientes

Compilación y ejecución ocurren en isolates externos a la interfaz. Compilar tiene un límite de 12 segundos; cada ejecución, 2 segundos; superar el plazo mata el isolate. Entrada JSON hasta 4 MB, respuesta hasta 512 KB UTF-8, estado propio hasta 64 KB, bytecode hasta 4 MB por programa y caché LRU de ocho versiones. Se serializan las llamadas del anfitrión para limitar trabajo concurrente; la política de audio conserva una alternativa base cuando el motor está ocupado.

Estos límites acotan entradas/salidas y tiempo, **no son una cuota dura de memoria ni aislamiento de proceso/OS**. No se presenta como ejecución segura de código deliberadamente hostil ni como SDK completo listo para un catálogo abierto. Falta fortalecer esa frontera, añadir APIs de red/colaboración, contratos visuales más amplios y mediciones de RAM/batería/latencia. La pantalla muestra duración de la llamada y fallos; no inventa atribución de RAM o CPU por extensión.

Fuentes del prototipo: [dart_eval](https://pub.dev/packages/dart_eval), [API Runtime](https://pub.dev/documentation/dart_eval/latest/dart_eval/Runtime-class.html). Su uso se eligió como decisión técnica provisional para lógica portable en Dart; no implica soporte de todo Flutter ni de todo Dart.


## Catálogo GitHub (prototipo local posterior)

`https://github.com/autor/repositorio` público, con `catalog.json` en la raíz de su rama predeterminada. Ejemplo publicado: https://github.com/Joao-s02/rp-music-extensions . Cada consulta fija el commit y utiliza esa revisión también para descargar.

```json
{"schemaVersion":1,"extensions":[{"id":"autor.ejemplo","name":"Ejemplo","version":"0.1.0","description":"Descripción","path":"packages/ejemplo.rpmx","sha256":"64 caracteres hexadecimales minúsculos"}]}
```

Máximo 100 entradas y 128 KB de índice/paquete. Rutas relativas sin `..`, ni URL externas. id, name, version y description deben coincidir exactamente con el paquete. Hash calculado sobre bytes exactos; usar `*.rpmx -text` en .gitattributes para evitar alteración al publicar. Al actualizar: regenerar paquete, incrementar versión, actualizar índice y hash en el mismo commit. Instalación y actualización requieren elección y revisión de permisos. No se promete autenticidad de autor mediante SHA-256. Los paquetes ya no son assets de producción; los ejemplos locales siguen disponibles para pruebas y desarrollo.
