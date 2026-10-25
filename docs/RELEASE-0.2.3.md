## Cambios

- Nueva interfaz Nocturnal Pulse para Android y Windows, basada en el diseño aportado: tema oscuro cian/violeta, tipografías incluidas sin conexión, álbumes con carátulas, minirreproductor móvil y reproductor ampliado.
- Eliminar listas desde su fila o detalle, con confirmación y persistencia. Las canciones y los favoritos se conservan.
- Corrección de controles multimedia Android: el optimizador release eliminaba iconos necesarios para publicar la sesión. Se conservan y se añade una comprobación automática del APK.
- Estado multimedia con cola, índice y duración real; diagnóstico del servicio en Ajustes.
- Nuevo icono RP Music aprobado, integrado en Android y Windows.

## Descargas

- **Android universal:** RP-Music-0.2.3-android.apk.
- **Android ARM64:** RP-Music-0.2.3-android-arm64.apk, más pequeño y apropiado para Galaxy A34 y Poco X6.
- **Windows x64:** extraer todo RP-Music-0.2.3-windows-x64.zip y abrir rp_music.exe.
- Guías USO.md y PRUEBAS-0.2.3.md, ejemplo descubrir.json y SHA256SUMS.txt adjuntos.

Actualiza sobre la versión anterior para conservar biblioteca, listas y favoritos. Ambos APK son 0.2.3+5 y mantienen el certificado anterior. La firma Android sigue siendo de desarrollo.

## Verificación y pendientes

30 pruebas automatizadas aprobadas, análisis estático limpio y compilaciones release de ambas plataformas verificadas. Comparación en emulador Android API 37: con los iconos recortados no aparece notificación y falla una acción multimedia; conservándolos, la notificación y sesión funcionan al reproducir, pausar y reanudar sin errores del servicio.

**Falta retestear físicamente en Galaxy A34 y Poco X6**, incluido segundo plano y pantalla bloqueada. El problema anterior de instalación en Tecno y el cierre de audio subjetivo en Windows siguen pendientes. El nuevo diseño no implica soporte de DSP, DAC exclusivo, ecualizador, letras o temporizador.

Esta es una versión preliminar de pruebas, no estable.
