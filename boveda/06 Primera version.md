---
tipo: plan-inicial
estado: historico-con-proyeccion-pendiente
actualizado: 2026-10-26
---
# Primera version

## Alcance de esta nota

Enfoque inicial acordado. La primera versión publicable ya se entregó en 0.2.0 y hubo releases posteriores; no es una planificación todavía por empezar. Actualidad: [[10 Estado del repositorio]]. Primera reconstrucción: [[11 Reconstruccion - primera base]].

## Enfoque y secuencia original

Reproductor local sólido y extensión pequeña que demuestre pantalla/lógica antes de integraciones completas. Bóveda primero y conservación de Git/contexto durante reconstrucción. Web opcional.

Secuencia propuesta: documentar, inventariar alfa, reconstruir base Flutter, persistir biblioteca/audio, probar extensión, completar funciones avanzadas, medir y ampliar servicios. Era propuesta de etapas, no calendario ni renuncia a requisitos finales.

## Avance respecto a ese plan

- Base local Android/Windows y distribución: entregadas por incrementos.
- Personalización declarativa y después programas Dart/API 2 con permisos/recuperación: publicados.
- Primera fuente experimental de búsqueda/audio: implementada priorizando Android, con límites.
- Letras, edición de etiquetas, gapless/fundido, ecualizador, mayor libertad visual y mediciones: pendientes según [[03 Biblioteca y reproduccion]], [[04 Extensiones]], [[07 Preguntas e investigacion]].

Se proponía validar raíz/subcarpetas, reproducción/navegación sin bloqueos observados, uso local sin cuenta/red e instalación/desactivación de extensión sin recompilar. Cada entrega registra qué se comprobó; no es garantía universal ni validación de todos los códecs.
