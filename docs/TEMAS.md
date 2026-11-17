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
| `decoration` | Adorno en el encabezado principal |

Para convertir un PNG a Base64 desde PowerShell, abre una terminal en la carpeta de la imagen y ejecuta lo siguiente. Copia el resultado como valor de la clave del recurso dentro de `images`.

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path 'play.png')))
```

Por ejemplo, usa la clave `play` para el icono de reproducir y `background` para el fondo. Conserva las comillas del valor Base64 y las comas entre los recursos. Puedes empezar únicamente con colores y añadir imágenes después.

Usa iconos cuadrados con fondo transparente. El tamaño máximo es 512 × 512 por recurso y 2048 × 2048 para el fondo. El archivo completo admite hasta 4 MiB. Los recursos omitidos usan el aspecto predeterminado.

## Probar y compartir

1. Abre **Temas → Importar tema** y selecciona el archivo. Se aplica al importarlo.
2. Recorre Biblioteca, Favoritos, Listas, Temas, Ajustes y el reproductor. Comprueba el modo claro y oscuro y que los iconos se distingan cuando cambia su estado. Prueba en Android y Windows si los tienes disponibles.
3. Prepara una captura de la biblioteca y otra del reproductor con el tema aplicado. Incluye la autoría y el permiso de redistribución de cada recurso que uses.
4. Propone tu paquete y las capturas mediante una solicitud de cambios en [rp-music-themes](https://github.com/Joao-s02/rp-music-themes). La revisión comprueba legibilidad, compatibilidad y permisos de los recursos antes de incorporar el tema.

## Catálogo

RP Music 0.4.0 consulta el catálogo de [rp-music-themes](https://github.com/Joao-s02/rp-music-themes). Para pruebas de desarrollo se puede sustituir la dirección con `RP_MUSIC_THEME_CATALOG` mediante `--dart-define` al compilar. Un valor vacío usa Minimalista como catálogo local de prueba. El índice HTTPS contiene `version: 1` y una lista `themes`. Cada entrada incluye `name`, `url` HTTPS del paquete y `sha256` en hexadecimal. `preview` es la URL HTTPS opcional de la captura. Las rutas relativas se resuelven desde el índice. El servidor de paquetes debe responder directamente, sin redirecciones. La app compara el SHA-256 del paquete descargado antes de instalarlo.
