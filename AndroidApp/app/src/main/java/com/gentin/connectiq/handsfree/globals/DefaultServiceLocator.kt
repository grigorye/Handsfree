package com.gentin.connectiq.handsfree.globals

import android.content.Context
import android.content.ContextWrapper
import androidx.lifecycle.LifecycleCoroutineScope
import com.gentin.connectiq.handsfree.impl.ContactsRepositoryImpl
import com.gentin.connectiq.handsfree.impl.DefaultGarminConnector
import com.gentin.connectiq.handsfree.impl.DefaultOutgoingMessageDispatcher
import com.gentin.connectiq.handsfree.impl.DefaultPhoneCallService
import com.gentin.connectiq.handsfree.impl.GarminConnector
import com.gentin.connectiq.handsfree.impl.IncomingMessageDispatcher
import com.gentin.connectiq.handsfree.impl.OutgoingMessageDispatcher
import com.gentin.connectiq.handsfree.impl.PhoneCallService
import com.gentin.connectiq.handsfree.impl.RemoteMessageService
import com.gentin.connectiq.handsfree.impl.contactsGroupId
import com.gentin.connectiq.handsfree.impl.forEachContactInGroup
import com.gentin.connectiq.handsfree.impl.forEachContactWithPhoneNumberInFavorites
import com.gentin.connectiq.handsfree.impl.lastTrackedPhoneState

class DefaultServiceLocator(
    base: Context?,
    lifecycleScope: LifecycleCoroutineScope
) : ContextWrapper(base) {

    private val phoneCallService: PhoneCallService by lazy {
        DefaultPhoneCallService(this)
    }

    private val targetContactsGroupName: String? = null // e.g. "Handsfree", null for Favorites

    private val contactsRepository by lazy {
        ContactsRepositoryImpl(this) {
            if (targetContactsGroupName != null) {
                val groupId = contactsGroupId(this, targetContactsGroupName)
                if (groupId != null) {
                    forEachContactInGroup(this, groupId, it)
                }
            } else {
                forEachContactWithPhoneNumberInFavorites(this, it)
            }
        }
    }

    private val incomingMessageDispatcher: IncomingMessageDispatcher by lazy {
        IncomingMessageDispatcher(
            phoneCallService,
            syncImp = {
                lastTrackedPhoneState?.let {
                    outgoingMessageDispatcher.sendPhoneState(it)
                }
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