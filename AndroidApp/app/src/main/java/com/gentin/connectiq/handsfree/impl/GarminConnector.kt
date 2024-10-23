package com.gentin.connectiq.handsfree.impl

import android.content.Context
import android.content.ContextWrapper
import android.os.Looper
import android.util.Log
import androidx.lifecycle.LifecycleCoroutineScope
import androidx.lifecycle.LiveData
import androidx.lifecycle.MediatorLiveData
import androidx.lifecycle.MutableLiveData
import com.garmin.android.connectiq.ConnectIQ
import com.garmin.android.connectiq.ConnectIQ.IQApplicationInfoListener
import com.garmin.android.connectiq.ConnectIQ.IQOpenApplicationStatus
import com.garmin.android.connectiq.IQApp
import com.garmin.android.connectiq.IQDevice
import com.garmin.android.connectiq.exception.InvalidStateException
import com.garmin.android.connectiq.exception.ServiceUnavailableException
import com.gentin.connectiq.handsfree.globals.appLogName
import com.gentin.connectiq.handsfree.globals.defaultApp
import com.gentin.connectiq.handsfree.globals.simApp
import com.gentin.connectiq.handsfree.globals.storeID
import com.gentin.connectiq.handsfree.globals.watchApps
import com.gentin.connectiq.handsfree.helpers.breakIntoDebugger
import com.gentin.connectiq.handsfree.helpers.isRunningInEmulator
import com.google.gson.Gson
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

val pingBody = mapOf("cmd" to "ping")

interface GarminConnector {
    fun launch()
    fun terminate()

    fun sendMessage(message: OutgoingMessage)
    fun openWatchAppInStore(app: IQApp = defaultApp())
    fun openWatchAppOnDevice(device: IQDevice, app: IQApp, completion: (succeeded: Boolean) -> Unit)
    fun openWatchAppOnEveryDevice(
        app: IQApp = defaultApp(),
        completion: (destination: OutgoingMessageDestination, succeeded: Boolean) -> Unit
    )

    fun trackFirstAppLaunch(device: IQDevice, app: IQApp)

    val sentMessagesCounter: Int
    val acknowledgedMessagesCounter: Int

    val knownDeviceInfos: LiveData<List<DeviceInfo>>
}

data class DeviceInfo(
    val name: String,
    val connected: Boolean,
    var installedAppsCount: Int
) {
    val displayName: String
        get() = name.replace(" ", " ")
}

