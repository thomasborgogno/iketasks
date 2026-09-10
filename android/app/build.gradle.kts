import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("org.jetbrains.kotlin.plugin.compose")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.bortho.iketasks"
    // Flutter's bundled default (flutter.compileSdkVersion) lags behind; androidx.glance
    // needs compileSdk 37+, so override it explicitly.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlin {
        compilerOptions {
            jvmTarget = JvmTarget.JVM_17
        }
    }

    buildFeatures {
        compose = true
    }

    defaultConfig {
        applicationId = "com.bortho.iketasks"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    val keyPropsFile = rootProject.file("key.properties")
    val keyProps = Properties().apply {
        if (keyPropsFile.exists()) load(keyPropsFile.inputStream())
    }

    signingConfigs {
        create("release") {
            val ksPath: String? = System.getenv("KEYSTORE_PATH") ?: keyProps.getProperty("storeFile")
            val ksPassword: String? = System.getenv("KEYSTORE_PASSWORD") ?: keyProps.getProperty("storePassword")
            val ksAlias: String? = System.getenv("KEY_ALIAS") ?: keyProps.getProperty("keyAlias")
            val ksKeyPassword: String? = System.getenv("KEY_PASSWORD") ?: keyProps.getProperty("keyPassword")
            if (ksPath != null && ksPassword != null && ksAlias != null && ksKeyPassword != null) {
                storeFile = file(ksPath)
                storePassword = ksPassword
                keyAlias = ksAlias
                keyPassword = ksKeyPassword
            }
        }
    }

    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
        }
        release {
            // NOTE: this block is configured by Gradle for every task, including
            // `assembleDebug` - it must never throw here, or debug builds break too.
            val hasReleaseKeys = System.getenv("KEYSTORE_PATH") != null
                || keyPropsFile.exists()
            signingConfig = if (hasReleaseKeys) {
                signingConfigs.getByName("release")
            } else {
                logger.warn(
                    "Release signing keys not found (set KEYSTORE_PATH env var or provide " +
                        "key.properties) - falling back to debug signing for release builds."
                )
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation(platform("com.google.firebase:firebase-bom:34.18.0"))
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-play-services:1.11.0")
    implementation("androidx.glance:glance-appwidget:1.3.0-alpha02")
    implementation("androidx.glance:glance-material3:1.3.0-alpha02")
}
