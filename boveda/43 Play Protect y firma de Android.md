---
tipo: investigacion-de-distribucion
estado: corregido-en-candidato-confirmado-por-usuario
actualizado: 2026-10-29
---
# Play Protect y firma de Android

## Informe confirmado

El usuario informa que Play Protect califica la app como dañina desde la versión anterior y la actual (contexto0.3.12/0.3.13) y señala el efecto sobre confianza/instalaciones. Texto literal, categoría, captura, dispositivo y versión de Play Protect pendientes. No equivale a clasificación reproducida por el agente ni a falso positivo confirmado.

## Aclaración posterior del usuario

Primero pide enviar la app para analizar. En versiones anteriores el análisis terminaba indicando que era segura; desde la versión anterior y la actual, después del análisis advierte que posiblemente es dañina, aunque permite instalar. Es descripción del usuario, no transcripción literal ni categoría técnica reproducida. Por tanto, no reducir el incidente a app desconocida o solicitud inicial de escaneo. Pendientes captura/texto final, categoría y dispositivo. La firma de depuración y los permisos ya existían antes: no explican por sí solos el cambio temporal del resultado. Priorizar comparación de versiones/bibliotecas y clasificación específica, con revisión oficial si corresponde. Cambiar firma no debe usarse para eludir el veredicto.

## Comprobación local

APK publicado0.3.13 examinado con aapt/apksigner: firma válida, certificado CN=Android Debug; SHA256 eba2769ed11d359c8f89f6991bc6867c7766f6f46a4295bc5386e7d41ce7d38d. Gradle release usa signingConfigs.debug. Una compilación release puede llevar certificado debug: las comprobaciones anteriores de integridad/compatibilidad de actualización no equivalen a firma de producción adecuada ni certificación antimalware. Mantener el certificado explicaba compatibilidad, pero no justifica seguir publicando con identidad de depuración.

Permisos efectivos del APK: WAKE_LOCK, INTERNET, REQUEST_INSTALL_PACKAGES, FOREGROUND_SERVICE, FOREGROUND_SERVICE_MEDIA_PLAYBACK, POST_NOTIFICATIONS, ACCESS_NETWORK_STATE y permiso interno de receptor no exportado. No declara SMS/contactos/accesibilidad/lector de notificaciones ajenas. POST_NOTIFICATIONS no equivale a NOTIFICATION_LISTENER. REQUEST_INSTALL_PACKAGES sirve al actualizador: comprueba hash, identidad, versión y mismo certificado antes de abrir el instalador de Android; no demuestra por sí mismo la causa del aviso.

Comparación Git v0.3.11-alpha.1..v0.3.13-alpha.1: manifiesto, configuración de firma y dependencias pubspec sin cambios relevantes (solo versión de app). No atribuir el comienzo del aviso a permisos recién añadidos. No se han auditado exhaustivamente dependencias ni reproducido el veredicto de Google; no afirmar ausencia de código dañino ni que el aviso sea mero desconocimiento.

## Documentación oficial consultada

