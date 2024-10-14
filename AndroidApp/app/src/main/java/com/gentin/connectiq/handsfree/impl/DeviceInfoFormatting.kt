package com.gentin.connectiq.handsfree.impl

const val hideDevicesWithoutApps = true

fun formattedDeviceInfos(deviceInfos: List<DeviceInfo>): String {
    return if (hideDevicesWithoutApps) {
        formattedFilteredDeviceInfos(deviceInfos)
    } else {
        formattedUnfilteredDeviceInfos(deviceInfos)
    }
}

fun formattedUnfilteredDeviceInfos(deviceInfos: List<DeviceInfo>): String {
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

fun formattedFilteredDeviceInfos(deviceInfos: List<DeviceInfo>): String {
    val matchingCount = deviceInfos.count { it.connected && it.installedAppsCount > 0 }
    return deviceInfos
        .filter {
            if (matchingCount > 0) {
                it.connected && it.installedAppsCount > 0
            } else {
                true
            }
        }
        .sortedWith(compareBy {
            if (!it.connected) {
                -1
            } else {
                it.installedAppsCount
            }
        })
        .reversed()
        .joinToString(",$nbsp ") {
            val symbol = if (it.connected) {
                if (it.installedAppsCount > 0) {
                    if (matchingCount > 1) {
                        "‼️"
                    } else {
                        ""
                    }
                } else {
                    "⏹️️"
                }
            } else {
                "⏸️"
            }
            "$symbol$nbsp${it.displayName}"
        }
}

fun messageForDeviceInfos(deviceInfos: List<DeviceInfo>): String {
    val matchingCount = deviceInfos.count { it.connected && it.installedAppsCount > 0 }
    val message = if (matchingCount > 1) {
        listOf(
            "Only *one* connected Handsfree-enabled device is supported a time!",
            "To workaround the issue,",
            "1. Do one of the following:",
            "- Uninstall the app from all but one of the devices and tap $refreshMessage.",
            "- Disable phone connection on all but one of the devices.",
            "2. Then toggle the phone connection OFF and ON on the only remaining Handsfree-enabled device."
        )
    } else {
        listOf()
    }
    return message.joinToString("\n\n")
}

private const val nbsp = " "
const val refreshMessage = "🔄${nbsp}Refresh"
