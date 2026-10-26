---
tipo: pruebas-y-mejoras
estado: implementado-con-validacion-local
actualizado: 2026-10-25
---
# Pruebas 0.2.5 y mejoras 0.2.6

## Informe confirmado

El usuario reporta que Ver actualización no conduce a una descarga utilizable; solicita ventana centrada con versión actual/nueva, Actualizar para descargar y Actualizar después. Confirma que borrar funciona al reelegir carpeta desde Ajustes, pero pide mejorar autorización de escritura. Solicita widget Android de inicio y orden por varios criterios/dirección. Quiere profundizar en extensiones mediante preguntas; respuestas en [[22 Extensiones - alcance del primer sistema]]. No ha solicitado publicar esta nueva versión ni hacer push.

## Implementación local 0.2.6+8

### Actualizaciones

Se sustituye el banner por una oferta centrada, una vez por consulta con una versión disponible, con versión instalada y encontrada, tamaño, novedades, descarga con progreso/cancelación y botón posterior de instalar Android. Actualizar después cierra sin omitir permanentemente la versión; Ajustes permite reabrir el detalle. Se conserva la verificación SHA-256, validación nativa de paquete/firma/código e instalador con confirmación Android. Windows también descarga y verifica el ZIP desde la aplicación y permite mostrarlo en el explorador; extracción/reemplazo siguen siendo manuales. No reemplaza el EXE en ejecución. El enlace web sigue disponible en el controlador como alternativa.

### Escritura y borrado

Antes de detener/borrar se comprueba el permiso de escritura persistido. Si falta, se abre el selector Android orientado a la raíz actual y se solicita lectura/escritura: debe autorizarse la misma carpeta; otra no se acepta para borrar el documento original. Cancelar conserva archivo/referencias y no detiene la pista. Ajustes ofrece Permitir eliminar archivos. Al elegir raíz nueva ya se solicitaba escritura desde 0.2.5; el permiso antiguo de solo lectura no se amplía por actualizar un APK.

No existe un interruptor de escritura SAF en Ajustes generales de permisos. El usuario debe autorizar la carpeta mediante el selector; no se puede conceder sin él. Recomendación vigente: mantener la carpeta elegida y pedir escritura en contexto al intentar borrar. Alternativa futura en investigación: para medios indexados y mapeables, MediaStore.createDeleteRequest permite consentimiento del sistema por archivo/grupo; no cubre todos los proveedores SAF y no está implementado. No se añaden permisos generales de todos los archivos.

### Widget Android

Proveedor nativo de widget redimensionable para inicio con título, artista, carátula disponible y anterior/reproducir-pausar/siguiente. Se conecta mediante MediaBrowser/MediaController a la misma sesión de audio; no crea otro reproductor. Actualizaciones por eventos, sin consultas periódicas. Imagen reducida para RemoteViews; icono como alternativa. Tocar carátula/título abre la aplicación. Ajustes ofrece Añadir widget y alternativa manual si el launcher no admite fijarlo.

La reproducción solicitada sin pista espera la restauración de biblioteca/sesión; si no hay sesión y hay canciones, prepara la primera según el orden elegido. No inicia reproducción espontáneamente por colocar el widget: solo por pulsar sus controles. Se declara dependencia AndroidX media 1.7.0 para la sesión compatible utilizada por audio_service; no se sustituye ese servicio ni sus parches. Proveedor registrado y conexión/comandos/estado de la sesión comprobados en emulador API 37. Falta verificar el gesto de añadir y la presentación en launchers/teléfonos físicos.

### Orden

Selector por título, artista, álbum, duración, fecha de modificación, tamaño y nombre de archivo, más botón ascendente/descendente. Preferencia persistida. Se aplica a las vistas de canciones (biblioteca, favoritos, grupos y listas) sin reescribir los IDs guardados de las listas; la cola nueva sigue el orden visible al elegir una canción. No reordena la cola ya iniciada al cambiar la preferencia. Comparación de texto independiente de mayúsculas y vocales acentuadas; no se promete colación completa de todos los idiomas. Fecha significa modificación del archivo, no fecha de incorporación al catálogo.