- [Tipos de aviso y diagnóstico](https://developers.google.com/android/play-protect/warning-dev-guidance): distingue app dañina, escaneo recomendado, envío a comprobación y bloqueo por permisos sensibles. Mensaje exacto necesario para clasificar. No todos se resuelven mediante apelación.
- [Firma Android](https://developer.android.com/studio/publish/app-signing): certificado debug inadecuado para publicación; cambiar certificado sin transición válida rompe actualización directa. No sustituir firma ni ID a ciegas: plan de migración y preservación de datos antes de distribuir.
- [Revisión de clasificación](https://support.google.com/googleplay/android-developer/answer/2992033): apelación oficial si tras revisión se considera clasificación incorrecta; no hay apelación enviada ni respuesta de Google.

## Próximos pasos propuestos

Obtener texto exacto del aviso, revisar categoría y componentes afectados, preparar firma propia de producción con custodia/respaldos y transición compatibles, revisar permisos/SDK necesarios. Si corresponde a clasificación dañina incorrecta tras auditoría, preparar informe con APK/hash y solicitar revisión oficial con autorización del usuario. Cambiar firma no garantiza eliminar el aviso. No recomendar desactivar Play Protect ni cambiar identidad para esquivar una clasificación. No se han cambiado claves, identidad, permisos, binarios ni releases en esta investigación.

Antecedentes: [[17 Actualizaciones opcionales desde la app]], [[27 Publicacion de releases - contenido obligatorio]], [[42 Albumes y extensiones con identidad RP 0.3.13]].

## Implementación autorizada posterior — candidato0.3.14+23

Usuario solicita solucionar el problema. Se implementa firma de producción sin fallbackdebug, inicialización privada con contraseña aleatoria/DPAPI/ACL y exclusiónGit. tools/build-android-signed.ps1 valida identidad histórica, genera prueba de rotación y verifica APKfinal. Huella pública nueva f1aa76f72f2c5df21ddeb5da304c7b7b8f9cbea320560b2767f18d0e49e7723f. No se guardan credenciales en bóveda. Helper de respaldo interactivo disponible; pendiente que propietario custodie copia recuperable con contraseña propia.

Android9+ usa clave propia con linaje; Android6–8 mantiene firmante antiguo por compatibilidad. No se cambia applicationId ni se quitan funciones/permisos para evadir una clasificación. AppUpdates reconoce descendientes del certificado instalado, conservando hash/version/identidad y verificación final Android. La primera transición desde0.3.13 debe abrirse desde Archivos/Descargas porque su instalador interno exige firma idéntica.

Bloqueo comprobado: GradleassembleRelease --dry-run sin credenciales falla explícitamente. APK normal compilado211.8s; firma válida general/v2/v3 y por rangosAPI23–27/28–32. EmuladorAPI37 actualiza0.3.13→0.3.14 sin desinstalar; listaRP-firma-conservada-0314 y firstInstallTime conservados después de reinicio. SHA256 del APK instalado coincide exactamente con candidato 779936fdcae781ed5ab87ab7e08345043365d982ff60e68e2008ba87a904245a.

Play Protect se ejecutó en emuladorAPI37 con GMS26.36.35 y PlayStore53.7.23-34: No harmful apps found, RP Music entre recién analizadas. Evidencia XML/PNG guardada localmente. Se probó análisis de app instalada, no el análisis de instalación del teléfono del usuario; no se declara resuelta globalmente la detección ni respuesta de Google. El chequeo anterior del emulador no era una comparación controlada con0.3.13: no atribuir causalidad demostrada a la nueva firma.

Comparación reproducible tools/audit_android_apks.py:0.3.11→0.3.13 sin cambiosDEX ni bibliotecas nativas de terceros; cambiosAOTFlutter, sin altas/bajas de entradas ZIP ni corrupción/duplicados. No equivale a auditoría exhaustiva ni escáner antimalware. Informe técnico preparado en docs/PLAY-PROTECT-REVIEW.md, no enviado. Candidato y guía de prueba local en dist/play-protect-review; no publicado ni push. Prueba física del flujo de instalación y veredicto específico pendientes.

Cierre de regresión:164 pruebas aprobadas/una optativa omitida y análisis limpio. Reanálisis del APK final tras empaquetar firmas: mismo resultado sin apps dañinas, RP Music listada, hash cotejado con APK instalado. Flujo del teléfono original aún pendiente.

## Resultado físico informado después del candidato

El usuario informa que sigue apareciendo como app dañina después de recibir el APK0.3.14 de revisión. Se registra como continuidad de la detección en teléfono, no como corrección resuelta. Falta comprobar hash del archivo efectivamente probado, texto/categoría exactos y versiones del dispositivo/Play Protect; no atribuir causa sin esos datos. El análisis instalado sin alertas del emulador conserva su alcance limitado y no contradice ni sustituye este resultado. No afirmar que la firma elimina el aviso ni recomendar otra identidad/menos funciones como evasión.

Informe de revisión actualizado con resultado persistente. No se ha enviado a Google; envío requiere autorización explícita de contacto y posiblemente la cuenta del propietario. La captura del aviso final es el dato siguiente necesario para conocer la categoría y orientar auditoría específica.

Formulario oficial consultado: exige correo, packageName, SHA256 de APK subido a VirusTotal e información de apoyo. Indica que decisiones son finales y no habrá respuesta; no prometer diagnóstico detallado de Google. No se subió el candidato a VirusTotal ni se envió formulario. Autorizar contacto/subida y obtener correo son dependencias adicionales si procede apelar; primero precisar categoría del aviso.

## Captura recibida — bloqueo de app dañina

La captura del usuario muestra Google Play Protect, RP Music, título «Se bloqueó la app dañina» y texto «Es posible que esta app sea dañina». Ofrece Instalar de todas formas y Entendido. Es evidencia visual de bloqueo por posible daño, no mera app desconocida ni petición de analizar. No muestra nombre de amenaza, categoría específica, hash/versión del APK, versión de Android o de Play Protect; no inferir malware específico ni falso positivo. No copiar la captura completa al repositorio porque contiene elementos del entorno personal ajenos al diagnóstico.

Se añade texto exacto al informe. Siguiente paso propuesto: analizar el APK0.3.14 de revisión en VirusTotal, con autorización explícita porque el servicio puede compartir archivo con socios/clientes y hace públicos informes. No se subió nada ni se contactó a Google. Resultados VT serían indicios adicionales, no equivalencia garantizada al veredicto de Play Protect. Solicitud de Google requiere hash de APK subido a VT; no prometer resolución/reclasificación sin resultado.

## VirusTotal autorizado — 2026-10-28

El usuario autoriza explícitamente subir el APK0.3.14 de revisión a VirusTotal tras conocer la compartición del archivo/informe. Hash779936fdcae781ed5ab87ab7e08345043365d982ff60e68e2008ba87a904245a verificado localmente. Consulta previa del hash: Item not found. Archivo seleccionado y Confirm upload pulsado; subida en curso, no confundir con análisis completado. No autoriza todavía apelación/contacto a Google.

## VirusTotal completado — 2026-10-28

Subida explícitamente autorizada y completada del APK0.3.14, SHA256779936fdcae781ed5ab87ab7e08345043365d982ff60e68e2008ba87a904245a. [Informe público](https://www.virustotal.com/gui/file/779936fdcae781ed5ab87ab7e08345043365d982ff60e68e2008ba87a904245a/detection). Resultado visible: ningún proveedor marca malicioso; 67 Undetected, 7 tipo no soportado y Google Failure. No contar Failure como limpio ni equiparar este informe a Play Protect: aviso del teléfono permanece sin resolver. Evidencia AX/PNG local y texto de apelación preparado, no enviado. Solicitar autorización de contacto y correo del propietario antes de presentar a Google.

## Nueva investigación local autorizada

El usuario no quiere contactar a Google; se descarta enviar apelación en este trabajo. Se reproduce el bloqueo instalando desde Archivos en emulador, no solo escaneando la app instalada. Perfil controlado con actualización manual y límite de interpretación en [[44 Diagnostico local de instalacion y actualizaciones manuales]].

## Cierre posterior del caso probado

0.3.15 sin permiso de instalación aceptada por Play Protect en comparación controlada; usuario confirma instalación directa sin advertencia en su teléfono. Firma sola no bastó. Evidencia, alcance y actualización por web/Archivos: [[44 Diagnostico local de instalacion y actualizaciones manuales]]. Sin apelación ni garantía universal.
