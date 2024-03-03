package com.gentin.connectiq.handsfree.impl

import kotlinx.serialization.Serializable

@Serializable
enum class Command(val key: String) {
    CALL("call"),
    HANGUP("hangup")
}

@Serializable
data class CommonRequest(
    val cmd: String
)

@Serializable
data class CallRequest(
    val args: CallArgs
)

@Serializable
data class CallArgs(
    val number: String
)
