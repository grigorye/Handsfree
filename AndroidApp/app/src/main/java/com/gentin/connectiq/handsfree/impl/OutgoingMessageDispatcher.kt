package com.gentin.connectiq.handsfree.impl

import android.content.Context
import android.telephony.TelephonyManager
import android.util.Log
import com.gentin.connectiq.handsfree.contacts.ContactData
import com.gentin.connectiq.handsfree.helpers.normalizePhoneNumber


interface OutgoingMessageDispatcher {
    fun sendSyncYou(contacts: List<ContactData>, phoneState: PhoneState?)
    fun sendPhones(contacts: List<ContactData>)
    fun sendPhoneState(phoneState: PhoneState)
}

class DefaultOutgoingMessageDispatcher(
    val context: Context,
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

    override fun sendPhones(contacts: List<ContactData>) {
        val msg = mapOf(
            "cmd" to "setPhones",
            "args" to phonesArgs(contacts)
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

    private fun phoneStateChangedArgs(phoneState: PhoneState): Map<String, Any?> {
        val stateArgs = when (phoneState.stateExtra) {
            TelephonyManager.EXTRA_STATE_IDLE -> {
                mapOf(
                    "state" to "noCallInProgress"
                )
            }

            TelephonyManager.EXTRA_STATE_OFFHOOK -> {
                mapOf(
                    "state" to "callInProgress",
                    "number" to dispatchedPhoneNumber(context, phoneState.incomingNumber),
                    "name" to phoneState.incomingDisplayNames.firstOrNull()
                )
            }

            TelephonyManager.EXTRA_STATE_RINGING -> {
                mapOf(
                    "state" to "ringing",
                    "number" to dispatchedPhoneNumber(context, phoneState.incomingNumber),
                    "name" to phoneState.incomingDisplayNames.firstOrNull()
                )
            }

            else -> {
                Log.e(TAG, "unknownPhoneStateExtra: ${phoneState.stateExtra}")
                return mapOf(
                    "unknownState" to phoneState.stateExtra,
                )
            }
        }
        val headsetArgs = mapOf(
            "isHeadsetConnected" to phoneState.isHeadsetConnected
        )
        return stateArgs + headsetArgs
    }

    private fun send(msg: OutgoingMessage) {
        remoteMessageService.sendMessage(msg)
    }

    private fun send(msg: Map<String, Any>) {
        send(OutgoingMessage(OutgoingMessageDestination(), msg))
    }

    companion object {
        private val TAG: String = DefaultOutgoingMessageDispatcher::class.java.simpleName
    }
}

private fun dispatchedPhoneNumber(context: Context, incomingNumber: String?): String? {
    return incomingNumber?.let { normalizePhoneNumber(context, it) }
}