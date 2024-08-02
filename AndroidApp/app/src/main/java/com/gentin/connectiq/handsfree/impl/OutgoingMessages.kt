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

data class OutgoingMessageDestination(
    val device: IQDevice? = null,
    val app: IQApp? = null
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
        return "{$deviceRep, $appRep}"
    }
}
