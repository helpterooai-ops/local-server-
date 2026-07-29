plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.helpterooai.local_server"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // السطر الجديد لتفعيل الـ Desugaring لمكتبة الإشعارات
        isCoreLibraryDesugaringEnabled = true 
    }

    defaultConfig {
        applicationId = "com.helpterooai.local_server"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

tasks.configureEach {
    if (name.contains("CMake") || name.contains("cxx") || name.contains("Cxx")) {
        enabled = false
    }
}

// البلوك الجديد لإضافة أداة الـ Desugaring المطلوبة
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}