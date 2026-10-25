# audio_service 0.18.19 — copia local con corrección Android

Origen: paquete audio_service 0.18.19 de pub.dev, licencia MIT conservada. Se copian lib, android y darwin más metadatos y licencia; los ejemplos y pruebas originales no son dependencias de RP Music.

Corrección de cierre respecto al paquete de origen: AudioService.stop() invoca exitForegroundState() antes de desactivar la sesión y stopSelf(). Esto libera el estado foreground y wake lock incluso si el servicio continúa enlazado a la actividad. Con androidStopForegroundOnPause=false, la implementación original dejaba la notificación foreground después de Detener en la prueba nativa de RP Music.

La copia se selecciona explícitamente mediante dependency_overrides. No se modifica la caché global de Pub. Al actualizar la dependencia, revisar si upstream ya resuelve este caso y repetir la prueba de pausa/reanudación/cambio en segundo plano y detención antes de retirar el parche. Los demás archivos del paquete se mantienen como dependencia externa; se excluyen del análisis del código propio, conservando su licencia.

Además, exitPlayingState() libera el wake lock al pausar aunque se conserve foreground; enterPlayingState() ya lo recupera al reanudar. Se evita mantener la CPU despierta innecesariamente durante una pausa sin volver a iniciar el servicio desde segundo plano.
