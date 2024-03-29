plugins {
    id("com.android.application")
    kotlin("android")
    kotlin("plugin.serialization") version "1.9.22"
}

kotlin {
    jvmToolchain {
        languageVersion.set(JavaLanguageVersion.of("17"))
    }
}

val compileSdkVersion: String by project
val minSdkVersion: String by project
val targetSdkVersion: String by project
val packageName = "com.gentin.connectiq.handsfree"
val versionCode: String by project
val versionName: String by project
val sourceVersion = providers.exec {
    commandLine("git", "describe", "--match", "736fd2e"/* unmatchable */, "--dirty", "--always")
}.standardOutput.asText.get().trim()

android {
    namespace = this@Build_gradle.packageName
    compileSdk = this@Build_gradle.compileSdkVersion.toInt()

    defaultConfig {
        applicationId = this@Build_gradle.packageName
        minSdk = minSdkVersion.toInt()
        targetSdk = targetSdkVersion.toInt()
        versionCode = this@Build_gradle.versionCode.toInt()
        versionName = this@Build_gradle.versionName
        buildConfigField("String", "SOURCE_VERSION", "\"$sourceVersion\"")
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    buildFeatures {
        buildConfig = true
    }
}

dependencies {
    implementation("androidx.recyclerview:recyclerview:1.3.2")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
    implementation("androidx.appcompat:appcompat:1.6.1")

    implementation("com.garmin.connectiq:ciq-companion-app-sdk:2.0.3@aar")

    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.3")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.0")
    implementation("androidx.lifecycle:lifecycle-service:2.7.0")

    implementation("dev.doubledot.doki:library:0.0.1@aar") {
        isTransitive = true
    }
    implementation("com.google.android.material:material:1.11.0")
    implementation("io.noties.markwon:core:4.6.2")
}
