package com.gentin.connectiq.handsfree.impl

import android.text.TextUtils
import com.gentin.connectiq.handsfree.globals.DefaultServiceLocator

fun knownDevicesMarkdown(garminConnector: GarminConnector? = DefaultServiceLocator.activeGarminConnector): String {
    return garminConnector?.let {
        TextUtils.join(
            "\n",
            it.knownDeviceInfos.map { deviceInfo ->
                "- **${deviceInfo.name}** (${if (deviceInfo.connected) "connected" else "not connected"})"
            }
        )
    } ?: ""
}