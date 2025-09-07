package com.gentin.connectiq.handsfree.impl

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class CompanionInfo(
    @SerialName("v") val version: VersionInfo
)

@Serializable
data class VersionInfo(
    @SerialName("n") val versionName: String,
    @SerialName("c") val versionCode: Int,
    @SerialName("s") val sourceVersion: String,
    @SerialName("t") val buildType: String,
    @SerialName("f") val flavor: String
)

fun companionInfo(): CompanionInfo {
    return CompanionInfo(
        version = versionInfo()
    )
}