package com.gentin.connectiq.handsfree.impl

import android.telephony.TelephonyManager
import android.util.Log
import com.gentin.connectiq.handsfree.contacts.ContactsRepository
import com.gentin.connectiq.handsfree.helpers.normalizePhoneNumber


interface ContactsService {
    fun contactsJsonObject()
}

interface OutgoingMessageDispatcher {
    fun sendPhones()
    fun sendPhoneState(phoneState: PhoneState, args: Map<String, Any> = mapOf())
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

    override fun sendPhoneState(phoneState: PhoneState, args: Map<String, Any>) {
        when (phoneState.stateExtra) {
            TelephonyManager.EXTRA_STATE_IDLE -> {
                val msg = mapOf(
                    "cmd" to "phoneStateChanged",
                    "args" to args + mapOf(
                        "state" to "noCallInProgress"
                    )
                )
                send(msg)
            }

            TelephonyManager.EXTRA_STATE_OFFHOOK -> {
                val msg = mapOf(
                    "cmd" to "phoneStateChanged",
                    "args" to args + mapOf(
                        "state" to "callInProgress",
                        "number" to dispatchedPhoneNumber(phoneState.incomingNumber)
                    )
                )
                send(msg)
            }

            TelephonyManager.EXTRA_STATE_RINGING -> {
                val msg = mapOf(
                    "cmd" to "phoneStateChanged",
                    "args" to args + mapOf(
                        "state" to "ringing",
                        "number" to dispatchedPhoneNumber(phoneState.incomingNumber)
                    )
                )
                send(msg)
            }

            else -> {
                Log.e(TAG, "unknownPhoneStateExtra: ${phoneState.stateExtra}")
            }
        }
    }

    fun send(msg: Map<String, Any>) {
        remoteMessageService.sendMessage(msg)
    }

    companion object {
        private val TAG: String = DefaultOutgoingMessageDispatcher::class.java.simpleName
    }
}

private fun dispatchedPhoneNumber(incomingNumber: String?): String {
    return incomingNumber?.also { normalizePhoneNumber(it) } ?: ""
}