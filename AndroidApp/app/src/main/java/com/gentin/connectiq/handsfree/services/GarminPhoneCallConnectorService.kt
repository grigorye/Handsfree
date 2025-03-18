@file:Suppress("EmptyMethod")

package com.gentin.connectiq.handsfree.services

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.database.ContentObserver
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.lifecycle.LifecycleService
import androidx.lifecycle.lifecycleScope
import androidx.preference.PreferenceManager
import com.gentin.connectiq.handsfree.globals.AvailableContacts
import com.gentin.connectiq.handsfree.globals.AvailableRecents
import com.gentin.connectiq.handsfree.globals.DefaultServiceLocator
import com.gentin.connectiq.handsfree.globals.watchApps
import com.gentin.connectiq.handsfree.helpers.isRunningInEmulator
import com.gentin.connectiq.handsfree.impl.ACTIVATE_AND_OPEN_WATCH_APP_IN_STORE
import com.gentin.connectiq.handsfree.impl.ACTIVATE_AND_OPEN_WATCH_APP_ON_DEVICE
import com.gentin.connectiq.handsfree.impl.ACTIVATE_AND_PING
import com.gentin.connectiq.handsfree.impl.ACTIVATE_AND_RECONNECT
import com.gentin.connectiq.handsfree.impl.ACTIVATE_FROM_MAIN_ACTIVITY_ACTION
import com.gentin.connectiq.handsfree.impl.GarminConnector
import com.gentin.connectiq.handsfree.impl.OutgoingMessageDestination
import com.gentin.connectiq.handsfree.impl.PhoneState
import com.gentin.connectiq.handsfree.impl.PhoneStateId
import com.gentin.connectiq.handsfree.impl.everywhere
import com.gentin.connectiq.handsfree.impl.isBroadcastEnabled
import com.gentin.connectiq.handsfree.impl.isIncomingCallsEnabled
import com.gentin.connectiq.handsfree.impl.phoneState
import com.gentin.connectiq.handsfree.impl.phoneStateId
import java.util.Date


data class StartStats(
    val launchDate: Date = Date(),
    var total: Int = 0,
    var phoneState: Int = 0,
    var incomingMessage: Int = 0,
    var bootCompleted: Int = 0,
    var mainActivity: Int = 0,
    var other: Int = 0
)

var startStats = StartStats()

var lastTrackedPhoneStateId: PhoneStateId? = null
    private set

var lastTrackedPhoneState: PhoneState? = null
    private set

fun fallbackPhoneState(): PhoneState {
    return PhoneState(PhoneStateId.Idle)
}

var lastRecentsSentOnChange: AvailableRecents? = null
var lastContactsSentOnChange: AvailableContacts? = null

class GarminPhoneCallConnectorService : LifecycleService() {

    private val preferenceChangeListener =
        SharedPreferences.OnSharedPreferenceChangeListener { _, _ ->
            ensureForegroundService()
        }

    private val sharedPreferences: SharedPreferences by lazy {
        PreferenceManager.getDefaultSharedPreferences(this)
    }

    private val callLogObserver = object : ContentObserver(Handler(Looper.getMainLooper())) {
        override fun onChange(selfChange: Boolean) {
            super.onChange(selfChange)
            if (lastTrackedPhoneStateId != null && lastTrackedPhoneStateId != PhoneStateId.Idle) {
                Log.d(TAG, "callLogDidChange.ignoredDuePhoneStateId: $lastTrackedPhoneStateId")
                return
            }
            val recents = l.recents()
            if (recents == lastRecentsSentOnChange) {
                Log.d(TAG, "callLogDidChange.ignoredDueNoChangeInRecents")
                return
            }
            Log.d(TAG, "callLogDidChange.recentsDidChangeToo")
            l.outgoingMessageDispatcher.sendRecents(recents)
            lastRecentsSentOnChange = recents
        }
    }

    private val contactsObserver = object : ContentObserver(Handler(Looper.getMainLooper())) {
        override fun onChange(selfChange: Boolean) {
            super.onChange(selfChange)
            val contacts = l.availableContacts()
            if (contacts == lastContactsSentOnChange) {
                Log.d(TAG, "contactsDidChange.ignoredDueToNoChanges")
                return
            }
            Log.d(TAG, "contactsDidChange.sendingChanges")
            l.outgoingMessageDispatcher.sendContacts(contacts)
            lastContactsSentOnChange = contacts
        }
    }

