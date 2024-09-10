package com.gentin.connectiq.handsfree.impl

import android.content.Context
import android.telephony.TelephonyManager
import android.util.Log
import com.gentin.connectiq.handsfree.calllogs.CallLogEntry
import com.gentin.connectiq.handsfree.contacts.ContactData
import com.gentin.connectiq.handsfree.helpers.normalizePhoneNumber

data class QueryResult(
    var phones: List<ContactData>? = null,
    var phoneState: PhoneState? = null,
    var recents: List<CallLogEntry>? = null
)

interface OutgoingMessageDispatcher {
    fun sendSyncYou(contacts: List<ContactData>, phoneState: PhoneState?)
    fun sendQueryResult(destination: OutgoingMessageDestination, queryResult: QueryResult)
    fun sendPhones(destination: OutgoingMessageDestination, contacts: List<ContactData>)
    fun sendRecents(recents: List<CallLogEntry>)
    fun sendPhoneState(phoneState: PhoneState)
    fun sendOpenAppFailed(destination: OutgoingMessageDestination)
    fun sendOpenMeCompleted(
        destination: OutgoingMessageDestination,
        args: OpenMeArgs,
        succeeded: Boolean
    )
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

    override fun sendQueryResult(destination: OutgoingMessageDestination, queryResult: QueryResult) {
        var args = mutableMapOf<String, Any>()
        queryResult.recents?.apply {
            args["recents"] = recentsPojo(this)
        }
        queryResult.phones?.apply {
            args["phones"] = phonesPojo(this)
        }
        val msg = mapOf(
            "cmd" to "acceptQueryResult",
            "args" to args
        )
        send(OutgoingMessage(destination, msg))
    }

    override fun sendPhones(destination: OutgoingMessageDestination, contacts: List<ContactData>) {
        val msg = mapOf(
            "cmd" to "setPhones",
            "args" to phonesArgs(contacts)
        )
        send(OutgoingMessage(destination, msg))
    }

    override fun sendRecents(recents: List<CallLogEntry>) {
        val recentsPojo = recentsPojo(recents)
        val msg = mapOf(
            "cmd" to "recentsChanged",
            "args" to mapOf(
                "recents" to recentsPojo
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

    override fun sendOpenAppFailed(destination: OutgoingMessageDestination) {
        val msg = mapOf(
            "cmd" to "openAppFailed"
        )
        send(OutgoingMessage(destination, msg))
    }

    override fun sendOpenMeCompleted(
        destination: OutgoingMessageDestination,
        args: OpenMeArgs,
        succeeded: Boolean
    ) {
        val msg = mapOf(
            "cmd" to "openMeCompleted",
            "args" to mapOf(
                "messageForWakingUp" to args.messageForWakingUp,
                "succeeded" to succeeded
            )
        )
        send(OutgoingMessage(destination, msg))
    }

    private fun phonesPojo(contacts: List<ContactData>): Any {
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
        return pojo
    }

    private fun phonesArgs(contacts: List<ContactData>): Map<String, Any> {
        return mapOf(
            "phones" to phonesPojo(contacts)
        )
    }

    private fun recentsPojo(recents: List<CallLogEntry>): Any {
        val pojo = ArrayList<Any>()
        for (entry in recents) {
            pojo.add(
                mapOf(
                    "number" to entry.number,
                    "name" to entry.name,
                    "date" to entry.date,
                    "duration" to entry.duration,
                    "type" to entry.type,
                    "isNew" to entry.isNew
                )
            )
        }

        return pojo
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