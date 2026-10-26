---
tipo: requisitos
estado: confirmado-con-investigacion-pendiente
actualizado: 2026-10-26
---
# Extensiones

## Objetivo confirmado

Permitir que cualquier miembro de la comunidad programe funciones y personalizaciones. Se busca la mayor libertad posible: tipografías, colores, controles, carátulas, distribución y pantallas completas. También habrá personalización básica sin extensiones.

La base debe conservar su fluidez; el usuario acepta que extensiones más exigentes permitan aprovechar dispositivos con más recursos. Esto no elimina la necesidad de estudiar aislamiento y comportamiento ante fallos.

## Separación obligatoria de repositorios

**Confirmado por el usuario (2026-10-26): toda nueva extensión se desarrolla y publica exclusivamente en https://github.com/Joao-s02/rp-music-extensions . Nunca en el repositorio principal https://github.com/Joao-s02/rp_music .**

- Repositorio de extensiones: implementaciones y fuentes específicas, paquetes `.rpmx`, recursos propios, documentación y pruebas particulares de cada extensión, catálogo y sus actualizaciones.
- Repositorio principal: reproductor, motor de extensiones, contratos/SDK, permisos, instalación/catálogo y componentes genéricos necesarios para ejecutar extensiones. Los clientes, parsers y lógica específicos de un servicio pertenecen a su extensión; no trasladarlos al núcleo bajo la etiqueta de adaptador.
- No copiar extensiones completas como ejemplos o fixtures en el repositorio principal. Para probar el motor pueden usarse fixtures sintéticos mínimos y genéricos; las pruebas de cada extensión permanecen con ella.
- Los paquetes de extensiones se distribuyen desde el repositorio de extensiones, no como assets del APK/ZIP ni como adjuntos de las releases del repositorio principal. La app y su documentación pueden enlazar al catálogo y explicar compatibilidad/permisos.
- Antes de crear o actualizar una extensión, trabajar en su repositorio y revisar esta separación. Una actualización del motor o SDK necesaria para soportarla se desarrolla en la app como capacidad genérica.

**Estado real y pendiente:** los prototipos y 0.3.1 ya dejaron fuentes/paquetes de ejemplo, fixtures y lógica específica de proveedor en el repositorio principal, además de un paquete adjunto a su release. Esta regla corrige el criterio para próximos trabajos. En el trabajo local 0.3.2 se migra el material de la fuente inicial al repositorio de extensiones (incluido su cliente/parser y pruebas), conservando antecedentes y verificando búsqueda/audio con el programa externo. El material heredado de Biblioteca viva/Pulso nocturno sigue pendiente de migración. No afirmar que la arquitectura actual ya cumple la separación completa ni borrar el historial publicado.

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


2026-10-26: trabajo local vigente 0.3.2+11 en [[28 Pruebas 0.3.1 y mejoras 0.3.2]]: detalle de álbum, áreas seguras, nombre de fuente y navegación aportada por extensión. Se migra la lógica específica de la fuente al repositorio de extensiones; contrato HTTP genérico en la app y actualización de paquete requerida. Material previo de Biblioteca viva/Pulso aún pendiente de migración. No se publica 0.3.2 en esta tarea.


2026-10-26 — publicación confirmada: [v0.3.2-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.3.2-alpha.1), app 0.3.2+11, tag b8fd967. Android universal/ARM64, Windows, USO/PRUEBAS/CAMBIOS y hashes: siete adjuntos públicos verificados por tamaño y SHA-256. Extensión 0.2.0 y catálogo compatible publicados exclusivamente en rp-music-extensions (da3e455); paquete remoto verificado y versión 0.1.0 conservada para 0.3.1. Ya no es entrega solo local. Ver [[28 Pruebas 0.3.1 y mejoras 0.3.2]] para commits, hashes, pruebas y pendientes.


2026-10-26: trabajo local 0.3.3+12 en [[29 Pruebas 0.3.2 y mejoras 0.3.3]]: nuevo reproductor según referencia sin ecualizador (reservado a próxima extensión), listas existentes desde álbum, artistas separados por comas, historial para Anterior y acceso de fuente integrado al tema sin botón duplicado. Extensiones modificadas solo en repositorio separado; no hay publicación autorizada de 0.3.3. Consultar verificación final antes de dar funciones por comprobadas.
