package com.gentin.connectiq.handsfree.impl

import android.content.Context
import com.gentin.connectiq.handsfree.calllogs.CallLogEntry
import com.gentin.connectiq.handsfree.contacts.ContactData
import com.gentin.connectiq.handsfree.helpers.pojoList
import com.gentin.connectiq.handsfree.helpers.pojoMap
import com.gentin.connectiq.handsfree.terms.*
import java.security.MessageDigest

typealias Version = Int

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

@OptIn(ExperimentalStdlibApi::class)
fun strippedVersionedPojo(
    hitVersion: Version?,
    pojo: Any?,
    metadataOnly: Boolean = false
): VersionedPojo {
    val version = "$pojo".md5().takeLast(4).hexToInt()
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
    fun sendPhoneState(destination: OutgoingMessageDestination, phoneState: PhoneState)
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
            cmdMsgField to syncYouCmd,
            argsMsgField to mapOf(
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
            subjects[phonesSubject] = mapOf(
                subjectVersion to version,
                subjectValue to pojo
            )
        }
        queryResult.recents?.apply {
            subjects[recentsSubject] = mapOf(
                subjectVersion to version,
                subjectValue to pojo
            )
        }
        queryResult.audioState?.apply {
            subjects[audioStateSubject] = mapOf(
                subjectVersion to version,
                subjectValue to pojo
            )
        }
        val msg = mapOf(
            cmdMsgField to acceptQueryResultCmd,
            argsMsgField to mapOf(
                subjectsArg to subjects
            )
        )
        send(OutgoingMessage(destination, msg))
    }

    override fun sendPhones(destination: OutgoingMessageDestination, contacts: List<ContactData>) {
        val msg = mapOf(
            cmdMsgField to setPhonesCmd,
            argsMsgField to phonesArgs(contacts)
        )
        send(OutgoingMessage(destination, msg))
    }

    override fun sendContacts(contacts: List<ContactData>) {
        sendSubject(phonesSubject, strippedVersionedPojo(null, phonesPojo(contacts)))
    }

    override fun sendRecents(recents: List<CallLogEntry>) {
        sendSubject(recentsSubject, strippedVersionedPojo(null, recentsPojo(recents)))
    }

    override fun sendAudioState(state: AudioState) {
        sendSubject(audioStateSubject, strippedVersionedPojo(null, audioStatePojo(state)))
    }

    override fun sendPhoneState(destination: OutgoingMessageDestination, phoneState: PhoneState) {
        val args = phoneStateChangedArgs(phoneState)
        val msg = mapOf(
            cmdMsgField to phoneStateChangedCmd,
            argsMsgField to args
        )
        send(OutgoingMessage(destination, msg))
    }

    override fun sendOpenAppFailed(destination: OutgoingMessageDestination) {
        val msg = mapOf(
            cmdMsgField to openAppFailedCmd
        )
        send(OutgoingMessage(destination, msg))
    }

    override fun sendOpenMeCompleted(
        destination: OutgoingMessageDestination,
        args: OpenMeArgs,
        succeeded: Boolean
    ) {
        val msg = mapOf(
            cmdMsgField to openMeCompletedCmd,
            argsMsgField to mapOf(
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
        val args = when (state.stateId) {
            PhoneStateId.Idle -> {
                mapOf(
                    "state" to "noCallInProgress"
                )
            }

            PhoneStateId.OffHook -> {
                mapOf(
                    "state" to "callInProgress",
                    "number" to state.number,
                    "name" to state.name
                )
            }

            PhoneStateId.Ringing -> {
                mapOf(
                    "state" to "ringing",
                    "number" to state.number,
                    "name" to state.name
                )
            }

            PhoneStateId.Unknown -> {
                return mapOf(
                    "unknownState" to null
                )
            }
        }
        return args
    }

    private fun sendSubject(subject: String, versionedPojo: VersionedPojo) {
        val msg = mapOf(
            cmdMsgField to subjectsChangedCmd,
            argsMsgField to mapOf(
                subjectsArg to mapOf(
                    subject to mapOf(
                        subjectVersion to versionedPojo.version,
                        subjectValue to versionedPojo.pojo
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

fun audioStatePojo(state: AudioState): Any {
    return pojoMap(state)
}

fun phonesPojo(contacts: List<ContactData>): Any {
    return pojoList(contacts)
}

fun recentsPojo(recents: List<CallLogEntry>): Any {
    return pojoList(recents)
}
