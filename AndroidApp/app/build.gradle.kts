import java.util.Properties

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.serialization)

    id("androidx.navigation.safeargs.kotlin")
}

kotlin {
    jvmToolchain {
        languageVersion.set(JavaLanguageVersion.of("17"))
    }
}

val sourceVersion = providers.exec {
    commandLine("git", "describe", "--match", "736fd2e"/* unmatchable */, "--dirty", "--always")
}.standardOutput.asText.get().trim().replace("-dirty", "*")

project.file("version.properties").inputStream().use {
    val props = Properties()
    props.load(it)
    props.forEach { (k, v) ->
        project.extensions.extraProperties[k.toString()] = v
    }
}

android {
    namespace = "com.gentin.connectiq.handsfree"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.gentin.connectiq.handsfree"

        minSdk = 28
        //noinspection OldTargetApi
        targetSdk = 34

        versionCode = {
            val versionCode: String by project
            versionCode.toInt()
        }()

        versionName = {
            val versionName: String by project
            versionName
        }()

        buildConfigField("String", "SOURCE_VERSION", "\"$sourceVersion\"")
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro"
            )
        }
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

fun DependencyHandlerScope.implementationAar(
    notation: Provider<MinimalExternalModuleDependency>,
    configure: ModuleDependency.() -> Unit = {}
) {
    val dep = notation.get()
    val group = dep.module.group
    val name = dep.module.name
    val version = dep.versionConstraint.requiredVersion
    val dependencyNotation = "$group:$name:$version@aar"
    add("implementation", dependencyNotation, configure)
}

dependencies {
    implementation(libs.androidx.appcompat)
    implementation(libs.androidx.constraintlayout)
    implementation(libs.androidx.lifecycle.livedata.core.ktx)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.lifecycle.service)
    implementation(libs.androidx.navigation.fragment.ktx)
    implementation(libs.androidx.navigation.ui.ktx)
    implementation(libs.androidx.preference.ktx)

    implementation(libs.gson)
    implementation(libs.jackson.module.kotlin)

    implementationAar(libs.ciq.companion.app.sdk)

    implementation(libs.kotlinx.serialization.json)
    implementation(libs.kotlinx.coroutines.android)

    implementationAar(libs.doki) {
        isTransitive = true
    }

    implementation(libs.material)

    implementation(libs.markwon.core)
    implementation(libs.markwon.image)
    implementation(libs.markwon.html)

    implementation(libs.androidsvg.aar)
}
