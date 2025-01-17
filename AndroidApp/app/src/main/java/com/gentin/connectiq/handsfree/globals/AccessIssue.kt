package com.gentin.connectiq.handsfree.globals

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
enum class AccessIssue {
    @SerialName("p")
    NoPermission,
    @SerialName("r")
    ReadFailure,
    @SerialName("d")
    Disabled
}
