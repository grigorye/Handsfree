plugins {
    id("com.android.application")
    kotlin("android")
    kotlin("plugin.serialization") version "1.9.22"
    id("androidx.navigation.safeargs.kotlin")
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
}.standardOutput.asText.get().trim().replace("-dirty", "*")

android {
    namespace = this@Build_gradle.packageName
    compileSdk = this@Build_gradle.compileSdkVersion.toInt()

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro"
            )
        }
    }

    defaultConfig {
        applicationId = this@Build_gradle.packageName
        minSdk = minSdkVersion.toInt()
        targetSdk = targetSdkVersion.toInt()
        versionCode = this@Build_gradle.versionCode.toInt()
        versionName = this@Build_gradle.versionName
        buildConfigField("String", "SOURCE_VERSION", "\"$sourceVersion\"")
    }

    buildFeatures {
        buildConfig = true
        viewBinding = true
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = "1.8"
    }
    flavorDimensions += listOf("distribution")
    productFlavors {
        create("googlePlay") {
            dimension = "distribution"
        }
        create("selfHosted") {
            dimension = "distribution"
        }
    }
}

dependencies {
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("androidx.constraintlayout:constraintlayout:2.2.1")
    implementation("androidx.lifecycle:lifecycle-livedata-core-ktx:2.9.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.9.0")
    implementation("androidx.lifecycle:lifecycle-service:2.9.0")
    implementation("androidx.navigation:navigation-fragment-ktx:2.9.0")
    implementation("androidx.navigation:navigation-ui-ktx:2.9.0")
    implementation("androidx.preference:preference-ktx:1.2.1")

    implementation("com.google.code.gson:gson:2.11.0")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin:2.15.0")

    implementation("com.garmin.connectiq:ciq-companion-app-sdk:2.0.3@aar")

    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.3")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")

    implementation("dev.doubledot.doki:library:0.0.1@aar") {
        isTransitive = true
    }
    implementation("com.google.android.material:material:1.12.0")

    implementation("io.noties.markwon:core:4.6.2")
    implementation("io.noties.markwon:image:4.6.2")
    implementation("io.noties.markwon:html:4.6.2")

    implementation("com.caverock:androidsvg-aar:1.4")
}
