package com.garmin.android.apps.connectiq.sample.comm.broadcastreceivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.garmin.android.apps.connectiq.sample.comm.helpers.goAsync
import com.garmin.android.apps.connectiq.sample.comm.services.GarminPhoneCallConnectorService

class PhoneStateBroadcastReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) = goAsync {
        Log.d(TAG, "intent: $intent")
        val intentForConnector =
            Intent(context, GarminPhoneCallConnectorService::class.java).apply {
                action = intent.action
                putExtras(intent)
            }
        context.startForegroundService(intentForConnector);
    }

    companion object {
        private val TAG: String = PhoneStateBroadcastReceiver::class.java.simpleName
    }
}

