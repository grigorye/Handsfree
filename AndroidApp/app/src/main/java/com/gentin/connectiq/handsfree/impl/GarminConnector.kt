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
    }

    override fun sendMessage(message: Map<String, Any>) {
        pendingMessages?.apply {
            Log.d(TAG, "addedPending: $message")
            add(message)
        } ?: sendMessageAsync(message)
    }

    private var shuttingDownSDK = false

    private fun shutdownSDK() {
        Log.d(TAG, "shutdownSDK")
        shuttingDownSDK = true
        // It is a good idea to unregister everything and shut things down to
        // release resources and prevent unwanted callbacks.
        connectIQ.unregisterAllForEvents()
        connectIQ.shutdown(this)
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
        Log.d(TAG, "shuttingDownSDK: $shuttingDownSDK")
        if (!shuttingDownSDK) {
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

    private fun sendMessageAsync(message: Map<String, Any>) {
        lifecycleScope.launch(Dispatchers.Default) {
            try {
                sendMessageOrReschedule(message)
            } catch (e: ServiceUnavailableException) {
                Log.d(TAG, "sendMessageAsyncFailed: $e")
                breakIntoDebugger()
            }
        }
    }

    private fun sendMessageOrReschedule(message: Map<String, Any>) {
        try {
            connectIQ.knownDevices.forEach { device ->
                sendMessageSync(device, message)
            }
        } catch (e: ServiceUnavailableException) {
            Log.d(TAG, "sendMessageOrRescheduleFailed: $e")
            breakIntoDebugger()
            Log.d(TAG, "schedulingLaterRetry: $message")
            if (pendingMessages == null) {
                pendingMessages = ArrayList()
            }
            pendingMessages!!.add(message)
            throw e
        }
    }

    private fun processPendingMessages() {
        Log.d(TAG, "pendingMessages: $pendingMessages")
        while (pendingMessages!!.isNotEmpty()) {
            val message = pendingMessages!![0]
            sendMessageOrReschedule(message)
            pendingMessages!!.removeFirst()
        }
        pendingMessages = null
    }

    private var sentMessagesCounter = 0

    private fun sendMessageSync(device: IQDevice, messageValue: Map<String, Any>) {
        val message = mapOf("id" to sentMessagesCounter) + messageValue
        sentMessagesCounter += 1

        Log.d(
            TAG,
            "device.${device.deviceIdentifier}(${device.friendlyName}) <- msg${message}"
        )
        connectIQ.sendMessage(device, myApp, message) { _, _, status ->
            Log.d(
                TAG,
                "device.${device.deviceIdentifier}(${device.friendlyName}) -> ack(${status}, msg${message}"
            )
        }
    }

    companion object {
        private val TAG: String = DefaultGarminConnector::class.java.simpleName
    }
}

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