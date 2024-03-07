package com.gentin.connectiq.handsfree.contacts

import android.content.Context
import android.provider.ContactsContract

fun contactsGroupId(context: Context, groupName: String): Int? {
    val cursor = context.contentResolver.query(
        ContactsContract.Groups.CONTENT_URI,
        arrayOf(
            ContactsContract.Groups.TITLE,
            ContactsContract.Groups._ID
        ),
        "${ContactsContract.Groups.TITLE} = ?",
        arrayOf(groupName),
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
