plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin") // Flutter plugin must come after Android/Kotlin
}

dependencies {
    // Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.14.0"))

    // Firebase Analytics (you can add others like firestore, auth etc.)
    implementation("com.google.firebase:firebase-analytics")
}

android {
    namespace = "com.example.doctor_admin_panel"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.doctor_admin_panel"

        // ✅ Update this as required by firebase_auth
        minSdk = 23                      // <-- Was: flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
