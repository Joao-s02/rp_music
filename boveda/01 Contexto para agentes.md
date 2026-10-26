---
tipo: guia
estado: vigente
actualizado: 2026-10-26
---
# Contexto para agentes

## Resumen de incorporación

RP Music será un reproductor de música local de código abierto, construido en Flutter, dirigido a una comunidad que pueda personalizarlo mediante extensiones. Android y Windows son prioritarios; web es opcional. El núcleo debe ser sencillo, fluido, sin internet y sin cuenta. Las extensiones podrán ampliar funciones y transformar la interfaz. Ver [[02 Vision y decisiones]], [[03 Biblioteca y reproduccion]] y [[04 Extensiones]].

El usuario está aprendiendo Dart y Flutter. Este es uno de sus primeros proyectos ambiciosos. Prefiere explicaciones claras y decisiones sostenibles. Flutter, Git y GitHub CLI se verificaron durante la reconstrucción y publicación; ver [[10 Estado del repositorio]].

## Orden de autoridad

1. Instrucciones actuales del usuario y reglas aplicables del entorno.
2. Requisitos confirmados en la entrevista, consolidados en esta bóveda.
3. Decisiones posteriores explícitas y registradas.
4. Propuestas, documentos históricos y código existente como referencias.

No atribuir al usuario elecciones de paquetes, bases de datos, motores o lenguajes de extensiones que todavía no hizo. No convertir las opciones sugeridas durante la entrevista en aprobaciones implícitas.

## Mantenimiento obligatorio

En cada tarea con cambios relevantes de contexto:

1. Leer las notas afectadas antes de actuar.
2. Actualizar el requisito o decisión en su nota principal, con motivo y estado.
3. Añadir vínculos a las áreas que dependan de ella.
4. Actualizar [[07 Preguntas e investigacion]] si se resuelve o surge una duda.
5. Registrar en [[09 Registro de cambios]] qué cambió, por qué, qué se comprobó y qué queda pendiente.
6. Actualizar [[10 Estado del repositorio]] cuando cambie la implementación o su validación.
7. **Revisar y actualizar README.md en cada actualización del proyecto**, por requisito explícito del usuario (2026-10-25). Mantener versión publicada y versión local claramente diferenciadas, novedades, enlaces de descarga/pruebas, instalación, capacidades reales, verificaciones y pendientes. Si una sección no cambia, comprobar que sigue vigente; no basta con cambiar el número de versión. Actualizarlo antes de terminar el trabajo y, cuando se autorice una publicación, incluirlo en los cambios que se envían. Esta obligación no concede autorización automática para publicar, hacer push o crear releases.

8. **Antes de publicar una release de GitHub, leer y cumplir [[27 Publicacion de releases - contenido obligatorio]]**, por instrucción explícita del usuario (2026-10-26). Entrega conjunta de Android universal, Android ARM64, Windows y adjuntos documentales. Priorizar Android en desarrollo no permite publicar una entrega parcial sin excepción expresa.

9. **Antes de crear o modificar una extensión, cumplir la separación de repositorios de [[04 Extensiones]].** Sus fuentes, paquetes y lógica específica van exclusivamente a rp-music-extensions; el repositorio principal contiene el motor/SDK y capacidades genéricas. No copiar extensiones al principal ni adjuntarlas a sus releases.

Conservar el historial de cambios de criterio. No registrar secretos, tokens, credenciales ni datos privados de bibliotecas de servicios. Una actualización pequeña no necesita una nota nueva si encaja en una existente.

## Siguiente trabajo

Identidad visual vigente: [[15 Identidad visual e icono]]. El usuario eligió la variante A; consultar esa nota antes de cambiar marca, iconos o tema. Distinguir iconos integrados de pautas de interfaz todavía no aplicadas.

La primera base de [[11 Reconstruccion - primera base]] se publicó en [[12 Release 0.2.0-alpha.1]]. El estado local posterior y los resultados del usuario están en [[13 Pruebas reales y correcciones 0.2.1]]: leer esa nota antes de continuar. Seguir [[06 Primera version]] y resolver las investigaciones de extensiones conservando esta documentación y Git. Ver [[10 Estado del repositorio]].

Antecedente de pruebas y publicación 0.2.2: [[14 Pruebas 0.2.1 y correcciones 0.2.2]]. Leerlo primero para no tratar instalación Tecno o notificaciones físicas como problemas ya verificados en los teléfonos.

Trabajo posterior vigente: leer [[16 Pruebas 0.2.2 y rediseno 0.2.3]] antes de continuar. El usuario confirmó que 0.2.2 sigue sin controles en Galaxy/Poco aun con permiso; la interfaz Stitch se adapta en Flutter y 0.2.3+5 se publicó posteriormente como v0.2.3-alpha.1 por autorización explícita. Consultar la confirmación al final de esa nota; el retesteo físico sigue pendiente.

