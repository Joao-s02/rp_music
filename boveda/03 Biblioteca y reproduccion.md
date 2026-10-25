---
tipo: requisitos
estado: confirmado
actualizado: 2026-10-24
---
# Biblioteca y reproduccion

## Archivos y organización

- El usuario selecciona **una sola carpeta raíz**. Puede contener subcarpetas organizadas libremente. No confundir varias ubicaciones posibles de almacenamiento con múltiples raíces simultáneas.
- Biblioteca objetivo: cientos y miles de canciones.
- Vistas base: canciones, álbumes, artistas y carpetas. La aclaración de la última ronda incorpora álbumes y artistas a la base.
- Géneros y búsquedas o filtros más detallados se consideran ampliaciones para extensiones.
- Formatos solicitados: MP3, FLAC, M4A, MP4, WAV y OPUS. Debe comprobarse reproducción de audio por plataforma y códec; MP4 es un contenedor y no implica un reproductor de vídeo.

## Funciones base confirmadas

- Biblioteca, búsqueda, listas de reproducción y favoritos.
- Cola, reproducción aleatoria y repetición.
- Carátulas y edición de metadatos.
- Reproducir, pausar, cambiar canción y navegar por su posición como controles habituales.
- Letras integradas en archivos y letras en archivos externos; incluir soporte de letras sincronizadas cuando estén disponibles según la aceptación de esa pregunta.
- Al editar metadatos, permitir elegir entre modificar el archivo musical o guardar el cambio solo en la biblioteca.

## Reproducción e integración con el sistema

El usuario aceptó el conjunto de funciones preguntado:

- Reproducción con pantalla apagada y en segundo plano.
- Controles en notificaciones y pantalla de bloqueo de Android.
- Teclas multimedia de Windows.
- Recordar la cola y continuar desde donde se cerró.
- Reproducción sin pausas entre canciones y fundido entre pistas.
- En Windows, opción para cerrar la aplicación o mantener reproducción en la bandeja al cerrar la ventana.

La prioridad y compatibilidad de gapless y fundido deben validarse; están dentro de la visión solicitada, pero no se ha definido que toda ella deba entregarse en el primer incremento. No se ha elegido si restaurar posición también debe iniciar reproducción automáticamente.

## Fuera del núcleo

- Ecualizador: extensión.
- Buscar letras faltantes por internet: extensión.
- Cuentas e integraciones de servicios: extensiones opcionales.

## Pendientes de comportamiento

Frecuencia de escaneo, detección automática de cambios, biblioteca cacheada, agrupación de etiquetas incompletas y cambios de carpeta raíz todavía requieren decisión o propuesta explícita. Se sugirió mostrar lo guardado y actualizar en segundo plano, pero la respuesta confirmó la raíz única sin aprobar expresamente todo ese comportamiento.

Relaciones: [[02 Vision y decisiones]], [[04 Extensiones]], [[05 Rendimiento]], [[07 Preguntas e investigacion]].

## Actualización confirmada e implementación local — 2026-10-25

El usuario pidió eliminar listas completas. Implementado con confirmación y persistencia, conservando archivos, favoritos, catálogo y otras listas; pruebas aprobadas. Rediseño e investigación de notificaciones posteriores a 0.2.2 en [[16 Pruebas 0.2.2 y rediseno 0.2.3]]. La comprobación en emulador no sustituye al retesteo físico.
