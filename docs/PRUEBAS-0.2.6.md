# Pruebas de RP Music 0.2.6+8

La versión 0.2.6 conserva paquete/datos de 0.2.5. Distribución preliminar: [v0.2.6-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.2.6-alpha.1).

## Actualizar desde la app

La consulta solo puede ofrecer una release compatible posterior real. Para probar la ventana nueva cuando exista: Ajustes → Buscar actualizaciones; debe abrirse centrada con versión actual/nueva, tamaño y novedades. Actualizar descarga dentro de la app con progreso y cancelación. Después Android permite abrir el instalador del sistema, que conserva su confirmación; Windows descarga un ZIP verificado y permite mostrarlo en el explorador. Extraerlo en otra carpeta y cerrar la app anterior desde Salir en bandeja sigue siendo manual.

Actualizar después cierra sin omitir permanentemente la versión. En Ajustes, Ver actualización debe reabrir el detalle, incluso si ya hay una descarga verificada. Comprobar pantalla de 360 px y texto aumentado. Las pruebas automatizadas usan una versión sintética futura y respuestas aisladas; no se publica una release falsa para esta prueba. La actualización real entre dos releases públicas aún debe verificarse.

## Escritura para borrar

Usa copias prescindibles de dos canciones. Si la carpeta ya tiene escritura, borrar con confirmación funciona como antes. Si viene de una versión que guardó solo lectura, confirmar Eliminar debe abrir el selector Android en esa carpeta para autorizarla; selecciona la misma y concede acceso. Elegir otra no autoriza el archivo original. Cancelar conserva archivo, referencias y reproducción. Se puede autorizar antes desde Ajustes → Biblioteca → Permitir eliminar archivos.

No existe un interruptor de escritura SAF en permisos generales de Android. Una actualización no puede ampliar un permiso previo sin intervención del usuario. Algunos proveedores o SD pueden rechazar escritura/eliminación; probar ambos en el teléfono.

## Widget Android

Mantén pulsado el escritorio del teléfono → Widgets → RP Music, o usa Ajustes → Pantalla de inicio → Añadir widget. El launcher puede pedir confirmación. Comprueba título, artista, carátula cuando exista, anterior, reproducir/pausar y siguiente. Tocar título/carátula abre RP Music. Prueba con la app en segundo plano, pausada, cerrada por el sistema y tras reiniciar el teléfono. Si aún no elegiste música, abre RP Music y elige tu carpeta.

El widget comparte sesión con notificación y app, y no inicia música automáticamente al colocarlo. La prueba nativa cubre registro del proveedor y comandos/estado con sesión real en emulador; no equivale a verificar el gesto de añadir, presentación y recuperación en todos los launchers.

## Orden de canciones

En Biblioteca, favoritos y vistas de canciones de álbum/artista/carpeta/lista, selecciona título, artista, álbum, duración, fecha de modificación, tamaño o archivo. Pulsa la flecha para invertir ascendente/descendente. Comprueba que se conserva al reiniciar y que seleccionar una canción forma la cola con el orden visible. La cola que ya estaba sonando no cambia solo por modificar la preferencia. Fecha de modificación es la del archivo; no es la fecha en que se añadió a la app.

## Extensiones

La entrevista definió primera biblioteca programable con filtros, listas automáticas y carátulas propias/mosaico, varias activas, conflictos elegidos y recuperación. Su motor/SDK no está implementado todavía; la extensión actual sigue siendo declarativa. No probar como disponibles esas funciones futuras.

Los resultados finales de análisis, pruebas, paquetes y límites se conservan en la nota 21 de la bóveda.
