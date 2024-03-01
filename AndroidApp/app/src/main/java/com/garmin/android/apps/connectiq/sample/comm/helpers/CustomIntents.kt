package com.garmin.android.apps.connectiq.sample.comm.helpers

import android.content.Context
import android.content.Intent
import android.util.Log
import com.garmin.android.apps.connectiq.sample.comm.services.GarminPhoneCallConnectorService

const val ACTIVATE_FROM_MAIN_ACTIVITY_ACTION = "ACTIVATE_FROM_MAIN_ACTIVITY"
const val ACTIVATE_FROM_KEEP_AWAKE = "ACTIVATE_FROM_KEEP_AWAKE"

fun startConnector(context: Context, customAction: String) {
    val tag = object {}.javaClass.enclosingMethod?.name

    val intentForConnector = Intent(context, GarminPhoneCallConnectorService::class.java).apply {
        action = customAction
    }
    Log.d(tag, "startConnectorCustomAction: $customAction")
    context.startForegroundService(intentForConnector)
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
