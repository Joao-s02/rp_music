# Probar RP Music 0.3.0+9 — extensiones experimentales

Release v0.3.0-alpha.1 para Android y Windows. Incluye el motor API 2 y permite instalar ambos ejemplos desde archivo/repositorio; no los lleva embebidos. No requiere archivos musicales privados para las pruebas automatizadas.

## Instalar

Android: instalar el APK sobre la versión anterior sin desinstalar. Windows: salir de la anterior desde la bandeja, extraer el ZIP completo y abrir rp_music.exe con DLL/data. No abrir versiones simultáneas sobre los mismos datos. Elegir la carpeta de música habitual o una carpeta con copias de prueba.

## Biblioteca viva

1. En Extensiones, pulsa Instalar Biblioteca viva. Ningún permiso viene aceptado automáticamente: revisa lectura de metadatos, reproducción, listas y datos propios; acepta y activa si estás de acuerdo.
2. Vuelve a Biblioteca. Debe aparecer Biblioteca viva, con sus resultados y Filtros combinados contraíbles. Prueba artista, álbum, carpeta, duración y favoritos juntos; la búsqueda de la cabecera también se aplica.
3. Reproduce/mezcla resultados. Guardar lista crea una copia manual; Crear lista automática guarda las reglas además de su composición.
4. En Listas, abre la lista y Cambiar carátula. Prueba imagen propia y después mosaico automático. No se modifica ninguna imagen original ni archivo musical.
5. Añade una canción a la carpeta y actualiza el catálogo; cuando termine el escaneo, debe recalcularse la lista automática. Prueba también cambiar favoritos si la regla usa ese filtro.
6. Desactiva la extensión. La regla queda inactiva y conserva su última composición/carátula. Reactivarla permite recalcular. Una lista automática no permite editar integrantes manualmente para evitar que las reglas sobrescriban esas ediciones.

## Dos extensiones y nivel avanzado

Instala Pulso nocturno y revisa también Sustituir funciones base. Puede coexistir con Biblioteca viva. En Quién controla cada función comprueba propietarios de biblioteca, reproductor y aleatorio. Abre el reproductor ampliado: Pulso nocturno coloca controles antes de carátula. Activa Aleatorio para probar la política de cambiar de artista cuando existe alternativa en la cola. El motor, notificación y widget continúan siendo los originales.

Cambiar de propietario o volver a una personalización API 1 se hace explícitamente desde Extensiones. Volver a la base · modo seguro desactiva programas sin borrar música, listas ni carátulas. Comprueba que se conserva todo al cerrar y volver a abrir.

## Importar archivo propio

Los ejemplos `.rpmx` también están junto a sus fuentes en examples/extensions/programables. Importar extensión permite elegir esos archivos; no se recompila la aplicación. Un paquete reemplazado requiere revisar permisos. Prueba cancelar antes de aceptar: no debe sustituir ni activar nada.

## Alcance y límites

65 pruebas automatizadas, análisis limpio y comprobaciones del intérprete en ejecutables release de Windows y Android. Las sondas usan datos sintéticos y comprueban filtros, política, diseño y terminación de bucles; las capturas/widget tests comprueban interfaz, creación de listas, opciones de imagen/mosaico y modo seguro. Falta validar en teléfono físico el recorrido completo de instalar/interactuar, selector de imagen y bibliotecas grandes. No se promete toda la libertad de Flutter ni ejecución de código hostil: solo ejemplos/código de confianza mientras sea experimental. Red para programas, escritura de música y aislamiento duro de memoria aún no forman parte del SDK. El catálogo remoto lo consulta la app bajo acción explícita del usuario.

Ver docs/EXTENSIONES-API-2.md y la nota 23 de la bóveda para el contrato técnico y resultados finales de paquetes.


Catálogo, revisión 2026-10-26: dos pruebas de validación de enlaces/índices y nueve regresiones de sistema/UI aprobadas; las dos UI de 360/1280 se repitieron incluyendo abrir/cancelar el diálogo de repositorio y ausencia de botones offline. Análisis final limpio. Descarga real de ambos paquetes publicados verificada mediante tools/verify_extension_catalog.dart. Las sondas AOT citadas arriba corresponden al prototipo anterior; no se repitieron para el catálogo.


Publicación 0.3.0: incluye el indicador de versión Instalada/Actualizar en el catálogo. YouTube Music es de la 0.3.1 separada y no está soportado en esta release. Registro de verificaciones finales: boveda/25 Release 0.3.0.md.


Validación del candidato publicado: 68 pruebas automatizadas y análisis limpio, más regresión Windows nativa de reproducción/volumen/bandeja/borrado aprobada. Los resultados de sondas AOT del prototipo anterior se mantienen como antecedentes, no una nueva prueba física.
