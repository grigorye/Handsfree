package com.gentin.connectiq.handsfree.impl

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class CommonRequest(
    val cmd: String
)

@Serializable
data class CallRequest(
    val args: CallArgs
)

@Serializable
data class QueryRequest(
    val args: QueryArgs
)

@Serializable
data class OpenMeRequest(
    val args: OpenMeArgs
)

@Serializable
data class SetAudioVolumeRequest(
    val args: SetAudioVolumeRequestArgs
)

@Serializable
data class MuteRequest(
    val args: MuteRequestArgs
)

@Serializable
data class MuteRequestArgs(
    val on: Boolean
)

@Serializable
data class RelVolume(
    @SerialName("i") val index: Int,
    @SerialName("m") val max: Int
)

@Serializable
data class SetAudioVolumeRequestArgs(
    @SerialName("v") val volume: RelVolume
)

@Serializable
data class OpenMeArgs(
    val messageForWakingUp: String?
)

@Serializable
data class CallArgs(
    val number: String
)

@Serializable
data class QueryArgs(
    val subjects: List<SubjectQuery>
)

@Serializable
data class SubjectQuery(
    val name: String,
    val version: Version? = null
)
