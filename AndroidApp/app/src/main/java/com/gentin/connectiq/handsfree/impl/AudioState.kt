package com.gentin.connectiq.handsfree.impl

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class AudioState(
    @SerialName("h") val isHeadsetConnected: Boolean,
    @SerialName("m") val isMuted: Boolean,
    @SerialName("v") var volume: RelVolume
)
