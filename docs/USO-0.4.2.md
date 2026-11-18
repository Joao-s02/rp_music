# Uso de RP Music 0.4.2

## Instalar y actualizar

Android: usa el APK universal si desconoces la arquitectura; ARM64 es una descarga menor para equipos compatibles de 64 bits. Instala sobre la app existente, sin desinstalar, para conservar biblioteca, favoritos, listas, letras y temas. Los APK mantienen el certificado de distribución y no solicitan instalación interna de paquetes. Las actualizaciones se abren desde la página oficial y Archivos/Descargas.

Windows: extrae el ZIP completo en una carpeta nueva y ejecuta rp_music.exe junto con sus DLL y data. Conserva los datos privados de la aplicación y no mezcles dependencias de versiones anteriores.

## Biblioteca y reproducción

Elige tu carpeta, espera el escaneo y abre una canción. Biblioteca permite explorar carpetas, álbumes y artistas; Favoritos y Listas usan archivos locales. El minirreproductor abre Ahora suena. Cola, aleatorio, repetición y controles multimedia conservan la sesión; restaurar la sesión no inicia audio por sí solo.

Dentro de una lista, los filtros están junto al título. Usa los tres puntos para cambiar carátula o eliminar la lista; eliminar una lista no borra los archivos de música.

## Cola editable

Abre «Ahora suena» y toca **Cola**. En ventanas estrechas se abre desde abajo. En ventanas amplias se abre a la derecha. La canción actual aparece separada de las pendientes.

- En la biblioteca, abre **⋮**, mantén pulsada la canción en Android o haz clic derecho en Windows. Elige **Reproducir a continuación** o **Añadir al final de la cola**. También puedes añadir colecciones desde su cabecera.
- Arrastra una pista desde su asa para cambiar el orden. Su menú permite subir, bajar, poner a continuación o quitar la entrada. Las canciones repetidas cuentan como entradas independientes.
- La última acción **Reproducir a continuación** ocupa el próximo turno. Si añades B y después C, sonará C antes de B. El aleatorio muestra el orden efectivo y conserva esas prioridades. Al desactivarlo se recupera el orden de origen de las pistas pendientes con las ediciones manuales.
- **Vaciar pendientes** deja sonar la canción actual. Al abrir de nuevo la app, la cola y la posición se recuperan en pausa.

## Letras

Se leen letras incrustadas y LRC/TXT importados. La sincronización depende de las marcas del archivo; un TXT no se convierte en letra sincronizada. La cabecera muestra una carátula pequeña. Expandir mantiene el desplazamiento por líneas. Toca una línea sincronizada para buscar esa posición y los bordes del fondo para ocultar/mostrar controles.

## Temas

Abre Descargados o Catálogo para ver su contenido. Puedes importar un .rptheme o descargarlo. Un tema instalado queda marcado; si existe una revisión compatible posterior aparece Actualizar tema. Para Miku, instala o actualiza a revisión 2 desde el catálogo. Los temas cambian apariencia, sin mover la distribución ni ejecutar código.

Catálogo y guía: https://github.com/Joao-s02/rp-music-themes

## Fotos de artistas y conexión

La música funciona sin cuenta ni internet. Las fotos están desactivadas inicialmente. En Biblioteca → Artistas, activa Fotos de artistas si quieres consultar imágenes. Al cargar las filas se envían el nombre y el título de una canción a Deezer; Wikimedia sirve de respaldo por nombre. No se envían audio, archivos, rutas, álbumes ni listas. Las filas cercanas pueden prepararse al desplazar. Se reutiliza la caché y se guardan las fuentes; mantén pulsada la foto para verlas.

Puedes desactivar las fotos en el mismo lugar: se detienen las consultas y se conserva la caché privada. Una coincidencia ausente o dudosa muestra el icono de respaldo. La selección por nombre de Wikimedia no se valida con la canción. Los proveedores aplican sus condiciones y pueden cambiar disponibilidad: https://developers.deezer.com/termsofuse y https://www.wikimedia.org/.

## Android y segundo plano

En Ajustes revisa notificaciones, restricciones de batería y diagnóstico multimedia. Los botones conservan el mismo tamaño incluso con texto ampliado. El comportamiento de segundo plano, widgets, audífonos y controles depende también de Android y del fabricante.
