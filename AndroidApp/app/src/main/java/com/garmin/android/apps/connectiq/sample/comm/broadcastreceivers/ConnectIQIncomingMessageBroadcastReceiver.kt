package com.garmin.android.apps.connectiq.sample.comm.broadcastreceivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.garmin.android.apps.connectiq.sample.comm.services.GarminPhoneCallConnectorService

class ConnectIQIncomingMessageBroadcastReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "intent: $intent")
        val intentForConnector =
            Intent(context, GarminPhoneCallConnectorService::class.java).apply {
                action = intent.action
                putExtras(intent)
            }
        context.startForegroundService(intentForConnector)
    }

    companion object {
        val TAG: String = ConnectIQIncomingMessageBroadcastReceiver::class.java.simpleName
    }
}