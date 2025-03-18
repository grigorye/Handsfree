package com.gentin.connectiq.handsfree.impl

import android.content.Context
import com.gentin.connectiq.handsfree.R
import com.gentin.connectiq.handsfree.globals.isInDebugMode

const val hideDevicesWithoutApps = true

fun titleForDevice(deviceInfo: DeviceInfo, appConflict: Boolean, context: Context): String {
    val format = context.getString(R.string.settings_device_with_symbol_fmt)
    val title = format
        .replace("{{device_name}}", deviceInfo.name)
        .replace("{{symbol}}", symbolForDeviceInfo(deviceInfo, appConflict, context))
    return title
}

fun formattedDeviceInfos(deviceInfos: List<DeviceInfo>, context: Context): String {
    return if (hideDevicesWithoutApps) {
        formattedFilteredDeviceInfos(deviceInfos, context)
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

fun formattedFilteredDeviceInfos(deviceInfos: List<DeviceInfo>, context: Context): String {
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
            val suffix = if (it.connected) {
                formattedAppInfo(it.installedAppsInfo, context)
            } else {
                ""
            }
            listOfNotNull(
                titleForDevice(it, appConflict = matchingCount > 1, context),
                suffix
            ).joinToString(" ")
        }
}

fun formattedAppInfo(installedAppsInfo: List<InstalledAppInfo>, context: Context?): String? {
    if (context?.let { isInDebugMode(it) } != true) {
        return null
    }
    val joined = installedAppsInfo.joinToString { installedAppInfo ->
        "${installedAppInfo.appConfig()}"
    }
    return if (joined == "") {
        null
    } else {
        "($joined)"
    }
}

fun symbolForDeviceInfo(deviceInfo: DeviceInfo, appConflict: Boolean, context: Context): String {
    return with(deviceInfo) {
        if (connected) {
            if (installedAppsInfo.isNotEmpty()) {
                if (appConflict) {
                    context.getString(R.string.settings_device_symbol_conflicting)
                } else {
                    installedAppsInfo.map { info ->
                        if (info.appVersionInfo.version == 1) {
                            context.getString(R.string.settings_device_symbol_active)
                        } else {
                            val appConfig = info.appConfig()
                            if (appConfig == null) {
                                context.getString(R.string.settings_device_symbol_loading)
                            } else if (isBroadcastEnabled(appConfig)) {
                                context.getString(R.string.settings_device_symbol_active)
                            } else {
                                context.getString(R.string.settings_device_symbol_standby)
                            }
                        }
                    }.joinToString(separator = "")
                }
            } else {
                context.getString(R.string.settings_device_symbol_missing_app)
            }
        } else {
            context.getString(R.string.settings_device_symbol_not_connected)
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
