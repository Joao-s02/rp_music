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

Conservar el historial de cambios de criterio. No registrar secretos, tokens, credenciales ni datos privados de bibliotecas de servicios. Una actualización pequeña no necesita una nota nueva si encaja en una existente.

## Siguiente trabajo

Identidad visual vigente: [[15 Identidad visual e icono]]. El usuario eligió la variante A; consultar esa nota antes de cambiar marca, iconos o tema. Distinguir iconos integrados de pautas de interfaz todavía no aplicadas.

La primera base de [[11 Reconstruccion - primera base]] se publicó en [[12 Release 0.2.0-alpha.1]]. El estado local posterior y los resultados del usuario están en [[13 Pruebas reales y correcciones 0.2.1]]: leer esa nota antes de continuar. Seguir [[06 Primera version]] y resolver las investigaciones de extensiones conservando esta documentación y Git. Ver [[10 Estado del repositorio]].

Antecedente de pruebas y publicación 0.2.2: [[14 Pruebas 0.2.1 y correcciones 0.2.2]]. Leerlo primero para no tratar instalación Tecno o notificaciones físicas como problemas ya verificados en los teléfonos.

Trabajo posterior vigente: leer [[16 Pruebas 0.2.2 y rediseno 0.2.3]] antes de continuar. El usuario confirmó que 0.2.2 sigue sin controles en Galaxy/Poco aun con permiso; la interfaz Stitch se adapta en Flutter y 0.2.3+5 se publicó posteriormente como v0.2.3-alpha.1 por autorización explícita. Consultar la confirmación al final de esa nota; el retesteo físico sigue pendiente.

Trabajo local posterior vigente: [[18 Pruebas 0.2.3 y correcciones 0.2.4]]. El usuario aprobó el actualizador opcional y reportó teclado que pierde foco, corte de reproducción y error foreground en Galaxy Android 16. Leer la copia local documentada de audio_service y sus dos ajustes antes de cambiar dependencias. 0.2.4+6 se publicó como v0.2.4-alpha.1 por autorización explícita; confirmación, adjuntos y límites al final de la nota 18. El retesteo físico sigue pendiente.

Trabajo vigente publicado: [[20 Pruebas 0.2.4 y mejoras 0.2.5]]. Informe del usuario confirma notificaciones visibles en 0.2.4 móvil; se incorporan cuatro mejoras en 0.2.5+7. Posteriormente el usuario autoriza recompilar escritorio y publicar v0.2.5-alpha.1; publicación y siete adjuntos confirmados en la nota 20. Consultar validaciones y permisos SAF de escritura antes de continuar.

Tras pruebas de 0.2.5, consultar [[21 Pruebas 0.2.5 y mejoras 0.2.6]] antes de continuar con actualizador, permisos, widget y orden en 0.2.6 local. Antes del sistema programable leer [[22 Extensiones - alcance del primer sistema]]: alcance aceptado de biblioteca/listas/carátulas, varias activas, permisos y recuperación; todavía no es implementación del runtime.


2026-10-26: usuario autoriza publicar 0.3.0 mientras prueba 0.3.1. Preparación separada y alcance en [[25 Release 0.3.0]]; no incluir YouTube ni modificar la copia de pruebas 0.3.1.


Publicación vigente confirmada: v0.3.0-alpha.1, Android universal/ARM64 y Windows, siete adjuntos verificados. Fuente y cierre en [[25 Release 0.3.0]]. 0.3.1 permanece en pruebas separadas; no está en esta release.
