package com.gentin.connectiq.handsfree.globals

import com.gentin.connectiq.handsfree.calllogs.CallLogEntry
import kotlinx.serialization.EncodeDefault
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class AvailableRecents(
    @OptIn(ExperimentalSerializationApi::class) @EncodeDefault
    @SerialName("r") val list: List<CallLogEntry> = listOf(),
    @SerialName("a") val accessIssue: AccessIssue? = null
)