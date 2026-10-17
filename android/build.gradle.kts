allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

gradle.afterProject {
    if (plugins.hasPlugin("com.android.library") || plugins.hasPlugin("com.android.application")) {
        val extension = extensions.findByName("android")
        if (extension != null) {
            try {
                val method = extension.javaClass.getMethod("setNdkVersion", String::class.java)
                method.invoke(extension, "30.0.16248370")
            } catch (_: Throwable) {
            }
        }
    }
}


