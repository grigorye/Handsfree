package com.gentin.connectiq.handsfree.notifications

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import androidx.core.app.NotificationCompat
import com.gentin.connectiq.handsfree.impl.IncomingMessageSource

fun showPongNotification(context: Context, source: IncomingMessageSource) {
    val channelId = "WATCH_APP"
    val channel = NotificationChannel(
        channelId,
        "Watch app",
        NotificationManager.IMPORTANCE_LOW
    )
    channel.description = "Notifications from the watch app."

    val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
    val pendingLaunchIntent = PendingIntent.getActivity(
        context, 0, launchIntent, PendingIntent.FLAG_IMMUTABLE
    )

    val notification = NotificationCompat.Builder(context, channelId)
        .setContentText("Ping OK: ${source.device.friendlyName}")
        .setSmallIcon(android.R.drawable.sym_def_app_icon)
        .setContentIntent(pendingLaunchIntent)
        .build()
    val notificationManager = context.getSystemService(NotificationManager::class.java)
    notificationManager.createNotificationChannel(channel)
    notificationManager.notify(source.device.hashCode(), notification)
}