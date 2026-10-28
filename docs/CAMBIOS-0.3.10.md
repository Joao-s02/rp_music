# Cambios 0.3.10+19

- Windows usa just_audio_media_kit/libmpv en lugar del backend WinRT anterior. M4A reales y OPUS reproducidos; controles MP3/FLAC/MP4/WAV también comprobados. Android conserva su motor y parches audio_service.
- Diagnóstico conserva error nativo y tiempos con URLs redactadas. Cargas fallidas o interrumpidas no bloquean la siguiente canción; límite Windows de 30 segundos.
- Catálogo externo: YouTube Windows 0.4.1 y YouTube Explorador Windows 0.1.0 independientes, API 2, app mínima 0.3.10. Código de proveedores Android conservado.
- Radio por internet 0.1.1 renueva enlace y registra clic en una consulta. Radio original preservada; actualización se ofrece desde app 0.3.9.

Verificación: 142 pruebas aprobadas, una de red optativa omitida, análisis limpio y cinco casos nativos Windows. YouTube API 2 y Explorador JS reprodujeron audio real con controles/revocación. Radio ensayada inició aproximadamente en cinco segundos; no es garantía para toda red/estación ni comparación con la misma emisora del usuario.

Pendientes: Android físico en esta versión, escucha prolongada y más emisoras/equipos. La latencia Android API 3 de 3–6 segundos informada por el usuario sigue pendiente; este cambio Windows no la declara solucionada. Dependencias de audio fijadas y experimentales; licencias y procedencia nativa incluidas. No modifica música local ni releases previas.
