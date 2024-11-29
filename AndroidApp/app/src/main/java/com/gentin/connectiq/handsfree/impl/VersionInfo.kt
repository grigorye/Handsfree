package com.gentin.connectiq.handsfree.impl

import com.gentin.connectiq.handsfree.BuildConfig

fun versionInfoString(): String {
    return arrayOf(
        BuildConfig.VERSION_NAME,
        "(" + BuildConfig.VERSION_CODE + ")",
        BuildConfig.SOURCE_VERSION,
        "(" + BuildConfig.BUILD_TYPE + ")",
    ).joinToString(" ")
}

fun versionInfo(): VersionInfo {
    return VersionInfo(
        versionName = BuildConfig.VERSION_NAME,
        versionCode = BuildConfig.VERSION_CODE,
        sourceVersion = BuildConfig.SOURCE_VERSION,
        buildType = BuildConfig.BUILD_TYPE
    )
}