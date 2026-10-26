# RP Music 0.3.2-alpha.1

Detalle de álbum renovado, correcciones visuales del reproductor y más posibilidades para las extensiones de fuentes de música en la nube.

- Álbum con carátula, información disponible, reproducir/aleatorio, guardar como lista y pestañas de pistas/cola; canción activa destacada.
- El buscador de fuentes respeta la barra de navegación del sistema. El reproductor ampliado muestra el nombre del servicio correspondiente.
- Las extensiones compatibles pueden añadir un acceso a la navegación mediante permisos y un manifiesto; motor HTTP genérico y catálogo que selecciona versiones compatibles.

## Descargas

- Android universal/global: RP-Music-0.3.2-android.apk.
- Android de 64 bits: RP-Music-0.3.2-android-arm64.apk.
- Windows x64: extraer todo RP-Music-0.3.2-windows-x64.zip.
- Adjuntos: USO.md, PRUEBAS-0.3.2.md, CAMBIOS-0.3.2.md y SHA256SUMS.txt.

Actualiza Android encima de la versión anterior para conservar datos; mantiene la firma de distribución de desarrollo. Windows necesita el ejecutable junto con sus DLL y data.

## Extensiones

Se distribuyen exclusivamente en [rp-music-extensions](https://github.com/Joao-s02/rp-music-extensions), separadas de la app. Actualiza el paquete inicial de fuente a 0.2.0 y acepta sus nuevos permisos para usar su acceso de navegación. La entrada base 0.1.0 se conserva para usuarios de RP Music 0.3.1; el nuevo catálogo selecciona la variante compatible. La fuente inicial sigue priorizando Android; Windows recibe mejoras locales/visuales. Listas, favoritos, historial y cuentas de fuentes en línea continúan pendientes.

## Validación

Suite completa inicial de 75 pruebas, comprobación adicional de navegación y análisis sin incidencias. Prueba nativa Android con paquete externo: búsqueda, dos canciones, pausa/seek, observación de continuidad con HOME/pantalla apagada y retirada de permisos aprobadas. APK normal instalado/abierto y Windows iniciado; ZIP y firmas verificados. Falta retesteo físico y escucha prolongada en distintas redes. Consulta PRUEBAS para el recorrido recomendado.
