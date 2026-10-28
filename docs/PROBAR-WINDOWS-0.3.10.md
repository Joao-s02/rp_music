# Windows0.3.10 — audio y YouTube

App0.3.10+19 publicada. [Descargar la release completa](https://github.com/Joao-s02/rp_music/releases/tag/v0.3.10-alpha.1). Requiere esta versión para usar las fuentes YouTube API2 Windows.

## Actualizar la app

Extraer el ZIP completo en una carpeta nueva, cerrar la app anterior desde la bandeja y abrir rp_music.exe de la nueva. Conservar DLL/data/licencias junto al ejecutable. Incluye libmpv-2.dll; no copiar solo el EXE ni borrar el soporte privado de la app. No desinstalar ni borrar biblioteca/listas/extensiones al actualizar.

Solo cambia motor de Windows; Android conserva el motor previo y parches audio_service. No instala paquetes de códecs ni cambia ajustes del sistema. Archivos musicales originales intactos; no es necesario convertirlos o reescribir sus etiquetas.

## YouTube en Windows

Los candidatos están exclusivamente en rp-music-extensions/previews/0.3.10; **disponibles en el catálogo público** y no vienen dentro del ZIP/APK:

- youtube-music-windows.rpmx — YouTube Windows0.4.1, API2, requiere app0.3.10.
- youtube-explorer-windows.rpmx — YouTube Explorador Windows0.1.0, API2, requiere app0.3.10.
- radio-internet.rpmx — Radio por internet0.1.1, API3, requiere app0.3.9 o posterior.

Consultar el repositorio desde Extensiones → Explorar repositorio e instalar, revisar permisos y activar. Para los dos YouTube API2, elegir quién controla **Fuente** (Usar esta fuente) y abrir YT o YT Explorar. Son identidades Windows independientes; las extensiones Android originales se conservan. No se migra YouTube a JavaScript.

También se probó audio real del Explorador musical JS0.1.0 publicado con el motor nuevo. Puede conservarse instalado; volver a seleccionar canción tras reiniciar para obtener un enlace nuevo. No elegir una pantalla JS como propietaria de Fuente.

YouTube sigue siendo una integración experimental sin cuenta; algunas canciones, regiones o redes pueden fallar. Audio real y controles ya comprobados en los casos documentados, no solamente búsqueda/bytes/URL. No hay cuenta/sincronización nueva ni garantía universal.

## Radio y errores

Radio0.1.1 renueva el enlace y registra el clic con una sola consulta, manteniendo HTTPS/UUID/validación del servidor público. Conserva favoritas privadas del mismo ID; no borres la extensión ni sus datos. El directorio y la emisora siguen influyendo en la demora; no se garantiza un plazo para toda radio.

En Ajustes → Diagnóstico multimedia ahora aparecen el último error nativo de audio y tiempos de resolución/carga, con URLs redactadas. El mensaje de carga ya no acusa automáticamente al formato. Un archivo realmente inválido debe informar y permitir seleccionar otro; cancelar/cambiar pista debe liberar la carga pendiente.

## Prueba recomendada

1. Confirmar versión0.3.10; reproducir M4A/OPUS que fallaban y MP3/FLAC/MP4 de control. Probar pausa/seek/siguiente/anterior y cierre a bandeja.
2. Instalar YouTube Windows API2 candidato, buscar y reproducir dos canciones; cambiar a Explorador Windows y probar álbum/lista. Conservar controles y parada por desactivación.
3. Repetir la radio que tardaba~30s; anotar emisora/red/tiempo hasta sonido. Conservar diagnóstico si la demora persiste.
4. Verificar favoritos/listas/letras/carpeta conservados. No convertir ni borrar archivos para estas pruebas.

Evidencia y límites actuales: [bóveda](../boveda/39%20Audio%20Windows%20M4A%20OPUS%20y%20YouTube.md). Android físico y escucha prolongada en varios equipos pendientes.
