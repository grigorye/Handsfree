package com.gentin.connectiq.handsfree.impl

import com.garmin.android.connectiq.IQApp
import com.garmin.android.connectiq.IQDevice
import com.gentin.connectiq.handsfree.globals.appLogName

data class OutgoingMessage(
    val destination: OutgoingMessageDestination = OutgoingMessageDestination(),
    val body: Map<String, Any>
) {
    override fun toString(): String {
        return "{$destination, $body}"
    }
}
val everywhere = OutgoingMessageDestination()

data class OutgoingMessageDestination(
    val device: IQDevice? = null,
    val app: IQApp? = null,
    val matchV1: Boolean? = null
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
        return listOf(deviceRep, appRep, matchV1Rep).joinToString(prefix = "{", postfix = "}")
    }
}