class DefaultGarminConnector(
    base: Context?,
    private val lifecycleScope: LifecycleCoroutineScope,
    val dispatchIncomingMessage: (Any, IncomingMessageSource) -> Unit,
    val appDataMayBeInvalidated: (IQDevice, IQApp) -> Unit
) : ContextWrapper(base), GarminConnector {

    private lateinit var connectIQ: ConnectIQ

    override val knownDeviceInfos: LiveData<List<DeviceInfo>> by lazy {
        MediatorLiveData<List<DeviceInfo>>().apply {
            addSource(knownDevices) { knownDevices ->
                value = knownDevices.values.toList()
            }
        }
    }

    override fun launch() {
        Log.d(TAG, "launch")
        val dispatcher = if (isRunningInEmulator()) Dispatchers.Main else Dispatchers.Default

        lifecycleScope.launch(dispatcher) {
            if (Looper.myLooper() == null) {
                Looper.prepare()
            }
            startSDK()
        }
    }

    override fun terminate() {
        Log.d(TAG, "stop")
        shutdownSDK()
        pendingMessages = ArrayList()
    }

    override fun sendMessage(message: OutgoingMessage) {
        pendingMessages?.apply {
            Log.d(TAG, "addedPending: $message")
            add(message)
        } ?: sendMessageOrRescheduleAsync(message)
    }

    override fun openWatchAppInStore(app: IQApp) {
        Log.d(TAG, "Opening ${app.displayName}")
        try {
            val succeeded = connectIQ.openStore(storeID(app))
            Log.d(TAG, "openStoreSucceeded: $succeeded")
        } catch (e: RuntimeException) {
            Log.e(TAG, "openStoreFailed: $e")
        }
    }

    override fun openWatchAppOnEveryDevice(
        app: IQApp,
        completion: (destination: OutgoingMessageDestination, succeeded: Boolean) -> Unit
    ) {
        connectIQ.knownDevices.forEach { device ->
            openWatchAppOnDevice(device, app) { succeeded ->
                val destination = OutgoingMessageDestination(device, app)
                completion(destination, succeeded)
            }
        }
    }

    override fun openWatchAppOnDevice(
        device: IQDevice,
        app: IQApp,
        completion: (succeeded: Boolean) -> Unit
    ) {
        try {
            connectIQ.openApplication(device, app) { _, _, status ->
                when (status) {
                    IQOpenApplicationStatus.PROMPT_SHOWN_ON_DEVICE -> completion(true)
                    IQOpenApplicationStatus.PROMPT_NOT_SHOWN_ON_DEVICE -> completion(false)
                    IQOpenApplicationStatus.APP_IS_NOT_INSTALLED -> completion(false)
                    IQOpenApplicationStatus.APP_IS_ALREADY_RUNNING -> completion(true)
                    IQOpenApplicationStatus.UNKNOWN_FAILURE -> completion(false)
                    null -> completion(false)
                }
                Log.d(
                    TAG,
                    "openWatchAppOnDevice(${device.friendlyName}, ${appLogName(app)}): $status"
                )
            }
        } catch (e: RuntimeException) {
            Log.e(TAG, "openWatchAppOnDeviceFailed(${device.friendlyName}, ${appLogName(app)}): $e")
            completion(false)
        } catch (e: InvalidStateException) {
            Log.e(
                TAG,
                "openWatchAppOnDeviceFailed(NoAdbConnection?)(${device.friendlyName}, ${
                    appLogName(app)
                }): $e"
            )
            completion(false)
        }
    }

    override fun trackFirstAppLaunch(device: IQDevice, app: IQApp) {
        trackInstalledApp(device, app)
    }

    private var shuttingDownSDK = false

    private fun shutdownSDK() {
        Log.d(TAG, "shutdownSDK")
        shuttingDownSDK = true
        connectIQ.shutdown(this)
        shuttingDownSDK = false
    }

    private fun startSDK() {
        Log.d(TAG, "startSDK")
        val connectType = if (isRunningInEmulator()) {
            ConnectIQ.IQConnectType.TETHERED
        } else {
            ConnectIQ.IQConnectType.WIRELESS
        }

        connectIQ = ConnectIQ.getInstance(this, connectType)
        connectIQ.initialize(this, true, connectIQListener)
    }

    private fun startIncomingMessageProcessing(device: IQDevice) {
        Log.d(
            TAG,
            "startIncomingMessageProcessing: ${device.deviceIdentifier}(${device.friendlyName})"
        )
        for (app in watchApps) {
            connectIQ.registerForAppEvents(device, app) { _, _, message, _ ->
                for (o in message) {
                    val deviceTag = "device.${device.deviceIdentifier}(${device.friendlyName})"
                    Log.d(TAG, "$deviceTag(${appLogName(app)}) -> $o")
                    dispatchIncomingMessage(o, IncomingMessageSource(device, app))
                }
            }
        }
    }

    private val notInstalledApps = mutableMapOf<Long, MutableList<IQApp>>()

    private fun trackNotInstalledApp(device: IQDevice, app: IQApp) {
        val key = device.deviceIdentifier
        val apps = notInstalledApps[key] ?: mutableListOf()
        apps.add(app)
        notInstalledApps[key] = apps
    }

    private fun trackInstalledApp(device: IQDevice, app: IQApp) {
        val key = device.deviceIdentifier
        val apps = notInstalledApps[key] ?: mutableListOf()
        apps.removeIf { x -> x.applicationId == app.applicationId }
        notInstalledApps[key] = apps
    }

    private fun isNotInstalledApp(device: IQDevice, app: IQApp): Boolean {
        return notInstalledApps[device.deviceIdentifier]?.contains(app) ?: false
    }

    private fun clearNotInstalledApps() {
        notInstalledApps.clear()
    }

    private fun startOutgoingMessageGeneration(device: IQDevice) {
        Log.d(
            TAG,
            "startOutgoingMessageGeneration: ${device.deviceIdentifier}(${device.friendlyName})"
        )
        for (app in watchApps) {
            connectIQ.getApplicationInfo(
                app.applicationId,
                device,
                object : IQApplicationInfoListener {
                    override fun onApplicationInfoReceived(p0: IQApp?) {
                        if (p0 == null) {
                            assert(false)
                            return
                        }
                        when {
                            p0.status == IQApp.IQAppStatus.INSTALLED -> {
                                Log.d(
                                    TAG,
                                    "appStatus(${device.friendlyName}, ${appLogName(app)}): INSTALLED (${p0.version()})"
                                )
                                val deviceInfo = knownDevicesAcc[device.deviceIdentifier]
                                if (deviceInfo == null) {
                                    assert(false)
                                } else {
                                    deviceInfo.installedAppsCount += 1
                                    knownDevicesAcc[device.deviceIdentifier] = deviceInfo
                                    knownDevices.postValue(knownDevicesAcc)
                                }
                                appDataMayBeInvalidated(device, app)
                            }

                            p0.status == IQApp.IQAppStatus.UNKNOWN && p0.applicationId == simApp.applicationId -> {
                                Log.d(
                                    TAG,
                                    "appStatus(${device.friendlyName}, ${appLogName(app)}): INSTALLED (${p0.version()})"
                                )
                                appDataMayBeInvalidated(device, app)
                            }

                            else -> {
                                Log.d(
                                    TAG,
                                    "appInfoReceived(${device.friendlyName}): ${appLogName(app)}, ${p0.status}"
                                )
                            }
                        }
                    }

                    override fun onApplicationNotInstalled(p0: String?) {
                        Log.d(
                            TAG,
                            "appStatus(${device.friendlyName}, ${appLogName(app)}): NOT_INSTALLED"
                        )
                        trackNotInstalledApp(device, app)
                    }
                })
        }
    }

    private fun stopOutgoingMessageGeneration() {
        clearNotInstalledApps()
    }

    private var installedAppsTrackingEnabled = true

    private fun startMessageProcessing() {
        Log.d(TAG, "connectIQ: $connectIQ")
        Log.d(
            TAG,
            "knownDevices: ${
                connectIQ.knownDevices
                    .map { x -> "${x.deviceIdentifier}(${x.friendlyName})" }
            }"
        )
        connectIQ.knownDevices.forEach { device ->
            startIncomingMessageProcessing(device)
        }
    }

    private fun stopMessageProcessing() {
        Log.d(TAG, "stoppingMessageProcessing")
        if (installedAppsTrackingEnabled) {
            stopOutgoingMessageGeneration()
        }
    }

    private val connectIQListener = DefaultConnectIQListener(this)

    fun onSDKReady() {
        sdkStartCount += 1
        sentMessagesCounter = 0
        acknowledgedMessagesCounter = 0
        Log.d(TAG, "sdkReady: $sdkStartCount")
        lifecycleScope.launch(Dispatchers.Default) {
            try {
                stopMessageProcessing()
                stopObservingDeviceEvents()
                startObservingDeviceEvents()
                startMessageProcessing()
                processPendingMessages()
                pendingMessages = null
            } catch (e: ServiceUnavailableException) {
                Log.e(TAG, "serviceUnavailableOnSDKReady: $e")
                breakIntoDebugger()
            }
        }
    }

    fun onSDKShutDown() {
        if (shuttingDownSDK) {
            Log.d(TAG, "shuttingDownSDK")
        } else {
            sdkRelaunchesOnExceptions += 1
            Log.d(TAG, "relaunchingSDKOnException")
            shuttingDownSDK = true
            connectIQ.shutdown(this) // Workaround no actual shutdown on exceptions
            shuttingDownSDK = false

            lifecycleScope.launch(Dispatchers.Default) {
                if (Looper.myLooper() == null) {
                    Looper.prepare()
                }
                if (pendingMessages == null) {
                    pendingMessages = ArrayList()
                }
                startSDK()
            }
        }
    }

    private val knownDevices = MutableLiveData(mapOf<Long, DeviceInfo>())
    private val knownDevicesAcc = mutableMapOf<Long, DeviceInfo>()

    private fun stopObservingDeviceEvents() {
        Log.d(TAG, "stopObservingDeviceEvents: ${connectIQ.knownDevices}")
        connectIQ.knownDevices.forEach { device ->
            device.status = connectIQ.getDeviceStatus(device)
            connectIQ.unregisterForDeviceEvents(device)
        }
        knownDevicesAcc.clear()
        Log.d(TAG, "postingNewKnownDevices: $knownDevicesAcc")
        knownDevices.postValue(knownDevicesAcc)
    }

    private fun startObservingDeviceEvents() {
        Log.d(TAG, "startObservingDeviceEvents: ${connectIQ.knownDevices}")
        connectIQ.knownDevices.forEach { device ->
            device.status = connectIQ.getDeviceStatus(device)
            connectIQ.registerForDeviceEvents(device) { _, status ->
                knownDevicesAcc[device.deviceIdentifier] =
                    DeviceInfo(
                        device.friendlyName,
                        connected = status == IQDevice.IQDeviceStatus.CONNECTED,
                        installedAppsCount = 0
                    )
                Log.d(TAG, "postingNewKnownDevices: $knownDevicesAcc")
                knownDevices.postValue(knownDevicesAcc)
                Log.d(
                    TAG,
                    "device.${device.deviceIdentifier}(${device.friendlyName}) <- status($status)"
                )
                if (installedAppsTrackingEnabled && (status == IQDevice.IQDeviceStatus.CONNECTED)) {
                    startOutgoingMessageGeneration(device)
                }
            }
        }
    }

    private var pendingMessages: ArrayList<OutgoingMessage>? = ArrayList()

    private fun sendMessageOrRescheduleAsync(message: OutgoingMessage) {
        lifecycleScope.launch(Dispatchers.Default) {
            try {
                sendMessageSync(message)
            } catch (e: ServiceUnavailableException) {
                Log.e(TAG, "sendMessageOrRescheduleFailed($message): $e")
                breakIntoDebugger()
                if (pendingMessages == null) {
                    pendingMessages = ArrayList()
                }
                pendingMessages!!.add(message)
                throw e
            }
        }
    }

    private fun processPendingMessages() {
        Log.d(TAG, "pendingMessages: $pendingMessages")
        while (pendingMessages!!.isNotEmpty()) {
            val message = pendingMessages!![0]
            sendMessageSync(message)
            pendingMessages!!.removeAt(0)
        }
        pendingMessages = null
    }

    private var sdkStartCount = 0
    override var sentMessagesCounter = 0
        private set
    override var acknowledgedMessagesCounter = 0
        private set

    private fun useOnlyInstalledAppsForSendingMessages(): Boolean {
        return true
    }

    private fun appsForSendingMessages(device: IQDevice): List<IQApp> {
        return watchApps.filter {
            if (!useOnlyInstalledAppsForSendingMessages()) {
                true
            } else {
                !isNotInstalledApp(device, it)
            }
        }
    }

    private val gson = Gson()
    private val tagMessages = false

    private fun sendMessageSync(messageValue: OutgoingMessage) {
        sentMessagesCounter += 1
        val sdkStartCount = this.sdkStartCount
        val id = "$sdkStartCount.$sentMessagesCounter"
        val message = if (tagMessages) { mapOf("id" to id) + messageValue.body } else { messageValue.body }

        val destination = messageValue.destination
        val targetDevices = if (destination.device != null) {
            listOf(destination.device)
        } else {
            connectIQ.connectedDevices
        }

        try {
            targetDevices.forEach { device ->
                val targetApps = if (destination.app != null) {
                    listOf(destination.app)
                } else {
                    appsForSendingMessages(device)
                }
                targetApps.forEach { app ->
                    val appLogName = appLogName(app)
                    if (messageValue.body == pingBody) {
                        Log.d(
                            TAG,
                            "device.${device.deviceIdentifier}(${device.friendlyName})($appLogName) <- msg-ping.$id"
                        )
                        connectIQ.sendMessage(device, app, "ping".toByteArray()) { _, _, status ->
                            Log.d(
                                TAG,
                                "device.${device.deviceIdentifier}(${device.friendlyName})($appLogName) -> ack-ping(${status}, msg.$id) [$sentMessagesCounter]"
                            )
                        }
                    } else {
                        Log.d(
                            TAG,
                            "device.${device.deviceIdentifier}(${device.friendlyName})($appLogName) <- msg.$id(${
                                gson.toJson(
                                    message
                                )
                            })"
                        )
                        connectIQ.sendMessage(device, app, message) { _, _, status ->
                            acknowledgedMessagesCounter += 1
                            Log.d(
                                TAG,
                                "device.${device.deviceIdentifier}(${device.friendlyName})($appLogName) -> ack(${status}, msg.$id) [$acknowledgedMessagesCounter]"
                            )
                        }
                    }
                }
            }
        } catch (e: ServiceUnavailableException) {
            Log.e(TAG, "sendMessageFailed($message): $e")
            breakIntoDebugger()
            throw e
        }
    }

    companion object {
        private val TAG: String = DefaultGarminConnector::class.java.simpleName
    }
}

var sdkRelaunchesOnExceptions = 0

class DefaultConnectIQListener(
    private val garminConnector: DefaultGarminConnector
) : ConnectIQ.ConnectIQListener {
    override fun onInitializeError(errStatus: ConnectIQ.IQSdkErrorStatus) {
        Log.d(TAG, "initializeError: ${errStatus.name}")
    }

    override fun onSdkReady() {
        Log.d(TAG, "sdkReady")
        garminConnector.onSDKReady()
    }

    override fun onSdkShutDown() {
        Log.d(TAG, "sdkShutdown")
        garminConnector.onSDKShutDown()
    }

    companion object {
        private val TAG: String = DefaultConnectIQListener::class.java.simpleName
    }
}