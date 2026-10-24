---
tipo: alcance-y-plan
estado: enfoque-aceptado-detalle-propuesto
actualizado: 2026-10-24
---
# Primera version

## Enfoque aceptado

Empezar con un reproductor local sólido y una extensión pequeña que demuestre que se pueden cambiar pantallas y añadir funciones, antes de desarrollar integraciones completas con YouTube Music y Spotify. La web es opcional.

El usuario pidió primero preparar la bóveda y luego autorizó iniciar la reconstrucción. Ya existe un primer incremento; su prueba declarativa de personalización no completa todavía el runtime ni la libertad de pantallas prevista. Ver [[11 Reconstruccion - primera base]] y [[10 Estado del repositorio]].

## Secuencia propuesta

1. Concluir la documentación y resolver las decisiones que condicionan arquitectura y extensiones.
2. Inventariar el código anterior y preparar la reconstrucción conservando Git, bóveda y contexto.
3. Crear una base Flutter mínima para Android y Windows; validar acceso a carpeta raíz y reproducción de formatos solicitados.
4. Incorporar biblioteca persistente, vistas, cola, listas, favoritos, carátulas y controles del sistema en incrementos comprobables.
5. Validar pronto una extensión instalable con cambios de pantalla y una función adicional. La prueba debe ocurrir antes de dar por cerrada la arquitectura.
6. Completar letras, edición de metadatos, restauración, bandeja y funciones de audio según capacidad comprobada.
7. Medir fluidez y consumo; comprobar recuperación y compatibilidad del sistema de extensiones.
8. Investigar e implementar, cuando resulte viable, ecualizador y conexiones a servicios.

Esta secuencia es una propuesta de trabajo, no un calendario ni una reducción de los requisitos finales. Gapless, fundido y demás funciones solicitadas siguen registradas en [[03 Biblioteca y reproduccion]].

## Condiciones de validación propuestas

- Seleccionar una raíz y reconocer archivos dentro de sus subcarpetas.
- Reproducir y cambiar pistas en ambas plataformas sin bloqueos observados en los escenarios probados.
- Navegar por canciones, álbumes, artistas y carpetas.
- Operar la base sin cuenta y sin acceso a internet.
- Instalar la extensión de prueba sin recompilar la aplicación.
- Activar su pantalla y función, desactivarla y restaurar la interfaz base.
- Registrar compatibilidad real por formato y plataforma, pruebas realizadas y limitaciones.

Falta acordar el alcance exacto de la primera versión publicable. Véanse [[05 Rendimiento]], [[04 Extensiones]] y [[07 Preguntas e investigacion]].
