package com.gentin.connectiq.handsfree.services

import android.content.Context
import android.text.TextUtils
import com.gentin.connectiq.handsfree.R
import com.gentin.connectiq.handsfree.globals.outgoingCallsShouldBeEnabled
import com.gentin.connectiq.handsfree.impl.GarminConnector
import com.gentin.connectiq.handsfree.impl.sdkRelaunchesOnExceptions
import java.text.DateFormat

data class NotificationContent(
    var title: String,
    var text: String? = null
)

class NotificationContentGenerator(
    private var garminConnector: GarminConnector,
    var context: Context
) {
    private fun isInDebugMode(): Boolean {
        return false
    }

    fun notificationContent(): NotificationContent {
        return if (isInDebugMode()) {
            debugModeNotificationContent()
        } else {
            releaseModeNotificationContent()
        }
    }

    private fun releaseModeNotificationContent(): NotificationContent {
        val deviceInfo = garminConnector.knownDeviceInfos.value?.lastOrNull()

        return if (deviceInfo != null) {
            val deviceName = deviceInfo.name
            if (deviceInfo.connected)
                if (outgoingCallsShouldBeEnabled(context)) {
                    NotificationContent("Serving outgoing calls from $deviceName")
                } else {
                    NotificationContent("Connected to $deviceName", "Not serving outgoing calls.")
                }
            else
                NotificationContent("Not connected to $deviceName")
        } else {
            NotificationContent("Not connected", "Use Garmin Connect to add a device.")
        }
    }

    private fun debugModeNotificationContent(): NotificationContent {
        val dateFormatted = DateFormat.getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT)
            .format(startStats.launchDate)
        val title = "${context.getString(R.string.app_name)}: $dateFormatted"
        val text = TextUtils.join(
            ", ", arrayOf(
                "i.${startStats.incomingMessage}",
                "p.${startStats.phoneState}",
                "e.$sdkRelaunchesOnExceptions",
                "s.${garminConnector.sentMessagesCounter}",
                "a.${garminConnector.acknowledgedMessagesCounter}",
                "o.${startStats.other}",
                "b.${startStats.bootCompleted}",
                "m.${startStats.mainActivity}"
            )
        )
        return NotificationContent(title, text)
    }
}