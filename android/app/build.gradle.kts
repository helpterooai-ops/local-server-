plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.chaquo.python") // تفعيل إضافة بايثون
}

android {
    namespace = "com.helpterooai.local_server"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
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

// إعدادات بايثون والمكتبات التي سيتم تحميلها داخل التطبيق
chaquopy {
    defaultConfig {
        pip {
            install("requests")
            install("pyTelegramBotAPI") // مكتبة صنع بوتات التيليجرام
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}