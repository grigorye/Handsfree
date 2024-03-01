package com.garmin.android.apps.connectiq.sample.comm.services

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.content.pm.ServiceInfo
import android.telephony.TelephonyManager
import android.text.TextUtils
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.lifecycle.LifecycleService
import androidx.lifecycle.lifecycleScope
import com.garmin.android.apps.connectiq.sample.comm.activities.MainActivity
import com.garmin.android.apps.connectiq.sample.comm.broadcastreceivers.scheduleKeepAwakeBroadcast
import com.garmin.android.apps.connectiq.sample.comm.globals.DefaultServiceLocator
import com.garmin.android.apps.connectiq.sample.comm.helpers.ACTIVATE_FROM_KEEP_AWAKE
import com.garmin.android.apps.connectiq.sample.comm.helpers.ACTIVATE_FROM_MAIN_ACTIVITY_ACTION
import com.garmin.android.apps.connectiq.sample.comm.impl.PhoneState
import com.garmin.android.apps.connectiq.sample.comm.impl.lastTrackedPhoneState
import com.garmin.android.apps.connectiq.sample.comm.impl.sendPhoneState
import java.text.DateFormat
import java.util.Date

data class StartStats(
    val launchDate: Date = Date(),
    var total: Int = 0,
    var phoneState: Int = 0,
    var incomingMessage: Int = 0,
    var bootCompleted: Int = 0,
    var mainActivity: Int = 0,
    var keepAwake: Int = 0,
    var other: Int = 0
)

var startStats = StartStats()

class GarminPhoneCallConnectorService : LifecycleService() {

    override fun onCreate() {
        Log.d(TAG, "onCreate")
        super.onCreate()
        scheduleKeepAwakeBroadcast(this, 5)
        garminConnector.onStart()
    }

    override fun onDestroy() {
        Log.d(TAG, "onDestroy")
        garminConnector.onStop()
        super.onDestroy()
    }

    private var delayedIntents: ArrayList<Intent>? = ArrayList()

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)

        startStats.total += 1

        Log.d(TAG, "intent: $intent")

        val resultCode: Int = when (intent?.action) {
            "android.intent.action.PHONE_STATE" -> {
                startStats.phoneState += 1
                scheduleIntent(intent)
                START_NOT_STICKY
            }

            "com.garmin.android.connectiq.INCOMING_MESSAGE" -> {
                startStats.incomingMessage += 1
                ensureForegroundService()
                START_REDELIVER_INTENT
            }

            "android.intent.action.BOOT_COMPLETED" -> {
                startStats.bootCompleted += 1
                START_REDELIVER_INTENT
            }

            ACTIVATE_FROM_MAIN_ACTIVITY_ACTION -> {
                startStats.mainActivity += 1
                START_REDELIVER_INTENT
            }

            ACTIVATE_FROM_KEEP_AWAKE -> {
                startStats.keepAwake += 1
                START_REDELIVER_INTENT
            }

            else -> {
                startStats.other += 1
                START_REDELIVER_INTENT
            }
        }

        ensureForegroundService()

        Log.d(TAG, "onStartResultCode: $resultCode")
        return resultCode
    }

    private fun scheduleIntent(intent: Intent) {
        delayedIntents?.add(intent) ?: processIntent(intent)
    }

    private fun processIntent(intent: Intent) {
        val stateExtra = intent.getStringExtra(TelephonyManager.EXTRA_STATE)!!

        @Suppress("DEPRECATION")
        val incomingNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)
        Log.d(TAG, "stateExtra: $stateExtra")
        Log.d(TAG, "incomingNumber: $incomingNumber")

        accountPhoneState(incomingNumber, stateExtra)
    }

    private fun ensureForegroundService() {
        val channelId = "GARMIN_CONNECT"
        val channel = NotificationChannel(
            channelId,
            "Garmin Connect",
            NotificationManager.IMPORTANCE_LOW
        )
        channel.description = "Allows making calls from Garmin devices."

        val resultIntent = Intent(this, MainActivity::class.java)
        val resultPendingIntent = PendingIntent.getActivity(
            this, 0, resultIntent, PendingIntent.FLAG_IMMUTABLE
        )

        val dateFormatted = DateFormat.getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT)
            .format(startStats.launchDate)
        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Comm: $dateFormatted")
            .setContentText(
                TextUtils.join(
                    ", ", arrayOf(
                        "i.${startStats.incomingMessage}",
                        "p.${startStats.phoneState}",
                        "b.${startStats.bootCompleted}",
                        "m.${startStats.mainActivity}",
                        "k.${startStats.keepAwake}",
                        "o.${startStats.other}"
                    )
                )
            )
            .setSmallIcon(android.R.drawable.stat_notify_sync)
            .setOngoing(true)
            .setForegroundServiceBehavior(Notification.FOREGROUND_SERVICE_IMMEDIATE)
            .setContentIntent(resultPendingIntent)
            .build()
        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager.createNotificationChannel(channel)

        startForeground(
            /* id = */ 100,
            /* notification = */ notification,
            /* foregroundServiceType = */ ServiceInfo.FOREGROUND_SERVICE_TYPE_MANIFEST
        )
    }

    private fun accountPhoneState(incomingNumber: String?, stateExtra: String) {
        val outgoingMessageDispatcher = l.outgoingMessageDispatcher

        val phoneState = PhoneState(incomingNumber, stateExtra)
        lastTrackedPhoneState = phoneState

        sendPhoneState(phoneState) { message ->
            outgoingMessageDispatcher.send(message)
        }
    }

    private val l by lazy {
        DefaultServiceLocator(
            this,
            lifecycleScope = lifecycleScope,
            onSDKReadyImp = {
                Log.d(TAG, "delayedIntents: $delayedIntents")
                if (delayedIntents != null) {
                    val intents = delayedIntents
                    delayedIntents = null
                    intents?.forEach {
                        processIntent(it)
                    }
                }
            }
        )
    }

    private val garminConnector by lazy { l.garminConnector }

    companion object {
        private val TAG: String = GarminPhoneCallConnectorService::class.java.simpleName
    }
}