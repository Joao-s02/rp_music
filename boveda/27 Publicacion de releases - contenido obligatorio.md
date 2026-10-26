---
tipo: politica-de-publicacion
estado: confirmado-por-el-usuario
actualizado: 2026-10-26
---
# Publicacion de releases - contenido obligatorio

## Requisito vigente

El usuario establece que las releases de GitHub deben distribuir conjuntamente Android universal (también llamado global), Android de 64 bits (ARM64) y Windows, acompañados de los documentos y archivos necesarios. Este requisito rige las próximas publicaciones; una prioridad de desarrollo Android no autoriza por sí sola a omitir los otros paquetes de una release.

## Adjuntos mínimos por versión

| Archivo | Contenido requerido |
| --- | --- |
| `RP-Music-<version>-android.apk` | APK Android universal/global. |
| `RP-Music-<version>-android-arm64.apk` | APK Android ARM64, para dispositivos de 64 bits compatibles. |
| `RP-Music-<version>-windows-x64.zip` | Aplicación Windows portable completa: ejecutable, DLL, data y demás dependencias necesarias. |
| `PRUEBAS-<version>.md` | Pruebas que debe realizar el usuario, pasos, resultados esperados, plataformas y funciones a comprobar; distinguir pruebas ya realizadas y pendientes. |
| `CAMBIOS-<version>.md` | Novedades, correcciones, límites conocidos y pendientes de esa versión. Debe ser un adjunto Markdown separado; el texto de la release no lo sustituye. |
| `USO.md` | Instrucciones de instalación/actualización, uso y conservación de datos; advertencias concretas que apliquen. |
| `SHA256SUMS.txt` | SHA-256 de todos los demás adjuntos publicados, generado después de cerrar sus contenidos. |

Añadir los archivos que requiera la entrega: manifiestos, ejemplos genéricos del SDK, licencias o recursos auxiliares. No son una lista fija ni se incluyen secretos, credenciales o archivos privados. Por la instrucción posterior del usuario, las extensiones y sus paquetes se publican exclusivamente en el repositorio de extensiones: no adjuntarlos a releases del repositorio principal ni incorporarlos al APK/ZIP. Enlazar al catálogo e indicar versiones compatibles; ver [[04 Extensiones]].

## Preparación y comprobación

1. Leer esta nota antes de preparar cualquier release y reunir los tres paquetes de aplicación y sus documentos.
2. Mantener código, tag, versión/número de compilación y binarios coherentes. No renombrar un paquete de una versión anterior para completar una plataforma ni presentar una sonda de pruebas como aplicación normal.
3. Ejecutar las verificaciones apropiadas para cada plataforma y registrar su alcance real. Android debe mantener la firma compatible al actualizar; Windows debe contener el paquete completo. Documentar las diferencias de funciones entre plataformas sin prometer paridad no implementada.
4. Revisar y actualizar README con novedades, plataformas, enlaces, instalación, validaciones y límites. Mantener alineados README, notas de release y `CAMBIOS-<version>.md`.
5. Preparar la release como borrador; verificar nombres, versiones y presencia de todos los adjuntos. Comparar tamaños y hashes de los archivos subidos con los locales antes de publicarla.
6. Confirmar el enlace público y registrar tag/commit, adjuntos, verificaciones, límites y pendientes en la nota de la release y [[09 Registro de cambios]].

## Paquetes faltantes y excepciones

No publicar por iniciativa propia una release incompleta si falta Android universal, ARM64, Windows o alguno de los documentos obligatorios. Completar primero el paquete; si existe un impedimento real, explicarlo al usuario y obtener una instrucción explícita para una excepción o para aplazar la publicación. No hace falta pedir confirmación adicional cuando ya están autorizadas la publicación y la entrega completa.

Una excepción anterior no se convierte en regla para futuras releases. Priorizar una plataforma en desarrollo o conservar otra versión para Windows no sustituye el requisito de publicar los tres paquetes bajo la misma versión, salvo excepción expresa del usuario.

## Antecedente y alcance de esta actualización

[[26 Release 0.3.1]] se publicó previamente solo para Android. Esta nota registra la nueva instrucción posterior; no afirma que esa release ya contenga ARM64 separado, Windows o un MD de cambios ni modifica sus adjuntos automáticamente. Completar o reeditar una release existente es un trabajo separado que debe realizarse con la autorización correspondiente.

Relaciones: [[01 Contexto para agentes]], [[10 Estado del repositorio]], [[25 Release 0.3.0]], [[26 Release 0.3.1]], [[09 Registro de cambios]].
