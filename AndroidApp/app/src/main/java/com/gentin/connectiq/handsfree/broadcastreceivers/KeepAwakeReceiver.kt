package com.gentin.connectiq.handsfree.broadcastreceivers

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.gentin.connectiq.handsfree.impl.ACTIVATE_FROM_KEEP_AWAKE
import com.gentin.connectiq.handsfree.impl.startConnector


class KeepAwakeReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "onReceivePid: ${android.os.Process.myPid()}")

        startConnector(context, ACTIVATE_FROM_KEEP_AWAKE)
        scheduleKeepAwakeBroadcast(context, 5)
    }

    companion object {
        val TAG: String = KeepAwakeReceiver::class.java.simpleName
    }
}

// Relying on keep awake is not reliable and it results in the need for launching on boot (that
// itself is problematic due to problems with initialization of Garmin SDK at that moment).
// We (luckily) can employ INCOMING_MESSAGE as a trigger instead.
var keepAwakeEnabled = false

fun scheduleKeepAwakeBroadcast(context: Context, minutes: Int) {
    val tag = object {}.javaClass.enclosingMethod?.name

    Log.d(tag, "keepAwakeEnabled: $keepAwakeEnabled")
    if (!keepAwakeEnabled) {
        return
    }

    val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    val intent = Intent(context, KeepAwakeReceiver::class.java)
    val pendingIntent =
        PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_IMMUTABLE)

    val canScheduleExactAlarms = alarmManager.canScheduleExactAlarms()
    Log.d(tag, "canScheduleExactAlarms: $canScheduleExactAlarms")
    if (canScheduleExactAlarms) {
        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            System.currentTimeMillis() + 1000 * 60 * minutes,
            pendingIntent
        )
    }
}