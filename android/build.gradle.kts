buildscript {
    repositories {
        google()
        mavenCentral()
        // أضفنا مستودع Chaquopy هنا
        maven { url = uri("https://chaquo.com/maven") }
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
        // أحدث إصدار مستقر، متوافق مع Gradle 9 و AGP 9.x
        classpath("com.chaquo.python:gradle:17.0.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        // نفس مستودع Chaquopy مطلوب هنا أيضًا لحل مكتباته وقت البناء
        maven { url = uri("https://chaquo.com/maven") }
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

    // إجبار جميع المكتبات على استخدام compileSdk 36
    afterEvaluate {
        extensions.findByType<com.android.build.gradle.BaseExtension>()?.let { ext ->
            ext.compileSdkVersion(36)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}