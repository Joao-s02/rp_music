# Comparación local de Play Protect 0.3.15

Estado: candidato local sin publicar. Play Protect acepta la variante en emulador API37; falta comprobar el teléfono del usuario. El control fue bloqueado tras analizarse por la misma vía.

Los dos APK se encuentran en `dist/play-protect-local-0315/`:

- `RP-Music-0.3.15-android-review.apk`: control con instalador interno.
- `RP-Music-0.3.15-android-manual-updates-review.apk`: actualizaciones mediante página oficial y Archivos, sin permiso para solicitar instalaciones.

El código musical, extensiones, recursos y bibliotecas son idénticos en ambos. Solo difieren el permiso del manifiesto y las firmas de integridad. Los hashes están en `SHA256SUMS.txt`. Se conserva la identidad y la transición de firma; no desinstalar para actualizar.

Para comprobar la variante, copiar el segundo APK a Descargas y abrirlo desde Archivos. Mantener Play Protect activo. Si aparece el bloqueo, registrar el texto y cancelar; no es necesario ignorarlo. Si instala, comprobar versión, listas y biblioteca. El resultado en un dispositivo no garantiza el de todos los demás.

Las descargas de música y las extensiones no se eliminan. El cambio afecta a la actualización de la propia aplicación: abre la página oficial para descargar la versión siguiente y después instalarla desde Archivos.

Verificación del código: 166 pruebas aprobadas, una opcional omitida y análisis sin incidencias. Esto no constituye un veredicto de Play Protect. Evidencia y estado: [Diagnóstico local](../boveda/44%20Diagnostico%20local%20de%20instalacion%20y%20actualizaciones%20manuales.md).

El modo sin instalador es ahora el predeterminado. `-NoDirectInstaller:$false` y `RP_ANDROID_NO_DIRECT_INSTALLER=false` permiten reproducir exclusivamente el control diagnóstico. Copia del APK aceptado sin modificar: `dist/RP-Music-0.3.15-android.apk`.
