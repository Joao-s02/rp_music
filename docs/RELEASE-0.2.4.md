## Cambios

- **Actualizaciones opcionales:** consulta en segundo plano como máximo una vez al día, sin bloquear el uso local. Ajustes permite desactivar la consulta, buscar manualmente e incluir versiones de prueba.
- **Android:** descarga del APK compatible con progreso y cancelación, verificación SHA-256 y comprobación de paquete, versión y certificado antes de abrir la instalación. Android pide las autorizaciones necesarias; no instala en silencio.
- **Búsqueda móvil:** lupa desplegable, foco estable al abrir el teclado y limpieza del filtro al cerrar la búsqueda.
- **Reproducción en segundo plano:** conserva la prioridad del servicio entre pausas/cambios para evitar reinicios prohibidos. Pausar libera el bloqueo de CPU y Detener libera el servicio y su notificación.
- **Diagnóstico:** texto seleccionable, copiar, exportar e importar logs; historial acotado de eventos de la sesión.
- **Biblioteca vacía:** nueva composición según la referencia, contador real, botón Elegir carpeta y sugerencias Music/SD.

## Descargar e instalar

- **Galaxy A34 / Poco X6 y otros ARM64:** RP-Music-0.2.4-android-arm64.apk.
- **Android universal:** RP-Music-0.2.4-android.apk.
- **Windows x64:** extraer todo RP-Music-0.2.4-windows-x64.zip y abrir rp_music.exe junto a sus DLL y data.
- Se adjuntan USO.md, PRUEBAS-0.2.4.md, descubrir.json y SHA256SUMS.txt.

**Esta primera versión con actualizador se instala manualmente sobre la anterior, sin desinstalar para conservar los datos.** Desde 0.2.4 se podrán detectar versiones posteriores. Windows consulta y abre la página de descarga; no sustituye automáticamente el programa abierto.

Ambos APK son 0.2.4+6 y mantienen el certificado anterior. La firma sigue siendo de desarrollo.

## Verificación y pendientes

42 pruebas automatizadas aprobadas, análisis estático limpio y paquetes release verificados. Pruebas en emulador Android API 37: búsqueda con teclado/foco estables, cambio automático en segundo plano, pausa/reanudación, detención del servicio y validación de un APK real antes de pedir autorización.

**Pendiente retesteo prolongado en Galaxy A34 5G Android 16 y Poco X6**, y una actualización completa entre releases públicas posteriores con confirmación del instalador y comprobación de datos conservados. Si vuelve a cortarse la música, copiar/exportar el diagnóstico antes de cerrar la app.

Siguen pendientes los informes anteriores de instalación Tecno y sonido de cierre Windows. Es una versión preliminar de pruebas, no estable.
