# Compilar RP Music

Guía de desarrollo actual. Versión de app en pubspec.yaml y lib/app/app_version.dart; contrastar ambas antes de empaquetar. [Índice de documentación](README.md) · [Arquitectura vigente](../boveda/31%20Arquitectura%20vigente.md).

## Java para Android

La compilación necesita un **JDK 17 completo** (incluye `bin/javac`), no solo un JRE. Algunas dependencias Android requieren esa versión aunque Flutter ejecute Gradle con el Java de Android Studio.

En Windows se puede extraer Eclipse Temurin JDK 17 en `%USERPROFILE%\.jdks\`. Gradle reconoce esta ubicación automáticamente. Además hay que seleccionar el JDK como Java activo: detectar el JDK no basta si Gradle sigue usando un JRE como JVM actual. No es necesario modificar el código de las dependencias ni añadir rutas personales al repositorio.

Seleccionar la carpeta extraída (ajustar la versión instalada):

```powershell
$jdkPath = Join-Path $env:USERPROFILE '.jdks\jdk-17.0.20.1+1'
& (Join-Path $jdkPath 'bin\javac.exe') -version
[Environment]::SetEnvironmentVariable('JAVA_HOME', $jdkPath, 'User')
$env:JAVA_HOME = $jdkPath
flutter config --jdk-dir $jdkPath
```

Reiniciar terminales/editores abiertos para que reciban JAVA_HOME actualizado. La selección de Flutter queda guardada en su configuración de usuario.

Comprobar desde la carpeta `android`:

```powershell
.\gradlew.bat javaToolchains --offline --console=plain
```

La lista debe mostrar Java 17 con `Is JDK: true`. Si aparece únicamente `Is JDK: false`, se ha encontrado un entorno de ejecución sin compilador. Tras instalar el JDK, repetir la comprobación antes de compilar.

Desde la raíz del proyecto:

```powershell
flutter build apk --release
```

El APK resultante está en `build/app/outputs/flutter-apk/app-release.apk`. Es un archivo de compilación local; no sustituye por sí solo paquetes de `dist` ni releases publicadas. La firma de distribución actual sigue siendo de desarrollo.

Usar el flujo completo de Flutter para que regenere el registro de plugins correspondiente a release. Omitir ese paso con `--no-pub` o invocar Gradle directamente después de una compilación debug puede dejar un registro que incluye `integration_test`, aunque esa dependencia de pruebas no se enlace en release.

Si Gradle espera comprobaciones de red, todas las dependencias están en caché y Flutter **ya generó los archivos para release**, se puede verificar desde `android` con `.\gradlew.bat assembleRelease --offline --console=plain`. Esta alternativa produce el APK en `build/app/outputs/apk/release/` y no sustituye la preparación de Flutter.

Descargar desde [Adoptium](https://adoptium.net/temurin/releases/?version=17), elegir Windows x64 **JDK** y verificar el SHA-256 oficial. Referencias: [API oficial de descarga y verificación](https://adoptium.net/installation/ci-scripts) y [detección de herramientas Java de Gradle](https://docs.gradle.org/current/userguide/toolchains.html).


## audio_service local en 0.2.4

El proyecto incluye third_party/audio_service 0.18.19 con dos ajustes Android de foreground/wake lock descritos en su RP-MUSIC-PATCH.md; se selecciona mediante dependency_overrides. No sustituir por Pub sin revisar la corrección y repetir las pruebas nativas. No se modifica la caché global. La copia incluye licencia MIT y fuentes de las plataformas declaradas.

Para probar segundo plano: `flutter test integration_test/android_notification_test.dart -d <emulador>`. La sonda release de tools/android_notification_probe.dart es independiente de la entrada normal; no distribuirla. Se puede enviar la actividad a Inicio después de RP_PROBE_READY y leer RP_RELEASE_PROBE en logcat.

La prueba integration_test/update_install_test.dart necesita preparar antes un APK real del mismo certificado con código superior. El escenario usado fue una sonda local con --build-number 7, mientras la app de prueba era código 6. Guardar la sonda en build/update-check, instalar manualmente la APK debug de integración, transferir la muestra con `adb push` a /data/local/tmp/rp-update-fixture.apk y copiarla con `adb shell run-as com.example.rp_music` a files/updates/rp-music-update.apk. Crear primero files/updates con run-as. Con REQUEST_INSTALL_PACKAGES deshabilitado para la fuente, la prueba espera que se abra autorización después de validar hash/versión/firma. Ejecutar la prueba sobre la app debug ya preparada; su limpieza automática puede desinstalarla al terminar. No requiere root. No se confirmó instalación ni se distribuyó esa sonda de código 7.

Después de pruebas, compilar siempre la entrada normal `flutter build apk --release`; comprobar la versión/número actuales de pubspec y app_version.dart, firma y recursos antes de copiar a dist (referencia publicada al revisar: 0.3.3/código 12). Para ARM64: `flutter build apk --release --split-per-abi --target-platform android-arm64`. La versión de pubspec y lib/app/app_version.dart deben avanzar juntas en futuras entregas, incluyendo el canal/tag y un código superior para cada actualización instalable.

En esta máquina, la regeneración de plugins requirió restaurar enlaces temporales Windows mediante junctions locales dentro de windows/flutter/ephemeral/.plugin_symlinks. No se modificó la configuración global del sistema. Esos enlaces generados no forman parte de la distribución ni del repositorio; en otros entornos Flutter puede requerir soporte de enlaces o Modo de desarrollador.

No ejecutar pruebas y compilaciones Flutter al mismo tiempo: comparten registros generados de plugins. Para Windows ejecutar primero la prueba nativa y después `flutter build windows --release`; distribuir la carpeta Release completa en ZIP y preparar las guías de la versión. Las extensiones se entregan desde su repositorio separado, no dentro del ZIP ni como adjuntos de la app.


## Flujo normal de verificación y distribución

Ejecutar secuencialmente en la raíz, ajustando dispositivo y herramientas del entorno:

```powershell
flutter pub get
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --release
# Conservar/copiar el universal antes de generar la variante:
flutter build apk --release --split-per-abi --target-platform android-arm64
flutter build windows --release
```

Para pruebas nativas consultar integration_test; Android de fuente recibe un paquete externo según el contrato API 2. No incluirlo como fixture específico del principal. Las pruebas nativas, sus permisos/fixture y su alcance se documentan en la nota de cada versión. Las sondas de tools no son la entrada distribuible; después reconstruir lib/main.dart mediante el flujo completo de Flutter.

Universal: build/app/outputs/flutter-apk/app-release.apk. ARM64: app-arm64-v8a-release.apk en la misma carpeta. Windows: build/windows/x64/runner/Release completo. No distribuir solo el EXE ni sobrescribir una copia de pruebas que se deba conservar. Comprobar firmas, ABI/versión, recursos, ZIP y hashes después de cerrar las guías. La firma actual es de desarrollo, no una firma definitiva de tienda.

Publicar exige autorización y el contenido de la [política de releases](../boveda/27%20Publicacion%20de%20releases%20-%20contenido%20obligatorio.md). Los comandos de build no publican nada por sí solos. La sonda con código 7 descrita antes es un antecedente del actualizador de 0.2.4, no el número que deba usarse hoy.
