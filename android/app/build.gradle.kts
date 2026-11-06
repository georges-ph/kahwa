import java.io.FileInputStream
import java.util.Base64
import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Pick the google-services.json of the Firebase project this build talks to:
// production for a release build, development for anything else, or for a
// release built with --dart-define=FIREBASE_ENV=dev. It has to match the
// choice made in lib/core/config.dart, or the app starts with two different
// Firebase projects and crashes. With a single project, keep one
// google-services.json and none of the two files below: nothing is copied.
val requestedTasks = gradle.startParameter.taskNames.joinToString(" ").lowercase()
// Flutter hands the --dart-define values to Gradle, each one base64 encoded.
val dartDefines =
    (project.findProperty("dart-defines") as String?)
        ?.split(",")
        ?.filter { it.isNotEmpty() }
        ?.map { String(Base64.getDecoder().decode(it)) }
        ?: emptyList()
val releaseOnDev = "FIREBASE_ENV=dev" in dartDefines
val googleServicesVariant =
    if (requestedTasks.contains("release") && !releaseOnDev) "prod" else "dev"
val googleServicesSource = file("google-services-$googleServicesVariant.json")
if (googleServicesSource.exists()) {
    googleServicesSource.copyTo(file("google-services.json"), overwrite = true)
    logger.lifecycle("Using google-services.json for: $googleServicesVariant")
}

// The release signing key is described in android/key.properties, which is
// git-ignored (see key.properties.example). Without that file, release
// builds are signed with the debug key, so a fresh clone still builds.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasReleaseSigning = keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "ga.jundbits.kahwa"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "ga.jundbits.kahwa"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            if (releaseOnDev) {
                // A full speed "kahwa dev", signed with the debug key like the
                // other dev builds, so it installs over them and Google sign
                // in knows it.
                signingConfig = signingConfigs.getByName("debug")
                applicationIdSuffix = ".dev"
                resValue("string", "app_name", "kahwa dev")
                manifestPlaceholders["linkHost"] = "shtrilekahwa-dev.web.app"
            } else {
                signingConfig = signingConfigs.getByName(if (hasReleaseSigning) "release" else "debug")
                resValue("string", "app_name", "kahwa")
                // The site whose links open in the app.
                manifestPlaceholders["linkHost"] = "shtrilekahwa.web.app"
            }
        }
        // Debug and profile builds talk to the development project. They
        // install as a separate app, "kahwa dev", so the real one can stay
        // on the same phone. Profile is set apart: Flutter copies it from
        // debug before these lines run.
        for (name in listOf("debug", "profile")) {
            getByName(name) {
                applicationIdSuffix = ".dev"
                resValue("string", "app_name", "kahwa dev")
                manifestPlaceholders["linkHost"] = "shtrilekahwa-dev.web.app"
            }
        }
    }
}

flutter {
    source = "../.."
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}
