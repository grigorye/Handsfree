package com.gentin.connectiq.handsfree.impl

data class PhoneState(
    val incomingNumber: String?,
    val incomingDisplayNames: List<String>,
    val stateExtra: String,
    val isHeadsetConnected: Boolean
)
