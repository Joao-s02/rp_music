---
tipo: experimento-local-controlado
estado: confirmado-por-usuario-publicacion-en-preparacion
actualizado: 2026-10-29
---
# Diagnostico local de instalacion y actualizaciones manuales

## Autorización y límites

El usuario rechaza contactar a Google y pide intentar una investigación local. No enviar apelación, solicitar correo ni hacer nuevas subidas a VirusTotal/otros escáneres sin otra autorización. La subida0.3.14 previamente autorizada ya terminó. Conservar claves, packageName, funciones musicales, datos y protecciones Android. No cambiar identidad ni opacar código para esquivar una detección. [[43 Play Protect y firma de Android]].

## Reproducción nueva

En emuladorAPI37, abrir el mismo APK0.3.14 desde Downloads mediante DocumentsUI, pasar el aviso general de origen desconocido y confirmar Update reproduce Google Play Protect: Harmful app blocked / This app may be harmful. More details solo añade texto genérico de riesgo y enlace/Install anyway. No se pulsó Install anyway; se cerró con Got it. Evidencia XML/PNG local en dist/rp-install-blocked*. El análisis anterior de app instalada sin alertas no prueba el flujo de instalación; ahora se dispone de reproducción del bloqueo específico en emulador.

## Prueba propuesta e implementada localmente

Un permiso REQUEST_INSTALL_PACKAGES no es necesario para reproducción musical. Existía antes y no está confirmado como causa de la detección. Google Play lo considera de riesgo/restringido en su tienda; esas políticas no equivalen automáticamente a un veredicto Play Protect ni justifican acusar la app de ser downloader hostil. Referencias: https://support.google.com/googleplay/android-developer/answer/12085295 y https://developers.google.com/android/play-protect/warning-strings . No se identificó una categoría concreta en el aviso.

Se crea un perfil local explícito de manifiesto reviewNoInstaller que retira solamente REQUEST_INSTALL_PACKAGES; no es cambio por defecto de la release. Misma app0.3.15+24, mismo código compilado/firma/packageName y mismas extensiones. Native info informa el permiso real; sin él, el actualizador conserva consulta de versiones y abre la release oficial en navegador, sin descargar APK interno ni invocar instalar. UI informa Descargar desde la web y evita pausar audio. No se elimina el actualizador completo ni capacidades musicales/SDK. Android conserva verificaciones de firma y Play Protect en instalación desde Archivos.

Control: build-android-signed.ps1 sin flag. Variante: -NoDirectInstaller. Ambos en dist/play-protect-local-0315. Verificar igualdad de AOT/DEX/bibliotecas/recursos y diferencia real de permisos antes de interpretar resultados. Aún no hay resultado de clasificación para esos paquetes; no prometer que la retirada resuelva el aviso.

## Verificación parcial

Diez pruebas dirigidas de actualizador aprobadas, incluidas dos nuevas (modo manual sin descarga ni instalador y diálogo que abre release sin pausa). Fixture de prueba real de LocalStore en reloj simulado se sustituyó por MemoryStore para evitar espera de IO en la prueba de widgets; no se registra como fallo de IO de producto. Compilación y pruebas deben ejecutarse por separado; un arranque solapado se detuvo antes de recompilar los artefactos finales. Primer intento de compilación falló por plugin de integración en archivo generado ignorado; herramienta de firma retira ese bloque de pruebas de forma acotada antes de compilar la entrada normal.

Ambos APK compilados y firmados: control SHA256 `44d2989a52fef331084a8e7ca2f2f17703c2839e0314d9ca574f4b9bca6fe1a9`; variante manual `d10238a37d5c59b12b3796e43e7c0ff3e89260250c14a01148806413d6634a34`. Comparación local `dist/0.3.15-profile-comparison.json`: DEX, AOT Flutter, bibliotecas y recursos idénticos; solo cambian manifiesto y firmas de integridad. Permisos difieren únicamente en REQUEST_INSTALL_PACKAGES. Análisis estático del 29 de octubre sin incidencias. Pruebas completas y clasificación por instalación en curso.

