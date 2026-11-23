# Avisos de terceros de Android

Inventario de referencia de RP Music, obtenido del informe Gradle de la compilación ARM64. El APK universal añade el motor Flutter para armeabi-v7a y x86_64, de la misma revisión que ARM64. Gradle resuelve componentes cuyo código puede quedar fuera del APK tras la optimización.

## Licencias y atribuciones

- AndroidX y Media3 / Android Open Source Project. Apache-2.0. [AndroidX](https://github.com/androidx/androidx/blob/androidx-main/LICENSE.txt) y [Media3 1.4.1](https://github.com/androidx/media/blob/1.4.1/LICENSE).
- Kotlin estándar y Kotlin Serialization / JetBrains y colaboradores. Apache-2.0. [Kotlin 2.4.0 y sus atribuciones](https://github.com/JetBrains/kotlin/blob/v2.4.0/license/README.md) y [Kotlin Serialization 1.7.3](https://github.com/Kotlin/kotlinx.serialization/blob/v1.7.3/LICENSE.txt). Los textos de terceros de la biblioteca estándar JVM están en `kotlin-stdlib/`.
- Kotlin Coroutines / Copyright 2000-2020 JetBrains s.r.o. and Kotlin Programming Language contributors. Apache-2.0. [Licencia de 1.9.0](https://github.com/Kotlin/kotlinx.coroutines/blob/1.9.0/LICENSE.txt).
- JetBrains Annotations / Copyright 2000-2016 JetBrains s.r.o. Apache-2.0. [Licencia de 23.0.0](https://github.com/JetBrains/java-annotations/blob/23.0.0/LICENSE.txt).
- ReLinker / Copyright 2015 KeepSafe Software Inc. Apache-2.0. [Licencia de 1.4.5](https://github.com/KeepSafe/ReLinker/blob/1.4.5/LICENSE).
- Guava y FailureAccess / Google y colaboradores. Apache-2.0. [Licencia](https://github.com/google/guava/blob/v33.0.0/LICENSE).
- JSpecify / JSpecify y colaboradores. Apache-2.0. [Licencia de 1.0.0](https://github.com/jspecify/jspecify/blob/v1.0.0/LICENSE).
- Flutter y Dart JNI. Los avisos del motor, el framework, Dart y sus componentes están en `assets/flutter_assets/NOTICES.Z` dentro del APK.

El APK incluye el [texto completo Apache-2.0](../flutter_assets/assets/licenses/Apache-2.0.txt) y el [inventario general](../flutter_assets/THIRD_PARTY_NOTICES.md).

## Coordenadas resueltas por Gradle

| Componente Maven | Versión | Entrada |
| --- | --- | --- |
| `androidx.activity:activity` | 1.8.1 | Artefacto |
| `androidx.annotation:annotation-experimental` | 1.4.1 | Artefacto |
| `androidx.annotation:annotation-jvm` | 1.10.0 | Artefacto |
| `androidx.annotation:annotation` | 1.10.0 | Metadatos |
| `androidx.arch.core:core-common` | 2.2.0 | Artefacto |
| `androidx.arch.core:core-runtime` | 2.2.0 | Artefacto |
| `androidx.collection:collection-jvm` | 1.4.2 | Artefacto |
| `androidx.collection:collection` | 1.4.2 | Metadatos |
| `androidx.concurrent:concurrent-futures` | 1.1.0 | Artefacto |
| `androidx.core:core-ktx` | 1.18.0 | Artefacto |
| `androidx.core:core-viewtree` | 1.0.0 | Artefacto |
| `androidx.core:core` | 1.18.0 | Artefacto |
| `androidx.customview:customview` | 1.0.0 | Artefacto |
| `androidx.exifinterface:exifinterface` | 1.4.1 | Artefacto |
| `androidx.fragment:fragment` | 1.7.1 | Artefacto |
| `androidx.interpolator:interpolator` | 1.0.0 | Artefacto |
| `androidx.lifecycle:lifecycle-common-java8` | 2.10.0 | Artefacto |
| `androidx.lifecycle:lifecycle-common-jvm` | 2.10.0 | Artefacto |
| `androidx.lifecycle:lifecycle-common` | 2.10.0 | Metadatos |
| `androidx.lifecycle:lifecycle-livedata-core-ktx` | 2.10.0 | Artefacto |
| `androidx.lifecycle:lifecycle-livedata-core` | 2.10.0 | Artefacto |
| `androidx.lifecycle:lifecycle-livedata` | 2.10.0 | Artefacto |
| `androidx.lifecycle:lifecycle-process` | 2.10.0 | Artefacto |
| `androidx.lifecycle:lifecycle-runtime-android` | 2.10.0 | Artefacto |
| `androidx.lifecycle:lifecycle-runtime` | 2.10.0 | Metadatos |
| `androidx.lifecycle:lifecycle-viewmodel-android` | 2.10.0 | Artefacto |
| `androidx.lifecycle:lifecycle-viewmodel-savedstate-android` | 2.10.0 | Artefacto |
| `androidx.lifecycle:lifecycle-viewmodel-savedstate` | 2.10.0 | Metadatos |
| `androidx.lifecycle:lifecycle-viewmodel` | 2.10.0 | Artefacto |
| `androidx.loader:loader` | 1.0.0 | Artefacto |
| `androidx.media3:media3-common` | 1.4.1 | Artefacto |
| `androidx.media3:media3-container` | 1.4.1 | Artefacto |
| `androidx.media3:media3-database` | 1.4.1 | Artefacto |
| `androidx.media3:media3-datasource` | 1.4.1 | Artefacto |
| `androidx.media3:media3-decoder` | 1.4.1 | Artefacto |
| `androidx.media3:media3-exoplayer-dash` | 1.4.1 | Artefacto |
| `androidx.media3:media3-exoplayer-hls` | 1.4.1 | Artefacto |
| `androidx.media3:media3-exoplayer-smoothstreaming` | 1.4.1 | Artefacto |
| `androidx.media3:media3-exoplayer` | 1.4.1 | Artefacto |
| `androidx.media3:media3-extractor` | 1.4.1 | Artefacto |
| `androidx.media:media` | 1.7.0 | Artefacto |
| `androidx.profileinstaller:profileinstaller` | 1.4.0 | Artefacto |
| `androidx.savedstate:savedstate-android` | 1.4.0 | Artefacto |
| `androidx.savedstate:savedstate` | 1.4.0 | Metadatos |
| `androidx.startup:startup-runtime` | 1.1.1 | Artefacto |
| `androidx.tracing:tracing` | 1.2.0 | Artefacto |
| `androidx.versionedparcelable:versionedparcelable` | 1.1.1 | Artefacto |
| `androidx.viewpager:viewpager` | 1.0.0 | Artefacto |
| `androidx.window.extensions.core:core` | 1.0.0 | Artefacto |
| `androidx.window:window-java` | 1.2.0 | Artefacto |
| `androidx.window:window` | 1.2.0 | Artefacto |
| `com.getkeepsafe.relinker:relinker` | 1.4.5 | Artefacto |
| `com.google.guava:failureaccess` | 1.0.2 | Artefacto |
| `com.google.guava:guava` | 33.0.0-android | Artefacto |
| `com.google.guava:listenablefuture` | 9999.0-empty-to-avoid-conflict-with-guava | Artefacto |
| `io.flutter:arm64_v8a_release` | 1.0.0-692136cb6582dbfc5af3fb33c2515a069f2f66d0 | Artefacto |
| `io.flutter:flutter_embedding_release` | 1.0.0-692136cb6582dbfc5af3fb33c2515a069f2f66d0 | Artefacto |
| `org.jetbrains.kotlin:kotlin-stdlib` | 2.4.0 | Artefacto |
| `org.jetbrains.kotlinx:kotlinx-coroutines-android` | 1.9.0 | Artefacto |
| `org.jetbrains.kotlinx:kotlinx-coroutines-bom` | 1.9.0 | Metadatos |
| `org.jetbrains.kotlinx:kotlinx-coroutines-core-jvm` | 1.9.0 | Artefacto |
| `org.jetbrains.kotlinx:kotlinx-coroutines-core` | 1.9.0 | Metadatos |
| `org.jetbrains.kotlinx:kotlinx-serialization-bom` | 1.7.3 | Metadatos |
| `org.jetbrains.kotlinx:kotlinx-serialization-core-jvm` | 1.7.3 | Artefacto |
| `org.jetbrains.kotlinx:kotlinx-serialization-core` | 1.7.3 | Metadatos |
| `org.jetbrains:annotations` | 23.0.0 | Artefacto |
| `org.jspecify:jspecify` | 1.0.0 | Artefacto |
