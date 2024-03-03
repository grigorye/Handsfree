package com.garmin.android.apps.connectiq.sample.comm.globals

import android.content.Context
import android.content.ContextWrapper
import android.util.Log
import androidx.lifecycle.LifecycleCoroutineScope
import com.garmin.android.apps.connectiq.sample.comm.impl.ContactsRepositoryImpl
import com.garmin.android.apps.connectiq.sample.comm.impl.DefaultGarminConnector
import com.garmin.android.apps.connectiq.sample.comm.impl.DefaultOutgoingMessageDispatcher
import com.garmin.android.apps.connectiq.sample.comm.impl.DefaultPhoneCallService
import com.garmin.android.apps.connectiq.sample.comm.impl.DefaultRemoteMessageService
import com.garmin.android.apps.connectiq.sample.comm.impl.GarminConnector
import com.garmin.android.apps.connectiq.sample.comm.impl.IncomingMessageDispatcher
import com.garmin.android.apps.connectiq.sample.comm.impl.PhoneCallService
import com.garmin.android.apps.connectiq.sample.comm.impl.RemoteMessageService
import com.garmin.android.apps.connectiq.sample.comm.impl.breakIntoDebugger
import com.garmin.android.connectiq.exception.ServiceUnavailableException

class DefaultServiceLocator(
    base: Context?,
    lifecycleScope: LifecycleCoroutineScope,
    onSDKReadyImp: () -> Unit,
    onSDKShutdownImp: () -> Unit,
    val onServiceUnavailableImp: (ServiceUnavailableException) -> Unit
) : ContextWrapper(base) {

    private val phoneCallService: PhoneCallService by lazy {
        DefaultPhoneCallService(this)
    }

    private val contactsRepository by lazy {
        ContactsRepositoryImpl(this)
    }

    private val incomingMessageDispatcher: IncomingMessageDispatcher by lazy {
        IncomingMessageDispatcher(
            phoneCallService,
            syncImp = {
                outgoingMessageDispatcher.sendPhones()
            }
        )
    }

    private val remoteMessageService: RemoteMessageService by lazy {
        val connectIQ = garminConnector.connectIQ

        class CompoundRemoteMessageService : RemoteMessageService {
            override fun sendMessage(message: Map<String, Any>) {
                for (device in garminConnector.knownDevices()) {
                    DefaultRemoteMessageService(connectIQ, device, lifecycleScope).sendMessage(
                        message
                    )
                }
            }
        }
        CompoundRemoteMessageService()
    }

    private fun startIncomingMessageProcessing() {
        Log.d(TAG, "garminConnector.connectIQ: ${garminConnector.connectIQ}")
        try {
            Log.d(
                TAG,
                "knownDevices: ${
                    garminConnector.knownDevices()
                        .map { x -> "${x.deviceIdentifier}(${x.friendlyName})" }
                }"
            )
            for (device in garminConnector.knownDevices()) {
                device.status = garminConnector.connectIQ.getDeviceStatus(device)
                garminConnector.startIncomingMessageProcessing(device)
            }
        } catch (e: ServiceUnavailableException) {
            Log.e(TAG, "e: $e")
            breakIntoDebugger()
            onServiceUnavailableImp(e)
        }
    }

    val outgoingMessageDispatcher by lazy {
        DefaultOutgoingMessageDispatcher(remoteMessageService, contactsRepository)
    }

    val garminConnector: GarminConnector by lazy {
        DefaultGarminConnector(
            this,
            onSDKReady = {
                onSDKReadyImp()
                startIncomingMessageProcessing()
            },
            onSDKShutdown = {
                onSDKShutdownImp()
            },
            onServiceUnavailable = {
                onServiceUnavailableImp(it)
            },
            dispatchIncomingMessage = { o ->
                incomingMessageDispatcher.handleMessage(o)
            },
            accountDeviceConnection = { device ->
                Log.d(TAG, "deviceConnected: ${device.deviceIdentifier}(${device.friendlyName})")
            }
        )
    }

    companion object {
        private val TAG: String = DefaultServiceLocator::class.java.simpleName
    }
}