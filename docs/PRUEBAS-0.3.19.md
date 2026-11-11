# Pruebas de RP Music 0.3.19

## Verificación realizada

Análisis sin incidencias. La suite enfocada aprobó 47 pruebas, entre ellas el regreso desde listas a 360 y 1280 px, la selección de varias listas, la creación y los detalles, la navegación al desplazar Canciones, las marcas de voz en LRC y los cambios rápidos con motor simulado. La compilación Android de depuración también terminó correctamente.

La suite completa aprobó 185 pruebas, sin fallos y con 1 omitida. Android universal y ARM64 se compilaron y firmaron con las mismas identidades que 0.3.18 para sus rangos de API. Se verificaron versión, arquitecturas y ausencia del permiso de instalación directa. El ZIP Windows x64 se verificó con 32 archivos, incluidos DLL, datos, guías y licencias.

## Pruebas físicas pendientes

1. En Android, instala encima de 0.3.18 y comprueba que conserva la biblioteca, favoritos, listas y extensiones. Repite al actualizar de universal a ARM64 en un dispositivo compatible. Anota cualquier aviso de Play Protect.
2. Abre una lista y pulsa Atrás. Importa una portada horizontal y otra vertical y comprueba que ambas conservan sus proporciones. Desde Canciones añade una pista a dos listas existentes y crea una nueva en el mismo paso.
3. Recorre rápido una biblioteca grande y detente. Comprueba que aparecen las portadas, que el minirreproductor sigue accesible y que la barra inferior reaparece al cambiar el sentido del desplazamiento.
4. Abre Letras con un LRC que tenga `v1:` y `v2:`, incluidas palabras sincronizadas. Comprueba alineación, texto y tiempos. Repite con una pista sin carátula.
5. Descarga una canción y un álbum desde la extensión de YouTube. Comprueba que comparten destino tras reiniciar. Cámbialo desde Ajustes y verifica que la siguiente descarga va a la carpeta nueva.
6. En el Galaxy A34, pulsa Siguiente o Anterior varias veces seguidas y comprueba que la última pista suena. En Android 14 o posterior, conecta audífonos y usa el selector de salida. Comprueba el nombre, el icono y que el audio cambia de dispositivo.
7. En Windows, extrae el ZIP completo y verifica arranque, reproducción local, biblioteca, listas, descargas y cierre a bandeja.

La instalación, el cambio de salida, el rendimiento y Play Protect requieren pruebas en un teléfono físico.
