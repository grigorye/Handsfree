package com.gentin.connectiq.handsfree.globals

import com.gentin.connectiq.handsfree.contacts.ContactData
import kotlinx.serialization.EncodeDefault
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class AvailableContacts(
    @OptIn(ExperimentalSerializationApi::class) @EncodeDefault
    @SerialName("c") var contacts: List<ContactData> = listOf(),
    @SerialName("a") val accessIssue: AccessIssue? = null
)