package com.gentin.connectiq.handsfree.impl

import android.telephony.TelephonyManager
import com.gentin.connectiq.handsfree.contacts.ContactsRepository
import com.gentin.connectiq.handsfree.helpers.normalizePhoneNumber


interface ContactsService {
    fun contactsJsonObject()
}

interface OutgoingMessageDispatcher {
    fun sendPhones()
    fun sendPhoneState(phoneState: PhoneState)
}

class DefaultOutgoingMessageDispatcher(
    private val remoteMessageService: RemoteMessageService,
    private val contactsRepository: ContactsRepository
) : OutgoingMessageDispatcher {
    override fun sendPhones() {
        val contactsJsonObject = contactsRepository.contactsJsonObject()
        val msg = mapOf(
            "cmd" to "setPhones",
            "args" to mapOf(
                "phones" to contactsJsonObject
            )
        )
        send(msg)
    }

    override fun sendPhoneState(phoneState: PhoneState) {
        when (phoneState.stateExtra) {
            TelephonyManager.EXTRA_STATE_IDLE -> {
                val msg = mapOf(
                    "cmd" to "noCallInProgress"
                )
                send(msg)
            }

            TelephonyManager.EXTRA_STATE_OFFHOOK -> {
                val msg = mapOf(
                    "cmd" to "callInProgress",
                    "args" to mapOf(
                        "number" to dispatchedPhoneNumber(phoneState.incomingNumber)
                    )
                )
                send(msg)
            }

            TelephonyManager.EXTRA_STATE_RINGING -> {
                val msg = mapOf(
                    "cmd" to "ringing",
                    "args" to mapOf(
                        "number" to dispatchedPhoneNumber(phoneState.incomingNumber)
                    )
                )
                send(msg)
            }

            else -> {}
        }
    }

    fun send(msg: Map<String, Any>) {
        remoteMessageService.sendMessage(msg)
    }
}

private fun dispatchedPhoneNumber(incomingNumber: String?): String {
    return incomingNumber?.also { normalizePhoneNumber(it) } ?: ""
}