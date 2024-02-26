plugins {
    id("com.android.application")
    kotlin("android")
    kotlin("plugin.serialization") version "1.9.22"
}

val compileSdkVersion: String by project
val minSdkVersion: String by project
val targetSdkVersion: String by project
val packageName = "com.garmin.android.apps.connectiq.sample.comm"
val versionCode: String by project
val versionName: String by project

android {
    namespace = this@Build_gradle.packageName
    compileSdk = this@Build_gradle.compileSdkVersion.toInt()

    defaultConfig {
        applicationId = this@Build_gradle.packageName
        minSdk = minSdkVersion.toInt()
        targetSdk = targetSdkVersion.toInt()
        versionCode = this@Build_gradle.versionCode.toInt()
        versionName = this@Build_gradle.versionName
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
}
