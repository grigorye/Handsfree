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
    val matchingCount = deviceInfos.count { it.connected && it.installedAppsInfo.isNotEmpty() }
    return deviceInfos
        .filter {
            if (matchingCount > 0) {
                it.connected && it.installedAppsInfo.isNotEmpty()
            } else {
                true
            }
        }
        .sortedWith(compareBy {
            if (!it.connected) {
                -1
            } else {
                it.installedAppsInfo.count()
            }
        })
        .reversed()
        .joinToString(",$nbsp ") {
            val symbol =
                if (matchingCount > 1 && it.connected) {
                    "‼️"
                } else {
                    symbolForDeviceInfo(it)
                }
            "$symbol$nbsp${it.displayName}"
        }
}

fun symbolForDeviceInfo(deviceInfo: DeviceInfo): String {
    return with(deviceInfo) {
        if (connected) {
            if (installedAppsInfo.isNotEmpty()) {
                val info = installedAppsInfo[0]
                val appConfig = info.appConfig()
                if (isBroadcastEnabled(appConfig)) {
                    "▶️️"
                } else {
                    "🅿️"
                }
            } else {
                "⏹️️"
            }
        } else {
            "⏸️"
        }
    }
}

fun messageForDeviceInfos(deviceInfos: List<DeviceInfo>): String {
    val matchingCount = deviceInfos.count { it.connected && it.installedAppsInfo.isNotEmpty() }
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

const val nbsp = " "
const val refreshMessage = "🔄${nbsp}Refresh"
