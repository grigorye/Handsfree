plugins {
    id("com.android.application") version "8.3.2" apply false
    id("org.jetbrains.kotlin.android") version "1.8.0" apply false
    kotlin("plugin.serialization") version "1.9.22"
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}

buildscript {

    repositories {
        google()
    }
    dependencies {
        val navigationVersion = "2.7.7"
        classpath("androidx.navigation:navigation-safe-args-gradle-plugin:$navigationVersion")
    }
}
