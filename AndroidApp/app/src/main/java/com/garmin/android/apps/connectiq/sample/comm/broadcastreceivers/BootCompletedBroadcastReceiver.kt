package com.garmin.android.apps.connectiq.sample.comm.broadcastreceivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.content.ContextCompat.startForegroundService
import com.garmin.android.apps.connectiq.sample.comm.services.GarminPhoneCallConnectorService

class BootCompletedBroadcastReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Intent: $intent")
        startForegroundService(context, Intent(context, GarminPhoneCallConnectorService::class.java))
    }

    companion object {
        private val TAG: String = BootCompletedBroadcastReceiver::class.java.simpleName
    }
}
