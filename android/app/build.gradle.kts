plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// The single-ABI download must remain upgrade-compatible with the universal
// APK rather than gaining the default ABI-specific version-code offset.
if (project.findProperty("target-platform") == "android-arm64") {
    project.extensions.extraProperties.set("force-version-code-ignoring-abi", true)
}

android {
    namespace = "com.example.rp_music"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "30.0.16248370"
    // Manual updates are the release default after the controlled Play Protect test.
    // Explicit false is reserved for reproducing the diagnostic control APK.
    if (System.getenv("RP_ANDROID_NO_DIRECT_INSTALLER") != "false") {
        sourceSets.getByName("release").manifest.srcFile("src/reviewNoInstaller/AndroidManifest.xml")
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.rp_music"
        minSdk = flutter.minSdkVersion.coerceAtLeast(23)
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("production") {
            val keyPath = System.getenv("RP_ANDROID_KEYSTORE")
            if (!keyPath.isNullOrBlank()) {
                storeFile = file(keyPath)
                storePassword = System.getenv("RP_ANDROID_STORE_PASSWORD")
                keyAlias = System.getenv("RP_ANDROID_KEY_ALIAS") ?: "rp_music"
                keyPassword = System.getenv("RP_ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            // Production credentials are supplied by the local signing tool.
            // Never silently distribute another APK with a debug certificate.
            signingConfig = signingConfigs.getByName("production")
        }
    }
}

gradle.taskGraph.whenReady {
    val releaseRequested = allTasks.any {
        it.project == project && it.name.contains("Release") &&
            (it.name.startsWith("assemble") || it.name.startsWith("bundle") || it.name.startsWith("package"))
    }
    if (releaseRequested) {
        listOf("RP_ANDROID_KEYSTORE", "RP_ANDROID_STORE_PASSWORD", "RP_ANDROID_KEY_PASSWORD").forEach {
            require(!System.getenv(it).isNullOrBlank()) {
                "Missing production signing configuration. Use tools/build-android-signed.ps1."
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// Widget controls share the audio_service compatibility media session.
dependencies {
    implementation("androidx.media:media:1.7.0")
}
