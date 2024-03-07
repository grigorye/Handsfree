package com.gentin.connectiq.handsfree.contacts

import android.content.Context
import android.provider.ContactsContract

fun forEachContactInGroup(
    context: Context,
    groupId: Int,
    operation: (contactId: Int, displayName: String) -> Unit
) {
    val groupCursor = context.contentResolver.query(
        ContactsContract.Data.CONTENT_URI,
        arrayOf(
            ContactsContract.Contacts.DISPLAY_NAME,
            ContactsContract.CommonDataKinds.GroupMembership.CONTACT_ID
        ),
        "${ContactsContract.CommonDataKinds.GroupMembership.GROUP_ROW_ID} = ? AND ${ContactsContract.CommonDataKinds.GroupMembership.MIMETYPE} = '${ContactsContract.CommonDataKinds.GroupMembership.CONTENT_ITEM_TYPE}'",
        arrayOf("$groupId"),
        null
    )

    groupCursor?.apply {
        val displayNameColumn = getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)
        val contactIdColumn = getColumnIndex(ContactsContract.CommonDataKinds.GroupMembership.CONTACT_ID)
        while (moveToNext()) {
            val displayName = getString(displayNameColumn)
            val contactId = getInt(contactIdColumn)
            operation(contactId, displayName)
        }
        close()
    }
}

fun forEachContactWithPhoneNumberInFavorites(context: Context, operation: (contactId: Int, displayName: String) -> Unit) {
    val contactsCursor = context.contentResolver.query(
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