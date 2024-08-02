package com.gentin.connectiq.handsfree.impl

import com.garmin.android.connectiq.IQApp
import com.garmin.android.connectiq.IQDevice
import com.gentin.connectiq.handsfree.globals.appLogName

data class IncomingMessageSource(
    val device: IQDevice,
    val app: IQApp
) {
    override fun toString(): String {
        val deviceRep = device.friendlyName
        val appRep = appLogName(app)
        return "{$deviceRep, $appRep}"
    }
}
