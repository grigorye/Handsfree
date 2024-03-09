package com.gentin.connectiq.handsfree.impl

import android.telephony.TelephonyManager
import android.util.Log
import com.gentin.connectiq.handsfree.contacts.ContactData
import com.gentin.connectiq.handsfree.helpers.normalizePhoneNumber


interface OutgoingMessageDispatcher {
    fun sendSyncYou(contacts: List<ContactData>, phoneState: PhoneState?)
    fun sendPhoneState(phoneState: PhoneState)
}

class DefaultOutgoingMessageDispatcher(
    private val remoteMessageService: RemoteMessageService
) : OutgoingMessageDispatcher {
    override fun sendSyncYou(contacts: List<ContactData>, phoneState: PhoneState?) {
        val msg = mapOf(
            "cmd" to "syncYou",
            "args" to mapOf(
                "setPhones" to phonesArgs(contacts),
                "phoneStateChanged" to phoneState?.let { phoneStateChangedArgs(it) }
            )
        )
        send(msg)
    }

    override fun sendPhoneState(phoneState: PhoneState) {
        val args = phoneStateChangedArgs(phoneState)
        val msg = mapOf(
            "cmd" to "phoneStateChanged",
            "args" to args
        )
        send(msg)
    }

    private fun phonesArgs(contacts: List<ContactData>): Map<String, Any> {
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

        return mapOf(
            "phones" to pojo
        )
    }

    private fun phoneStateChangedArgs(phoneState: PhoneState): Map<String, Any> {
        return when (phoneState.stateExtra) {
            TelephonyManager.EXTRA_STATE_IDLE -> {
                mapOf(
                    "state" to "noCallInProgress"
                )
            }

            TelephonyManager.EXTRA_STATE_OFFHOOK -> {
                mapOf(
                    "state" to "callInProgress",
                    "number" to dispatchedPhoneNumber(phoneState.incomingNumber)
                )
            }

            TelephonyManager.EXTRA_STATE_RINGING -> {
                mapOf(
                    "state" to "ringing",
                    "number" to dispatchedPhoneNumber(phoneState.incomingNumber)
                )
            }

            else -> {
                Log.e(TAG, "unknownPhoneStateExtra: ${phoneState.stateExtra}")
                return mapOf(
                    "unknownState" to phoneState.stateExtra
                )
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