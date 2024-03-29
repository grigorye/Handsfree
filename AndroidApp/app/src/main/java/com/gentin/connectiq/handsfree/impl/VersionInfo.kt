package com.gentin.connectiq.handsfree.impl;

import com.gentin.connectiq.handsfree.BuildConfig

fun versionInfo(): String {
    return arrayOf(
        BuildConfig.VERSION_NAME,
        "(" + BuildConfig.VERSION_CODE + ")",
        BuildConfig.SOURCE_VERSION,
        "(" + BuildConfig.BUILD_TYPE + ")",
    ).joinToString(" ")
}
