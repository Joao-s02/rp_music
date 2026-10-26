---
tipo: requisitos
estado: confirmado-con-investigacion-pendiente
actualizado: 2026-10-26
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

Flutter no determina por sí solo el mecanismo de extensiones. Antes de elegirlo, comparar ejecución de lógica, representación de pantallas, permisos, acceso al audio, interoperabilidad, versiones y distribución. La entrevista no eligió un runtime. El prototipo posterior selecciona provisionalmente dart_eval y API 2 como decisión técnica del agente; ver [[23 Extensiones programables - primer prototipo]].

La viabilidad de Spotify y YouTube Music debe comprobarse con documentación oficial actual sobre catálogo, autenticación y reproducción. No se ha investigado ni prometido acceso a streams, disponibilidad de APIs ni compatibilidad con Play Store. El ecualizador también debe validar cómo se conecta al motor de audio.

La primera prueba será una extensión pequeña que cambie una pantalla y añada una función, aceptada por el usuario antes de las integraciones completas. Ver [[06 Primera version]] y [[07 Preguntas e investigacion]].

## Avance de implementación

Antecedente API 1: prueba declarativa JSON con dos presentaciones de biblioteca, color de acento y acción aleatoria predefinida. Se instala sin recompilar y permite elegir una presentación activa. No ejecuta programas ni permite pantallas arbitrarias; el runtime completo sigue abierto. Ver [[11 Reconstruccion - primera base]].

## Alcance confirmado posterior a 0.2.5

La primera extensión será biblioteca con filtros y acciones, carátulas propias/mosaico y listas automáticas. Varias activas con selección de conflictos, permisos separados, instalación por archivo y recuperación aceptados. Las creará el agente. Sustituciones avanzadas deseadas: reproductor, aleatorio y listas. Requisitos, conservación de datos y propuestas de contrato en [[22 Extensiones - alcance del primer sistema]]. Ese estado correspondía a 0.2.6; el trabajo posterior [[23 Extensiones programables - primer prototipo]] ya incorpora lógica Dart real y un SDK inicial limitado.

El prototipo 0.3.0 añade API 2 con Biblioteca viva y Pulso nocturno, permisos, varias activas, selección de funciones, reglas/carátulas y recuperación. Su alcance real y limitaciones de memoria/UI/red están en [[23 Extensiones programables - primer prototipo]]; no equivale al sistema completo de la visión.


2026-10-26: autorizado, creado y publicado repositorio público separado rp-music-extensions; catálogo por enlace integrado localmente, permisos antes de instalar y ejemplos retirados del bundle de producción. Ver alcance, verificaciones y límites en [[23 Extensiones programables - primer prototipo]]. La app no se publicó en esta tarea.


Inicio de integración YouTube Music y entrevista específica: [[24 YouTube Music - definicion e investigacion]]. No hay conexión implementada aún.


2026-10-26: el usuario prioriza Android. Implementada localmente 0.3.1+10 con adaptador YouTube Music sin cuenta, búsqueda de canciones, paquete externo, permiso network.youtube y capacidad source. Se cambió el cliente no oficial tras investigar #386; recepción completa de audio y sonda Android release continua aprobadas, recorrido nativo instalado en depuración aprobado. Suite: 77 pruebas. Límites y pendientes en [[24 YouTube Music - definicion e investigacion]]. Windows/listas/favoritos/historial de la fuente se posponen. No es publicación de la app.


2026-10-26: usuario valida 0.3.1 (búsqueda/audio rápidos, sin bugs ni lag observados) y autoriza nueva release. Diseño reportado queda para próxima versión. Comunicación pública: soporte de extensiones para fuentes de música en la nube, con adaptador inicial Android; no prometer cualquier proveedor ni ocultar límites. Se publica el mismo APK validado; Windows mantiene 0.3.0. Seguimiento en [[26 Release 0.3.1]].
