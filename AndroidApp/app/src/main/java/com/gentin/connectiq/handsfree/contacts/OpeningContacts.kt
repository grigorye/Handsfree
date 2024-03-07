package com.gentin.connectiq.handsfree.contacts

import android.content.Context
import android.content.Intent


fun openFavorites(context: Context) {
    @Suppress("DEPRECATION")
    val intent = Intent(android.provider.Contacts.Intents.UI.LIST_STARRED_ACTION)
    context.startActivity(intent)
}