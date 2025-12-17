package com.gentin.connectiq.handsfree.impl

import android.content.Context
import com.gentin.connectiq.handsfree.R
import com.gentin.connectiq.handsfree.globals.isInDebugMode

const val hideDevicesWithoutApps = true

fun titleForDevice(
    deviceInfo: DeviceInfo,
    appConflict: Boolean,
    context: Context,
    tailorForNotifications: Boolean
): String {
    val prefix = titlePrefixForDevice(
        deviceInfo,
        appConflict = appConflict,
        context,
        tailorForNotifications = tailorForNotifications,
    )
    val suffix = if (!appConflict && isSilent(deviceInfo)) {
        context.getString(R.string.settings_device_suffix_silent)
    } else {
        null
    }
    return listOfNotNull(prefix, suffix).joinToString(nbsp)
}

fun titlePrefixForDevice(
    deviceInfo: DeviceInfo,
    appConflict: Boolean,
    context: Context,
    tailorForNotifications: Boolean
): String {
    val symbol = symbolForDeviceInfo(deviceInfo, appConflict, context)
    if (tailorForNotifications) {
        val symbolsHiddenForNotifications = listOf(
            context.getString(R.string.settings_device_symbol_conflicting),
            context.getString(R.string.settings_device_symbol_active),
            context.getString(R.string.settings_device_symbol_standby)
        )
        if (symbol in symbolsHiddenForNotifications) {
            return deviceInfo.name
        }
    }
    val format = context.getString(R.string.settings_device_with_symbol_fmt)
    return format
        .replace("{{device_name}}", deviceInfo.name)
        .replace("{{symbol}}", symbolForDeviceInfo(deviceInfo, appConflict, context))
}

private fun isSilent(deviceInfo: DeviceInfo): Boolean {
    val installedAppsInfo = deviceInfo.installedAppsInfo
    return installedAppsInfo.isNotEmpty() && installedAppsInfo.find {
        val appConfig = it.appConfig()
        if (appConfig == null) {
            false
        } else {
            !isIncomingCallsEnabled(appConfig)
        }
    } != null
}

fun formattedDeviceInfos(
    deviceInfos: List<DeviceInfo>,
    context: Context,
    tailorForNotifications: Boolean = false,
    separator: String,
): FormattedDeviceInfos {
    return if (hideDevicesWithoutApps) {
        formattedFilteredDeviceInfos(
            deviceInfos,
            context,
            tailorForNotifications,
            separator = separator
        )
    } else {
        formattedUnfilteredDeviceInfos(deviceInfos)
    }
}

fun formattedUnfilteredDeviceInfos(deviceInfos: List<DeviceInfo>): FormattedDeviceInfos {
    val text = deviceInfos
        .sortedWith(compareBy { it.connected })
        .reversed()
        .joinToString(", ") {
            if (it.connected) {
                it.name
            } else {
                "⚠ ${it.name}"
            }
        }
    return FormattedDeviceInfos(text = text, appConflict = null)
}

data class FormattedDeviceInfos(
    val text: String,
    val appConflict: Boolean?
)

fun formattedFilteredDeviceInfos(
    deviceInfos: List<DeviceInfo>,
    context: Context,
    tailorForNotifications: Boolean,
    separator: String? = null,
): FormattedDeviceInfos {
    val matchingCount = deviceInfos.count { it.connected && it.installedAppsInfo.isNotEmpty() }
    val appConflict = matchingCount > 1
    val text = deviceInfos
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
        .joinToString(separator ?: ",$nbsp ") {
            val suffix = if (it.connected) {
                formattedAppInfo(it.installedAppsInfo, context)
            } else {
                ""
            }
            listOfNotNull(
                titleForDevice(
                    it,
                    appConflict = appConflict,
                    context = context,
                    tailorForNotifications = tailorForNotifications
                ),
                suffix
            ).joinToString(" ")
        }
    return FormattedDeviceInfos(text = text, appConflict = appConflict)
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
                    val hasLoading = installedAppsInfo.find {
                        (it.appVersionInfo.version != 1) && (it.appConfig() == null)
                    } != null
                    if (hasLoading) {
                        context.getString(R.string.settings_device_symbol_loading)
                    } else {
                        val hasActive = installedAppsInfo.find {
                            val appConfig = it.appConfig()
                            if (appConfig == null) {
                                false
                            } else {
                                isBroadcastEnabled(appConfig)
                            }
                        } != null
                        if (hasActive) {
                            context.getString(R.string.settings_device_symbol_active)
                        } else {
                            context.getString(R.string.settings_device_symbol_standby)
                        }
                    }
                }
            } else {
                context.getString(R.string.settings_device_symbol_missing_app)
            }
        } else {
            context.getString(R.string.settings_device_symbol_not_connected)
        }
    }
}

const val nbsp = " "
const val refreshMessage = "🔄${nbsp}Refresh"
