---
tipo: guia
estado: vigente
actualizado: 2026-10-25
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

Conservar el historial de cambios de criterio. No registrar secretos, tokens, credenciales ni datos privados de bibliotecas de servicios. Una actualización pequeña no necesita una nota nueva si encaja en una existente.

## Siguiente trabajo

La primera base de [[11 Reconstruccion - primera base]] se publicó en [[12 Release 0.2.0-alpha.1]]. El estado local posterior y los resultados del usuario están en [[13 Pruebas reales y correcciones 0.2.1]]: leer esa nota antes de continuar. Seguir [[06 Primera version]] y resolver las investigaciones de extensiones conservando esta documentación y Git. Ver [[10 Estado del repositorio]].

Último informe y versión publicada: [[14 Pruebas 0.2.1 y correcciones 0.2.2]]. Leerlo primero para no tratar instalación Tecno o notificaciones físicas como problemas ya verificados en los teléfonos.
