package com.gentin.connectiq.handsfree.services

import android.content.Context
import android.text.TextUtils
import androidx.preference.PreferenceManager
import com.gentin.connectiq.handsfree.R
import com.gentin.connectiq.handsfree.globals.outgoingCallsShouldBeEnabled
import com.gentin.connectiq.handsfree.impl.GarminConnector
import com.gentin.connectiq.handsfree.impl.formattedDeviceInfos
import java.text.DateFormat

data class NotificationContent(
    var title: String? = null,
    var text: String? = null
)

class NotificationContentGenerator(
    private val garminConnector: GarminConnector,
    val context: Context
) {
    private fun isInDebugMode(): Boolean {
        val sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context)
        return sharedPreferences.getBoolean("debug", false)
    }

    fun notificationContent(): NotificationContent {
        return if (isInDebugMode()) {
            debugModeNotificationContent()
        } else {
            releaseModeNotificationContent()
        }
    }

    private fun releaseModeNotificationContent(): NotificationContent {
        val deviceInfos = garminConnector.knownDeviceInfos.value

        return if (deviceInfos.isNullOrEmpty()) {
            NotificationContent("Not connected", "Add a device via Garmin Connect")
        } else {
            if (deviceInfos.count() > 1) {
                val formattedDeviceInfos =
                    formattedDeviceInfos(deviceInfos, context, tailorForNotifications = true)
                if (!outgoingCallsShouldBeEnabled(context)) {
                    NotificationContent("Outgoing calls are off", "Serving $formattedDeviceInfos")
                } else {
                    NotificationContent(text = "Serving $formattedDeviceInfos")
                }
            } else {
                val deviceInfo = deviceInfos[0]
                val deviceName = deviceInfo.name
                if (deviceInfo.connected)
                    if (outgoingCallsShouldBeEnabled(context)) {
                        NotificationContent(text = "Serving $deviceName")
                    } else {
                        NotificationContent("Outgoing calls are off", "Connected to $deviceName")
                    }
                else
                    NotificationContent("Not connected to $deviceName")
            }
        }
    }

    private fun debugModeNotificationContent(): NotificationContent {
        val stats = debugModeStats(garminConnector)
        val title = "${context.getString(R.string.app_name)}: ${stats.launchDateFormatted}"
        return NotificationContent(title, stats.encodedStats)
    }
}

data class DebugModeStats(
    val launchDateFormatted: String,
    val encodedStats: String
)

fun debugModeStats(garminConnector: GarminConnector): DebugModeStats {
    val launchDateFormatted = DateFormat.getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT)
        .format(g.startStats.launchDate)
    val encodedStats = TextUtils.join(
        ", ", arrayOf(
            "i.${g.startStats.incomingMessage}",
            "p.${g.startStats.phoneState}",
            "e.${g.startStats.sdkExceptionDates.count()}",
            "s.${garminConnector.sentMessagesCounter}",
            "a.${garminConnector.acknowledgedMessagesCounter}",
            "o.${g.startStats.other}",
            "b.${g.startStats.bootCompleted}",
            "m.${g.startStats.mainActivity}"
        )
    )
    return DebugModeStats(launchDateFormatted, encodedStats)
}