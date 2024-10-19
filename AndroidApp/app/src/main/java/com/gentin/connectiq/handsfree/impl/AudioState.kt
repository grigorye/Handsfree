package com.gentin.connectiq.handsfree.impl

import kotlinx.serialization.Serializable

@Serializable
data class AudioState(
    val isHeadsetConnected: Boolean,
    val isMuted: Boolean,
    var audioRelVolume: RelVolume
)
