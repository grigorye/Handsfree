package com.gentin.connectiq.handsfree.impl

import com.garmin.android.connectiq.IQApp
import com.garmin.android.connectiq.IQDevice
import com.gentin.connectiq.handsfree.globals.appLogName

data class OutgoingMessage(
    val destination: OutgoingMessageDestination,
    val body: Map<String, Any>
) {
    override fun toString(): String {
        return "{$destination, $body}"
    }
}

val everywhere = OutgoingMessageDestination(
    device = null,
    app = null,
    accountBroadcastOnly = true
)
val everywhereExactly = OutgoingMessageDestination(
    device = null,
    app = null,
    accountBroadcastOnly = false
)

data class OutgoingMessageDestination(
    val device: IQDevice?,
    val app: IQApp?,
    val matchV1: Boolean? = null,
    val matchLM: Boolean? = null,
    val accountBroadcastOnly: Boolean = false,
    val skipOnAppConfig: (AppConfig) -> Boolean = { false }
) {
    override fun toString(): String {
        val deviceRep = if (device != null) {
            device.friendlyName
        } else {
            "every-device"
        }
        val appRep = if (app != null) {
            appLogName(app)
        } else {
            "every-app"
        }
        val matchV1Rep = when (matchV1) {
            true -> "v1"
            false -> "!v1"
            null -> null
        }
        val broadcastOnlyRep = when (accountBroadcastOnly) {
            true -> "bc-only"
            false -> "!"
        }
        val matchLMRep = when (matchLM) {
            true -> "lm"
            false -> "ff"
            null -> null
        }
        return listOf(
            deviceRep, appRep, matchV1Rep, broadcastOnlyRep, matchLMRep
        ).joinToString(prefix = "{", postfix = "}")
    }
}
