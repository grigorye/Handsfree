package com.gentin.connectiq.handsfree.impl

fun formattedDeviceInfos(deviceInfos: List<DeviceInfo>): String {
    return deviceInfos
        .sortedWith(compareBy { it.connected })
        .reversed()
        .joinToString(", ") {
            if (it.connected) {
                it.name
            } else {
                "⚠ ${it.name}"
            }
        }
}
