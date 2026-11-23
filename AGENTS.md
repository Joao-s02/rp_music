# Contexto obligatorio del proyecto

En una copia con bóveda local, antes de proponer arquitectura o modificar el proyecto, leer `boveda/00 Inicio.md`, `boveda/01 Contexto para agentes.md` y las notas relacionadas con la tarea.

Desde un clon sin bóveda, empezar por README.md y docs/README.md. La bóveda es la fuente de contexto mantenida del proyecto. Las instrucciones actuales del usuario tienen prioridad. El código alfa y `arquitectura-reproductor-flutter.md` son antecedentes, no decisiones vigentes por defecto.

En cada trabajo que aporte contexto importante, actualizar las notas afectadas y `boveda/09 Registro de cambios.md` antes de terminar. Registrar decisiones, motivos, resultados de verificaciones, límites y pendientes. Distinguir requisitos confirmados, propuestas, investigación e implementación comprobada. No afirmar que algo está implementado solo por estar documentado.

Mantener enlaces relativos de Obsidian `[[Nombre de nota]]`, evitar duplicar decisiones y no guardar credenciales o datos privados de cuentas en la bóveda. Si cambia una decisión, conservar su antecedente en el registro y actualizar sus referencias.

El usuario autorizó sustituir el código alfa por un proyecto nuevo, pero pidió crear primero esta bóveda. No borrar la bóveda, este archivo ni el historial Git durante la reconstrucción. No publicar, enviar cambios a GitHub ni crear repositorios sin autorización correspondiente.

Comunicar en español y explicar decisiones de forma accesible: el usuario está aprendiendo Flutter y Dart.

## Nombres de ramas Git

Regla obligatoria: nunca crear ni renombrar una rama de RP Music para que empiece con `codex/`. Usar nombres descriptivos del trabajo, por ejemplo `feat/cola-editable`, `fix/restaurar-reproduccion` o `release/0.4.3`. Esta regla no implica renombrar ramas existentes.

## Cumplimiento de licencias en futuras versiones

Toda versión futura de RP Music debe cumplir las condiciones de la licencia vigente del proyecto y de cada dependencia o recurso que se distribuya. La licencia actual del código propio es GPL-3.0-or-later.

Antes de publicar, verificar las licencias y atribuciones en los paquetes finales de cada plataforma, revisar las dependencias que hayan cambiado y comprobar que la descarga ofrece el código fuente correspondiente a esos binarios cuando la licencia lo exija. Si falta una obligación aplicable por cumplir o verificar, resolverla antes de publicar. Consultar [los avisos de terceros](THIRD_PARTY_NOTICES.md) y la [guía de distribución del código fuente](docs/DISTRIBUCION-FUENTE.md).
