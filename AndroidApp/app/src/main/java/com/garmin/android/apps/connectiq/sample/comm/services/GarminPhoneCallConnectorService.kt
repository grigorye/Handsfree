package com.garmin.android.apps.connectiq.sample.comm.services

import android.R
import android.app.ForegroundServiceStartNotAllowedException
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.lifecycle.LifecycleService
import androidx.lifecycle.lifecycleScope
import com.garmin.android.apps.connectiq.sample.comm.broadcastreceivers.scheduleKeepAwakeBroadcast
import com.garmin.android.apps.connectiq.sample.comm.globals.DefaultServiceLocator
import com.garmin.android.apps.connectiq.sample.comm.impl.PhoneState
import com.garmin.android.apps.connectiq.sample.comm.impl.lastTrackedPhoneState
import com.garmin.android.apps.connectiq.sample.comm.impl.sendPhoneState


class GarminPhoneCallConnectorService : LifecycleService() {

    override fun onCreate() {
        Log.d(TAG, "onCreate")
        super.onCreate()
        scheduleKeepAwakeBroadcast(this)
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

        ensureForegroundService()

        Log.d(TAG, "Intent: $intent")
        if (intent?.action == "android.intent.action.PHONE_STATE") {
            scheduleIntent(intent)
            return START_NOT_STICKY
        }

        return START_REDELIVER_INTENT
    }

    private fun scheduleIntent(intent: Intent) {
        delayedIntents?.add(intent) ?: processIntent(intent)
    }

    private fun processIntent(intent: Intent) {
        val stateExtra = intent.getStringExtra(TelephonyManager.EXTRA_STATE)!!
        val incomingNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)
        Log.d(TAG, "stateExtra: $stateExtra")
        Log.d(TAG, "incomingNumber: $incomingNumber")

        accountPhoneState(incomingNumber, stateExtra)
    }

    private fun ensureForegroundService() {
        try {
            val CHANNEL_ID = "FOREGROUND_SERVICE"
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Status",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            channel.description = "Allows making calls from Garmin devices."

            val notification = NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentText("Serving call requests from Garmin devices")
                .setSmallIcon(R.drawable.stat_notify_sync)
                .setSilent(true)
                .setOngoing(true)
                .setForegroundServiceBehavior(Notification.FOREGROUND_SERVICE_IMMEDIATE)
                .build()
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)

            startForeground(
                /* id = */ 100,
                /* notification = */ notification,
                /* foregroundServiceType = */
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_MANIFEST
                } else {
                    0
                }
            )
        } catch (e: Exception) {
            Log.e(TAG, "Exception: ${e}")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S
                && e is ForegroundServiceStartNotAllowedException
            ) {
                // App not in a valid state to start foreground service
                // (e.g. started from bg)
            }
            // ...
        }
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
                if (delayedIntents == null) {
                    Log.e(TAG, "Delayed intents is already null.")
                } else {
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