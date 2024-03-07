package com.gentin.connectiq.handsfree.contacts

import android.content.Context
import android.content.Intent
import android.provider.Contacts


fun openFavorites(context: Context) {
    @Suppress("DEPRECATION")
    val intent = Intent(Contacts.Intents.UI.LIST_STARRED_ACTION)
    context.startActivity(intent)
}