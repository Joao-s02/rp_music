# Distribución del código fuente

Para cada versión distribuida en binario, ofrece acceso gratuito al código fuente correspondiente desde la misma página de descarga. Incluye un enlace directo junto al APK universal, el APK ARM64 y el ZIP Windows. GPLv3 §6(d) permite alojarlo en otro servidor si el acceso es equivalente, las indicaciones son claras y las fuentes siguen disponibles.

- Identifica el commit exacto que generó cada binario. Incluye `pubspec.lock`, las copias en `third_party`, los parches, las configuraciones y los scripts necesarios para compilar e instalar el software.
- Incluye las fuentes correspondientes de terceros cuando sus licencias lo exijan. Para la DLL Windows de Immuch360, el [aviso de audio Windows](../third_party/windows_audio/NOTICE.md) identifica la DLL por SHA-256 y enlaza las fuentes y la receta exactas. Ofrece ese archivo junto a la descarga de RP Music que contiene esa DLL. La fuente correspondiente de la DLL histórica publicada con 0.4.8 sigue pendiente.
- Comprueba que una persona pueda descargar los archivos y compilar desde una copia limpia siguiendo [COMPILACION.md](COMPILACION.md). Para Android, usa una clave propia al seguir el flujo de firma. La clave oficial de RP Music y las credenciales se mantienen privadas.
- Comprueba los avisos y atribuciones en ambos APK y en el ZIP. Cierra el inventario de Gradle con `gradlew.bat :app:dependencies --configuration releaseRuntimeClasspath`. Vincula también el SDK Flutter y el motor a sus revisiones exactas.
- Añade los avisos y el enlace a la fuente correspondiente a la release. Verifica los enlaces sin iniciar sesión y conserva el manifiesto SHA-256 de los archivos publicados.

[Texto de GPLv3](../LICENSE) · [Avisos de terceros](../THIRD_PARTY_NOTICES.md)
