package com.gentin.connectiq.handsfree.impl

import android.content.Context
import android.content.ContextWrapper
import android.provider.ContactsContract
import android.provider.ContactsContract.CommonDataKinds
import android.provider.ContactsContract.CommonDataKinds.Phone
import kotlinx.serialization.Serializable


@Serializable
data class PhoneData(
    val id: Long,
    var raw: String,
    var normalized: String? = null,
    var formatted: String? = null,
    val label: String = "",
)

@Serializable
data class ContactData(
    val id: Int,
    var name: String,
    var number: String,
    var phoneDataList: List<PhoneData> = ArrayList<PhoneData>()
)

interface ContactsRepository {
    fun contactsJsonObject(): Any
}

class ContactsRepositoryImpl(base: Context?) : ContextWrapper(base), ContactsRepository {

    private fun contactsGroupId(): Int? {
        val cursor = contentResolver.query(
            ContactsContract.Groups.CONTENT_URI,
            arrayOf(
                ContactsContract.Groups.TITLE,
                ContactsContract.Groups._ID
            ),
            "${ContactsContract.Groups.TITLE} = ?",
            arrayOf("Garmin"),
            null
        )
        var groupId: Int? = null
        cursor?.apply {
            val idColumn = getColumnIndex(ContactsContract.Groups._ID)
            if (moveToFirst()) {
                groupId = getInt(idColumn)
            }
            close()
        }
        return groupId
    }

    private fun forEachContactInGroup(
        groupId: Int,
        operation: (contactId: Int, displayName: String) -> Unit
    ) {
        val groupCursor = contentResolver.query(
            ContactsContract.Data.CONTENT_URI,
            arrayOf(
                ContactsContract.Contacts.DISPLAY_NAME,
                CommonDataKinds.GroupMembership.CONTACT_ID
            ),
            "${CommonDataKinds.GroupMembership.GROUP_ROW_ID} = ? AND ${CommonDataKinds.GroupMembership.MIMETYPE} = '${CommonDataKinds.GroupMembership.CONTENT_ITEM_TYPE}'",
            arrayOf("$groupId"),
            null
        )

        groupCursor?.apply {
            val displayNameColumn = getColumnIndex(Phone.DISPLAY_NAME)
            val contactIdColumn = getColumnIndex(CommonDataKinds.GroupMembership.CONTACT_ID)
            while (moveToNext()) {
                val displayName = getString(displayNameColumn)
                val contactId = getInt(contactIdColumn)
                operation(contactId, displayName)
            }
            close()
        }
    }

    private fun forEachContactWithPhoneNumberInFavorites(operation: (contactId: Int, displayName: String) -> Unit) {
        val contactsCursor = contentResolver.query(
            ContactsContract.Data.CONTENT_URI,
            arrayOf(
                ContactsContract.Data.DISPLAY_NAME_PRIMARY,
                ContactsContract.Contacts.HAS_PHONE_NUMBER,
                ContactsContract.Data.CONTACT_ID
            ),
            "${ContactsContract.Contacts.STARRED} = 1",
            null,
            null
        )

        contactsCursor?.apply {
            val displayNameColumn = getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME)
            val hasPhoneNumberColumn = getColumnIndex(ContactsContract.Contacts.HAS_PHONE_NUMBER)
            val contactIdColumn = getColumnIndex(ContactsContract.Data.CONTACT_ID)

            while (moveToNext()) {
                val contactId = getInt(contactIdColumn)
                val displayName = getString(displayNameColumn)

                if (getInt(hasPhoneNumberColumn) == 1) {
                    operation(contactId, displayName)
                }
            }
            close()
        }
    }

    private fun numbersForContact(contactId: Int): ArrayList<String> {
        var numbers = ArrayList<String>()
        val phonesCursor = contentResolver.query(
            Phone.CONTENT_URI,
            arrayOf(
                Phone._ID,
                Phone.NUMBER,
                Phone.NORMALIZED_NUMBER
            ),
            "${Phone.CONTACT_ID} = ?",
            arrayOf("$contactId"),
            null
        )
        phonesCursor?.apply {
            val phoneIDColumn = getColumnIndex(Phone._ID)
            val phoneNumberColumn = getColumnIndex(Phone.NUMBER)
            val normalizedPhoneNumberColumn = getColumnIndex(Phone.NORMALIZED_NUMBER)
            val phoneDataList = ArrayList<PhoneData>()
            while (moveToNext()) {
                val phoneID = getLong(phoneIDColumn)
                val phoneNumber = getString(phoneNumberColumn)
                val phoneData = PhoneData(phoneID, phoneNumber)
                val normalizedPhoneNumber = getString(normalizedPhoneNumberColumn)
                normalizedPhoneNumber?.let {
                    phoneData.normalized = it
                    phoneData.formatted = formatPhoneNumber(it)
                }
                phoneDataList.add(phoneData)
            }
            close()

            var phoneData = phoneDataList[0]
            val number = phoneData.normalized ?: phoneData.raw
            numbers.add(number)
        }
        return numbers
    }

    fun contacts(): List<ContactData> {
        var contacts = ArrayList<ContactData>()
        val groupId = contactsGroupId()
        if (groupId != null) {
            forEachContactInGroup(groupId) { contactId, displayName ->
                val number = numbersForContact(contactId)[0]
                contacts.add(ContactData(contactId, displayName, number))
            }
        }
        return contacts.sortedBy { it.name }
    }

    override fun contactsJsonObject(): Any {
        var crashMe = ContactData(-1, "Crash Me", "1233")
        val list = listOf(crashMe) + contacts()

        val pojo = ArrayList<Any>()
        for (contact in list) {
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
}