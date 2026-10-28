# Cambios 0.3.11+20

- Gesto horizontal en carátula y minirreproductor: izquierda siguiente, derecha anterior; conserva controles de avance/volumen.
- Android: widgets compacto, horizontal y carátula, con mínimos de redimensionado110×48dp y controles adaptables. El launcher determina cuadrícula y pasos de tamaño.
- Listas y álbumes del Explorador con portada grande, nombre, información y acciones.
- Descargas respetan álbum seleccionado; las letras no eligen edición. Álbum completo en cola secuencial, carpeta única, progreso, cancelación y motivos por pista fallida. Portada compartida, artista de álbum y numeración coherentes; no sobrescribe originales.
- Biblioteca agrupa por artista del álbum y lee numeración. La próxima actualización manual relee caché antigua una vez sin modificar música.
- Fotos de artistas mediante fuente autorizada, coincidencia de nombre y caché privada offline64MiB.
- Catálogo externo: YouTube Android/Windows0.5.0 y Explorador Android/Windows0.2.0, app mínima0.3.11, API2 conservada. Requieren revisión del nuevo permiso library.read. Variantes anteriores preservadas.

147 pruebas aprobadas/una de red optativa omitida, análisis limpio. Álbum público de seis canciones exportado en Windows con etiquetas, numeración y portadas iguales; foto guardada y abierta offline. Binarios normales Android/Windows tras integración; licencias Windows incluidas. Confirmación del usuario de audio/descarga YouTube y M4A/OPUS corresponde a0.3.10.

Pendientes: Android físico para launcher/widgets/SAF, escucha prolongada y cobertura de redes/canciones/retratos. La cola necesita app abierta; no persiste descargas pendientes al cerrarla. No repara etiquetas de archivos anteriores. Latencia AndroidAPI3 de3–6s sigue pendiente. Sin cuentas/sincronización nuevas ni migración YouTube a JavaScript.
