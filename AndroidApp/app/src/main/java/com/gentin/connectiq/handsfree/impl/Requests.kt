package com.gentin.connectiq.handsfree.impl

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class CommonRequest(
    @SerialName("c") val cmd: String
)

@Serializable
data class CommonRequestV1(
    val cmd: String
)

@Serializable
data class CallRequest(
    @SerialName("a") val args: CallArgs
)

@Serializable
data class CallRequestV1(
    val args: CallArgsV1
)

@Serializable
data class QueryRequest(
    @SerialName("a") val args: QueryArgs
)

@Serializable
data class OpenMeRequest(
    @SerialName("a") val args: OpenMeArgs
)

@Serializable
data class SetAudioVolumeRequest(
    @SerialName("a") val args: SetAudioVolumeRequestArgs
)

@Serializable
data class MuteRequest(
    @SerialName("a") val args: MuteRequestArgs
)

@Serializable
data class MuteRequestArgs(
    @SerialName("o") val on: Boolean
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
    @SerialName("m") val messageForWakingUp: String?
)

@Serializable
data class CallArgs(
    @SerialName("n") val number: String
)

@Serializable
data class CallArgsV1(
    val number: String
)

@Serializable
data class QueryArgs(
    @SerialName("s") val subjects: List<SubjectQuery>
)

@Serializable
data class SubjectQuery(
    @SerialName("n") val name: String,
    @SerialName("v") val version: Version? = null
)
