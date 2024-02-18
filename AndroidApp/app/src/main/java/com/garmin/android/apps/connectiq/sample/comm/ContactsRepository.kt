package com.garmin.android.apps.connectiq.sample.comm

import android.content.Context
import android.content.ContextWrapper
import android.provider.ContactsContract
import android.provider.ContactsContract.CommonDataKinds.Phone
import android.telephony.PhoneNumberUtils
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import java.util.Locale

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
    val id: String,
    var name: String,
    var number: String,
    var phoneDataList: List<PhoneData> = ArrayList<PhoneData>()
)

typealias ContactDataList = ArrayList<ContactData>

class ContactsRepository(base: Context?) : ContextWrapper(base) {

    fun contactDataList(): ContactDataList {
        val contactDataList = ArrayList<ContactData>()
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
                val contactId = getLong(contactIdColumn).toString()
                val displayName = getString(displayNameColumn)

                if (getLong(hasPhoneNumberColumn) == 1L) {
                    val phonesCursor = contentResolver.query(
                        Phone.CONTENT_URI,
                        arrayOf(
                            Phone._ID,
                            Phone.NUMBER,
                            Phone.NORMALIZED_NUMBER
                        ),
                        Phone.CONTACT_ID + " = " + contactId,
                        null,
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
                                val formattedPhoneNumber = PhoneNumberUtils.formatNumber(
                                    normalizedPhoneNumber,
                                    Locale.getDefault().country
                                )
                                phoneData.formatted = formattedPhoneNumber
                            }
                            phoneDataList.add(phoneData)
                        }
                        close()

                        val number = phoneDataList[0].raw
                        val contactData = ContactData(contactId, displayName, number)
                        contactDataList.add(contactData)
                    }
                }
            }
            close()
        }
        return contactDataList
    }

    fun contactsJsonObject(): Any {
        val list = contactDataList()
        val pojo = ArrayList<Any>()
        for (contact in list) {
            pojo.add(mapOf(
                "number" to contact.number,
                "name" to contact.name,
                "id" to contact.id
            ))
        }
        return pojo
    }
}