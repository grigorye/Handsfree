package com.gentin.connectiq.handsfree.impl

import android.content.Context
import com.gentin.connectiq.handsfree.calllogs.CallLogEntry
import com.gentin.connectiq.handsfree.contacts.ContactData
import com.gentin.connectiq.handsfree.helpers.pojoList
import com.gentin.connectiq.handsfree.helpers.pojoMap
import com.gentin.connectiq.handsfree.terms.acceptQueryResultCmd
import com.gentin.connectiq.handsfree.terms.argsMsgField
import com.gentin.connectiq.handsfree.terms.argsV1MsgField
import com.gentin.connectiq.handsfree.terms.audioStateSubject
import com.gentin.connectiq.handsfree.terms.broadcastSubject
import com.gentin.connectiq.handsfree.terms.cmdMsgField
import com.gentin.connectiq.handsfree.terms.cmdV1MsgField
import com.gentin.connectiq.handsfree.terms.companionInfoSubject
import com.gentin.connectiq.handsfree.terms.messageForWakingUpArg
import com.gentin.connectiq.handsfree.terms.openAppFailedCmd
import com.gentin.connectiq.handsfree.terms.openMeCompletedCmd
import com.gentin.connectiq.handsfree.terms.phoneStateChangedCmd
import com.gentin.connectiq.handsfree.terms.phoneStateChangedV1Cmd
import com.gentin.connectiq.handsfree.terms.phonesSubject
import com.gentin.connectiq.handsfree.terms.recentsSubject
import com.gentin.connectiq.handsfree.terms.setPhonesV1Cmd
import com.gentin.connectiq.handsfree.terms.subjectValue
import com.gentin.connectiq.handsfree.terms.subjectVersion
import com.gentin.connectiq.handsfree.terms.subjectsArg
import com.gentin.connectiq.handsfree.terms.subjectsChangedCmd
import com.gentin.connectiq.handsfree.terms.succeededArg
import com.gentin.connectiq.handsfree.terms.syncYouCmd
import java.security.MessageDigest

typealias Version = Int

data class QueryResult(
    var broadcastEnabled: Boolean? = null,
    var phoneState: PhoneState? = null,
    var audioState: VersionedPojo? = null,
    var phones: VersionedPojo? = null,
    var recents: VersionedPojo? = null,
    var companionInfo: VersionedPojo? = null,
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
    fun sendSyncYouV1(contacts: List<ContactData>, phoneState: PhoneState?)
    fun sendQueryResult(destination: OutgoingMessageDestination, queryResult: QueryResult)
    fun sendPhonesV1(destination: OutgoingMessageDestination, contacts: List<ContactData>)
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
    private val remoteMessageService: RemoteMessageService,
    private val trackAppListeningForBroadcast: (OutgoingMessageDestination, enabled: Boolean) -> Unit,
) : OutgoingMessageDispatcher {
    override fun sendPing() {
        send(pingBody, everywhereExactly)
    }

    override fun sendSyncYouV1(contacts: List<ContactData>, phoneState: PhoneState?) {
        val msg = mapOf(
            cmdV1MsgField to syncYouCmd,
            argsV1MsgField to mapOf(
                setPhonesV1Cmd to phonesArgsV1(contacts),
                phoneStateChangedV1Cmd to phoneState?.let { phoneStateChangedArgsV1(it) }
            )
        )
        send(msg, everywhereExactly)
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
        queryResult.companionInfo?.apply {
            subjects[companionInfoSubject] = mapOf(
                subjectVersion to version,
                subjectValue to pojo
            )
        }
        queryResult.broadcastEnabled?.apply {
            subjects[broadcastSubject] = mapOf(
                subjectVersion to if (this) {
                    1
                } else {
                    0
                },
                subjectValue to {}
            )
            trackAppListeningForBroadcast(destination, this)
        }
        val msg = mapOf(
            cmdMsgField to acceptQueryResultCmd,
            argsMsgField to mapOf(
                subjectsArg to subjects
            )
        )
        send(OutgoingMessage(destination, msg))
    }

    override fun sendPhonesV1(
        destination: OutgoingMessageDestination,
        contacts: List<ContactData>
    ) {
        val msg = mapOf(
            cmdV1MsgField to setPhonesV1Cmd,
            argsV1MsgField to phonesArgsV1(contacts)
        )
        send(OutgoingMessage(destination, msg))
    }

    override fun sendContacts(contacts: List<ContactData>) {
        sendSubject(
            phonesSubject,
            strippedVersionedPojo(null, phonesPojo(contacts)),
            destination = everywhere
        )
    }

    override fun sendRecents(recents: List<CallLogEntry>) {
        sendSubject(
            recentsSubject,
            strippedVersionedPojo(null, recentsPojo(recents)),
            everywhere.copy(matchV1 = false)
        )
    }

    override fun sendAudioState(state: AudioState) {
        sendSubject(
            audioStateSubject,
            strippedVersionedPojo(null, audioStatePojo(state)),
            everywhereExactly.copy(matchV1 = false)
        )
    }

    override fun sendPhoneState(destination: OutgoingMessageDestination, phoneState: PhoneState) {
        val destinationV1 = destination.copy(matchV1 = true)
        val argsV1 = phoneStateChangedArgsV1(phoneState)
        val msgV1 = mapOf(
            cmdV1MsgField to phoneStateChangedV1Cmd,
            argsV1MsgField to argsV1
        )
        send(OutgoingMessage(destinationV1, msgV1))

        val destinationV2 = destination.copy(matchV1 = false)
        val argsV2 = pojoMap(phoneState)
        val msgV2 = mapOf(
            cmdMsgField to phoneStateChangedCmd,
            argsMsgField to argsV2
        )
        send(OutgoingMessage(destinationV2, msgV2))
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
                messageForWakingUpArg to args.messageForWakingUp,
                succeededArg to succeeded
            )
        )
        send(OutgoingMessage(destination, msg))
    }

    private fun phonesArgsV1(contacts: List<ContactData>): Map<String, Any> {
        return mapOf(
            "phones" to phonesPojoV1(contacts)
        )
    }

    private fun phoneStateChangedArgsV1(state: PhoneState): Map<String, Any?> {
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

    private fun sendSubject(
        subject: String,
        versionedPojo: VersionedPojo,
        destination: OutgoingMessageDestination
    ) {
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
        send(OutgoingMessage(destination, msg))
    }

    private fun send(msg: OutgoingMessage) {
        remoteMessageService.sendMessage(msg)
    }

    private fun send(msg: Map<String, Any>, destination: OutgoingMessageDestination) {
        send(OutgoingMessage(destination, msg))
    }
}

fun audioStatePojo(state: AudioState): Any {
    return pojoMap(state)
}

fun phonesPojo(contacts: List<ContactData>): Any {
    return pojoList(contacts)
}

fun phonesPojoV1(contacts: List<ContactData>): Any {
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

fun recentsPojo(recents: List<CallLogEntry>): Any {
    return pojoList(recents)
}

fun companionInfoPojo(info: CompanionInfo): Any {
    return pojoMap(info)
}