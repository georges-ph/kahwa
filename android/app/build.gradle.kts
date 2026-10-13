plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("com.google.firebase.firebase-perf")
    id("com.google.firebase.crashlytics")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Pick the google-services.json of the Firebase project this build talks to:
// production for a release build, development for anything else. It has to
// match the choice made in lib/core/config.dart, or the app starts with two
// different Firebase projects and crashes. With a single project, keep one
// google-services.json and none of the two files below: nothing is copied.
val requestedTasks = gradle.startParameter.taskNames.joinToString(" ").lowercase()
val googleServicesVariant = if (requestedTasks.contains("release")) "prod" else "dev"
val googleServicesSource = file("google-services-$googleServicesVariant.json")
if (googleServicesSource.exists()) {
    googleServicesSource.copyTo(file("google-services.json"), overwrite = true)
    logger.lifecycle("Using google-services.json for: $googleServicesVariant")
}

android {
    namespace = "ga.jundbits.kahwa"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "ga.jundbits.kahwa"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
