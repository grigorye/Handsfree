package com.garmin.android.apps.connectiq.sample.comm.impl

import android.content.Context
import android.content.ContextWrapper
import android.util.Log
import com.garmin.android.apps.connectiq.sample.comm.globals.myApp
import com.garmin.android.connectiq.ConnectIQ
import com.garmin.android.connectiq.IQDevice
import com.garmin.android.connectiq.exception.ServiceUnavailableException


interface GarminConnector {
    fun onStart()
    fun onStop()
    fun startIncomingMessageProcessing(device: IQDevice)

    fun knownDevices(): List<IQDevice>

    val connectIQ: ConnectIQ
}

class DefaultGarminConnector(
    base: Context?,
    val onSDKReady: () -> Unit,
    val onSDKShutdown: () -> Unit,
    val onServiceUnavailable: (ServiceUnavailableException) -> Unit,
    val dispatchIncomingMessage: (Any) -> Unit,
    val accountDeviceConnection: (IQDevice) -> Unit,
) : ContextWrapper(base), GarminConnector {

    override lateinit var connectIQ: ConnectIQ

    override fun onStop() {
        Log.d(TAG, "onStop")
        // It is a good idea to unregister everything and shut things down to
        // release resources and prevent unwanted callbacks.
        connectIQ.unregisterAllForEvents()
        connectIQ.shutdown(this)
    }

    override fun onStart() {
        Log.d(TAG, "onStart")
        val connectType = if (isRunningInEmulator()) {
            connectIQ = ConnectIQ.getInstance(this, ConnectIQ.IQConnectType.TETHERED)
        } else {
            connectIQ = ConnectIQ.getInstance()
        }

        connectIQ.initialize(this, true, connectIQListener)
    }

    override fun startIncomingMessageProcessing(device: IQDevice) {
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

    override fun knownDevices(): List<IQDevice> {
        return connectIQ.knownDevices ?: listOf()
    }

    private fun accountDeviceStatus(device: IQDevice, status: IQDevice.IQDeviceStatus) {
        Log.d(TAG, "device.${device.deviceIdentifier}(${device.friendlyName}) <- status($status)")
        when (status) {
            IQDevice.IQDeviceStatus.CONNECTED -> {
                accountDeviceConnection(device)
            }

            else -> {}
        }
    }

    private fun exerciseConnection() {
        connectIQ.knownDevices.forEach { device ->
            val status = connectIQ.getDeviceStatus(device)
            Log.d(
                TAG,
                "status.${device.deviceIdentifier}(${device.friendlyName}): $status"
            )
        }
    }

    private val connectIQListener: ConnectIQ.ConnectIQListener =
        object : ConnectIQ.ConnectIQListener {
            override fun onInitializeError(errStatus: ConnectIQ.IQSdkErrorStatus) {
                Log.d(TAG, "initializeError: ${errStatus.name}")
            }

            override fun onSdkReady() {
                Log.d(TAG, "sdkReady")
                try {
                    exerciseConnection()
                } catch (e: ServiceUnavailableException) {
                    Log.d(TAG, "e: $e")
                    breakIntoDebugger()
                    onServiceUnavailable(e)
                    return
                }
                onSDKReady()
            }

            override fun onSdkShutDown() {
                Log.d(TAG, "sdkShutdown")
                onSDKShutdown()
            }
        }

    companion object {
        private val TAG: String = DefaultGarminConnector::class.java.simpleName
    }
}