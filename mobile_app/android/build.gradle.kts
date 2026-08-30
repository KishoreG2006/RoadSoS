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
    val applyNamespace = {
        val android = project.extensions.findByName("android")
        if (android != null) {
            try {
                val getter = android.javaClass.methods.firstOrNull { it.name == "getNamespace" }
                val setter = android.javaClass.methods.firstOrNull { it.name == "setNamespace" && it.parameterTypes.size == 1 && it.parameterTypes[0] == String::class.java }
                if (getter != null && setter != null && getter.invoke(android) == null) {
                    setter.invoke(android, "dev.isar.${project.name.replace('-', '_')}")
                }
            } catch (_: Exception) {
            }
        }
    }

    if (project.state.executed) {
        applyNamespace()
    } else {
        project.afterEvaluate {
            applyNamespace()
        }
    }
}

subprojects {
    project.afterEvaluate {
        val android = project.extensions.findByName("android")
        if (android is com.android.build.gradle.BaseExtension) {
            android.compileSdkVersion(36)
        }
    }
}


subprojects {
    if (project.name != "app") {
        project.evaluationDependsOn(":app")
    }
}


tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
