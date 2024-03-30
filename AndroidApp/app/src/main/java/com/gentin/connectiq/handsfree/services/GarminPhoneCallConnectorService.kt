package com.gentin.connectiq.handsfree.services

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.telephony.TelephonyManager
import android.text.TextUtils
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.lifecycle.LifecycleService
import androidx.lifecycle.lifecycleScope
import com.gentin.connectiq.handsfree.R
import com.gentin.connectiq.handsfree.broadcastreceivers.scheduleKeepAwakeBroadcast
import com.gentin.connectiq.handsfree.globals.DefaultServiceLocator
import com.gentin.connectiq.handsfree.impl.ACTIVATE_AND_OPEN_WATCH_APP_IN_STORE
import com.gentin.connectiq.handsfree.impl.ACTIVATE_AND_RECONNECT
import com.gentin.connectiq.handsfree.impl.ACTIVATE_FROM_KEEP_AWAKE
import com.gentin.connectiq.handsfree.impl.ACTIVATE_FROM_MAIN_ACTIVITY_ACTION
import com.gentin.connectiq.handsfree.impl.GarminConnector
import com.gentin.connectiq.handsfree.impl.HeadsetConnectionMonitor
import com.gentin.connectiq.handsfree.impl.PhoneState
import com.gentin.connectiq.handsfree.impl.sdkRelaunchesOnExceptions
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

var lastTrackedPhoneState: PhoneState? = null
    private set

class GarminPhoneCallConnectorService : LifecycleService() {

    override fun onCreate() {
        Log.d(TAG, "onCreate")
        super.onCreate()
        scheduleKeepAwakeBroadcast(this, 5)
        garminConnector.launch()
        headPhoneConnectionMonitor.start()
    }

    override fun onDestroy() {
        Log.d(TAG, "onDestroy")
        headPhoneConnectionMonitor.stop()
        garminConnector.terminate()
        super.onDestroy()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)

        startStats.total += 1

        Log.d(TAG, "onStartCommand.intent: $intent")

        val resultCode: Int = when (intent?.action) {
            "android.intent.action.PHONE_STATE" -> {
                startStats.phoneState += 1
                processPhoneStateIntent(intent)
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

            ACTIVATE_AND_RECONNECT -> {
                startStats.other += 1
                garminConnector.terminate()
                garminConnector.launch()
                START_REDELIVER_INTENT
            }

            ACTIVATE_AND_OPEN_WATCH_APP_IN_STORE -> {
                garminConnector.openWatchAppInStore()
                START_NOT_STICKY
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


    private fun processPhoneStateIntent(intent: Intent) {
        val stateExtra = intent.getStringExtra(TelephonyManager.EXTRA_STATE)!!
        Log.d(TAG, "stateExtra: $stateExtra")

        val shouldHaveIncomingNumber = ActivityCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_CALL_LOG
        ) == PackageManager.PERMISSION_GRANTED
        Log.d(TAG, "shouldHaveIncomingNumber: $shouldHaveIncomingNumber")

        @Suppress("DEPRECATION")
        if (shouldHaveIncomingNumber && !intent.hasExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)) {
            Log.d(TAG, "skippedForNoIncomingNumberWhilePermission: $intent")
            return
        }

        @Suppress("DEPRECATION")
        val incomingNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)
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

        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingLaunchIntent = PendingIntent.getActivity(
            this, 0, launchIntent, PendingIntent.FLAG_IMMUTABLE
        )

        val dateFormatted = DateFormat.getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT)
            .format(startStats.launchDate)
        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("${getString(R.string.app_name)}: $dateFormatted")
            .setContentText(
                TextUtils.join(
                    ", ", arrayOf(
                        "i.${startStats.incomingMessage}",
                        "p.${startStats.phoneState}",
                        "e.${sdkRelaunchesOnExceptions}",
                        "s.${garminConnector.sentMessagesCounter}",
                        "a.${garminConnector.acknowledgedMessagesCounter}",
                        "o.${startStats.other}",
                        "b.${startStats.bootCompleted}",
                        "m.${startStats.mainActivity}",
                        "k.${startStats.keepAwake}",
                    )
                )
            )
            .setSmallIcon(android.R.drawable.stat_notify_sync)
            .setOngoing(true)
            .setForegroundServiceBehavior(Notification.FOREGROUND_SERVICE_IMMEDIATE)
            .setContentIntent(pendingLaunchIntent)
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
        val incomingDisplayNames = incomingNumber?.let {
            availableDisplayNames(it)
        } ?: listOf()
        val isHeadsetConnected = headPhoneConnectionMonitor.isHeadsetConnected()
        val phoneState = PhoneState(
            incomingNumber,
            incomingDisplayNames,
            stateExtra,
            isHeadsetConnected
        )
        lastTrackedPhoneState = phoneState
        l.outgoingMessageDispatcher.sendPhoneState(phoneState)
    }

    private fun availableDisplayNames(incomingNumber: String): List<String> {
        return try {
            val displayNames = l.contactsRepository.displayNamesForPhoneNumber(incomingNumber)
            Log.d(TAG, "displayNames: $displayNames")
            displayNames
        } catch (e: RuntimeException) {
            Log.e(TAG, "failedToRetrieveDisplayNames: $e")
            listOf()
        }
    }

    private val l by lazy {
        DefaultServiceLocator(
            this,
            lifecycleScope = lifecycleScope
        )
    }

    private val garminConnector: GarminConnector by lazy { l.garminConnector }

    private val headPhoneConnectionMonitor = HeadsetConnectionMonitor(this) {
        sendHeadsetState()
    }

    private fun sendHeadsetState() {
        accountPhoneState(
            lastTrackedPhoneState?.incomingNumber,
            lastTrackedPhoneState?.stateExtra ?: TelephonyManager.EXTRA_STATE_IDLE
        )
    }

    companion object {
        private val TAG: String = GarminPhoneCallConnectorService::class.java.simpleName
    }
}