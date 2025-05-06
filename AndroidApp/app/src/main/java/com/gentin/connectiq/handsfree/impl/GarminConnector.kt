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
import com.garmin.android.connectiq.ConnectIQ.IQSdkErrorStatus
import com.garmin.android.connectiq.IQApp
import com.garmin.android.connectiq.IQDevice
import com.garmin.android.connectiq.exception.InvalidStateException
import com.garmin.android.connectiq.exception.ServiceUnavailableException
import com.gentin.connectiq.handsfree.globals.appLogName
import com.gentin.connectiq.handsfree.globals.simApp
import com.gentin.connectiq.handsfree.globals.storeID
import com.gentin.connectiq.handsfree.globals.watchApps
import com.gentin.connectiq.handsfree.helpers.breakIntoDebugger
import com.gentin.connectiq.handsfree.helpers.isRunningInEmulator
import com.gentin.connectiq.handsfree.services.startStats
import com.gentin.connectiq.handsfree.terms.cmdMsgField
import com.google.gson.Gson
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.Date

val pingBody = mapOf(cmdMsgField to "ping")

typealias AppConfigs = Map<String, AppConfig>
typealias MutableAppConfigs = MutableMap<String, AppConfig>

interface GarminConnector {
    fun launch()
    fun terminate()

    fun appVersion(device: IQDevice, app: IQApp): Int?
    fun sendMessage(message: OutgoingMessage)
    fun openWatchAppInStore(app: IQApp)
    fun openWatchAppOnDevice(device: IQDevice, app: IQApp, completion: (succeeded: Boolean) -> Unit)
    fun openWatchAppOnEveryDevice(
        app: IQApp,
        completion: (destination: OutgoingMessageDestination, succeeded: Boolean) -> Unit
    )

    fun trackFirstAppLaunch(device: IQDevice, app: IQApp)
    fun trackAppConfig(device: IQDevice, app: IQApp, config: AppConfig)
    fun appConfig(device: IQDevice, app: IQApp): AppConfig?

    val sentMessagesCounter: Int
    val acknowledgedMessagesCounter: Int

    val knownDeviceInfos: LiveData<List<DeviceInfo>>
    val appConfigsLiveData: LiveData<AppConfigs>
}

data class InstalledAppInfo(
    val appConfig: () -> AppConfig?,
    val appVersionInfo: WatchAppVersionInfo
)

data class WatchAppVersionInfo(
    val version: Int,
    val appName: String
)

data class DeviceInfo(
    val name: String,
    private val connectedImp: () -> Boolean,
    private var installedAppsInfoImp: () -> List<InstalledAppInfo>
) {
    val installedAppsInfo: List<InstalledAppInfo>
        get() = installedAppsInfoImp()
    val connected: Boolean
        get() = connectedImp()
}

