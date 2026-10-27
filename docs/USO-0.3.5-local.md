# RP Music 0.3.5 — cambios locales

> Antecedente de preparación local. Para la entrega publicada consultar [la guía 0.3.5](USO-0.3.5.md).

Esta compilación todavía no está publicada. La release pública continúa en 0.3.4. Conserva tus datos instalando Android encima de la versión anterior, sin desinstalar; Windows necesita su carpeta completa. No elimines el soporte privado de la app.

## Letras de tu música

Al seleccionar una canción se leen sus letras incrustadas. No necesitas una extensión ni conexión para verlas. En el reproductor abre **Letras**. Las letras LRC siguen la posición y permiten tocar una línea para avanzar; el texto sin marcas se muestra sin sincronización. Importar LRC/TXT sigue disponible.

Para buscar letras faltantes, importa el candidato **Letras locales 0.1.0** desde el repositorio independiente de extensiones y acepta sus permisos. En Extensiones, el proveedor de **Letras de canciones locales** debe estar activo. La búsqueda comienza automáticamente al seleccionar una canción que no tenga letra incrustada ni copia guardada; no envía toda tu biblioteca al abrir.

Las letras encontradas se guardan solo dentro de RP Music. No se escriben en tus archivos. Después funcionan sin conexión. Si no hay coincidencia se evita repetir la consulta durante 24 horas; un fallo de conexión permite reintentar después de cinco minutos. El botón de nube en Letras permite reintentar explícitamente. Desactivar la extensión impide nuevas consultas, pero conserva las letras ya guardadas.

## Descargas YouTube

Importa la actualización candidata **YouTube Android 0.4.0**, compatible con app 0.3.5. Revisa los nuevos dominios de consulta, incluidos MusicBrainz y Cover Art Archive. Conservar el paquete 0.3.0 no incorpora automáticamente las mejoras de búsqueda de su código.

Al descargar se consulta la información musical y se añaden los datos encontrados y las letras al nuevo M4A, antes de elegir dónde guardarlo. No se cambia la calidad ni se recodifica audio. La selección del destino sigue siendo manual. Actualiza la biblioteca si guardaste dentro de su carpeta.

No todas las canciones tienen todos los datos. Un servicio caído o un archivo incompatible producen un aviso de información parcial o audio sin etiquetar; no se inventan álbumes, años ni letras. Canciones instrumentales se distinguen de una búsqueda sin resultados. Un directo o remix no debe recibir automáticamente la letra de la versión de estudio.

Spotify está cancelado. Se retiró del catálogo **local**; el catálogo remoto y las publicaciones anteriores siguen conservados hasta una publicación autorizada. YouTube Windows mantiene sus límites nativos previos; este candidato nuevo de YouTube es Android.

## Límites

Lectura Android mediante permisos de carpeta: copia temporal privada de hasta 256 MiB y 30 segundos, borrada tras leer. Letras hasta 256 KiB. SYLT soportado con marcas en milisegundos, sin compresión/cifrado. Otras variantes y archivos concretos necesitan validación. Las letras comunitarias pueden faltar o corresponder a otra edición; el sistema filtra candidatos pero no garantiza cualquier canción.

Estado y verificaciones: [nota de implementación](../boveda/33%20Metadatos%20de%20descargas%20YouTube.md). Extensiones y candidatos pertenecen exclusivamente a [rp-music-extensions](https://github.com/Joao-s02/rp-music-extensions).
