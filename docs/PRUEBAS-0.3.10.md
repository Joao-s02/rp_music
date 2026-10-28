# Pruebas 0.3.10

## Ya comprobado

142 pruebas automáticas aprobadas (132 app y diez externas), una red optativa omitida; análisis limpio. Cinco casos nativos Windows: doce variantes de formatos, fallo/recuperación, dos fuentes API 2, pantallas JS/audio remoto y controles/bandeja. Son casos distintos, sin sumar repeticiones. Cinco M4A originales se reprodujeron intactos; OPUS/MP3/FLAC/WAV sintéticos y MP4 control avanzaron.

YouTube API 2: búsquedas de 20 resultados, dos canciones, pausa, avance a 10 segundos, siguiente/anterior y parada al desactivar. Explorador JS: audio real y continuación 100+100. Radio 0.1.1: reproducción AAC, pausa/reanudación y revocación; unos cinco segundos hasta inicio en estación/red ensayadas. Hubo avisos nativos no fatales de osc/caché/TLS al cerrar, sin errores de reproducción en los casos aprobados.

## Comprobar tras instalar

1. Android: actualizar encima de la versión anterior; comprobar datos, biblioteca, notificación/widget y audio local. No hubo prueba física Android nueva.
2. Windows: extraer ZIP completo en carpeta nueva. Probar los mismos M4A y OPUS que fallaban y MP3/FLAC/MP4 que funcionaban. Comprobar progreso, pausa, avance, volumen, siguiente/anterior, bandeja y cierre.
3. Instalar fuentes Windows desde catálogo, aceptar permisos y seleccionar Fuente. Buscar, reproducir dos canciones y abrir artistas/álbumes/listas en Explorador. Desactivar debe detener su audio.
4. Abrir Explorador musical JS, buscar/abrir páginas y escuchar. Actualizar Radio a 0.1.1, probar la misma emisora del fallo y otra, favoritas, pausa/reanudación. Anotar tiempo hasta oír audio y red usada.
5. Probar archivo no válido y después uno válido: el segundo debe poder reproducirse. Si falla, compartir código de diagnóstico, versión/formato y pasos sin rutas o datos privados.
6. Escucha prolongada, reinicio y recuperación de sesión. Verificar hashes antes de distribuir copias.

No se garantiza todo códec/emisora. La latencia Android API 3 requiere medición propia; conservar API 2 es intencional. No confundir respuesta HTTP o resolución con prueba de audio nativo.
