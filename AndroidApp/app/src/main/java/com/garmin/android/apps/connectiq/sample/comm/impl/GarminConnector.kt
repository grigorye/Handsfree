package com.garmin.android.apps.connectiq.sample.comm.impl

import android.content.Context
import android.content.ContextWrapper
import android.util.Log
import com.garmin.android.apps.connectiq.sample.comm.R
import com.garmin.android.apps.connectiq.sample.comm.globals.myApp
import com.garmin.android.apps.connectiq.sample.comm.services.globalServiceLocator
import com.garmin.android.connectiq.ConnectIQ
import com.garmin.android.connectiq.IQDevice

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
    val dispatchIncomingMessage: (Any) -> Unit
) : ContextWrapper(base), GarminConnector {

    override lateinit var connectIQ: ConnectIQ

    override fun onStop() {
        // It is a good idea to unregister everything and shut things down to
        // release resources and prevent unwanted callbacks.
        connectIQ.unregisterAllForEvents()
        connectIQ.shutdown(this)
    }

    override fun onStart() {
        val connectType = if (isRunningInEmulator()) {
            ConnectIQ.IQConnectType.TETHERED
        } else {
            ConnectIQ.IQConnectType.WIRELESS
        }

        connectIQ = ConnectIQ.getInstance(this, connectType)
        connectIQ.initialize(this, true, connectIQListener)
    }

    override fun startIncomingMessageProcessing(device: IQDevice) {
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
        Log.i(TAG, "Status changed for device ${device}: ${status}")
    }

    private val connectIQListener: ConnectIQ.ConnectIQListener =
        object : ConnectIQ.ConnectIQListener {
            override fun onInitializeError(errStatus: ConnectIQ.IQSdkErrorStatus) {
                Log.d(
                    TAG,
                    getString(R.string.initialization_error) + ": " + errStatus.name
                )
            }

            override fun onSdkReady() {
                Log.d(TAG, "sdkReady")
                onSDKReady()
                knownDevices().forEach {
                    connectIQ.registerForDeviceEvents(it) { device, status ->
                        Log.d(TAG, "device(${device.friendlyName}) <- status($status)")
                        when (status) {
                            IQDevice.IQDeviceStatus.CONNECTED -> {
                                globalServiceLocator!!.outgoingMessageDispatcher.sendPhones()
                            }

                            else -> {}
                        }
                    }
                }
            }

            override fun onSdkShutDown() {
                Log.d(TAG, "sdkShutdown")
            }
        }

    companion object {
        private val TAG: String = DefaultGarminConnector::class.java.simpleName
    }
}