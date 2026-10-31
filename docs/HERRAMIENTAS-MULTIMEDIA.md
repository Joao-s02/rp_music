# Herramientas multimedia opcionales — protocolo 1

Desarrollo local0.3.17+26. La app mantiene reproducción y descarga; editores audiovisuales se instalan por separado. RP Edits reside en su repositorio independiente por petición del usuario. No se incorpora su motor a APK/ZIP del reproductor.

Desde Letras, Crear un edit consulta complementos Android con acción `com.rpmusic.OPEN_MEDIA_PROJECT`, MIME `application/vnd.rpmusic.project+json`, metadata `com.rpmusic.protocol=1` y firma coincidente con RP Music. La selección del usuario inicia el intercambio. No se ejecutan componentes arbitrarios ni se descargan APK automáticamente.

La solicitud contiene protocolo, título, artista, letra original y URI content del audio; portada opcional. JSON y recursos se autorizan mediante ClipData y acceso de solo lectura. FileProvider expone únicamente cache/media_tools; el receptor copia activos a su almacenamiento privado y no escribe originales. Pistas remotas requieren descargarse antes. Recursos temporales del host caducan tras24h; el borrador del editor no depende de ellos después de importar.

Contrato Dart común: MediaToolRequest/MediaToolPlatform. Windows compila la misma interfaz y muestra que el editor aún no está disponible; su adaptación de lanzamiento está pendiente del port. No presentar compatibilidad ejecutable Windows como implementada.

Verificación intermedia: análisis limpio,165 pruebas/una omitida con DLL QuickJS del build Windows en PATH. Compilación Android debug de integración realizada; conexión nativa completa requiere misma firma en ambos APK. Sin publicación ni prueba física nueva.

Cierre local: análisis final limpio, Android0.3.17+26 normal release firmado/verificado en dist/editor-candidate; editor0.1.0 firmado en su repositorio separado. Ambos conservan identidad compatible; apertura real entre estos APK finales pendiente de teléfono. Imagen API37 descartada para completar pruebas por imponer4GiB RAM pese al límite solicitado. Compilaciones en serie y límites moderados. No hay release nueva publicada ni compilación Windows nueva.

Validación física posterior: A34/Android16, actualización del host por ADB sin desinstalar y apertura del editor desde Letras comprobadas. Nueve pruebas instrumentales del editor; APK release firmado exporta y guarda un fragmento real de5s con audio, texto y marca desactivada. Verificación del MP4:150cuadros/30fps,5026ms y presentación720×1280 con rotación. Otros equipos/Android y Windows pendientes. Sin nueva release publicada. El apartado de cierre previo conserva el estado anterior a disponer de teléfono.
