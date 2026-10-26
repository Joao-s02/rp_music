---
tipo: pendientes
estado: abierto
actualizado: 2026-10-26
---
# Preguntas e investigacion

## Antes de fijar la arquitectura

| Tema | Qué resolver | Estado |
| --- | --- | --- |
| Extensiones ejecutables | Runtime, lenguaje, paquete e instalación en Android y Windows; prueba de UI y lógica. | Prototipo local dart_eval/API 2; alcance, validación y límites en [[23 Extensiones programables - primer prototipo]]. |
| Audio | Motor y backends, formatos/códecs, gapless, fundido y futura conexión de ecualizador. | Backend inicial elegido y compilado; validación física y funciones avanzadas pendientes. |
| Almacenamiento | Acceso persistente a una raíz y sus subcarpetas en ambas plataformas; unidades extraíbles y permisos. | SAF Android y ruta Windows implementados; falta validación en dispositivos y unidades extraíbles. |
| Servicios | Capacidades oficiales actuales de catálogo y reproducción de YouTube Music y Spotify. | Pendiente; no prometer viabilidad. |
| Play Store | Compatibilidad del modelo elegido de extensiones y su distribución con políticas vigentes. | Pendiente de revisión oficial. |
| Aislamiento | Permisos de ambos niveles, fallos, límites y atribución de consumo. | Requisito general confirmado; diseño pendiente. |

Consultar fuentes oficiales actuales cuando se realice esta investigación y registrar enlaces, fecha, conclusión y límites. Esta bóveda no presenta dichas capacidades como verificadas.

## Preguntas de producto abiertas

Identidad base resuelta el 2026-10-25: variante A elegida e integrada en recursos; parámetros en [[15 Identidad visual e icono]]. Aplicación y validación del tema de interfaz aún pendientes.

Bloqueo de compilación por Java resuelto en esta máquina: JDK 17 completo instalado/seleccionado y APK release compilado y con firma verificada. Pasos de configuración en docs/COMPILACION.md; antecedentes y evidencia en [[09 Registro de cambios]].

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

## Notificaciones y rediseño posteriores a 0.2.2

El informe físico sigue negativo en Galaxy A34 y Poco X6, incluido ARM64 y permiso concedido. Se detectaron iconos dinámicos ausentes del APK reducido y se corrigió su conservación. Sonda release con sesión/notificación real aprobada en emulador API 37; comparación causal posterior reprodujo el fallo CustomAction sin icono al recortar los recursos; detalle y validación final en [[16 Pruebas 0.2.2 y rediseno 0.2.3]]. La aplicación inicial del tema ya está implementada; no mantenerla como completamente pendiente ni inferir soporte de DSP/DAC/ecualizador desde el ZIP.

## Actualizador opcional

Viabilidad documental evaluada en [[17 Actualizaciones opcionales desde la app]]. GitHub releases puede servir como fuente pública; latest excluye nuestras prereleases. Android permite solicitar instalación, con firma compatible y gestión de consentimiento del sistema. La propuesta fue aprobada e implementada posteriormente en 0.2.4: consulta diaria configurable, canales, descarga/verificación Android y enlace Windows. Firma de distribución estable y recorrido entre releases públicas siguen pendientes; ver [[18 Pruebas 0.2.3 y correcciones 0.2.4]].

## Informe móvil posterior a 0.2.4

El usuario confirma que ya aparecen los controles de notificación; el informe negativo anterior se conserva como antecedente. Se añade carátula e iconos simplificados en sesión Android; falta verificar su presentación física. Borrado de archivos mediante SAF implementado con permiso de escritura y confirmación, sujeto al proveedor; comprobar permiso antiguo de solo lectura y SD. Ver [[20 Pruebas 0.2.4 y mejoras 0.2.5]].

## Entrevista de extensiones y mejoras 0.2.6

Resueltos para la primera entrega: ejemplo de biblioteca, varias extensiones, conflictos elegidos por el usuario, instalación por archivo, permisos normales separados, recuperación y conservación de datos; carátulas propias/mosaico y listas automáticas. Falta elegir runtime, lenguaje, formato, límites y contratos; ver [[22 Extensiones - alcance del primer sistema]]. SAF no se puede ampliar a escritura silenciosamente: 0.2.6 solicita autorización de la misma carpeta al borrar. MediaStore.createDeleteRequest es alternativa investigada, sin implementar; ver [[21 Pruebas 0.2.5 y mejoras 0.2.6]].

## Prototipo 0.3.0

Elección técnica provisional de dart_eval para lógica en isolates y UI mediante contratos limitados. Permisos, reglas y recuperación implementados como prototipo; faltan aislamiento duro de memoria, red, comunicación entre paquetes y componentes arbitrarios. Ver [[23 Extensiones programables - primer prototipo]].


2026-10-26: requisitos de YouTube Music confirmados: solo audio dentro de RP Music, segundo plano/pantalla apagada, Android y Windows, sin cuenta, listas/favoritos/historial locales y búsqueda/exploración. Se investigan fuentes primarias oficiales y alternativas no oficiales; elección de vía pendiente de respuesta. No hay streaming remoto implementado ni comprobado. Detalles en boveda/24 YouTube Music - definicion e investigacion.md.


Trabajo vigente 2026-10-26: [[24 YouTube Music - definicion e investigacion]] — el usuario aceptó priorizar Android y la primera entrega de búsqueda/reproducción sin cuenta. 0.3.1+10 local añade fuente Android y paquete externo; 77 pruebas y recorrido nativo instalado aprobados, con límites documentados. Windows/listas/favoritos/historial de la fuente pendientes. No repetir elección de vía no oficial ni prioridad de plataforma. Última release pública de la app: 0.2.6.


2026-10-26: usuario valida 0.3.1 (búsqueda/audio rápidos, sin bugs ni lag observados) y autoriza nueva release. Diseño reportado queda para próxima versión. Comunicación pública: soporte de extensiones para fuentes de música en la nube, con adaptador inicial Android; no prometer cualquier proveedor ni ocultar límites. Se publica el mismo APK validado; Windows mantiene 0.3.0. Seguimiento en [[26 Release 0.3.1]].
