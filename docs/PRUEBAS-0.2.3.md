# RP Music 0.2.3 — prueba local

Nueva interfaz basada en las pantallas Stitch, eliminación de listas y correcciones de integración multimedia. Distribución preliminar: [v0.2.3-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.2.3-alpha.1).

## Instalar

Actualiza sobre la versión anterior para conservar biblioteca, listas y favoritos. Ambos APK tienen el mismo identificador, certificado y código de versión 5. La firma sigue siendo de desarrollo.

- `RP-Music-0.2.3-android.apk`: universal.
- `RP-Music-0.2.3-android-arm64.apk`: ARM64, más pequeño, apropiado para Galaxy A34 y Poco X6.
- Windows: extrae todo el ZIP y abre `rp_music.exe`; conserva sus DLL y la carpeta data.

## Galaxy A34 y Poco X6

1. Abre una canción y comprueba que suena. Baja el panel de notificaciones y comprueba título, pausa y anterior/siguiente. En sistemas recientes, el control puede estar en el área multimedia de ajustes rápidos.
2. Pausa y reanuda desde el panel. Cambia de canción; el título y el estado deben cambiar.
3. Pulsa Inicio y apaga la pantalla; comprueba reproducción y controles en la pantalla bloqueada. Desbloquea y vuelve a la app.
4. Si no aparecen, abre **Ajustes → Diagnóstico multimedia** mientras suena una canción. Anota reproducción, estado del audio, número de notificaciones multimedia, sesión presente/no detectada, estado del canal y último error si existe. Indica también modelo y versión Android/One UI/HyperOS.
5. Si el canal figura bloqueado, revísalo desde **Abrir ajustes de notificaciones**. El permiso concedido por sí solo no demuestra que el servicio se haya publicado.

## Interfaz y listas

- Recorre Canciones, Álbumes, Artistas y Carpetas. Los álbumes muestran carátulas reales cuando existen; no se descargan imágenes de muestra.
- Pulsa un álbum para ver sus canciones o su botón de reproducción para iniciar el álbum.
- En móvil, pulsa título/carátula del minirreproductor para abrir la vista completa. Allí están posición, volumen, cola, aleatorio y repetición.
- Crea una lista, añade canciones y pulsa su papelera. **Cancelar** conserva la lista; **Eliminar** la borra sin borrar canciones. También puedes eliminar desde su detalle. Cierra y vuelve a abrir para comprobar persistencia.
- Comprueba el tamaño de texto habitual y aumentado. Búsqueda, teclado y pantallas vacías deben poder usarse sin desbordarse.
- Windows conserva volumen, bandeja y cierre configurables; comprueba reproducción y navegación con el nuevo diseño.

## Evidencia y límites

La comparación release reprodujo cero notificaciones y un error de acción multimedia sin icono cuando se recortan los iconos del servicio. Conservándolos, la sonda publica una notificación con sesión válida, sin errores, y mantiene controles al pausar/reanudar.

Las pruebas locales incluyen eliminación persistida, protección de archivos/favoritos/otras listas, cancelación, estado multimedia y diseños a 360/1280 px con texto 130 %. La sonda Android release se comprueba en un emulador API 37. Esta evidencia no sustituye la comprobación física en Samsung/Xiaomi ni resuelve por sí sola el problema de instalación informado previamente en Tecno.

Las funciones DSP, bit-perfect, DAC exclusivo, ecualizador, letras, temporizador e historial ilustradas en el diseño no se presentan como implementadas.
