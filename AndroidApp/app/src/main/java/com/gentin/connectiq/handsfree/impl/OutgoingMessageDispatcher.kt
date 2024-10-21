package com.gentin.connectiq.handsfree.impl

import android.content.Context
import android.telephony.TelephonyManager
import android.util.Log
import com.gentin.connectiq.handsfree.calllogs.CallLogEntry
import com.gentin.connectiq.handsfree.contacts.ContactData
import com.gentin.connectiq.handsfree.helpers.normalizePhoneNumber
import com.gentin.connectiq.handsfree.helpers.pojoList
import com.gentin.connectiq.handsfree.helpers.pojoMap
import java.security.MessageDigest

typealias Version = String

data class QueryResult(
    var phoneState: PhoneState? = null,
    var audioState: VersionedPojo? = null,
    var phones: VersionedPojo? = null,
    var recents: VersionedPojo? = null
)

data class VersionedPojo(
    val version: Version,
    val pojo: Any?
)

fun strippedVersionedPojo(
    hitVersion: Version?,
    pojo: Any?,
    metadataOnly: Boolean = false
): VersionedPojo {
    val version = "$pojo".md5()
    return VersionedPojo(
        version = version,
        pojo = if (version == hitVersion || metadataOnly) {
            null
        } else {
            pojo
        }
    )
}

@OptIn(ExperimentalStdlibApi::class)
fun String.md5(): String {
    val md = MessageDigest.getInstance("MD5")
    val digest = md.digest(this.toByteArray())
    return digest.toHexString()
}

interface OutgoingMessageDispatcher {
    fun sendPing()
    fun sendSyncYou(contacts: List<ContactData>, phoneState: PhoneState?)
    fun sendQueryResult(destination: OutgoingMessageDestination, queryResult: QueryResult)
    fun sendPhones(destination: OutgoingMessageDestination, contacts: List<ContactData>)
    fun sendContacts(contacts: List<ContactData>)
    fun sendRecents(recents: List<CallLogEntry>)
    fun sendPhoneState(phoneState: PhoneState)
    fun sendAudioState(state: AudioState)
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
    override fun sendPing() {
        send(pingBody)
    }

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

    override fun sendQueryResult(
        destination: OutgoingMessageDestination,
        queryResult: QueryResult
    ) {
        val subjects = mutableMapOf<String, Any>()
        queryResult.phones?.apply {
            subjects["phones"] = mapOf(
                "version" to version,
                "value" to pojo
            )
        }
        queryResult.recents?.apply {
            subjects["recents"] = mapOf(
                "version" to version,
                "value" to pojo
            )
        }
        queryResult.audioState?.apply {
            subjects["audioState"] = mapOf(
                "version" to version,
                "value" to pojo
            )
        }
        val msg = mapOf(
            "cmd" to "acceptQueryResult",
            "args" to mapOf(
                "subjects" to subjects
            )
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

    override fun sendContacts(contacts: List<ContactData>) {
        sendSubject("phones", strippedVersionedPojo(null, phonesPojo(contacts)))
    }

    override fun sendRecents(recents: List<CallLogEntry>) {
        sendSubject("recents", strippedVersionedPojo(null, recentsPojo(recents)))
    }

    override fun sendAudioState(state: AudioState) {
        sendSubject("audioState", strippedVersionedPojo(null, audioStatePojo(state)))
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

    private fun phonesArgs(contacts: List<ContactData>): Map<String, Any> {
        return mapOf(
            "phones" to phonesPojo(contacts)
        )
    }

    private fun phoneStateChangedArgs(state: PhoneState): Map<String, Any?> {
        val args = when (state.stateExtra) {
            TelephonyManager.EXTRA_STATE_IDLE -> {
                mapOf(
                    "state" to "noCallInProgress"
                )
            }

            TelephonyManager.EXTRA_STATE_OFFHOOK -> {
                mapOf(
                    "state" to "callInProgress",
                    "number" to dispatchedPhoneNumber(context, state.incomingNumber),
                    "name" to state.incomingDisplayNames.firstOrNull()
                )
            }

            TelephonyManager.EXTRA_STATE_RINGING -> {
                mapOf(
                    "state" to "ringing",
                    "number" to dispatchedPhoneNumber(context, state.incomingNumber),
                    "name" to state.incomingDisplayNames.firstOrNull()
                )
            }

            else -> {
                Log.e(TAG, "unknownPhoneStateExtra: ${state.stateExtra}")
                return mapOf(
                    "unknownState" to state.stateExtra,
                )
            }
        }
        return args
    }

    private fun sendSubject(subject: String, versionedPojo: VersionedPojo) {
        val msg = mapOf(
            "cmd" to "subjectsChanged",
            "args" to mapOf(
                "subjects" to mapOf(
                    subject to mapOf(
                        "version" to versionedPojo.version,
                        "value" to versionedPojo.pojo
                    )
                )
            )
        )
        send(msg)
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

fun audioStatePojo(state: AudioState): Any {
    return pojoMap(state)
}

fun phonesPojo(contacts: List<ContactData>): Any {
    return pojoList(contacts)
}

fun recentsPojo(recents: List<CallLogEntry>): Any {
    return pojoList(recents)
}
