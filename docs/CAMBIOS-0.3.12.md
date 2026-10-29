# Cambios0.3.12+21

- Letras sincronizadas con tiempos válidos tienen prioridad entre interpretaciones compatibles; se intenta búsqueda alternativa si solo se recibe texto. Se conserva el álbum elegido y se corrige la comparación de duración numérica. No se inventan tiempos.
- Letras vivas y vista Escena: tipografía grande, transiciones, fondo con movimiento suave y controles ocultables para grabar pantalla. EnhancedLRC resalta palabras con marcas explícitas. LRC normal se anima por línea.
- Sincronización recuperada en caché privada tiene prioridad sobre texto incrustado antiguo; consulta posterior no degrada una letra sincronizada por texto. Archivos originales sin modificar.
- Reproductor ampliado fijo, sin desplazamiento vertical: carátula flexible y sin borde cian, indicador de origen solo arriba y volumen detrás de botón junto a Detalles/Letras/Cola.
- Cola abre centrada en pista actual y conserva acceso a anteriores/siguientes. Indicador decorativo animado mientras reproduce, detenido en pausa/movimiento reducido; no es un ecualizador.
- Catálogo externo: YouTube Android/Windows0.5.1, Explorador Android/Windows0.2.1 y Letras locales0.1.1, app mínima0.3.12. API2 y variantes anteriores conservadas.

155 pruebas aprobadas, una de red optativa omitida, análisis limpio. Cuatro tamaños, barras del sistema y texto hasta2× comprobados. Descarga pública Windows con55 líneas LRC incrustadas, audio reproducido, seek solicitado a marca y bloques de audio idénticos tras etiquetar. Capturas demostrativas de widgets Flutter; no prueba de dispositivo físico.

Pendientes: Android físico, escucha prolongada y valoración visual del usuario. Letras dependen de cobertura del proveedor; texto plano se identifica si no hay LRC. Grabación mediante grabador del dispositivo, sin exportador de vídeo integrado. La latencia API3 Android sigue como asunto separado. No se reescribe música descargada anteriormente; las mejoras de letras se guardan en la app.
