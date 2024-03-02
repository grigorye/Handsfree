package com.garmin.android.apps.connectiq.sample.comm.broadcastreceivers

import android.annotation.SuppressLint
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.garmin.android.apps.connectiq.sample.comm.helpers.startConnector

class BootCompletedBroadcastReceiver : BroadcastReceiver() {

    @SuppressLint("UnsafeProtectedBroadcastReceiver")
    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "intent: $intent")
        if (!keepAwakeEnabled) {
            // Attempts to launch it on boot fail because the service running inside GarminConnect
            // dies. On the other hand, it's not necessary to launch it on boot *unless* we rely
            // on e.g. alarms to relaunch the app (and we don't: relying on INCOMING_MESSAGE as
            // a trigger instead).
        } else {
            startConnector(context, intent)
        }
    }

    companion object {
        private val TAG: String = BootCompletedBroadcastReceiver::class.java.simpleName
    }
}