Suite completa del 29 de octubre: 166 aprobadas, una optativa omitida. Imágenes de diseño respaldadas y restauradas. En el arranque del emulador aparecen ANR de System UI/Process system; reinicio sin cargar snapshot y sin borrar datos. Esto es un problema del entorno, no un resultado de clasificación de los candidatos.

## Instalador del 29 de octubre

Tras recuperar Android, DocumentsUI muestra los archivos pero no completa su apertura. Se abre el control mediante ACTION_VIEW del URI de ExternalStorageProvider, conservando el instalador y Play Protect del sistema. Esta vía difiere de la reproducción anterior desde DocumentsUI y debe constar como límite. Tras confirmar Update, Play Protect solicita App scan recommended / Scan app: enviar el APK a Google. No es un resultado limpio ni un bloqueo confirmado del control. Captura local `dist/play-protect-local-0315/scan-request.png` y XML `dist/rp-control-result-final.xml`.

No se pulsa Scan app. Por la negativa anterior del usuario a contactar con Google, se solicita distinguir autorización de análisis automático frente a contacto/apelación. Variante manual todavía no instalada. No afirmar solución; no publicar estos candidatos.

Autorización posterior del usuario, 29 de octubre: «Sí, autorizar el análisis automático». Autoriza la comparación de ambos paquetes mediante el análisis de Play Protect; no soporte/apelación. Se pulsa Scan app para el control y aparece Scanning. Resultado todavía pendiente.

## Resultado comprobado y decisión vigente

El análisis automático del control termina en **Harmful app blocked / This app may be harmful**. Se cierra con Got it, sin ignorar bloqueo. La variante manual se abre por el mismo ACTION_VIEW, solicita su propio análisis y termina en **This app looks safe / You can continue to install it**. Capturas `control-blocked.png` y `manual-safe.png` en `dist/play-protect-local-0315/`. Diferencia reproducible de los dos candidatos en este emulador; no confirma una categoría interna ni aceptación universal.

Se pulsa Install únicamente después del resultado seguro. Android confirma App updated. Versión instalada0.3.15+24, sin REQUEST_INSTALL_PACKAGES, fecha original de instalación conservada y lista `RP-firma-conservada-0314` presente en UI. APK instalado extraído y SHA256 coincide exactamente con la variante analizada. La biblioteca de prueba está vacía: no se presenta esto como comprobación nueva de reproducción física. No se borran datos ni se desactiva Play Protect.

Decisión posterior: el perfil sin instalador pasa a ser predeterminado para release y herramienta de firma. El control requiere `-NoDirectInstaller:$false` explícito; no distribuirlo. `RP_ANDROID_NO_DIRECT_INSTALLER=false` existe solo para diagnóstico. Se conserva el mecanismo musical y de extensiones; cambia únicamente la actualización de la propia app a navegador/Archivos. El APK aceptado se copia sin modificar a `dist/RP-Music-0.3.15-android.apk`, mismo hash. No publicado; prueba del teléfono del usuario pendiente. No enviar apelación/contactar soporte.

Verificación final del valor predeterminado: `:app:processReleaseMainManifest --offline` sin variable de perfil termina BUILD SUCCESSFUL; manifiesto combinado confirmado sin REQUEST_INSTALL_PACKAGES. No se modifica el APK ya analizado. `git diff --check` sin errores de espacio. No commit/push/release en esta fase.

## Confirmación física y publicación autorizada — 2026-10-29

El usuario confirma: «ahora google play protec ni aparece, directo instala la app». Resultado del universal en su teléfono, modelo/versiones no registrados; no se interpreta como protección desactivada ni garantía para todos los equipos. Luego autoriza publicar la nueva release. Se prepara 0.3.15+24, universal exacto probado, ARM64 y Windows completos con guías/hashes; no modificar catálogo externo. Verificación de borrador obligatoria antes de publicar. [[44 Diagnostico local de instalacion y actualizaciones manuales]].
