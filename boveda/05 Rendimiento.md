---
tipo: requisitos-y-propuestas
estado: pendiente-de-medicion
actualizado: 2026-10-24
---
# Rendimiento

## Prioridad confirmada

La interfaz debe sentirse fluida. El usuario considera especialmente molesto esperar muchos segundos a que aparezca la lista de música, sufrir bloqueos al reproducir o notar trabas al cambiar canciones. Biblioteca esperada: cientos y miles de archivos. La optimización estricta se concentra en la aplicación base; las extensiones pueden aumentar el consumo de manera visible y voluntaria.

No hay cifras acordadas de RAM, batería, tamaño, tiempo de arranque, latencia o fotogramas. Tampoco hay dispositivos de referencia elegidos.

## Propuestas para validar, no arquitectura aprobada

- Guardar un índice local para mostrar la biblioteca sin esperar un escaneo completo.
- Actualizar cambios de archivos fuera del trabajo que dibuja la interfaz.
- Cargar listas y carátulas según lo visible; limitar sus cachés.
- Medir por separado inicio, consulta de biblioteca, inicio de audio y cambio de pista.
- Comparar la base sin extensiones con escenarios de extensiones activas.
- Evitar que un escaneo o extensión interrumpa la reproducción.

## Plan de evidencia pendiente

El usuario ya probó tres celulares y una PC: informó buena fluidez general, pero escaneo de uno a dos minutos en celulares. La corrección local incorpora descubrimiento progresivo, MediaStore cuando procede y huellas de archivos; todavía falta medir la mejora en esos equipos. Véase [[13 Pruebas reales y correcciones 0.2.1]].

Elegir Android y Windows de referencia, una biblioteca reproducible y modo de compilación adecuado. Registrar hardware, cantidad y formatos de archivos, condiciones de caché, extensiones activas y resultados. Acordar presupuestos después de medir una primera prueba, sin inventar garantías.

El panel de consumo por extensión es un requisito de [[04 Extensiones]]; su precisión depende del mecanismo elegido. Ver [[07 Preguntas e investigacion]] y [[06 Primera version]].
