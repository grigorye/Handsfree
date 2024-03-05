package com.gentin.connectiq.handsfree.impl

import android.content.Context
import android.content.ContextWrapper
import android.os.Looper
import android.util.Log
import androidx.lifecycle.LifecycleCoroutineScope
import com.garmin.android.connectiq.ConnectIQ
import com.garmin.android.connectiq.IQDevice
import com.garmin.android.connectiq.exception.ServiceUnavailableException
import com.gentin.connectiq.handsfree.globals.myApp
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch


interface GarminConnector {
    fun launch()
    fun terminate()

    fun sendMessage(message: Map<String, Any>)
}

class DefaultGarminConnector(
    base: Context?,
    private val lifecycleScope: LifecycleCoroutineScope,
    val dispatchIncomingMessage: (Any) -> Unit
) : ContextWrapper(base), GarminConnector {

    private lateinit var connectIQ: ConnectIQ

    override fun launch() {
        Log.d(TAG, "launch")
        lifecycleScope.launch(Dispatchers.Default) {
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
        connectIQ.registerForAppEvents(device, myApp) { _, _, message, _ ->
            for (o in message) {
                dispatchIncomingMessage(o)
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
        Log.d(TAG, "sdkReady")
        lifecycleScope.launch(Dispatchers.Default) {
            try {
                startObservingDeviceEvents()
                startIncomingMessageProcessing()
                processPendingMessages()
                pendingMessages = null
            } catch (e: ServiceUnavailableException) {
                Log.d(TAG, "serviceUnavailableOnSDKReady: $e")
                breakIntoDebugger()
            }
        }
    }

    fun onSDKShutDown() {
        if (shuttingDownSDK) {
            Log.d(TAG, "shuttingDownSDK: $shuttingDownSDK")
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

    private fun startObservingDeviceEvents() {
        connectIQ.knownDevices.forEach { device ->
            device.status = connectIQ.getDeviceStatus(device)
            connectIQ.registerForDeviceEvents(device) { _, status ->
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

    private var sentMessagesCounter = 0
    private var acknowledgedMessagesCounter = 0

    private fun sendMessageSync(messageValue: Map<String, Any>) {
        sentMessagesCounter += 1
        val message = mapOf("id" to sentMessagesCounter) + messageValue

        try {
            connectIQ.connectedDevices.forEach { device ->
                Log.d(
                    TAG,
                    "device.${device.deviceIdentifier}(${device.friendlyName}) <- msg${message}"
                )
                connectIQ.sendMessage(device, myApp, message) { _, _, status ->
                    acknowledgedMessagesCounter += 1
                    Log.d(
                        TAG,
                        "device.${device.deviceIdentifier}(${device.friendlyName}) -> ack(${status}, msg.${acknowledgedMessagesCounter})"
                    )
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