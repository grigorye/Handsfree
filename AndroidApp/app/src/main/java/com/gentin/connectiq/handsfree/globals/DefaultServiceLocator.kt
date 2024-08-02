package com.gentin.connectiq.handsfree.globals

import android.content.Context
import android.content.ContextWrapper
import android.util.Log
import androidx.lifecycle.LifecycleCoroutineScope
import androidx.lifecycle.LiveData
import androidx.lifecycle.MediatorLiveData
import androidx.lifecycle.MutableLiveData
import com.gentin.connectiq.handsfree.contacts.ContactData
import com.gentin.connectiq.handsfree.contacts.ContactsRepository
import com.gentin.connectiq.handsfree.contacts.ContactsRepositoryImpl
import com.gentin.connectiq.handsfree.contacts.contactsGroupId
import com.gentin.connectiq.handsfree.contacts.forEachContactInGroup
import com.gentin.connectiq.handsfree.contacts.forEachContactWithPhoneNumberInFavorites
import com.gentin.connectiq.handsfree.impl.DefaultGarminConnector
import com.gentin.connectiq.handsfree.impl.DefaultOutgoingMessageDispatcher
import com.gentin.connectiq.handsfree.impl.DefaultPhoneCallService
import com.gentin.connectiq.handsfree.impl.DeviceInfo
import com.gentin.connectiq.handsfree.impl.GarminConnector
import com.gentin.connectiq.handsfree.impl.IncomingMessageDispatcher
import com.gentin.connectiq.handsfree.impl.OutgoingMessage
import com.gentin.connectiq.handsfree.impl.OutgoingMessageDestination
import com.gentin.connectiq.handsfree.impl.OutgoingMessageDispatcher
import com.gentin.connectiq.handsfree.impl.PhoneCallService
import com.gentin.connectiq.handsfree.impl.RemoteMessageService
import com.gentin.connectiq.handsfree.services.lastTrackedPhoneState

class DefaultServiceLocator(
    base: Context?,
    lifecycleScope: LifecycleCoroutineScope
) : ContextWrapper(base) {

    private val phoneCallService: PhoneCallService by lazy {
        DefaultPhoneCallService(this)
    }

    private val targetContactsGroupName: String? = null // e.g. "Handsfree", null for Favorites

    val contactsRepository: ContactsRepository by lazy {
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
                outgoingMessageDispatcher.sendSyncYou(availableContacts(), lastTrackedPhoneState)
            },
            syncPhonesImp = { source ->
                val destination = OutgoingMessageDestination(source.device, source.app)
                outgoingMessageDispatcher.sendPhones(destination, availableContacts())
            },
            openAppImp = { source ->
                garminConnector.openWatchAppOnDevice(source.device, source.app)
            }
        )
    }

    private fun availableContacts(): List<ContactData> {
        return try {
            contactsRepository.contacts()
        } catch (e: java.lang.RuntimeException) {
            Log.e(TAG, "contactsRetrievalFailed: $e")
            listOf()
        }
    }

    private val remoteMessageService: RemoteMessageService by lazy {

        class CompoundRemoteMessageService : RemoteMessageService {
            override fun sendMessage(message: OutgoingMessage) {
                garminConnector.sendMessage(message)
            }
        }
        CompoundRemoteMessageService()
    }

    val outgoingMessageDispatcher: OutgoingMessageDispatcher by lazy {
        DefaultOutgoingMessageDispatcher(this, remoteMessageService)
    }

    val garminConnector: GarminConnector by lazy {
        DefaultGarminConnector(
            this,
            lifecycleScope = lifecycleScope,
            dispatchIncomingMessage = { o, source ->
                incomingMessageDispatcher.handleMessage(o, source)
            }
        ).apply {
            activeGarminConnector.value = this
        }
    }

    companion object {
        private val TAG: String = DefaultServiceLocator::class.java.simpleName
        private val activeGarminConnector = MutableLiveData<GarminConnector>()
        val knownDeviceInfos: LiveData<List<DeviceInfo>> =
            MediatorLiveData<List<DeviceInfo>>().apply {
                addSource(activeGarminConnector) { garminConnector ->
                    addSource(garminConnector.knownDeviceInfos) {
                        value = it
                    }
                }
            }
    }
}

