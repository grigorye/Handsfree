package com.gentin.connectiq.handsfree.contacts

import android.content.Context
import android.content.ContextWrapper
import android.provider.ContactsContract.CommonDataKinds.Phone
import com.gentin.connectiq.handsfree.helpers.formatPhoneNumber
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
    fun contacts(): List<ContactData>
}

class ContactsRepositoryImpl(
    base: Context?,
    val iterateOverContacts: ((contactId: Int, displayName: String) -> Unit) -> Unit
) : ContextWrapper(base), ContactsRepository {

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

    override fun contacts(): List<ContactData> {
        var contacts = ArrayList<ContactData>()
        iterateOverContacts { contactId, displayName ->
            val number = numbersForContact(contactId)[0]
            contacts.add(ContactData(contactId, displayName, number))
        }
        return contacts.sortedBy { it.name }
    }
}
