package com.gentin.connectiq.handsfree.broadcastreceivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.gentin.connectiq.handsfree.helpers.startConnector

class ConnectIQIncomingMessageBroadcastReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "intent: $intent")
        startConnector(context, intent)
    }

    companion object {
        val TAG: String = ConnectIQIncomingMessageBroadcastReceiver::class.java.simpleName
    }
}