package com.gentin.connectiq.handsfree.impl

data class AudioState(
    val isHeadsetConnected: Boolean,
    val isMuted: Boolean,
    val audioRelVolume: RelVolume
)
