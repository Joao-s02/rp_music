# Compilar RP Music

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
