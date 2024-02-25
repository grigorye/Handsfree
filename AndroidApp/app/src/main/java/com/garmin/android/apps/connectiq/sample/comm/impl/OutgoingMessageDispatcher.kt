package com.garmin.android.apps.connectiq.sample.comm.impl


interface ContactsService {
    fun contactsJsonObject()
}

interface OutgoingMessageDispatcher {
    fun sendPhones()
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

    fun send(msg: Map<String, Any>) {
        remoteMessageService.sendMessage(msg)
    }
}