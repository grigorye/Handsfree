package com.garmin.android.apps.connectiq.sample.comm.impl

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
