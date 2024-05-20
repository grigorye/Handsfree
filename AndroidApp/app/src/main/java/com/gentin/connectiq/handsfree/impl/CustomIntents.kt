package com.gentin.connectiq.handsfree.impl

import android.content.Context
import android.content.Intent
import android.util.Log
import com.gentin.connectiq.handsfree.services.GarminPhoneCallConnectorService

const val ACTIVATE_FROM_MAIN_ACTIVITY_ACTION = "ACTIVATE_FROM_MAIN_ACTIVITY"
const val ACTIVATE_AND_RECONNECT = "ACTIVATE_AND_RECONNECT"
const val ACTIVATE_AND_OPEN_WATCH_APP_IN_STORE = "ACTIVATE_AND_OPEN_WATCH_APP_IN_STORE"

fun startConnector(context: Context, customAction: String) {
    val tag = object {}.javaClass.enclosingMethod?.name

    val intentForConnector = Intent(context, GarminPhoneCallConnectorService::class.java).apply {
        action = customAction
    }
    Log.d(tag, "startConnectorCustomAction: $customAction")
    val componentName = context.startForegroundService(intentForConnector)
    Log.d(tag, "startedConnector: $componentName")
}

fun startConnector(context: Context, sourceIntent: Intent) {
    val tag = object {}.javaClass.enclosingMethod?.name

    val intentForConnector = Intent(context, GarminPhoneCallConnectorService::class.java).apply {
        action = sourceIntent.action
        putExtras(sourceIntent)
    }
    Log.d(tag, "startConnectorSourceIntent: $sourceIntent")
    context.startForegroundService(intentForConnector)
}
