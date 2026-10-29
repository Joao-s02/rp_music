# Pruebas0.3.12

## Ya comprobado

155 pruebas aprobadas y una de red optativa omitida en ejecución conjunta; análisis lib/test/integration_test/tools sin incidencias. No sumar repeticiones dirigidas como casos distintos. Cinco paquetes API2 reales verificados en dart_eval: prioridad LRC, búsqueda alternativa, conservación ante fallo, duración incompatible rechazada e identidad de álbum preservada.

Prueba nativa Windows de descarga/etiquetado:55 líneas con tiempos leídas desde archivo M4A resultante; reproducción con avance superior a2s, solicitud de seek a marca, bloques mdat comparados por SHA256 antes/después. Avisos conocidos no fatales de osc/caché nativa presentes; no ocultarlos como ausencia total de logs. No se distribuye audio de prueba. Originales del usuario intactos.

Pantalla fija y gesto diagonal comprobados a320×568,360×640,800×360 y1280×720, con áreas seguras y texto1.6/2×. Volumen oculto y desplegable, origen sin duplicar, cola centrada78/100 con anterior/siguiente visibles e indicador que se detiene al pausar. LRC/EnhancedLRC, caché privada sobre texto incrustado antiguo, seguimiento/retroceso/cambio de pista y Escena/controles ocultables comprobados. Capturas revisadas visualmente, no equivalen a Android físico.

## Recorridos del usuario

1. Actualizar Android sin desinstalar o extraer Windows completo en carpeta nueva. Conservar datos, biblioteca y extensiones. Actualizar los cinco paquetes correspondientes desde catálogo.
2. Descargar canción con LRC disponible, abrir Letras, comprobar seguimiento y tocar una línea para avanzar. Repetir con archivo que antes mostraba texto: activar Letras locales0.1.1 y buscar sincronizada; volver sin red para comprobar caché.
3. Probar Escena, transiciones y ocultar controles tocando fondo; grabar con grabador del teléfono. Pausar/avanzar/cambiar canción. Probar movimiento reducido.
4. Arrastrar verticalmente la carátula del reproductor: la pantalla no debe moverse. Deslizar lateralmente con ligera inclinación debe cambiar canción; el deslizador de tiempo conserva su gesto. Probar vertical/horizontal y texto ampliado.
5. Volumen aparece al pulsar su botón y conserva porcentaje/silencio; al cerrar vuelve la pantalla quieta. Solo queda el indicador superior de origen y la carátula no lleva marco cian.
6. Abrir Cola lejos de la primera pista: actual centrada con anteriores/siguientes accesibles, indicador vivo al reproducir y quieto en pausa. Desplazarse y elegir otra canción.
7. Repetir audio local/remoto, notificación/widget, bandeja y escucha prolongada. Reportar pasos/plataforma/código sin rutas privadas ni credenciales.

Android físico no conectado durante esta validación; comprobación física y juicio visual pendientes. Disponibilidad de letras/canciones depende del proveedor/red. No se fabrican tiempos por palabra para LRC que no los ofrece.
