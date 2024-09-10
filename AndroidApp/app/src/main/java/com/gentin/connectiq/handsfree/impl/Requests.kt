package com.gentin.connectiq.handsfree.impl

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
data class OpenMeArgs(
    val messageForWakingUp: String?
)

@Serializable
data class CallArgs(
    val number: String
)

@Serializable
data class QueryArgs(
    val subjects: List<String>
)