package com.garmin.android.apps.connectiq.sample.comm.helpers

import android.content.Context
import android.content.Intent
import android.util.Log
import com.garmin.android.apps.connectiq.sample.comm.services.GarminPhoneCallConnectorService

val ACTIVATE_FROM_MAIN_ACTIVITY_ACTION = "ACTIVATE_FROM_MAIN_ACTIVITY"

fun startConnector(context: Context, action: String) {
    val tag = object {}.javaClass.enclosingMethod?.name

    val intentForConnector = Intent(context, GarminPhoneCallConnectorService::class.java).apply {
        this.action = action
    }
    Log.d(tag, "startConnectorAction: $action")
    context.startForegroundService(intentForConnector)
}
