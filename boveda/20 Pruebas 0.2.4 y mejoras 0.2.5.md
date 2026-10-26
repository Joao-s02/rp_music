---
tipo: pruebas-y-mejoras
estado: publicado-con-validacion-local
actualizado: 2026-10-25
---
# Pruebas 0.2.4 y mejoras 0.2.5

## Requisitos confirmados

El usuario confirma que los controles de notificaciones ya aparecen en 0.2.4 móvil. Pide título largo en una línea con movimiento horizontal, reproductor ampliado a pantalla completa, carátula en notificaciones e iconos minimalistas, Ajustes con secciones y botones propios, y eliminar el archivo de cada canción desde sus tres puntos con confirmación.

## Implementación local 0.2.5+7

- Reproductor ampliado como pantalla independiente completa, conservando barra de estado/áreas del sistema y desplazamiento para pantallas pequeñas. Título en una línea: anima solo si supera el ancho, con pausas en los extremos; respeta la opción de reducir animaciones y ofrece el título completo a accesibilidad.
- Carátula incrustada extraída fuera del hilo de interfaz Android y publicada como URI de archivo privado en MediaItem.artUri. Caché de ocho archivos; fallar o no tener carátula no interrumpe el audio. Generación de selección impide que una respuesta tardía reemplace la pista actual; conserva duración. Cinco iconos vectoriales simples, conservados ante optimización release y añadidos al verificador de APK. Android/fabricante deciden parte de la apariencia final de controles multimedia.
- Ajustes agrupados en Apariencia, Reproducción en segundo plano, Biblioteca y Actualizaciones. Acciones con botones e iconos; preferencias con interruptores; conserva identidad nocturna cian/violeta y temas.
- Menú de cada canción, también en listas, incluye Eliminar del dispositivo. Confirmación explícita de borrado irreversible. Solo tras éxito se retiran catálogo/favoritos/referencias en listas y cola. Si era la pista actual se detiene antes de borrar y se limpia la sesión al tener éxito. Ante rechazo conserva referencias y muestra explicación. Escaneo/cambio de raíz y borrado se excluyen mutuamente.
- Android solicita lectura/escritura mediante SAF y conserva únicamente permisos otorgados por el selector. Una carpeta elegida anteriormente con solo lectura puede requerir elegirla nuevamente. DocumentsContract.deleteDocument puede ser rechazado por el proveedor; no se solicitan permisos generales de almacenamiento. Windows usa borrado de archivo individual.

Referencia nativa consultada: [DocumentsContract.Document](https://developer.android.com/reference/android/provider/DocumentsContract.Document), permisos y soporte de eliminación. No se publica ni se envían cambios a GitHub por este pedido. La versión publicada sigue siendo v0.2.4-alpha.1; dist/0.2.4 se conserva.

## Verificaciones y límites

Análisis estático limpio y 46 pruebas automatizadas aprobadas, incluyendo borrado exitoso/fallido, cancelar/confirmar desde menú, título largo con movimiento reducido y carátulas tardías con duración conservada. Las pruebas del actualizador usan una versión futura sintética para seguir verificando descargas tras avanzar la versión local. Capturas de reproductor móvil/escritorio renovadas; móvil 360 px con texto 130 % revisado. Falta comprobación física de carátula/controles en Galaxy/Poco, borrado SAF en almacenamiento interno/SD con permiso nuevo y anterior, y reproducción prolongada con pantalla apagada. No se afirma validación física ni de borrado real en Windows.

Relaciones: [[18 Pruebas 0.2.3 y correcciones 0.2.4]], [[03 Biblioteca y reproduccion]], [[15 Identidad visual e icono]], [[10 Estado del repositorio]], [[09 Registro de cambios]].

## APK local verificado

Compilación release normal completada. APK universal en build/app/outputs/flutter-apk/app-release.apk: 57 067 540 bytes, versionName 0.2.5, versionCode 7, SHA-256 F6C71F73FA534F4D35EC6C8B756FB37C448C6C47FBBCAE953E743F219D30A90F. Verificador de recursos multimedia aprobado, incluidos cinco iconos nuevos. git diff --check correcto. La primera compilación encontró un registro generado con integration_test al ejecutar herramientas Flutter concurrentemente; la secuencia final pruebas y luego compilación completa regeneró el registro release correctamente. No compilar y ejecutar pruebas Flutter en paralelo. Sin nueva compilación Windows ni comprobación nativa/física de carátulas y borrado SAF.

## Publicación autorizada de 0.2.5 — 2026-10-25

El usuario solicita actualizar también escritorio y subir la nueva release a GitHub. Se prepara v0.2.5-alpha.1 preliminar con APK universal/ARM64 y Windows x64, guías, ejemplo y SHA-256. Se autoriza por este pedido el envío de fuentes y publicación; confirmar resultados y adjuntos al terminar. Se preservan versiones anteriores.

## Preparación multiplataforma comprobada

Windows release recompilado en 0.2.5+7. Prueba nativa con WAV sintéticos aprobada: cambios repetidos, volumen, bandeja y borrado real de una pista cargada tras detenerla, con limpieza de favoritos/listas/cola y conservación de los otros archivos. ZIP completo verificado con EXE, motor, backend, data, fuentes, icono, guías y ejemplo, sin integration_test.

Dist/0.2.5 contiene APK universal de 57 067 540 bytes, APK ARM64 de 21 340 769 bytes y ZIP Windows de 14 210 778 bytes. Ambos APK 0.2.5+7, firma v2 válida del mismo certificado que 0.2.4, recursos multimedia presentes y alineación ZIP 16 KB aprobada. Universal ARM32/ARM64/x64; variante solo ARM64. Guías de uso/pruebas renovadas y SHA256SUMS generado. La validación física de Android y el recorrido público de actualización quedan pendientes.

## Publicación confirmada de 0.2.5 — 2026-10-25

[Release v0.2.5-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.2.5-alpha.1) pública como preliminar; GitHub confirmó isDraft=false e isPrerelease=true. Etiqueta sobre 4e65a619a6ebed4b869cb2404f0eee221ae8690c y fuentes enviadas a main. Siete adjuntos en estado uploaded, verificados por tamaño y SHA-256 de GitHub contra dist/0.2.5: APK universal/ARM64, Windows x64, USO.md, PRUEBAS-0.2.5.md, descubrir.json y SHA256SUMS.txt. Windows incluye las mejoras compartidas y prueba nativa aprobada, incluido borrado real. La confirmación se registra después del commit etiquetado.

La publicación conserva releases anteriores y no sustituye las pruebas físicas Android, instalación Tecno, actualización entre releases desde el instalador ni retesteo con los archivos originales de Windows.
