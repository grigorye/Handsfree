package com.gentin.connectiq.handsfree.globals

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable


@Serializable
enum class Readiness {
    @SerialName("d")
    Disabled,
    @SerialName("p")
    NotPermitted,
    @SerialName("r")
    Ready
}

fun readiness(enabled: Boolean, permitted: Boolean): Readiness {
    if (!enabled) { return Readiness.Disabled }
    if (!permitted) { return Readiness.NotPermitted }
    return Readiness.Ready
}