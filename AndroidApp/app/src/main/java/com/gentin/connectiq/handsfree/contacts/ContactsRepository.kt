package com.gentin.connectiq.handsfree.contacts

import android.Manifest
import android.content.Context
import android.content.ContextWrapper
import android.content.pm.PackageManager
import android.database.ContentObserver
import android.net.Uri
import android.provider.BaseColumns
import android.provider.ContactsContract
import android.provider.ContactsContract.CommonDataKinds.Phone
import android.util.Log
import androidx.core.app.ActivityCompat
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
    var phoneDataList: List<PhoneData> = ArrayList()
)

interface ContactsRepository {
    fun subscribe(observer: ContentObserver)
    fun unsubscribe(observer: ContentObserver)
    fun contacts(): List<ContactData>
    fun displayNamesForPhoneNumber(phoneNumber: String): List<String>
}

class ContactsRepositoryImpl(
    base: Context?,
    val iterateOverContacts: ((contactId: Int, displayName: String) -> Unit) -> Unit
) : ContextWrapper(base), ContactsRepository {

    companion object {
        private val TAG = ContactsRepositoryImpl::class.java.simpleName
    }

    override fun subscribe(observer: ContentObserver) {
        val hasPermission = ActivityCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_CONTACTS
        ) == PackageManager.PERMISSION_GRANTED

        if (!hasPermission) {
            Log.e(TAG, "notPermittedToReadContacts")
            return
        }
        contentResolver.registerContentObserver(Phone.CONTENT_URI, true, observer)
        contentResolver.registerContentObserver(
            ContactsContract.PhoneLookup.CONTENT_FILTER_URI,
            true,
            observer
        )
    }

    override fun unsubscribe(observer: ContentObserver) {
        contentResolver.unregisterContentObserver(observer)
    }

    private fun numbersForContact(contactId: Int): ArrayList<String> {
        val numbers = ArrayList<String>()
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

            val phoneData = phoneDataList[0]
            val number = phoneData.normalized ?: phoneData.raw
            numbers.add(number)
        }
        return numbers
    }

    override fun contacts(): List<ContactData> {
        val contacts = ArrayList<ContactData>()
        iterateOverContacts { contactId, displayName ->
            val number = numbersForContact(contactId)[0]
            contacts.add(ContactData(contactId, displayName, number))
        }
        return contacts.sortedBy { it.name }
    }

    override fun displayNamesForPhoneNumber(phoneNumber: String): List<String> {
        val displayNames = ArrayList<String>()
        // https://stackoverflow.com/a/7967182/1859783
        val uri = Uri.withAppendedPath(
            ContactsContract.PhoneLookup.CONTENT_FILTER_URI,
            Uri.encode(phoneNumber)
        )
        val contactLookup = contentResolver.query(
            uri, arrayOf(
                BaseColumns._ID,
                ContactsContract.PhoneLookup.DISPLAY_NAME
            ), null, null, null
        )
        contactLookup?.apply {
            val displayNameColumn = getColumnIndex(ContactsContract.Data.DISPLAY_NAME)
            while (moveToNext()) {
                val displayName = getString(displayNameColumn)
                displayNames.add(displayName)
            }
            close()
        }
        return displayNames
    }
}