Trabajo local posterior vigente: [[18 Pruebas 0.2.3 y correcciones 0.2.4]]. El usuario aprobó el actualizador opcional y reportó teclado que pierde foco, corte de reproducción y error foreground en Galaxy Android 16. Leer la copia local documentada de audio_service y sus dos ajustes antes de cambiar dependencias. 0.2.4+6 se publicó como v0.2.4-alpha.1 por autorización explícita; confirmación, adjuntos y límites al final de la nota 18. El retesteo físico sigue pendiente.

Trabajo vigente publicado: [[20 Pruebas 0.2.4 y mejoras 0.2.5]]. Informe del usuario confirma notificaciones visibles en 0.2.4 móvil; se incorporan cuatro mejoras en 0.2.5+7. Posteriormente el usuario autoriza recompilar escritorio y publicar v0.2.5-alpha.1; publicación y siete adjuntos confirmados en la nota 20. Consultar validaciones y permisos SAF de escritura antes de continuar.

Tras pruebas de 0.2.5, consultar [[21 Pruebas 0.2.5 y mejoras 0.2.6]] antes de continuar con actualizador, permisos, widget y orden en 0.2.6 local. Antes del sistema programable leer [[22 Extensiones - alcance del primer sistema]]: alcance aceptado de biblioteca/listas/carátulas, varias activas, permisos y recuperación; todavía no es implementación del runtime.

El usuario autorizó implementar después de publicar 0.2.6. Trabajo local actual: [[23 Extensiones programables - primer prototipo]]. Leer sus límites: dart_eval, contratos UI limitados, permisos y recuperación, sin aislamiento duro de memoria ni SDK completo. API 1 conservada; 0.3.0 no está publicada.


Trabajo vigente 2026-10-26: [[24 YouTube Music - definicion e investigacion]] — el usuario aceptó priorizar Android y la primera entrega de búsqueda/reproducción sin cuenta. 0.3.1+10 local añade fuente Android y paquete externo; 77 pruebas y recorrido nativo instalado aprobados, con límites documentados. Windows/listas/favoritos/historial de la fuente pendientes. No repetir elección de vía no oficial ni prioridad de plataforma. Última release pública de la app: 0.2.6.


2026-10-26: usuario autoriza publicar 0.3.0 mientras prueba 0.3.1. Preparación separada y alcance en [[25 Release 0.3.0]]; no incluir YouTube ni modificar la copia de pruebas 0.3.1.


Publicación vigente confirmada: v0.3.0-alpha.1, Android universal/ARM64 y Windows, siete adjuntos verificados. Fuente y cierre en [[25 Release 0.3.0]]. 0.3.1 permanece en pruebas separadas; no está en esta release.


2026-10-26: usuario valida 0.3.1 (búsqueda/audio rápidos, sin bugs ni lag observados) y autoriza nueva release. Diseño reportado queda para próxima versión. Comunicación pública: soporte de extensiones para fuentes de música en la nube, con adaptador inicial Android; no prometer cualquier proveedor ni ocultar límites. Se publica el mismo APK validado; Windows mantiene 0.3.0. Seguimiento en [[26 Release 0.3.1]].


Publicación vigente confirmada: 0.3.1-alpha.1 Android, con cinco adjuntos y README remoto verificados. Mismo APK validado por el usuario; diseño pendiente para siguiente versión. Windows mantiene 0.3.0. Ver [[26 Release 0.3.1]].


2026-10-26: trabajo local vigente 0.3.2+11 en [[28 Pruebas 0.3.1 y mejoras 0.3.2]]: detalle de álbum, áreas seguras, nombre de fuente y navegación aportada por extensión. Se migra la lógica específica de la fuente al repositorio de extensiones; contrato HTTP genérico en la app y actualización de paquete requerida. Material previo de Biblioteca viva/Pulso aún pendiente de migración. No se publica 0.3.2 en esta tarea.


Cierre local 0.3.2: tres paquetes normales compilados (universal/ARM64/Windows), guías y hashes en dist/0.3.2-local; APK universal instalado/abierto, firma compatible con 0.3.1 y Windows iniciado. Suite inicial 75 pruebas, comprobación adicional de navegación y prueba nativa Android aprobadas; análisis sin incidencias. Extensión 0.2.0 aparte, actualización con permisos requerida. No hay publicación ni push de estos cambios; probar por archivo local hasta publicar catálogo. Resultados, tamaños, hashes y límites en [[28 Pruebas 0.3.1 y mejoras 0.3.2]].


2026-10-26 — publicación confirmada: [v0.3.2-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.3.2-alpha.1), app 0.3.2+11, tag b8fd967. Android universal/ARM64, Windows, USO/PRUEBAS/CAMBIOS y hashes: siete adjuntos públicos verificados por tamaño y SHA-256. Extensión 0.2.0 y catálogo compatible publicados exclusivamente en rp-music-extensions (da3e455); paquete remoto verificado y versión 0.1.0 conservada para 0.3.1. Ya no es entrega solo local. Ver [[28 Pruebas 0.3.1 y mejoras 0.3.2]] para commits, hashes, pruebas y pendientes.
