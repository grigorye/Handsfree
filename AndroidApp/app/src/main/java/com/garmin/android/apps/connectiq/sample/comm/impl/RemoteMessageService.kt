package com.garmin.android.apps.connectiq.sample.comm.impl

import android.util.Log
import androidx.lifecycle.LifecycleCoroutineScope
import com.garmin.android.apps.connectiq.sample.comm.globals.myApp
import com.garmin.android.connectiq.ConnectIQ
import com.garmin.android.connectiq.IQDevice
import com.garmin.android.connectiq.exception.InvalidStateException
import com.garmin.android.connectiq.exception.ServiceUnavailableException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

interface RemoteMessageService {
    fun sendMessage(message: Map<String, Any>)
}

private var sentMessagesCounter = 0

class DefaultRemoteMessageService(
    private val connectIQ: ConnectIQ,
    private val device: IQDevice,
    private val lifecycleScope: LifecycleCoroutineScope
) : RemoteMessageService {

    override fun sendMessage(message: Map<String, Any>) {
        lifecycleScope.launch(Dispatchers.Default) {
            sendMessageSync(message)
        }
    }

    private fun sendMessageSync(messageValue: Map<String, Any>) {
        val message = mapOf("id" to sentMessagesCounter) + messageValue
        sentMessagesCounter += 1

        Log.d(TAG, "device.${device.deviceIdentifier}(${device.friendlyName}) <- msg${message}")
        try {
            connectIQ.sendMessage(
                device,
                myApp,
                message
            ) { device, _, status ->
                Log.d(
                    TAG,
                    "device.${device.deviceIdentifier}(${device.friendlyName}) -> ack(${status}, msg${message}"
                )
            }
        } catch (e: InvalidStateException) {
            Log.e(TAG, "ConnectIQ is not in a valid state. ${e}")
        } catch (e: ServiceUnavailableException) {
            Log.e(TAG, "ConnectIQ service is unavailable. ${e}")
        }
    }

    companion object {
        private val TAG = DefaultRemoteMessageService::class.java.simpleName
    }
}