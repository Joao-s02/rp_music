---
tipo: pendientes
estado: abierto
actualizado: 2026-10-24
---
# Preguntas e investigacion

## Antes de fijar la arquitectura

| Tema | Qué resolver | Estado |
| --- | --- | --- |
| Extensiones ejecutables | Runtime, lenguaje, paquete e instalación en Android y Windows; prueba de UI y lógica. | Sin investigar ni elegir. |
| Audio | Motor y backends, formatos/códecs, gapless, fundido y futura conexión de ecualizador. | Backend inicial elegido y compilado; validación física y funciones avanzadas pendientes. |
| Almacenamiento | Acceso persistente a una raíz y sus subcarpetas en ambas plataformas; unidades extraíbles y permisos. | SAF Android y ruta Windows implementados; falta validación en dispositivos y unidades extraíbles. |
| Servicios | Capacidades oficiales actuales de catálogo y reproducción de YouTube Music y Spotify. | Pendiente; no prometer viabilidad. |
| Play Store | Compatibilidad del modelo elegido de extensiones y su distribución con políticas vigentes. | Pendiente de revisión oficial. |
| Aislamiento | Permisos de ambos niveles, fallos, límites y atribución de consumo. | Requisito general confirmado; diseño pendiente. |

Consultar fuentes oficiales actuales cuando se realice esta investigación y registrar enlaces, fecha, conclusión y límites. Esta bóveda no presenta dichas capacidades como verificadas.

## Preguntas de producto abiertas

- ¿Android y Windows se desarrollarán desde el inicio en paralelo o habrá una plataforma inicial? La respuesta autorizó reconstruir, pero no resolvió este punto.
- ¿Qué dispositivos, versiones mínimas de sistemas y biblioteca de referencia se usarán?
- ¿Actualizar automáticamente el índice al abrir, observar cambios continuamente o hacerlo manualmente?
- ¿Qué ocurre al cambiar la raíz o perder acceso a archivos?
- ¿Cómo agrupar álbumes cuando faltan etiquetas o hay compilaciones?
- ¿Restaurar posición sin iniciar audio o reanudar automáticamente?
- ¿Cómo evitar sobrescrituras inesperadas al editar metadatos? ¿Se desea respaldo?
- ¿Qué opciones concretas de personalización básica se incluirán?
- ¿Catálogo revisado, repositorios externos, paquetes firmados? ¿Quién administra la confianza?
- ¿Modo de recuperación y desactivación de extensiones con fallos?
- ¿Qué métricas mostrará el panel de consumo?
- ¿Qué licencia de código abierto se elegirá y cuál será el nombre público definitivo?
- ¿Qué funciones completas entrarán en el primer lanzamiento público?

No es necesario preguntar todo de una vez. Resolver primero lo que bloquee la siguiente tarea, proponiendo valores razonables y distinguiéndolos de decisiones aceptadas.

## Avance tras iniciar la reconstrucción

[[11 Reconstruccion - primera base]] registra la elección provisional de audio/persistencia, acceso SAF Android y una prueba declarativa de personalización. La tabla anterior conserva las investigaciones completas pendientes; no interpretar el backend provisional como validación de gapless, ecualizador o todos los códecs. Se trabaja en ambas plataformas en este incremento. El escaneo actual es manual; falta validar con el usuario su comportamiento final.

Relaciones: [[02 Vision y decisiones]], [[03 Biblioteca y reproduccion]], [[04 Extensiones]], [[05 Rendimiento]], [[06 Primera version]].