    override fun onCreate() {
        Log.d(TAG, "onCreate")
        super.onCreate()
        garminConnector.launch()
        garminConnector.knownDeviceInfos.observe(this) {
            ensureForegroundService()
        }
        l.headPhoneConnectionMonitor.start()
        l.callLogRepository.subscribe(callLogObserver)
        l.contactsRepository.subscribe(contactsObserver)
        sharedPreferences.registerOnSharedPreferenceChangeListener(preferenceChangeListener)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            l.audioManager.addOnCommunicationDeviceChangedListener(
                mainExecutor,
                l.communicationDeviceChangedListener
            )
        }
    }

    override fun onDestroy() {
        Log.d(TAG, "onDestroy")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            l.audioManager.removeOnCommunicationDeviceChangedListener(
                l.communicationDeviceChangedListener
            )
        }
        sharedPreferences.unregisterOnSharedPreferenceChangeListener(preferenceChangeListener)
        l.callLogRepository.unsubscribe(callLogObserver)
        l.headPhoneConnectionMonitor.stop()
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

            ACTIVATE_AND_RECONNECT -> {
                startStats.other += 1
                l.contactsRepository.invalidatePermissions()
                l.callLogRepository.invalidatePermissions()
                garminConnector.terminate()
                garminConnector.launch()
                START_REDELIVER_INTENT
            }

            ACTIVATE_AND_OPEN_WATCH_APP_IN_STORE -> {
                garminConnector.openWatchAppInStore()
                START_NOT_STICKY
            }

            ACTIVATE_AND_OPEN_WATCH_APP_ON_DEVICE -> {
                for (app in watchApps) {
                    garminConnector.openWatchAppOnEveryDevice(app) { destination, succeeded ->
                        if (!succeeded) {
                            l.outgoingMessageDispatcher.sendOpenAppFailed(destination)
                        }
                    }
                }
                START_NOT_STICKY
            }

            ACTIVATE_AND_PING -> {
                l.outgoingMessageDispatcher.sendPing()
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

        lastTrackedPhoneStateId = phoneStateId(stateExtra)

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

        val notificationAttributesGenerator = NotificationContentGenerator(garminConnector, this)
        val attributes = notificationAttributesGenerator.notificationContent()
        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle(attributes.title)
            .setContentText(attributes.text)
            .setSmallIcon(android.R.drawable.stat_notify_sync)
            .setOngoing(true)
            .setContentIntent(pendingLaunchIntent)
            .setShowWhen(false)
            .apply {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    setForegroundServiceBehavior(Notification.FOREGROUND_SERVICE_IMMEDIATE)
                }
            }
            .build()
        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager.createNotificationChannel(channel)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                /* id = */ 100,
                /* notification = */ notification,
                /* foregroundServiceType = */ ServiceInfo.FOREGROUND_SERVICE_TYPE_MANIFEST
            )
        } else {
            startForeground(
                /* id = */ 100,
                /* notification = */ notification
            )
        }
    }

    private fun accountPhoneState(incomingNumber: String?, stateExtra: String) {
        val incomingDisplayNames = incomingNumber?.let {
            availableDisplayNames(it)
        } ?: listOf()
        val phoneState = phoneState(
            this,
            stateExtra,
            incomingNumber,
            incomingDisplayNames
        )
        lastTrackedPhoneState = phoneState
        val where =
            if (phoneState.stateId == PhoneStateId.Ringing) {
                OutgoingMessageDestination(
                    device = null,
                    app = null,
                    skipOnAppConfig = { appConfig ->
                        if (isIncomingCallsEnabled(appConfig)) {
                            false
                        } else {
                            !isBroadcastEnabled(appConfig)
                        }
                    }
                )
            } else {
                everywhere
            }
        l.outgoingMessageDispatcher.sendPhoneState(where, phoneState)

        if (phoneState.stateId == PhoneStateId.Idle) {
            l.accountAudioState()
        } else if (stateExtra == TelephonyManager.EXTRA_STATE_OFFHOOK) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
                // Workaround audio route not yet up to date.
                val handler = Handler(Looper.getMainLooper())
                handler.postDelayed({
                    l.accountAudioState()
                }, 1000)
            } else {
                // We assume that A) audio route would be changed (automatically) soon after
                // call start.
                // However, it's also possible that B) it won't happen, e.g. when the ear-speaker
                // is used for the call.
                // To account both cases, we give it a try a few seconds after the call start.
                val handler = Handler(Looper.getMainLooper())
                handler.postDelayed({
                    l.accountAudioState()
                }, 1000)
            }
        } else {
            if (isRunningInEmulator()) {
                l.accountAudioState()
            }
        }

        if ((stateExtra == TelephonyManager.EXTRA_STATE_RINGING) && isOpenWatchAppOnRingingEnabled()) {
            for (app in watchApps) {
                l.garminConnector.openWatchAppOnEveryDevice(app) { destination, succeeded ->
                    if (!succeeded) {
                        l.outgoingMessageDispatcher.sendOpenAppFailed(destination)
                    }
                }
            }
        }
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

    private fun isOpenWatchAppOnRingingEnabled(): Boolean {
        return false
    }

    companion object {
        private val TAG: String = GarminPhoneCallConnectorService::class.java.simpleName
    }
}