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
data class CallRequestV1(
    val args: CallArgsV1
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

typealias SubjectQuery = List<String>

fun newSubjectQuery(name: String, version: Int? = null): SubjectQuery {
    val query = mutableListOf(name)
    if (version != null) {
        query.add("$version")
    }
    return query
}

fun subjectQueryName(query: SubjectQuery): String {
    return query[0]
}

fun subjectQueryVersion(query: SubjectQuery): Int? {
    if (query.size < 2) {
        return null
    }
    return query[1].toInt()
}
