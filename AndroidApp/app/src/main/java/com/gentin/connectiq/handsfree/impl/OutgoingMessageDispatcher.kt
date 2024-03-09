package com.gentin.connectiq.handsfree.impl

import android.telephony.TelephonyManager
import android.util.Log
import com.gentin.connectiq.handsfree.contacts.ContactData
import com.gentin.connectiq.handsfree.helpers.normalizePhoneNumber


interface ContactsService {
    fun contactsJsonObject()
}

interface OutgoingMessageDispatcher {
    fun sendPhones(contacts: List<ContactData>)
    fun sendPhoneState(phoneState: PhoneState, args: Map<String, Any> = mapOf())
}

class DefaultOutgoingMessageDispatcher(
    private val remoteMessageService: RemoteMessageService
) : OutgoingMessageDispatcher {
    override fun sendPhones(contacts: List<ContactData>) {
        val pojo = ArrayList<Any>()
        for (contact in contacts) {
            pojo.add(
                mapOf(
                    "number" to contact.number,
                    "name" to contact.name,
                    "id" to contact.id
                )
            )
        }

        val msg = mapOf(
            "cmd" to "setPhones",
            "args" to mapOf(
                "phones" to pojo
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