# APK de revisión 0.3.14+23

Este candidato corrige la configuración de firma y permite verificar el aviso reportado. No es una release pública ni una confirmación de que Google haya corregido una clasificación.

## Cómo probar sin borrar datos

1. Conservar instalada RP Music. No desinstalar ni borrar sus datos.
2. Transferir RP-Music-0.3.14-android-review.apk al teléfono y abrirlo desde Descargas/Archivos. No usar el instalador interno de0.3.13: su comprobación de igualdad de firmas no reconoce la transición nueva. Usar el instalador de Android conserva sus verificaciones de firma y Play Protect.
3. Comprobar que ofrece Actualizar. Si aparece conflicto de firma, detenerse y conservar los datos; no desinstalar para forzarlo.
4. Mantener Play Protect activado. Si pide analizar, permitir el análisis y comprobar el resultado final. Si vuelve a advertir de posible daño, detener la prueba y guardar captura/texto, versión de Android y versión de Play Protect para revisión oficial.
5. Tras actualizar, comprobar listas, favoritos, ajustes, carpeta/biblioteca, extensiones y reproducción. No se modifica la música original.

## Qué se comprobó

APK0.3.14+23 universal, mismo identificador com.example.rp_music. Android9+ usa una clave de producción propia y prueba criptográfica de rotación; Android6–8 conserva la identidad anterior para mantener actualizaciones. No se oculta ese límite: no es una sustitución completa de la clave de depuración en plataformas antiguas.

Firma validada paraAPI23–27 yAPI28–32, además de verificación general. En emulador AndroidAPI37, actualización0.3.13→0.3.14 mediante instalar-reemplazar, sin desinstalar; lista sintética y fecha de instalación conservadas después de reiniciar la app.

Play Protect del emulador: análisis ejecutado después de instalar, resultado No harmful apps found, RP Music visible entre aplicaciones recién analizadas. GMS26.36.35 y Play Store53.7.23-34. Es análisis de aplicación instalada: no equivale al análisis de instalación en el teléfono original ni acredita una revisión/retirada de detección por Google. El mismo APK analizado se verificó por SHA256 contra el candidato entregado.

Comparación0.3.11→0.3.13: DEX y bibliotecas nativas de terceros idénticos; cambiaron AOT Flutter/recursos. ZIP sin entradas duplicadas ni corrupción. Este cotejo no es un escáner antimalware ni determina el motivo del aviso.

## Resultado posterior del usuario

El aviso persiste en el teléfono. Este candidato no debe presentarse como solución confirmada. Pendientes texto/categoría exactos y revisión específica; el resultado del emulador no sustituye el del dispositivo afectado.
