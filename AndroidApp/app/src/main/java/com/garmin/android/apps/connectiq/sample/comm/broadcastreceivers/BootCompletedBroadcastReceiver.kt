package com.garmin.android.apps.connectiq.sample.comm.broadcastreceivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootCompletedBroadcastReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Intent: ${intent}")
    }

    companion object {
        private val TAG: String = PhoneStateBroadcastReceiver::class.java.simpleName
    }
}
