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
import com.garmin.android.connectiq.IQDevice
import com.garmin.android.connectiq.exception.ServiceUnavailableException
import com.gentin.connectiq.handsfree.globals.appLogName
import com.gentin.connectiq.handsfree.globals.prodApp
import com.gentin.connectiq.handsfree.globals.watchApps
import com.gentin.connectiq.handsfree.helpers.breakIntoDebugger
import com.gentin.connectiq.handsfree.helpers.isRunningInEmulator
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch


interface GarminConnector {
    fun launch()
    fun terminate()

    fun sendMessage(message: Map<String, Any>)
    fun openWatchAppInStore()

    val sentMessagesCounter: Int
    val acknowledgedMessagesCounter: Int

    val knownDeviceInfos: LiveData<List<DeviceInfo>>
}

data class DeviceInfo(
    val name: String,
    val connected: Boolean
)

class DefaultGarminConnector(
    base: Context?,
    private val lifecycleScope: LifecycleCoroutineScope,
    val dispatchIncomingMessage: (Any) -> Unit
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

    override fun sendMessage(message: Map<String, Any>) {
        pendingMessages?.apply {
            Log.d(TAG, "addedPending: $message")
            add(message)
        } ?: sendMessageOrRescheduleAsync(message)
    }

    override fun openWatchAppInStore() {
        try {
            connectIQ.openStore(prodApp.applicationId)
        } catch (e: RuntimeException) {
            Log.e(TAG, "openStoreFailed: $e")
        }
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
                    dispatchIncomingMessage(o)
                }
            }
        }
    }

    private fun startIncomingMessageProcessing() {
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

    private val connectIQListener = DefaultConnectIQListener(this)

    fun onSDKReady() {
        sdkStartCount += 1
        sentMessagesCounter = 0
        acknowledgedMessagesCounter = 0
        Log.d(TAG, "sdkReady: $sdkStartCount")
        lifecycleScope.launch(Dispatchers.Default) {
            try {
                stopObservingDeviceEvents()
                startObservingDeviceEvents()
                startIncomingMessageProcessing()
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

    private var knownDevices = MutableLiveData(mapOf<Long, DeviceInfo>())
    private var knownDevicesAcc = mutableMapOf<Long, DeviceInfo>()

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
                    DeviceInfo(device.friendlyName, status == IQDevice.IQDeviceStatus.CONNECTED)
                Log.d(TAG, "postingNewKnownDevices: $knownDevicesAcc")
                knownDevices.postValue(knownDevicesAcc)
                Log.d(
                    TAG,
                    "device.${device.deviceIdentifier}(${device.friendlyName}) <- status($status)"
                )
            }
        }
    }

    private var pendingMessages: ArrayList<Map<String, Any>>? = ArrayList()

    private fun sendMessageOrRescheduleAsync(message: Map<String, Any>) {
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
            pendingMessages!!.removeFirst()
        }
        pendingMessages = null
    }

    private var sdkStartCount = 0
    override var sentMessagesCounter = 0
        private set
    override var acknowledgedMessagesCounter = 0
        private set

    private fun sendMessageSync(messageValue: Map<String, Any>) {
        sentMessagesCounter += 1
        val sdkStartCount = this.sdkStartCount
        val id = "$sdkStartCount.$sentMessagesCounter"
        val message = mapOf("id" to id) + messageValue

        try {
            connectIQ.connectedDevices.forEach { device ->
                watchApps.forEach { app ->
                    val appLogName = appLogName(app)
                    Log.d(
                        TAG,
                        "device.${device.deviceIdentifier}(${device.friendlyName})($appLogName) <- msg.$id$messageValue"
                    )
                    connectIQ.sendMessage(device, app, message) { _, _, status ->
                        acknowledgedMessagesCounter += 1
                        val receivedId = "$sdkStartCount.$acknowledgedMessagesCounter"
                        Log.d(
                            TAG,
                            "device.${device.deviceIdentifier}(${device.friendlyName})($appLogName) -> ack(${status}, msg.$receivedId)"
                        )
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