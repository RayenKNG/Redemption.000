plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    
    // 👇 PANGGIL DISINI (Tanpa version, karena udah diatur di settings)
    id("com.google.gms.google-services") 
}

// ... sisanya ke bawah ...

android {
    namespace = "com.example.saveplate"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8 // Ubah ke 1_8 biar aman
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.saveplate"
        
        // 👇 WAJIB GANTI KE 21 BUAT FIREBASE
        minSdk = flutter.minSdkVersion 
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 👇 WAJIB AKTIFIN MULTIDEX (Pake sama dengan =)
        multiDexEnabled = true 
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

// 👇 TAMBAHAN DEPENDENSI MULTIDEX (PENTING!)
dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
