package com.gentin.connectiq.handsfree.contacts

import android.content.Context
import android.content.Intent
import android.provider.ContactsContract
import android.util.Log


fun openFavorites(context: Context) {
    val tag = object {}.javaClass.enclosingMethod?.name

    try {
        @Suppress("DEPRECATION")
        val intent = Intent(android.provider.Contacts.Intents.UI.LIST_STARRED_ACTION)
        context.startActivity(intent)
    } catch (e: RuntimeException) {
        Log.d(tag, "OldStyleOpenFavoritesFailed: $e")

        val intent = Intent(Intent.ACTION_VIEW).apply {
            data = ContactsContract.Contacts.CONTENT_URI
        }
        context.startActivity(intent)
    }
}