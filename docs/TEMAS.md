# Crear un tema para RP Music

Parte de [Minimalista](../assets/themes/minimalista.rptheme). Copia el archivo, consérvalo con la extensión `.rptheme` y ábrelo en un editor de texto. El formato es JSON en UTF-8.

```json
{
  "version": 1,
  "name": "Mi tema",
  "accent": "#80CFC8"
}
```

`accent` genera una paleta para el modo claro y oscuro. Los botones, el contenido de cada pantalla y la navegación conservan su distribución.

## Colores opcionales

El objeto `colors` permite elegir colores concretos en formato `#RRGGBB`. Admite `primary`, `onPrimary`, `secondary`, `onSecondary`, `surface`, `onSurface`, `onSurfaceVariant`, `outline`, `surfaceContainer`, `surfaceContainerLow` y `surfaceContainerLowest`. Las claves `on…` son el color de texto o iconos sobre la superficie correspondiente. Los colores omitidos se generan desde `accent`. Comprueba el contraste tanto en modo claro como oscuro al fijar colores.

## Imágenes opcionales

Añade un objeto `images` al JSON. Cada clave identifica un recurso y su valor contiene el PNG codificado en Base64, sin prefijo `data:`.

| Clave | Ubicación |
| --- | --- |
| `library`, `favorites`, `playlists`, `themes`, `settings` | Iconos de la navegación |
| `play`, `pause`, `previous`, `next`, `shuffle`, `repeat` | Controles de reproducción |
| `background` | Fondo de las pantallas de la app, atenuado para mantener la lectura |
| `decoration` | Imagen de marca en los encabezados de Biblioteca y reproductor, desde 0.4.1 |
| `lyrics`, `queue`, `volume`, `details` | Acciones del reproductor, desde 0.4.1 |
| `favorite`, `favoriteSelected` | Favorito desmarcado/marcado, desde 0.4.1 |
| `playlistAdd`, `playlistRemove`, `playlistCover` | Acciones de listas, desde 0.4.1 |
| `add`, `back`, `search`, `refresh`, `folder`, `artist`, `album`, `more`, `delete` | Recursos de biblioteca y colecciones, desde 0.4.1 |

Para convertir un PNG a Base64 desde PowerShell, abre una terminal en la carpeta de la imagen y ejecuta lo siguiente. Copia el resultado como valor de la clave del recurso dentro de `images`.

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path 'play.png')))
```

Por ejemplo, usa la clave `play` para el icono de reproducir y `background` para el fondo. Conserva las comillas del valor Base64 y las comas entre los recursos. Puedes empezar únicamente con colores y añadir imágenes después.

Usa iconos cuadrados con fondo transparente. El tamaño máximo es 512 × 512 por recurso y 2048 × 2048 para el fondo. El archivo completo admite hasta 4 MiB. Los recursos omitidos usan el aspecto predeterminado.

## Compatibilidad desde 0.4.1

Un tema que utilice los recursos añadidos en 0.4.1 debe incluir `"minAppVersion": "0.4.1"`. RP Music comprueba ese mínimo antes de instalar. Los paquetes anteriores siguen funcionando y los recursos omitidos usan los iconos base. Los nuevos recursos de favorito y cola pueden reutilizar los iconos de navegación del tema anterior.

Las imágenes del tema seleccionado se preparan antes de aplicarlo. RP Music mantiene sus decodificadores activos durante la navegación y libera esa retención al cambiar de tema.

## Probar y compartir

1. Abre **Ajustes → Apariencia → Temas → Descargados → Importar tema** y selecciona el archivo. Se aplica al importarlo.
2. Recorre Biblioteca, Favoritos, Listas, Temas, Ajustes y el reproductor. Comprueba el modo claro y oscuro y que los iconos se distingan cuando cambia su estado. Prueba en Android y Windows si los tienes disponibles.
3. Prepara una captura de la biblioteca y otra del reproductor con el tema aplicado. Incluye la autoría y el permiso de redistribución de cada recurso que uses.
4. Propone tu paquete y las capturas mediante una solicitud de cambios en [rp-music-themes](https://github.com/Joao-s02/rp-music-themes). La revisión comprueba legibilidad, compatibilidad y permisos de los recursos antes de incorporar el tema.

## Catálogo

RP Music 0.4.0 consulta el catálogo de [rp-music-themes](https://github.com/Joao-s02/rp-music-themes). Para pruebas de desarrollo se puede sustituir la dirección con `RP_MUSIC_THEME_CATALOG` mediante `--dart-define` al compilar. Un valor vacío usa Minimalista como catálogo local de prueba. El índice HTTPS contiene `version: 1` y una lista `themes`. Cada entrada incluye `name`, `url` HTTPS del paquete y `sha256` en hexadecimal. `preview` es la URL HTTPS opcional de la captura. Las rutas relativas se resuelven desde el índice. El servidor de paquetes debe responder directamente, sin redirecciones. La app compara el SHA-256 del paquete descargado antes de instalarlo.

## Revisiones y temas instalados (candidato 0.4.1)

La pantalla agrupa Descargados y Catálogo en tarjetas. Una entrada instalada queda deshabilitada para descargar. El nombre del tema es su identidad estable: consérvalo al actualizarlo. El paquete y su entrada del catálogo pueden incluir `"revision": 2`, un entero positivo que aumenta con cada actualización. Si se omite, vale 1. El `version: 1` existente sigue describiendo el formato del archivo.

Una revisión superior muestra **Actualizar tema**. La actualización verifica SHA-256, nombre y revisión del catálogo y sustituye la copia anterior, conservando un solo tema instalado. La app rechaza importar una revisión anterior. Una nueva revisión necesita un SHA-256 calculado sobre los bytes finales y una URL inmutable nueva en el catálogo. Cambiar bytes sin aumentar revision no anuncia una actualización.

Las instalaciones antiguas que tenían varias copias del mismo nombre se unifican al restaurar: se conserva la revisión superior y, a igualdad, la seleccionada. El catálogo público sigue sin modificarse durante las pruebas de este candidato.

## Tercera revisión local 0.4.1+33

Se añaden los recursos `filter`, `sortAscending` y `sortDescending`. La búsqueda inicial y los menús de canción reutilizan `search` y `more`, igual que sus equivalentes ya personalizados. Un paquete que necesite esta compilación incluye `"minAppBuild": 33` junto a `"minAppVersion": "0.4.1"`. El mínimo de compilación es un entero positivo; se rechaza un paquete que pida un build posterior al instalado.

Miku revisión 2 usa 34 recursos y glifos de reproducir/pausa centrados sin una segunda superficie circular. El círculo y su zona de pulsación los aporta la app. Los recursos nuevos se entregan localmente en Miku-Turquesa-revision2.rptheme; el catálogo público permanece sin cambios.

Descargados y Catálogo son tarjetas desplegables, cerradas al entrar por primera vez. Toca cada cabecera para abrir su contenido. Se conserva la selección del tema y las comprobaciones de revisión/descarga.

## Catálogo compatible con aplicaciones anteriores

Cada entrada mantiene su paquete base y puede añadir `updates`, una lista de revisiones con `revision`, `url`, `sha256`, `minAppVersion` y `minAppBuild` opcionales. La app elige la revisión compatible más alta. Las apps anteriores ignoran updates y conservan la descarga base; no se sustituye su URL por un paquete con recursos incompatibles. El nombre estable se toma de la entrada base. Se admiten hasta 20 revisiones por entrada y 100 temas por catálogo.
