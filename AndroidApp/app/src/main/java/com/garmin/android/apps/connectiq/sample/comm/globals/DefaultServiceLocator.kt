package com.garmin.android.apps.connectiq.sample.comm.globals

import android.content.Context
import android.content.ContextWrapper
import androidx.lifecycle.LifecycleCoroutineScope
import com.garmin.android.apps.connectiq.sample.comm.impl.ContactsRepositoryImpl
import com.garmin.android.apps.connectiq.sample.comm.impl.DefaultGarminConnector
import com.garmin.android.apps.connectiq.sample.comm.impl.DefaultOutgoingMessageDispatcher
import com.garmin.android.apps.connectiq.sample.comm.impl.DefaultPhoneCallService
import com.garmin.android.apps.connectiq.sample.comm.impl.GarminConnector
import com.garmin.android.apps.connectiq.sample.comm.impl.IncomingMessageDispatcher
import com.garmin.android.apps.connectiq.sample.comm.impl.PhoneCallService
import com.garmin.android.apps.connectiq.sample.comm.impl.RemoteMessageService

class DefaultServiceLocator(
    base: Context?,
    lifecycleScope: LifecycleCoroutineScope
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

        class CompoundRemoteMessageService : RemoteMessageService {
            override fun sendMessage(message: Map<String, Any>) {
                garminConnector.sendMessage(message)
            }
        }
        CompoundRemoteMessageService()
    }

    val outgoingMessageDispatcher: OutgoingMessageDispatcher by lazy {
        DefaultOutgoingMessageDispatcher(remoteMessageService, contactsRepository)
    }

    val garminConnector: GarminConnector by lazy {
        DefaultGarminConnector(
            this,
            lifecycleScope = lifecycleScope,
            dispatchIncomingMessage = { o ->
                incomingMessageDispatcher.handleMessage(o)
            }
        )
    }

    companion object {
        private val TAG: String = DefaultServiceLocator::class.java.simpleName
    }
}