# Prueba declarativa de extensiones — API 1

`descubrir.json` se importa desde la aplicación. Es una prueba de instalación, persistencia, selección de interfaz y una acción aportada por un paquete externo. No resuelve todavía la ejecución de lógica propia.

## Contrato experimental

| Campo | Requisito |
| --- | --- |
| `apiVersion` | Número `1`. |
| `id` | Identificador en minúsculas, letras/números, segmentos con punto o guion; máximo 100 caracteres. |
| `name` | Nombre no vacío, máximo 80 caracteres. |
| `description` | Texto, máximo 500 caracteres. |
| `permissions` | Lista vacía: esta versión no concede acceso al sistema. |
| `screen.layout` | `list` o `cards`. |
| `screen.accent` | Color hexadecimal `#RRGGBB`. |
| `actions` | Lista vacía o con `playRandom`. |

Máximo de archivo: 64 KB. No se descargan archivos, se evalúa código, se conceden permisos ni se interpretan rutas dentro del manifiesto. El identificador se utiliza como dato, nunca como ruta. El diseño de paquete, versionado y SDK puede cambiar.

La aplicación permite activar una presentación a la vez. Se conserva la elección al reiniciar. La acción `playRandom` usa las canciones filtradas de la biblioteca. Reimportar el mismo `id` reemplaza el manifiesto; desinstalar la presentación activa restaura la interfaz base.

La pantalla y la acción siguen siendo componentes programados en el núcleo: no permite todavía pantallas arbitrarias, comunicación entre extensiones, ecualización ni fuentes de audio nuevas. No confundir esta prueba con la visión completa documentada en la bóveda.
