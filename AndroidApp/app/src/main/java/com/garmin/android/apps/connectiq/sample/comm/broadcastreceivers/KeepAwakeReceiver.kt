package com.garmin.android.apps.connectiq.sample.comm.broadcastreceivers

import com.garmin.android.apps.connectiq.sample.comm.helpers.ACTIVATE_FROM_KEEP_AWAKE
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.garmin.android.apps.connectiq.sample.comm.helpers.startConnector


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