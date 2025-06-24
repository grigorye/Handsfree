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
import kotlinx.serialization.SerialName
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
    @SerialName("i") val id: Int,
    @SerialName("m") var name: String,
    @SerialName("n") var number: String,
)

interface ContactsRepository {
    fun invalidatePermissions()
    fun subscribe(observer: ContentObserver)
    fun unsubscribe(observer: ContentObserver)
    fun contactsData(limit: Int): List<ContactData>
    fun displayNamesForPhoneNumber(phoneNumber: String): List<String>
}

class ContactsRepositoryImpl(
    base: Context?,
    val iterateOverContacts: ((contactId: Int, displayName: String) -> Boolean) -> Unit
) : ContextWrapper(base), ContactsRepository {

    companion object {
        private val TAG = ContactsRepositoryImpl::class.java.simpleName
    }

    private val delayedObservers = ArrayList<ContentObserver>()

    override fun invalidatePermissions() {
        val hasPermission = ActivityCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_CONTACTS
        ) == PackageManager.PERMISSION_GRANTED

        if (hasPermission) {
            for (observer in delayedObservers) {
                subscribeIgnoringPermissions(observer)
            }
            delayedObservers.clear()
        }
    }

    override fun subscribe(observer: ContentObserver) {
        val hasPermission = ActivityCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_CONTACTS
        ) == PackageManager.PERMISSION_GRANTED

        if (!hasPermission) {
            delayedObservers.add(observer)
            Log.e(TAG, "notPermittedToReadContacts")
            return
        }
        subscribeIgnoringPermissions(observer)
    }

    private fun subscribeIgnoringPermissions(observer: ContentObserver) {
        contentResolver.registerContentObserver(
            Phone.CONTENT_URI,
            true,
            observer
        )
        contentResolver.registerContentObserver(
            ContactsContract.PhoneLookup.CONTENT_FILTER_URI,
            true,
            observer
        )
    }

    override fun unsubscribe(observer: ContentObserver) {
        delayedObservers.remove(observer)
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

            if (phoneDataList.isNotEmpty()) {
                val phoneData = phoneDataList[0]
                val number = phoneData.normalized ?: phoneData.raw
                numbers.add(number)
            }
        }
        return numbers
    }

    override fun contactsData(limit: Int): List<ContactData> {
        val contacts = ArrayList<ContactData>()
        iterateOverContacts { contactId, displayName ->
            val numbers = numbersForContact(contactId)
            if (numbers.isNotEmpty()) {
                val number = numbersForContact(contactId)[0]
                contacts.add(ContactData(contactId, displayName, number))
                return@iterateOverContacts contacts.size < limit
            }
            true
        }
        return contacts
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
