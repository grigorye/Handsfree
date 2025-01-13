package com.gentin.connectiq.handsfree.impl

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
enum class AudioDevice {
    @SerialName("h")
    Headset,
    @SerialName("w")
    WiredHeadset,
    @SerialName("s")
    Speaker,
    @SerialName("e")
    Earpiece
}

@Serializable
data class AudioState(
    @SerialName("h") val isHeadsetConnected: Boolean,
    @SerialName("d") val activeAudioDevice: AudioDevice?,
    @SerialName("m") val isMuted: Boolean,
    @SerialName("v") var volume: RelVolume
)
