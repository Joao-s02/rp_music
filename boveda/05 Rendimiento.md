---
tipo: requisitos-y-evidencia
estado: pendiente-de-medicion-formal
actualizado: 2026-10-29
---
# Rendimiento

## Publicado en 0.3.18 — carga de raíz Android

Usuario informa regresión percibida con 500/900 canciones. Se reduce trabajo evitable: descubrimiento antes de completar toda la raíz, etiquetas cacheadas desde el primer lote, omisión de lecturas de metadatos válidos y lotes de actualización más amplios. Pruebas sintéticas de integridad/progreso/caché no equivalen a medir segundos en Android. Comparación física de primera pista visible/fin con caché fría/caliente pendiente. [[47 Navegacion busquedas y escaneo 0.3.18]].


Informe0.3.9: usuario confirma nuevas extensiones funcionales en Android, pero percibe3–6s al buscar/abrir contenido y cambiar secciones API3; prioriza conservar YouTube API2. Inspección y ensayo sin red Windows no reproducen esa demora y no sustituyen medición Android. Causas por operación y mejoras todavía propuestas en [[38 Latencia de extensiones API 3]].

## Prioridad confirmada

Fluidez al abrir biblioteca, reproducir y cambiar canciones, para cientos/miles de archivos. La base concentra optimización; extensiones pueden consumir más recursos voluntariamente. No hay presupuestos acordados de RAM, batería, arranque, latencia o fotogramas.

## Implementado para reducir bloqueos

Catálogo persistente sin esperar escaneo nuevo, escaneo manual/progresivo con caché fuera del dibujo, listas/carátulas bajo demanda. Compilación/ejecución de programas en isolates con límites de tiempo/entrada/salida. Escrituras JSON serializadas con respaldo.

Actualizador fuera del arranque bloqueante y descargas por fragmentos. Diagnóstico multimedia acotado; parches foreground/wake lock de audio_service para pausas/transiciones/liberación. [[31 Arquitectura vigente]], [[18 Pruebas 0.2.3 y correcciones 0.2.4]]. Son medidas implementadas, no benchmarks ni garantía de batería universal.

## Evidencia disponible

| Fuente | Resultado y alcance |
| --- | --- |
| Primeros informes físicos | Buena fluidez general, escaneo de 1–2 minutos en móviles; posteriores mejoras de carga informadas. Equipos/condiciones en [[13 Pruebas reales y correcciones 0.2.1]]. |
| Usuario con 0.3.1 | Buscador 10/10, audio rápido y sin bugs/lag observados en su prueba. No es benchmark ni describe todos los temas/redes/equipos. [[26 Release 0.3.1]]. |
| 0.3.3 nativo | Un ensayo no alcanzó el progreso esperado en espera fija inicial; segundo recorrido aprobado. Conservar ese resultado sin prometer latencia. [[29 Pruebas 0.3.2 y mejoras 0.3.3]]. |

## Medición pendiente

Acordar biblioteca/equipos reproducibles, formatos/cantidad, caché fría/caliente, modo release, red y extensiones activas. Medir inicio/escaneo/primer audio/saltos/memoria/batería y comparar base sin extensiones con escenarios activos.

Hay equipos informados, pero no matriz de benchmark ni presupuestos aceptados. Panel de recursos por extensión pendiente; tiempo/fallos no equivalen a RAM/CPU/batería atribuida. No sumar pruebas repetidas como cobertura nueva. [[07 Preguntas e investigacion]].

## Desarrollo0.3.16

Instrumentación de motor/registro, red y acción API3, caché pública optativa de60s y descargas de álbum a disco implementadas localmente. Sin benchmark Android ni presupuestos acordados; resultados y límites en [[45 Portadas artistas navegacion y descargas 0.3.16]].
