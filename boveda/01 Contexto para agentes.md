---
tipo: guia
estado: vigente
actualizado: 2026-10-29
---
# Contexto para agentes

## Incorporación

RP Music es un reproductor local Flutter para Android y Windows, ampliable por extensiones. El usuario aprende Dart/Flutter: comunicar en español con explicaciones accesibles. El uso musical base funciona sin cuenta/conexión; actualizaciones y fuentes en línea son opcionales.

Leer esta nota, [[10 Estado del repositorio]] y las relacionadas con la tarea. Consultar [[31 Arquitectura vigente]] antes de modificar arquitectura. Referencia publicada al consolidar esta guía: 0.3.3+12. La versión y su evidencia se mantienen en Estado del repositorio, no en una cronología paralela aquí.

## Autoridad

1. Instrucciones actuales del usuario y reglas aplicables del entorno.
2. Requisitos confirmados y decisiones vigentes de las notas temáticas.
3. Código y verificaciones observadas; distinguir elecciones técnicas provisionales de decisiones del usuario.
4. Entrevistas, planes y versiones anteriores como antecedentes.

El alfa y arquitectura-reproductor-flutter.md son antecedentes, no decisiones actuales por defecto. La reconstrucción ya se hizo conservando Git y bóveda; no volver a preguntar su autorización ni borrar historial. Copia anterior de esta guía en [[30 Archivo de navegacion y estado]].

## Mantenimiento obligatorio

1. Actualizar la nota temática cuando cambie una decisión/capacidad. Conservar criterio anterior y motivo en [[09 Registro de cambios]] o la nota de versión.
2. Actualizar [[10 Estado del repositorio]] si cambia implementación, publicación o validación. Preparación y etapas históricas van a la nota de su versión, no al final del resumen actual.
3. Actualizar [[07 Preguntas e investigacion]] al resolver preguntas o detectar pendientes reales. No repetir entrevistas resueltas.
4. Registrar trabajo y verificaciones en [[09 Registro de cambios]], con límites y pendientes. No presentar emulador como físico ni sumar pruebas repetidas como casos distintos.
5. Revisar README.md en cada actualización: versión, instalación, capacidades, verificaciones y pendientes. Esto no autoriza por sí solo push ni publicación.
6. Usar enlaces Obsidian relativos y una nota principal por tema. El índice orienta, no repite el registro. No guardar credenciales ni datos privados de cuentas.
7. Antes de publicar, cumplir [[27 Publicacion de releases - contenido obligatorio]]: universal, ARM64, Windows y documentos/hashes. Excepciones requieren instrucción expresa. Publicar/enviar a GitHub solo con autorización correspondiente.
8. Antes de modificar extensiones, cumplir [[04 Extensiones]]: lógica, fuentes, recursos, pruebas y paquetes específicos exclusivamente en rp-music-extensions. Principal contiene reproductor, SDK y capacidades genéricas; no adjuntar extensiones a sus releases.

## Lecturas según la tarea

| Trabajo | Consultar |
| --- | --- |
| Audio, listas y metadatos | [[03 Biblioteca y reproduccion]], [[31 Arquitectura vigente]] y última nota de pruebas |
| Interfaz/marca | [[15 Identidad visual e icono]], [[28 Pruebas 0.3.1 y mejoras 0.3.2]], [[29 Pruebas 0.3.2 y mejoras 0.3.3]] |
| Extensiones | [[04 Extensiones]], [API 2](../docs/EXTENSIONES-API-2.md) y su repositorio separado |
| Fuente en línea | [[04 Extensiones]], [[31 Arquitectura vigente]]; [[24 YouTube Music - definicion e investigacion]] como antecedente |
| Actualizador/widget/escritura | [[17 Actualizaciones opcionales desde la app]], [[21 Pruebas 0.2.5 y mejoras 0.2.6]] y código actual |
| Compilar/publicar | [Compilación](../docs/COMPILACION.md), [[27 Publicacion de releases - contenido obligatorio]] y nota de versión |

## Límites que conservar

- Fuente inicial Android; YouTube Windows reproduce/descarga desde0.3.10. Cuentas y sincronización de listas/favoritos/historial online pendientes. Vía no oficial experimental ya aceptada: no repetir esa elección.
- dart_eval/API 2 es una elección técnica provisional, no Dart/Flutter arbitrario ni aislamiento duro de memoria.
- Ecualizador reservado a futura extensión: no añadir al núcleo ni darlo por implementado por un dibujo.
- Conservar los dos ajustes de third_party/audio_service; leer su RP-MUSIC-PATCH.md antes de sustituir la dependencia.
- No ejecutar pruebas/compilaciones Flutter concurrentes: comparten registros generados. Recompilar la entrada normal completa tras sondas y no distribuir ejecutables de integración.
- Resultados históricos y dispositivos informados no equivalen a garantía universal ni prueba nueva de la versión actual.
