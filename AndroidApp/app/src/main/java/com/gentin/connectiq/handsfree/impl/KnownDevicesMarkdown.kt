package com.gentin.connectiq.handsfree.impl

import android.text.TextUtils
import com.gentin.connectiq.handsfree.globals.DefaultServiceLocator

fun knownDevicesMarkdown(knownDeviceInfos: List<DeviceInfo>? = DefaultServiceLocator.knownDeviceInfos.value): String {
    return knownDeviceInfos?.let {
        TextUtils.join(
            "\n",
            it.map { deviceInfo ->
                "- **${deviceInfo.name}** (${if (deviceInfo.connected) "connected" else "not connected"})"
            }
        )
    } ?: ""
}