class DefaultGarminConnector(
    base: Context?,
    private val lifecycleScope: LifecycleCoroutineScope,
    val dispatchIncomingMessage: (Any, IncomingMessageSource) -> Unit,
    val appDataMayBeInvalidated: (IQDevice, IQApp) -> Unit
) : ContextWrapper(base), GarminConnector {

    private lateinit var connectIQ: ConnectIQ

    private val context: Context = this

    override val knownDeviceInfos: LiveData<List<DeviceInfo>> by lazy {
        MediatorLiveData<List<DeviceInfo>>().apply {
            addSource(knownDevices) { knownDevices ->
                value = knownDevices.values.toList()
            }
        }
    }

    override fun launch() {
        Log.d(TAG, "launch")
        val dispatcher = if (isRunningInEmulator(context)) Dispatchers.Main else Dispatchers.Default

        lifecycleScope.launch(dispatcher) {
            if (Looper.myLooper() == null) {
                Looper.prepare()
            }
            startSDK()
        }
    }

    override fun terminate() {
        Log.d(TAG, "stop")
        if (sdkState != SdkState.Ready && sdkState != SdkState.Initializing) {
            Log.e(TAG, "skippingSdkShutdownDueToState: $sdkState")
        } else {
            shutdownSDK()
        }
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
                val destination = OutgoingMessageDestination(
                    device,
                    app,
                    accountBroadcastOnly = false
                )
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
                    IQOpenApplicationStatus.APP_IS_ALREADY_RUNNING -> completion(false)
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

    enum class SdkState {
        Down,
        Initializing,
        InitializationFailed,
        Ready,
        ShuttingDown
    }
    private var sdkState: SdkState = SdkState.Down
        set(value) {
            Log.d(TAG, "sdkState: $field -> $value")
            field = value
        }

    private fun shutdownSDK() {
        Log.d(TAG, "shutdownSDK")
        sdkState = SdkState.ShuttingDown
        connectIQ.shutdown(this)
        sdkState = SdkState.Down
    }

    private fun startSDK() {
        Log.d(TAG, "startSDK")
        val connectType = if (isRunningInEmulator(context)) {
            ConnectIQ.IQConnectType.TETHERED
        } else {
            ConnectIQ.IQConnectType.WIRELESS
        }

        connectIQ = ConnectIQ.getInstance(this, connectType)
        sdkState = SdkState.Initializing
        connectIQ.initialize(this, true, connectIQListener)
    }

    private fun startIncomingMessageProcessing(device: IQDevice) {
        Log.d(
            TAG,
            "startIncomingMessageProcessing: ${device.deviceIdentifier}(${device.friendlyName})"
        )
        for (app in watchApps(context)) {
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
    private val installedApps = mutableMapOf<Long, MutableList<IQApp>>()

    private val appConfigs: MutableAppConfigs = mutableMapOf()
    override val appConfigsLiveData: MutableLiveData<AppConfigs> = MutableLiveData(mapOf())

    private fun trackNotInstalledApp(device: IQDevice, app: IQApp) {
        val key = device.deviceIdentifier
        run {
            val apps = notInstalledApps[key] ?: mutableListOf()
            apps.add(app)
            notInstalledApps[key] = apps
        }
        run {
            val apps = installedApps[key] ?: mutableListOf()
            apps.removeIf { x -> x.applicationId == app.applicationId }
            installedApps[key] = apps
        }
    }

    private fun trackInstalledApp(device: IQDevice, app: IQApp) {
        val key = device.deviceIdentifier
        run {
            val apps = notInstalledApps[key] ?: mutableListOf()
            apps.removeIf { x -> x.applicationId == app.applicationId }
            notInstalledApps[key] = apps
        }
        run {
            val apps = installedApps[key] ?: mutableListOf()
            if (apps.find { x -> x.applicationId == app.applicationId } == null) {
                apps.add(app)
            }
            installedApps[key] = apps
        }
    }

    private fun isNotInstalledApp(device: IQDevice, app: IQApp): Boolean {
        return notInstalledApps[device.deviceIdentifier]?.contains(app) ?: false
    }

    override fun trackAppConfig(device: IQDevice, app: IQApp, config: AppConfig) {
        val key = "${device.deviceIdentifier}, ${app.applicationId}"
        run {
            appConfigs[key] = config
            appConfigsLiveData.postValue(appConfigs)
        }
    }

    override fun appConfig(device: IQDevice, app: IQApp): AppConfig? {
        val key = "${device.deviceIdentifier}, ${app.applicationId}"
        return appConfigs[key]
    }

    override fun appVersion(device: IQDevice, app: IQApp): Int? {
        val version = installedApps[device.deviceIdentifier]
            ?.find { x -> x.applicationId == app.applicationId }
            ?.version()
        if (version == 0) {
            return null
        }
        return version
    }

    private fun clearNotInstalledApps() {
        notInstalledApps.clear()
        installedApps.clear()
    }

    private fun clearAppConfigs() {
        appConfigs.clear()
        appConfigsLiveData.postValue(appConfigs)
    }

    private fun startOutgoingMessageGeneration(device: IQDevice) {
        Log.d(
            TAG,
            "startOutgoingMessageGeneration: ${device.deviceIdentifier}(${device.friendlyName})"
        )
        for (app in watchApps(context)) {
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
                                    knownDevicesAcc[device.deviceIdentifier] = deviceInfo
                                    knownDevices.postValue(knownDevicesAcc)
                                }
                                trackInstalledApp(device, p0)
                                appDataMayBeInvalidated(device, app)
                            }

                            p0.status == IQApp.IQAppStatus.UNKNOWN && p0.applicationId == simApp.applicationId -> {
                                Log.d(
                                    TAG,
                                    "appStatus(${device.friendlyName}, ${appLogName(app)}): INSTALLED (${p0.version()})"
                                )
                                trackInstalledApp(device, p0)
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
        clearAppConfigs()
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

    fun onInitializeError(errStatus: IQSdkErrorStatus) {
        Log.e(TAG, "onInitializeError: $errStatus")
        sdkState = SdkState.InitializationFailed
    }

    fun onSDKReady() {
        sdkState = SdkState.Ready
        sdkStartCount += 1
        sentMessagesCounter = 0
        acknowledgedMessagesCounter = 0
        Log.d(TAG, "sdkReady: $sdkStartCount")
        lifecycleScope.launch(Dispatchers.Default) {
            try {
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
        if (sdkState == SdkState.ShuttingDown) {
            stopMessageProcessing()
            clearKnownDevices()
            Log.d(TAG, "shuttingDownSDK")
        } else {
            startStats.sdkExceptionDates.add(Date())
            Log.d(TAG, "relaunchingSDKOnException")
            sdkState = SdkState.ShuttingDown
            connectIQ.shutdown(this) // Workaround no actual shutdown on exceptions
            sdkState = SdkState.Down

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

    private fun clearKnownDevices() {
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
                        connectedImp = { status == IQDevice.IQDeviceStatus.CONNECTED },
                        installedAppsInfoImp = {
                            val installedApps = installedApps[device.deviceIdentifier]
                            installedApps?.map { app ->
                                InstalledAppInfo(
                                    appConfig = { appConfig(device, app) },
                                    appVersionInfo = WatchAppVersionInfo(app.version(), app.displayName)
                                )
                            } ?: listOf()
                        }
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
        return watchApps(context).filter {
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
        val message = if (tagMessages) {
            mapOf("id" to id) + messageValue.body
        } else {
            messageValue.body
        }

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
                for (app in targetApps) {
                    if (messageShouldBeSkipped(messageValue, device, app, destination))
                        continue
                    val appLogName = appLogName(app)
                    if (messageValue.body == pingBody) {
                        Log.d(
                            TAG,
                            "device.${device.deviceIdentifier}(${device.friendlyName})($appLogName) <- msg-ping.$id"
                        )
                        connectIQ.sendMessage(device, app, "ping") { _, _, status ->
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

    private fun skipReasonForDestination(
        appConfig: AppConfig?,
        device: IQDevice,
        app: IQApp,
        destination: OutgoingMessageDestination
    ): String? {
        when (destination.matchV1) {
            true -> if (appVersion(device, app) != 1) return "appVersionMatch(!1)"
            false -> if (appVersion(device, app) == 1) return "appVersionMatch(1)"
            null -> Unit
        }
        if (appConfig == null) {
            Log.d(TAG, "favoringAllDestinationsAsAppConfigIsNull")
            return null
        }
        when (destination.accountBroadcastOnly && (destination.matchV1 != true)) {
            true -> if (!isBroadcastEnabled(appConfig)) return "broadcastEnabled"
            false -> Unit
        }
        when (destination.matchLM) {
            true -> if (!isLowMemory(appConfig)) return "lowMemoryMatch(false)"
            false -> if (isLowMemory(appConfig)) return "lowMemoryMatch(true)"
            null -> Unit
        }
        if (destination.skipOnAppConfig(appConfig)) {
            return "skipOnAppConfig"
        }
        return null
    }

    private fun messageShouldBeSkipped(
        message: OutgoingMessage,
        device: IQDevice,
        app: IQApp,
        destination: OutgoingMessageDestination
    ): Boolean {
        val appConfig = appConfig(device, app)
        when (val reason = skipReasonForDestination(appConfig, device, app, destination)) {
            null -> {
                return false
            }
            else -> {
                val appLogName = appLogName(app)
                val messageLogValue = gson.toJson(
                    message
                )
                Log.d(
                    TAG,
                    "device.${device.deviceIdentifier}(${device.friendlyName})($appLogName) <- skip.$reason(${messageLogValue})"
                )
                return true
            }
        }
    }

    companion object {
        private val TAG: String = DefaultGarminConnector::class.java.simpleName
    }
}

class DefaultConnectIQListener(
    private val garminConnector: DefaultGarminConnector
) : ConnectIQ.ConnectIQListener {
    override fun onInitializeError(errStatus: IQSdkErrorStatus) {
        Log.e(TAG, "sdkInitializationFailure: ${errStatus.name}")
        garminConnector.onInitializeError(errStatus)
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