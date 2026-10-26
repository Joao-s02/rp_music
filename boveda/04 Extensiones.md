---
tipo: requisitos
estado: confirmado-con-investigacion-pendiente
actualizado: 2026-10-24
---
# Extensiones

## Objetivo confirmado

Permitir que cualquier miembro de la comunidad programe funciones y personalizaciones. Se busca la mayor libertad posible: tipografías, colores, controles, carátulas, distribución y pantallas completas. También habrá personalización básica sin extensiones.

La base debe conservar su fluidez; el usuario acepta que extensiones más exigentes permitan aprovechar dispositivos con más recursos. Esto no elimina la necesidad de estudiar aislamiento y comportamiento ante fallos.

## Instalación y compatibilidad

- Se desean varias vías de instalación; se plantearon catálogo, archivo y enlace a repositorio. Los detalles de cada mecanismo están pendientes.
- Instalación sin recompilar ni reinstalar toda la aplicación; reiniciar es aceptable, no se ha exigido recarga en caliente.
- Actualizaciones solo cuando el usuario las acepte.
- Prioridad: que las extensiones funcionen de forma equivalente en Android y Windows.
- Se aceptan capacidades específicas de una plataforma cuando sean necesarias.
- Se admite usar otros lenguajes además de Dart para facilitar su desarrollo. Ninguno está elegido.
- No se ha confirmado revisión obligatoria del catálogo: la respuesta a esa pregunta confirmó el consentimiento para actualizaciones.

## Permisos y colaboración

- Dos niveles: extensiones normales con permisos controlados y un nivel avanzado para extensiones de confianza.
- El alcance concreto de cada nivel está pendiente; no equivale a una aprobación de acceso irrestricto al sistema.
- Las extensiones deben poder colaborar; ejemplo de la entrevista: fuente musical y letras.
- Si varias sustituyen una misma pantalla, el usuario elige cuál utilizar.
- El usuario quiere ver cuáles consumen más recursos. Definir qué métricas pueden medirse y atribuirse de manera fiable.
- Recuperación y desactivación ante fallos fueron propuestas; no hubo aprobación específica de su comportamiento.

## Ejemplos deseados

1. YouTube Music: buscar y explorar catálogo, y reproducir dentro del reproductor.
2. Ecualizador.
3. Spotify: buscar y explorar catálogo, y reproducir dentro del reproductor.

Las cuentas necesarias se reservan para las extensiones que las requieran; no serán obligatorias para usar la base. La intención inicial mencionó también extracción de bibliotecas, pero la aclaración concreta priorizó exploración y reproducción; importación no es requisito confirmado de la primera versión.

## Investigación necesaria

Flutter no determina por sí solo el mecanismo de extensiones. Antes de elegirlo, comparar ejecución de lógica, representación de pantallas, permisos, acceso al audio, interoperabilidad, versiones y distribución. No hay runtime, SDK ni formato de paquete aprobados.

La viabilidad de Spotify y YouTube Music debe comprobarse con documentación oficial actual sobre catálogo, autenticación y reproducción. No se ha investigado ni prometido acceso a streams, disponibilidad de APIs ni compatibilidad con Play Store. El ecualizador también debe validar cómo se conecta al motor de audio.

La primera prueba será una extensión pequeña que cambie una pantalla y añada una función, aceptada por el usuario antes de las integraciones completas. Ver [[06 Primera version]] y [[07 Preguntas e investigacion]].

## Avance de implementación

Existe una prueba declarativa JSON con dos presentaciones de biblioteca, color de acento y acción aleatoria predefinida. Se instala sin recompilar y permite elegir una presentación activa. No ejecuta programas ni permite pantallas arbitrarias; el runtime completo sigue abierto. Ver [[11 Reconstruccion - primera base]].

## Alcance confirmado posterior a 0.2.5

La primera extensión será biblioteca con filtros y acciones, carátulas propias/mosaico y listas automáticas. Varias activas con selección de conflictos, permisos separados, instalación por archivo y recuperación aceptados. Las creará el agente. Sustituciones avanzadas deseadas: reproductor, aleatorio y listas. Requisitos, conservación de datos y propuestas de contrato en [[22 Extensiones - alcance del primer sistema]]. Ningún runtime/SDK programable está implementado todavía.


Publicación 0.3.0: motor API 2 experimental, permisos, varias activas, conflictos, reglas y recuperación implementados; catálogo GitHub y estado Instalada/Actualizar incluidos. No implica SDK visual completo, acceso de red a programas ni aislamiento duro de memoria. Detalles vigentes: [[23 Extensiones programables - primer prototipo]] y [[25 Release 0.3.0]].
