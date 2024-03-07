package com.gentin.connectiq.handsfree.broadcastreceivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.gentin.connectiq.handsfree.helpers.goAsync
import com.gentin.connectiq.handsfree.impl.startConnector

class PhoneStateBroadcastReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) = goAsync {
        Log.d(TAG, "intent: $intent")
        startConnector(context, intent)
    }

    companion object {
        private val TAG: String = PhoneStateBroadcastReceiver::class.java.simpleName
    }
}