## Verificación y límites

Pruebas nuevas para siete criterios/dirección, persistencia, solicitud de escritura antes del borrado, reproducción solicitada antes de restaurar, descarga ZIP Windows y oferta centrada con botón de descarga/cierre/reapertura. 52 pruebas automatizadas aprobadas y análisis estático limpio. Prueba nativa debug Android API 37 aprobada: registro del proveedor, conexión MediaBrowser, título, pausa/anterior/siguiente por el mismo código del widget, cambio automático en segundo plano, pausa/reanudación y liberación foreground al detener. Inicio frío: prueba Dart de solicitud antes de restaurar aprobada; la conexión nativa espera la publicación del handler antes de enviar controles, pero no se anuncia como recorrido completo de muerte del proceso/launcher ya validado. Captura de ventana de actualización a 360×740 y texto 130 % generada y revisada, sin desbordes, en design/verification/update-0.2.6-mobile.png. Falta probar escritura SAF interna/SD y widget en Galaxy/Poco; el retesteo prolongado y actualización real entre releases siguen pendientes. La release publicada sigue siendo v0.2.5-alpha.1.

Fuentes: [Storage Access Framework](https://developer.android.com/training/data-storage/shared/documents-files), [MediaStore y eliminación](https://developer.android.com/training/data-storage/shared/media), [widgets Android](https://developer.android.com/develop/ui/views/appwidgets/overview). Consultadas 2026-10-25.

Relaciones: [[20 Pruebas 0.2.4 y mejoras 0.2.5]], [[17 Actualizaciones opcionales desde la app]], [[03 Biblioteca y reproduccion]], [[22 Extensiones - alcance del primer sistema]], [[10 Estado del repositorio]], [[09 Registro de cambios]].

## Cierre de validación local

- Análisis estático limpio y 52 pruebas unitarias/widgets aprobadas.
- Prueba nativa debug Android API 37 aprobada con proveedor registrado, conexión y controles del widget sobre la sesión real, título/estado, cambio automático en segundo plano, pausa/reanudación y liberación al detener. Se corrigió la espera de la prueba porque pulsar Anterior reinicia el WAV sintético de cuatro segundos; no era fallo de avance. La conexión espera a que Dart publique sus controles antes de enviar una acción de inicio frío. El recorrido completo tras muerte del proceso y el gesto/presentación del launcher siguen sin validación física.
- Prueba nativa Windows aprobada: cambios repetidos, volumen, bandeja y borrado real de pista cargada con conservación de otros archivos.
- Windows release recompilado y EXE 0.2.6+8 comprobado. ZIP portable completo validado, con motor/backend/data/guías/ejemplo y sin integration_test.
- APK universal release de entrada normal compilado y confirmado 0.2.6+8, mismo certificado que 0.2.5, iconos multimedia presentes, proveedor MusicWidget en manifiesto y alineación ZIP 16 KB aprobada. Contiene ARM32/ARM64/x64.
- Captura centrada 360×740 con texto 130 % y tema real revisada.
- Paquetes locales en dist/0.2.6; guías USO-0.2.6.md y PRUEBAS-0.2.6.md en docs, y SHA256SUMS en dist. Sin publicación ni push; v0.2.5-alpha.1 sigue publicada.

- RP-Music-0.2.6-android.apk: 57332900 bytes; SHA-256 dc36f5560d18a2f07b41ee83040fe5b57a83546c17520d1b99de0fd5ea006cfe.
- RP-Music-0.2.6-windows-x64.zip: 14244352 bytes; SHA-256 4a8fb280182bc4a45823ee3205ab2f8a70d1e8ffda7ad789af1c7c45145f2428.

## Publicación 0.2.6 autorizada — 2026-10-25

El usuario solicita publicar 0.2.6 antes de comenzar la implementación programable de extensiones. Se prepara v0.2.6-alpha.1 con APK universal/ARM64, Windows x64, guías, ejemplo y hashes. Fuentes de 0.2.6 y requisitos de la entrevista se incluyen; el código nuevo de extensiones será un incremento posterior separado. Confirmar publicación/adjuntos al terminar.
